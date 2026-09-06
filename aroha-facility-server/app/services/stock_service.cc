#include "stock_service.h"
#include <drogon/drogon.h>
#include <random>
#include <sstream>
#include <set>

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
            "logged_at DATETIME DEFAULT CURRENT_TIMESTAMP);"
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

        dbClient->execSqlSync(
            "INSERT INTO stocks_master (id, station_id, category, name, stock_available, stock_consumed, present_stock, criticality_rate) VALUES (?, ?, ?, ?, ?, ?, ?, ?);",
            stockId, dto.station_id, dto.category, dto.name, initialAvailable, initialConsumed, presentStock, dto.criticality_rate
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

        auto result = dbClient->execSqlSync("SELECT stock_available, stock_consumed FROM stocks_master WHERE id = ?;", dto.stock_id);
        if (result.empty())
        {
            response["error"] = "Stock item not found";
            return response;
        }

        double currentAvailable = result[0]["stock_available"].as<double>();
        double currentConsumed = result[0]["stock_consumed"].as<double>();

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
            "UPDATE stocks_master SET stock_available = ?, stock_consumed = ?, present_stock = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?;",
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

        response["success"] = true;
        response["message"] = "Stock logged successfully (" + dto.action + ")";
        response["stock"]["id"] = dto.stock_id;
        response["stock"]["action"] = dto.action;
        response["stock"]["logged_quantity"] = dto.quantity;
        response["stock"]["stock_available"] = newAvailable;
        response["stock"]["stock_consumed"] = newConsumed;
        response["stock"]["present_stock"] = newPresent;
    }
    catch (const std::exception &e)
    {
        response["error"] = e.what();
    }
    return response;
}

Json::Value StockService::getAllStocks()
{
    ensureStockTablesExist();
    Json::Value response;
    try
    {
        auto dbClient = drogon::app().getDbClient();
        auto result = dbClient->execSqlSync("SELECT id, station_id, category, name, stock_available, stock_consumed, present_stock, criticality_rate, updated_at FROM stocks_master ORDER BY name ASC;");

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
        auto result = dbClient->execSqlSync("SELECT id, station_id, category, name, stock_available, stock_consumed, present_stock, criticality_rate, created_at, updated_at FROM stocks_master WHERE id = ?;", id);

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
        std::string sql = "SELECT id, station_id, category, name, stock_available, stock_consumed, present_stock, criticality_rate, updated_at FROM stocks_master WHERE 1=1";
        
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
