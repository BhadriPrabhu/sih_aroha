#include "stock_service.h"
#include <drogon/drogon.h>
#include <random>
#include <sstream>
#include <set>
#include <vector>

namespace
{
constexpr std::size_t kMinimumForecastObservations = 3;

std::string analyticsServiceUrl()
{
    const auto &config = drogon::app().getCustomConfig();
    return config.get("analytics_service_url", "http://127.0.0.1:8000").asString();
}
}

std::string StockService::generateUuid()
{
    static std::random_device rd;
    static std::mt19937 gen(rd());
    static std::uniform_int_distribution<> dis(0, 15);
    std::stringstream ss;
    ss << "stk-";
    for (int i = 0; i < 8; ++i)
    {
        ss << std::hex << dis(gen);
    }
    return ss.str();
}

static void ensureStockTablesExist()
{
    try
    {
        auto dbClient = drogon::app().getDbClient();
        dbClient->execSqlSync(
            "CREATE TABLE IF NOT EXISTS stocks_master ("
            "id TEXT PRIMARY KEY, "
            "station_id TEXT NOT NULL DEFAULT 'stn-maitri', "
            "category TEXT NOT NULL, "
            "name TEXT NOT NULL, "
            "stock_available REAL NOT NULL DEFAULT 0, "
            "stock_consumed REAL NOT NULL DEFAULT 0, "
            "present_stock REAL NOT NULL DEFAULT 0, "
            "criticality_rate REAL NOT NULL DEFAULT 0.5, "
            "criticality_status TEXT DEFAULT 'MEDIUM', "
            "essentiality_score REAL DEFAULT 0.5, "
            "lead_time_days REAL DEFAULT 7.0, "
            "forecast_daily_total REAL, "
            "forecast_mae REAL, "
            "analytics_updated_at DATETIME, "
            "is_synced INTEGER DEFAULT 0, "
            "created_at DATETIME DEFAULT CURRENT_TIMESTAMP, "
            "updated_at DATETIME DEFAULT CURRENT_TIMESTAMP);"
        );
        dbClient->execSqlSync(
            "CREATE TABLE IF NOT EXISTS stock_logs ("
            "id TEXT PRIMARY KEY, "
            "stock_id TEXT NOT NULL REFERENCES stocks_master(id) ON DELETE CASCADE, "
            "action TEXT NOT NULL, "
            "quantity REAL NOT NULL, "
            "notes TEXT, "
            "is_synced INTEGER DEFAULT 0, "
            "logged_at DATETIME DEFAULT CURRENT_TIMESTAMP);"
        );
        dbClient->execSqlSync(
            "CREATE TABLE IF NOT EXISTS stock_demand_history ("
            "id TEXT PRIMARY KEY, "
            "stock_id TEXT NOT NULL REFERENCES stocks_master(id) ON DELETE CASCADE, "
            "quantity REAL NOT NULL CHECK(quantity >= 0), "
            "observed_at DATETIME DEFAULT CURRENT_TIMESTAMP);"
        );
    }
    catch (const std::exception &e)
    {
        LOG_ERROR << "Error ensuring stock tables exist: " << e.what();
    }
}

Json::Value StockService::createStock(const CreateStockDto &dto)
{
    ensureStockTablesExist();
    Json::Value response;
    try
    {
        auto dbClient = drogon::app().getDbClient();
        std::string stockId = generateUuid();
        double initialAvailable = dto.stock_available;
        double initialConsumed = 0.0;
        double presentStock = initialAvailable - initialConsumed;

        std::string initialStatus = "MEDIUM";
        if (dto.criticality_rate >= 0.80) initialStatus = "CRITICAL";
        else if (dto.criticality_rate >= 0.60) initialStatus = "HIGH";
        else if (dto.criticality_rate >= 0.35) initialStatus = "MEDIUM";
        else initialStatus = "LOW";

        dbClient->execSqlSync(
            "INSERT INTO stocks_master (id, station_id, category, name, stock_available, stock_consumed, present_stock, criticality_rate, criticality_status, essentiality_score, lead_time_days) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);",
            stockId, dto.station_id, dto.category, dto.name, initialAvailable, initialConsumed, presentStock,
            dto.criticality_rate, initialStatus, dto.essentiality_score, dto.lead_time_days
        );

        response["success"] = true;
        response["message"] = "Stock record created successfully";
        response["stock"]["id"] = stockId;
        response["stock"]["station_id"] = dto.station_id;
        response["stock"]["category"] = dto.category;
        response["stock"]["name"] = dto.name;
        response["stock"]["stock_available"] = initialAvailable;
        response["stock"]["stock_consumed"] = initialConsumed;
        response["stock"]["present_stock"] = presentStock;
        response["stock"]["criticality_rate"] = dto.criticality_rate;
        response["stock"]["criticality_score"] = dto.criticality_rate;
        response["stock"]["criticality_status"] = "MEDIUM";
        response["stock"]["essentiality_score"] = dto.essentiality_score;
        response["stock"]["lead_time_days"] = dto.lead_time_days;
    }
    catch (const std::exception &e)
    {
        response["error"] = e.what();
    }
    return response;
}

Json::Value StockService::logStock(const LogStockDto &dto)
{
    ensureStockTablesExist();
    Json::Value response;
    try
    {
        auto dbClient = drogon::app().getDbClient();

        auto result = dbClient->execSqlSync("SELECT station_id, stock_available, stock_consumed, criticality_rate FROM stocks_master WHERE id = ?;", dto.stock_id);
        if (result.empty())
        {
            response["error"] = "Stock item not found";
            return response;
        }

        std::string stationId = result[0]["station_id"].as<std::string>();
        double currentAvailable = result[0]["stock_available"].as<double>();
        double currentConsumed = result[0]["stock_consumed"].as<double>();
        double criticalityRate = result[0]["criticality_rate"].as<double>();

        double newAvailable = currentAvailable;
        double newConsumed = currentConsumed;

        if (dto.action == "ADDED")
        {
            newAvailable += dto.quantity;
        }
        else if (dto.action == "USED")
        {
            newConsumed += dto.quantity;
        }
        else
        {
            response["error"] = "Invalid action. Must be 'ADDED' or 'USED'";
            return response;
        }

        double newPresent = newAvailable - newConsumed;

        dbClient->execSqlSync(
            "UPDATE stocks_master SET stock_available = ?, stock_consumed = ?, present_stock = ?, is_synced = 0, updated_at = CURRENT_TIMESTAMP WHERE id = ?;",
            newAvailable, newConsumed, newPresent, dto.stock_id
        );

        static std::random_device rd;
        static std::mt19937 gen(rd());
        static std::uniform_int_distribution<> dis(0, 15);
        std::stringstream ss;
        ss << "log-";
        for (int i = 0; i < 8; ++i) ss << std::hex << dis(gen);
        std::string logId = ss.str();

        dbClient->execSqlSync(
            "INSERT INTO stock_logs (id, stock_id, action, quantity, notes) VALUES (?, ?, ?, ?, ?);",
            logId, dto.stock_id, dto.action, dto.quantity, dto.notes
        );

        // Only consumption is demand. Replenishment changes inventory but must
        // not distort the demand time series used by the forecast model.
        if (dto.action == "USED")
        {
            const std::string demandId = "demand-" + logId.substr(4);
            dbClient->execSqlSync(
                "INSERT INTO stock_demand_history (id, stock_id, quantity) VALUES (?, ?, ?);",
                demandId, dto.stock_id, dto.quantity
            );
        }

        response["success"] = true;
        response["message"] = "Stock logged successfully (" + dto.action + ")";
        response["stock"]["id"] = dto.stock_id;
        response["stock"]["action"] = dto.action;
        response["stock"]["logged_quantity"] = dto.quantity;
        response["stock"]["stock_available"] = newAvailable;
        response["stock"]["stock_consumed"] = newConsumed;
        response["stock"]["present_stock"] = newPresent;
        response["analytics_triggered"] = (dto.action == "USED");

        if (dto.action == "USED")
        {
            triggerAnalytics(dto.stock_id);
        }
    }
    catch (const std::exception &e)
    {
        response["error"] = e.what();
    }
    return response;
}

void StockService::triggerAnalytics(const std::string &stockId)
{
    try
    {
        auto dbClient = drogon::app().getDbClient();
        auto stockResult = dbClient->execSqlSync(
            "SELECT station_id, present_stock, essentiality_score, lead_time_days "
            "FROM stocks_master WHERE id = ?;", stockId);
        auto historyResult = dbClient->execSqlSync(
            "SELECT quantity FROM stock_demand_history WHERE stock_id = ? "
            "ORDER BY observed_at ASC, rowid ASC;", stockId);

        if (stockResult.empty() || historyResult.size() < kMinimumForecastObservations)
        {
            LOG_INFO << "Analytics deferred for stock " << stockId
                     << ": at least " << kMinimumForecastObservations
                     << " USED observations are required.";
            return;
        }

        Json::Value forecastPayload;
        forecastPayload["item_id"] = stockId;
        forecastPayload["station_id"] = stockResult[0]["station_id"].as<std::string>();
        forecastPayload["forecast_horizon_days"] = 15;
        forecastPayload["demand_mode"] = "auto";
        forecastPayload["tune_alpha"] = true;
        Json::Value history(Json::arrayValue);
        for (const auto &row : historyResult)
        {
            history.append(row["quantity"].as<double>());
        }
        forecastPayload["historical_demand"] = history;

        auto client = drogon::HttpClient::newHttpClient(analyticsServiceUrl());
        auto forecastRequest = drogon::HttpRequest::newHttpJsonRequest(forecastPayload);
        forecastRequest->setPath("/forecast");
        forecastRequest->setMethod(drogon::Post);
        client->sendRequest(
            forecastRequest,
            [stockId, client](drogon::ReqResult result, const drogon::HttpResponsePtr &forecastResponse) {
                if (result != drogon::ReqResult::Ok || !forecastResponse || forecastResponse->getStatusCode() != drogon::k200OK)
                {
                    LOG_ERROR << "Forecast request failed for stock " << stockId;
                    return;
                }

                const auto forecast = forecastResponse->getJsonObject();
                if (!forecast || !forecast->isMember("forecast_daily_total") || !forecast->isMember("forecast_mae"))
                {
                    LOG_ERROR << "Forecast response was incomplete for stock " << stockId;
                    return;
                }

                try
                {
                    auto dbClient = drogon::app().getDbClient();
                    auto stockResult = dbClient->execSqlSync(
                        "SELECT station_id, present_stock, essentiality_score, lead_time_days "
                        "FROM stocks_master WHERE id = ?;", stockId);
                    if (stockResult.empty()) return;

                    Json::Value criticalityPayload;
                    criticalityPayload["item_id"] = stockId;
                    criticalityPayload["station_id"] = stockResult[0]["station_id"].as<std::string>();
                    criticalityPayload["current_stock"] = stockResult[0]["present_stock"].as<double>();
                    criticalityPayload["essentiality"] = stockResult[0]["essentiality_score"].as<double>();
                    criticalityPayload["lead_time_days"] = stockResult[0]["lead_time_days"].as<double>();
                    // These are the two forecast outputs required by the next stage.
                    criticalityPayload["forecast_daily_demand"] = (*forecast)["forecast_daily_total"];
                    criticalityPayload["forecast_mae"] = (*forecast)["forecast_mae"];

                    auto criticalityRequest = drogon::HttpRequest::newHttpJsonRequest(criticalityPayload);
                    criticalityRequest->setPath("/criticality");
                    criticalityRequest->setMethod(drogon::Post);
                    client->sendRequest(
                        criticalityRequest,
                        [stockId, forecast](drogon::ReqResult criticalityResult, const drogon::HttpResponsePtr &criticalityResponse) {
                            if (criticalityResult != drogon::ReqResult::Ok || !criticalityResponse || criticalityResponse->getStatusCode() != drogon::k200OK)
                            {
                                LOG_ERROR << "Criticality request failed for stock " << stockId;
                                return;
                            }

                            const auto criticality = criticalityResponse->getJsonObject();
                            if (!criticality || !criticality->isMember("criticality_score"))
                            {
                                LOG_ERROR << "Criticality response was incomplete for stock " << stockId;
                                return;
                            }

                            std::string criticalityStatus = "MEDIUM";
                            if (criticality->isMember("risk_category"))
                            {
                                criticalityStatus = (*criticality)["risk_category"].asString();
                            }
                            else if (criticality->isMember("criticality_status"))
                            {
                                criticalityStatus = (*criticality)["criticality_status"].asString();
                            }

                            try
                            {
                                drogon::app().getDbClient()->execSqlSync(
                                    "UPDATE stocks_master SET criticality_rate = ?, criticality_status = ?, forecast_daily_total = ?, forecast_mae = ?, is_synced = 0, analytics_updated_at = CURRENT_TIMESTAMP WHERE id = ?;",
                                    (*criticality)["criticality_score"].asDouble(),
                                    criticalityStatus,
                                    (*forecast)["forecast_daily_total"].asDouble(),
                                    (*forecast)["forecast_mae"].asDouble(),
                                    stockId);
                                LOG_INFO << "Analytics updated for stock " << stockId;
                            }
                            catch (const std::exception &e)
                            {
                                LOG_ERROR << "Unable to save analytics for stock " << stockId << ": " << e.what();
                            }
                        });
                }
                catch (const std::exception &e)
                {
                    LOG_ERROR << "Unable to prepare criticality request for stock " << stockId << ": " << e.what();
                }
            });
    }
    catch (const std::exception &e)
    {
        LOG_ERROR << "Unable to trigger analytics for stock " << stockId << ": " << e.what();
    }
}

Json::Value StockService::getAllStocks()
{
    ensureStockTablesExist();
    Json::Value response;
    try
    {
        auto dbClient = drogon::app().getDbClient();
        auto result = dbClient->execSqlSync("SELECT id, station_id, category, name, stock_available, stock_consumed, present_stock, criticality_rate, criticality_status, essentiality_score, lead_time_days, forecast_daily_total, forecast_mae, analytics_updated_at, updated_at FROM stocks_master ORDER BY name ASC;");

        Json::Value list(Json::arrayValue);
        for (const auto &row : result)
        {
            Json::Value item;
            item["id"] = row["id"].as<std::string>();
            item["station_id"] = row["station_id"].as<std::string>();
            item["category"] = row["category"].as<std::string>();
            item["name"] = row["name"].as<std::string>();
            item["stock_available"] = row["stock_available"].as<double>();
            item["stock_consumed"] = row["stock_consumed"].as<double>();
            item["present_stock"] = row["present_stock"].as<double>();
            item["criticality_rate"] = row["criticality_rate"].as<double>();
            if (!row["criticality_status"].isNull()) item["criticality_status"] = row["criticality_status"].as<std::string>();
            item["essentiality_score"] = row["essentiality_score"].as<double>();
            item["lead_time_days"] = row["lead_time_days"].as<double>();
            if (!row["forecast_daily_total"].isNull()) item["forecast_daily_total"] = row["forecast_daily_total"].as<double>();
            if (!row["forecast_mae"].isNull()) item["forecast_mae"] = row["forecast_mae"].as<double>();
            if (!row["analytics_updated_at"].isNull()) item["analytics_updated_at"] = row["analytics_updated_at"].as<std::string>();
            item["updated_at"] = row["updated_at"].as<std::string>();
            list.append(item);
        }

        response["success"] = true;
        response["count"] = list.size();
        response["stocks"] = list;
    }
    catch (const std::exception &e)
    {
        response["error"] = e.what();
    }
    return response;
}

Json::Value StockService::getStockById(const std::string &id)
{
    ensureStockTablesExist();
    Json::Value response;
    try
    {
        auto dbClient = drogon::app().getDbClient();
        auto result = dbClient->execSqlSync("SELECT id, station_id, category, name, stock_available, stock_consumed, present_stock, criticality_rate, criticality_status, essentiality_score, lead_time_days, forecast_daily_total, forecast_mae, analytics_updated_at, created_at, updated_at FROM stocks_master WHERE id = ?;", id);

        if (result.empty())
        {
            response["error"] = "Stock item not found";
            return response;
        }

        auto row = result[0];
        Json::Value item;
        item["id"] = row["id"].as<std::string>();
        item["station_id"] = row["station_id"].as<std::string>();
        item["category"] = row["category"].as<std::string>();
        item["name"] = row["name"].as<std::string>();
        item["stock_available"] = row["stock_available"].as<double>();
        item["stock_consumed"] = row["stock_consumed"].as<double>();
        item["present_stock"] = row["present_stock"].as<double>();
        item["criticality_rate"] = row["criticality_rate"].as<double>();
        if (!row["criticality_status"].isNull()) item["criticality_status"] = row["criticality_status"].as<std::string>();
        item["essentiality_score"] = row["essentiality_score"].as<double>();
        item["lead_time_days"] = row["lead_time_days"].as<double>();
        if (!row["forecast_daily_total"].isNull()) item["forecast_daily_total"] = row["forecast_daily_total"].as<double>();
        if (!row["forecast_mae"].isNull()) item["forecast_mae"] = row["forecast_mae"].as<double>();
        if (!row["analytics_updated_at"].isNull()) item["analytics_updated_at"] = row["analytics_updated_at"].as<std::string>();
        item["created_at"] = row["created_at"].as<std::string>();
        item["updated_at"] = row["updated_at"].as<std::string>();

        auto logResult = dbClient->execSqlSync("SELECT id, action, quantity, notes, logged_at FROM stock_logs WHERE stock_id = ? ORDER BY logged_at DESC;", id);
        Json::Value logs(Json::arrayValue);
        for (const auto &logRow : logResult)
        {
            Json::Value logEntry;
            logEntry["id"] = logRow["id"].as<std::string>();
            logEntry["action"] = logRow["action"].as<std::string>();
            logEntry["quantity"] = logRow["quantity"].as<double>();
            logEntry["notes"] = logRow["notes"].as<std::string>();
            logEntry["logged_at"] = logRow["logged_at"].as<std::string>();
            logs.append(logEntry);
        }

        response["success"] = true;
        response["stock"] = item;
        response["logs"] = logs;
    }
    catch (const std::exception &e)
    {
        response["error"] = e.what();
    }
    return response;
}

Json::Value StockService::getFilteredStocks(const std::string &category, const std::string &stationId)
{
    ensureStockTablesExist();
    Json::Value response;
    try
    {
        auto dbClient = drogon::app().getDbClient();
        std::string sql = "SELECT id, station_id, category, name, stock_available, stock_consumed, present_stock, criticality_rate, criticality_status, essentiality_score, lead_time_days, forecast_daily_total, forecast_mae, analytics_updated_at, updated_at FROM stocks_master WHERE 1=1";
        
        if (!category.empty()) sql += " AND LOWER(category) = LOWER('" + category + "')";
        if (!stationId.empty()) sql += " AND station_id = '" + stationId + "'";
        sql += " ORDER BY name ASC;";

        auto result = dbClient->execSqlSync(sql);
        Json::Value list(Json::arrayValue);
        for (const auto &row : result)
        {
            Json::Value item;
            item["id"] = row["id"].as<std::string>();
            item["station_id"] = row["station_id"].as<std::string>();
            item["category"] = row["category"].as<std::string>();
            item["name"] = row["name"].as<std::string>();
            item["stock_available"] = row["stock_available"].as<double>();
            item["stock_consumed"] = row["stock_consumed"].as<double>();
            item["present_stock"] = row["present_stock"].as<double>();
            item["criticality_rate"] = row["criticality_rate"].as<double>();
            if (!row["criticality_status"].isNull()) item["criticality_status"] = row["criticality_status"].as<std::string>();
            item["essentiality_score"] = row["essentiality_score"].as<double>();
            item["lead_time_days"] = row["lead_time_days"].as<double>();
            if (!row["forecast_daily_total"].isNull()) item["forecast_daily_total"] = row["forecast_daily_total"].as<double>();
            if (!row["forecast_mae"].isNull()) item["forecast_mae"] = row["forecast_mae"].as<double>();
            if (!row["analytics_updated_at"].isNull()) item["analytics_updated_at"] = row["analytics_updated_at"].as<std::string>();
            item["updated_at"] = row["updated_at"].as<std::string>();
            list.append(item);
        }

        response["success"] = true;
        response["filter"]["category"] = category;
        response["filter"]["station_id"] = stationId;
        response["count"] = list.size();
        response["stocks"] = list;
    }
    catch (const std::exception &e)
    {
        response["error"] = e.what();
    }
    return response;
}

Json::Value StockService::getStocksByCategory(const std::string &category)
{
    return getFilteredStocks(category, "");
}

Json::Value StockService::getAllCategories(const std::string &stationId)
{
    ensureStockTablesExist();
    Json::Value response;
    try
    {
        auto dbClient = drogon::app().getDbClient();
        std::string sql = "SELECT DISTINCT category FROM stocks_master";
        if (!stationId.empty()) sql += " WHERE station_id = '" + stationId + "'";
        sql += " ORDER BY category ASC;";

        auto result = dbClient->execSqlSync(sql);
        Json::Value categories(Json::arrayValue);
        for (const auto &row : result)
        {
            categories.append(row["category"].as<std::string>());
        }

        response["success"] = true;
        response["count"] = categories.size();
        response["categories"] = categories;
    }
    catch (const std::exception &e)
    {
        response["error"] = e.what();
    }
    return response;
}

Json::Value StockService::getStocksSortedByCriticality(const std::string &stationId)
{
    ensureStockTablesExist();
    Json::Value response;
    try
    {
        auto dbClient = drogon::app().getDbClient();
        std::string sql = "SELECT id, station_id, category, name, stock_available, stock_consumed, present_stock, criticality_rate, criticality_status, essentiality_score, lead_time_days, forecast_daily_total, forecast_mae, analytics_updated_at, updated_at FROM stocks_master";
        if (!stationId.empty())
        {
            sql += " WHERE station_id = '" + stationId + "'";
        }
        sql += " ORDER BY criticality_rate DESC, name ASC;";

        auto result = dbClient->execSqlSync(sql);
        Json::Value list(Json::arrayValue);
        for (const auto &row : result)
        {
            Json::Value item;
            item["id"] = row["id"].as<std::string>();
            item["station_id"] = row["station_id"].as<std::string>();
            item["category"] = row["category"].as<std::string>();
            item["name"] = row["name"].as<std::string>();
            item["stock_available"] = row["stock_available"].as<double>();
            item["stock_consumed"] = row["stock_consumed"].as<double>();
            item["present_stock"] = row["present_stock"].as<double>();
            item["criticality_rate"] = row["criticality_rate"].as<double>();
            if (!row["criticality_status"].isNull()) item["criticality_status"] = row["criticality_status"].as<std::string>();
            item["essentiality_score"] = row["essentiality_score"].as<double>();
            item["lead_time_days"] = row["lead_time_days"].as<double>();
            if (!row["forecast_daily_total"].isNull()) item["forecast_daily_total"] = row["forecast_daily_total"].as<double>();
            if (!row["forecast_mae"].isNull()) item["forecast_mae"] = row["forecast_mae"].as<double>();
            if (!row["analytics_updated_at"].isNull()) item["analytics_updated_at"] = row["analytics_updated_at"].as<std::string>();
            item["updated_at"] = row["updated_at"].as<std::string>();
            list.append(item);
        }

        response["success"] = true;
        response["count"] = list.size();
        response["stocks"] = list;
    }
    catch (const std::exception &e)
    {
        response["error"] = e.what();
    }
    return response;
}

Json::Value StockService::getTop5CriticalStocks(const std::string &stationId)
{
    ensureStockTablesExist();
    Json::Value response;
    try
    {
        auto dbClient = drogon::app().getDbClient();
        std::string sql = "SELECT id, station_id, category, name, stock_available, stock_consumed, present_stock, criticality_rate, criticality_status, essentiality_score, lead_time_days, forecast_daily_total, forecast_mae, analytics_updated_at, updated_at FROM stocks_master";
        if (!stationId.empty())
        {
            sql += " WHERE station_id = '" + stationId + "'";
        }
        sql += " ORDER BY criticality_rate DESC, name ASC LIMIT 5;";

        auto result = dbClient->execSqlSync(sql);
        Json::Value list(Json::arrayValue);
        for (const auto &row : result)
        {
            Json::Value item;
            item["id"] = row["id"].as<std::string>();
            item["station_id"] = row["station_id"].as<std::string>();
            item["category"] = row["category"].as<std::string>();
            item["name"] = row["name"].as<std::string>();
            item["stock_available"] = row["stock_available"].as<double>();
            item["stock_consumed"] = row["stock_consumed"].as<double>();
            item["present_stock"] = row["present_stock"].as<double>();
            item["criticality_rate"] = row["criticality_rate"].as<double>();
            if (!row["criticality_status"].isNull()) item["criticality_status"] = row["criticality_status"].as<std::string>();
            item["essentiality_score"] = row["essentiality_score"].as<double>();
            item["lead_time_days"] = row["lead_time_days"].as<double>();
            if (!row["forecast_daily_total"].isNull()) item["forecast_daily_total"] = row["forecast_daily_total"].as<double>();
            if (!row["forecast_mae"].isNull()) item["forecast_mae"] = row["forecast_mae"].as<double>();
            if (!row["analytics_updated_at"].isNull()) item["analytics_updated_at"] = row["analytics_updated_at"].as<std::string>();
            item["updated_at"] = row["updated_at"].as<std::string>();
            list.append(item);
        }

        response["success"] = true;
        response["count"] = list.size();
        response["top_critical_stocks"] = list;
    }
    catch (const std::exception &e)
    {
        response["error"] = e.what();
    }
    return response;
}

Json::Value StockService::getCriticalItemCount(const std::string &stationId)
{
    ensureStockTablesExist();
    Json::Value response;
    try
    {
        auto dbClient = drogon::app().getDbClient();
        std::string whereClause = "";
        if (!stationId.empty())
        {
            whereClause = " WHERE station_id = '" + stationId + "'";
        }

        std::string sql =
            "SELECT "
            "COUNT(*) AS total_items, "
            "SUM(CASE WHEN UPPER(criticality_status) = 'CRITICAL' OR criticality_rate >= 0.80 THEN 1 ELSE 0 END) AS critical_count, "
            "SUM(CASE WHEN (UPPER(criticality_status) = 'HIGH' OR (criticality_rate >= 0.60 AND criticality_rate < 0.80)) AND NOT (UPPER(criticality_status) = 'CRITICAL' OR criticality_rate >= 0.80) THEN 1 ELSE 0 END) AS high_count, "
            "SUM(CASE WHEN (UPPER(criticality_status) = 'MEDIUM' OR (criticality_rate >= 0.35 AND criticality_rate < 0.60)) AND NOT (UPPER(criticality_status) IN ('CRITICAL', 'HIGH') OR criticality_rate >= 0.60) THEN 1 ELSE 0 END) AS medium_count, "
            "SUM(CASE WHEN (UPPER(criticality_status) = 'LOW' OR criticality_rate < 0.35) AND NOT (UPPER(criticality_status) IN ('CRITICAL', 'HIGH', 'MEDIUM') OR criticality_rate >= 0.35) THEN 1 ELSE 0 END) AS low_count, "
            "SUM(CASE WHEN UPPER(criticality_status) IN ('CRITICAL', 'HIGH') OR criticality_rate >= 0.60 THEN 1 ELSE 0 END) AS total_critical_items "
            "FROM stocks_master" + whereClause + ";";

        auto result = dbClient->execSqlSync(sql);
        if (!result.empty())
        {
            auto row = result[0];
            int totalItems = row["total_items"].as<int>();
            int criticalCount = row["critical_count"].isNull() ? 0 : row["critical_count"].as<int>();
            int highCount = row["high_count"].isNull() ? 0 : row["high_count"].as<int>();
            int mediumCount = row["medium_count"].isNull() ? 0 : row["medium_count"].as<int>();
            int lowCount = row["low_count"].isNull() ? 0 : row["low_count"].as<int>();
            int totalCriticalItems = row["total_critical_items"].isNull() ? 0 : row["total_critical_items"].as<int>();

            response["success"] = true;
            if (!stationId.empty()) response["station_id"] = stationId;
            response["total_critical_items"] = totalCriticalItems;
            response["critical_count"] = criticalCount;
            response["high_count"] = highCount;
            response["medium_count"] = mediumCount;
            response["low_count"] = lowCount;
            response["total_items"] = totalItems;
        }
        else
        {
            response["success"] = true;
            if (!stationId.empty()) response["station_id"] = stationId;
            response["total_critical_items"] = 0;
            response["critical_count"] = 0;
            response["high_count"] = 0;
            response["medium_count"] = 0;
            response["low_count"] = 0;
            response["total_items"] = 0;
        }
    }
    catch (const std::exception &e)
    {
        response["success"] = false;
        response["error"] = e.what();
    }
    return response;
}

Json::Value StockService::getCriticalStocks(const std::string &status, const std::string &stationId)
{
    ensureStockTablesExist();
    Json::Value response;
    try
    {
        auto dbClient = drogon::app().getDbClient();
        std::string sql = "SELECT id, station_id, category, name, stock_available, stock_consumed, present_stock, criticality_rate, criticality_status, essentiality_score, lead_time_days, forecast_daily_total, forecast_mae, analytics_updated_at, updated_at FROM stocks_master WHERE 1=1";
        if (!stationId.empty())
        {
            sql += " AND station_id = '" + stationId + "'";
        }

        std::string targetStatus = status.empty() ? "HIGH" : status;
        if (targetStatus == "CRITICAL")
        {
            sql += " AND (UPPER(criticality_status) = 'CRITICAL' OR criticality_rate >= 0.80)";
        }
        else if (targetStatus == "HIGH")
        {
            sql += " AND (UPPER(criticality_status) IN ('CRITICAL', 'HIGH') OR criticality_rate >= 0.60)";
        }
        else
        {
            sql += " AND (UPPER(criticality_status) = '" + targetStatus + "')";
        }

        sql += " ORDER BY criticality_rate DESC, name ASC;";

        auto result = dbClient->execSqlSync(sql);
        Json::Value list(Json::arrayValue);
        for (const auto &row : result)
        {
            Json::Value item;
            item["id"] = row["id"].as<std::string>();
            item["station_id"] = row["station_id"].as<std::string>();
            item["category"] = row["category"].as<std::string>();
            item["name"] = row["name"].as<std::string>();
            item["stock_available"] = row["stock_available"].as<double>();
            item["stock_consumed"] = row["stock_consumed"].as<double>();
            item["present_stock"] = row["present_stock"].as<double>();
            item["criticality_rate"] = row["criticality_rate"].as<double>();
            if (!row["criticality_status"].isNull()) item["criticality_status"] = row["criticality_status"].as<std::string>();
            item["essentiality_score"] = row["essentiality_score"].as<double>();
            item["lead_time_days"] = row["lead_time_days"].as<double>();
            if (!row["forecast_daily_total"].isNull()) item["forecast_daily_total"] = row["forecast_daily_total"].as<double>();
            if (!row["forecast_mae"].isNull()) item["forecast_mae"] = row["forecast_mae"].as<double>();
            if (!row["analytics_updated_at"].isNull()) item["analytics_updated_at"] = row["analytics_updated_at"].as<std::string>();
            item["updated_at"] = row["updated_at"].as<std::string>();
            list.append(item);
        }

        response["success"] = true;
        response["count"] = list.size();
        response["critical_stocks"] = list;
    }
    catch (const std::exception &e)
    {
        response["error"] = e.what();
    }
    return response;
}


