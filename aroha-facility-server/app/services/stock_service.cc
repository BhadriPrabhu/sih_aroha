#include "stock_service.h"
#include <drogon/drogon.h>
#include <sqlite3.h>
#include <random>
#include <sstream>
#include <iomanip>

StockService::StockService(const std::string &dbPath)
    : dbPath_(dbPath)
{
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

Json::Value StockService::createStock(const CreateStockDto &dto)
{
    Json::Value response;
    sqlite3 *db = nullptr;

    if (sqlite3_open(dbPath_.c_str(), &db) != SQLITE_OK)
    {
        response["error"] = "Failed to connect to SQLite database";
        if (db) sqlite3_close(db);
        return response;
    }

    std::string stockId = generateUuid();
    double initialAvailable = dto.stock_available;
    double initialConsumed = 0.0;
    double presentStock = initialAvailable - initialConsumed;

    std::string sql = "INSERT INTO stocks_master (id, station_id, category, name, stock_available, stock_consumed, present_stock, criticality_rate) "
                      "VALUES (?, ?, ?, ?, ?, ?, ?, ?);";

    sqlite3_stmt *stmt = nullptr;
    if (sqlite3_prepare_v2(db, sql.c_str(), -1, &stmt, nullptr) != SQLITE_OK)
    {
        response["error"] = sqlite3_errmsg(db);
        sqlite3_close(db);
        return response;
    }

    sqlite3_bind_text(stmt, 1, stockId.c_str(), -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 2, dto.station_id.c_str(), -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 3, dto.category.c_str(), -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 4, dto.name.c_str(), -1, SQLITE_TRANSIENT);
    sqlite3_bind_double(stmt, 5, initialAvailable);
    sqlite3_bind_double(stmt, 6, initialConsumed);
    sqlite3_bind_double(stmt, 7, presentStock);
    sqlite3_bind_double(stmt, 8, dto.criticality_rate);

    if (sqlite3_step(stmt) == SQLITE_DONE)
    {
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
    else
    {
        response["error"] = sqlite3_errmsg(db);
    }

    sqlite3_finalize(stmt);
    sqlite3_close(db);
    return response;
}

Json::Value StockService::logStock(const LogStockDto &dto)
{
    Json::Value response;
    sqlite3 *db = nullptr;

    if (sqlite3_open(dbPath_.c_str(), &db) != SQLITE_OK)
    {
        response["error"] = "Failed to connect to SQLite database";
        if (db) sqlite3_close(db);
        return response;
    }

    // 1. Fetch current stock state
    std::string fetchSql = "SELECT stock_available, stock_consumed FROM stocks_master WHERE id = ?;";
    sqlite3_stmt *fetchStmt = nullptr;

    if (sqlite3_prepare_v2(db, fetchSql.c_str(), -1, &fetchStmt, nullptr) != SQLITE_OK)
    {
        response["error"] = sqlite3_errmsg(db);
        sqlite3_close(db);
        return response;
    }

    sqlite3_bind_text(fetchStmt, 1, dto.stock_id.c_str(), -1, SQLITE_TRANSIENT);

    if (sqlite3_step(fetchStmt) != SQLITE_ROW)
    {
        response["error"] = "Stock item not found";
        sqlite3_finalize(fetchStmt);
        sqlite3_close(db);
        return response;
    }

    double currentAvailable = sqlite3_column_double(fetchStmt, 0);
    double currentConsumed = sqlite3_column_double(fetchStmt, 1);
    sqlite3_finalize(fetchStmt);

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
        sqlite3_close(db);
        return response;
    }

    double newPresent = newAvailable - newConsumed;

    // 2. Update stocks_master
    std::string updateSql = "UPDATE stocks_master SET stock_available = ?, stock_consumed = ?, present_stock = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?;";
    sqlite3_stmt *updateStmt = nullptr;

    if (sqlite3_prepare_v2(db, updateSql.c_str(), -1, &updateStmt, nullptr) != SQLITE_OK)
    {
        response["error"] = sqlite3_errmsg(db);
        sqlite3_close(db);
        return response;
    }

    sqlite3_bind_double(updateStmt, 1, newAvailable);
    sqlite3_bind_double(updateStmt, 2, newConsumed);
    sqlite3_bind_double(updateStmt, 3, newPresent);
    sqlite3_bind_text(updateStmt, 4, dto.stock_id.c_str(), -1, SQLITE_TRANSIENT);

    if (sqlite3_step(updateStmt) != SQLITE_DONE)
    {
        response["error"] = sqlite3_errmsg(db);
        sqlite3_finalize(updateStmt);
        sqlite3_close(db);
        return response;
    }
    sqlite3_finalize(updateStmt);

    // 3. Log transaction in stock_logs
    std::string logId = "log-" + generateUuid();
    std::string insertLogSql = "INSERT INTO stock_logs (id, stock_id, action, quantity, notes) VALUES (?, ?, ?, ?, ?);";
    sqlite3_stmt *logStmt = nullptr;

    if (sqlite3_prepare_v2(db, insertLogSql.c_str(), -1, &logStmt, nullptr) == SQLITE_OK)
    {
        sqlite3_bind_text(logStmt, 1, logId.c_str(), -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(logStmt, 2, dto.stock_id.c_str(), -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(logStmt, 3, dto.action.c_str(), -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(logStmt, 4, dto.quantity);
        sqlite3_bind_text(logStmt, 5, dto.notes.c_str(), -1, SQLITE_TRANSIENT);
        sqlite3_step(logStmt);
        sqlite3_finalize(logStmt);
    }

    sqlite3_close(db);

    response["success"] = true;
    response["message"] = "Stock logged successfully (" + dto.action + ")";
    response["stock"]["id"] = dto.stock_id;
    response["stock"]["action"] = dto.action;
    response["stock"]["logged_quantity"] = dto.quantity;
    response["stock"]["stock_available"] = newAvailable;
    response["stock"]["stock_consumed"] = newConsumed;
    response["stock"]["present_stock"] = newPresent;

    return response;
}

Json::Value StockService::getAllStocks()
{
    Json::Value response;
    Json::Value list(Json::arrayValue);
    sqlite3 *db = nullptr;

    if (sqlite3_open(dbPath_.c_str(), &db) != SQLITE_OK)
    {
        response["error"] = "Failed to connect to SQLite database";
        if (db) sqlite3_close(db);
        return response;
    }

    std::string sql = "SELECT id, station_id, category, name, stock_available, stock_consumed, present_stock, criticality_rate, updated_at FROM stocks_master ORDER BY name ASC;";
    sqlite3_stmt *stmt = nullptr;

    if (sqlite3_prepare_v2(db, sql.c_str(), -1, &stmt, nullptr) == SQLITE_OK)
    {
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            Json::Value item;
            item["id"] = reinterpret_cast<const char *>(sqlite3_column_text(stmt, 0));
            item["station_id"] = reinterpret_cast<const char *>(sqlite3_column_text(stmt, 1));
            item["category"] = reinterpret_cast<const char *>(sqlite3_column_text(stmt, 2));
            item["name"] = reinterpret_cast<const char *>(sqlite3_column_text(stmt, 3));
            item["stock_available"] = sqlite3_column_double(stmt, 4);
            item["stock_consumed"] = sqlite3_column_double(stmt, 5);
            item["present_stock"] = sqlite3_column_double(stmt, 6);
            item["criticality_rate"] = sqlite3_column_double(stmt, 7);
            item["updated_at"] = sqlite3_column_text(stmt, 8) ? reinterpret_cast<const char *>(sqlite3_column_text(stmt, 8)) : "";
            list.append(item);
        }
        sqlite3_finalize(stmt);
    }

    sqlite3_close(db);

    response["success"] = true;
    response["count"] = list.size();
    response["stocks"] = list;
    return response;
}

Json::Value StockService::getStockById(const std::string &id)
{
    Json::Value response;
    sqlite3 *db = nullptr;

    if (sqlite3_open(dbPath_.c_str(), &db) != SQLITE_OK)
    {
        response["error"] = "Failed to connect to SQLite database";
        if (db) sqlite3_close(db);
        return response;
    }

    std::string sql = "SELECT id, station_id, category, name, stock_available, stock_consumed, present_stock, criticality_rate, created_at, updated_at FROM stocks_master WHERE id = ?;";
    sqlite3_stmt *stmt = nullptr;

    if (sqlite3_prepare_v2(db, sql.c_str(), -1, &stmt, nullptr) != SQLITE_OK)
    {
        response["error"] = sqlite3_errmsg(db);
        sqlite3_close(db);
        return response;
    }

    sqlite3_bind_text(stmt, 1, id.c_str(), -1, SQLITE_TRANSIENT);

    if (sqlite3_step(stmt) == SQLITE_ROW)
    {
        Json::Value item;
        item["id"] = reinterpret_cast<const char *>(sqlite3_column_text(stmt, 0));
        item["station_id"] = reinterpret_cast<const char *>(sqlite3_column_text(stmt, 1));
        item["category"] = reinterpret_cast<const char *>(sqlite3_column_text(stmt, 2));
        item["name"] = reinterpret_cast<const char *>(sqlite3_column_text(stmt, 3));
        item["stock_available"] = sqlite3_column_double(stmt, 4);
        item["stock_consumed"] = sqlite3_column_double(stmt, 5);
        item["present_stock"] = sqlite3_column_double(stmt, 6);
        item["criticality_rate"] = sqlite3_column_double(stmt, 7);
        item["created_at"] = sqlite3_column_text(stmt, 8) ? reinterpret_cast<const char *>(sqlite3_column_text(stmt, 8)) : "";
        item["updated_at"] = sqlite3_column_text(stmt, 9) ? reinterpret_cast<const char *>(sqlite3_column_text(stmt, 9)) : "";

        // Fetch audit logs
        Json::Value logs(Json::arrayValue);
        std::string logSql = "SELECT id, action, quantity, notes, logged_at FROM stock_logs WHERE stock_id = ? ORDER BY logged_at DESC;";
        sqlite3_stmt *logStmt = nullptr;
        if (sqlite3_prepare_v2(db, logSql.c_str(), -1, &logStmt, nullptr) == SQLITE_OK)
        {
            sqlite3_bind_text(logStmt, 1, id.c_str(), -1, SQLITE_TRANSIENT);
            while (sqlite3_step(logStmt) == SQLITE_ROW)
            {
                Json::Value logEntry;
                logEntry["id"] = reinterpret_cast<const char *>(sqlite3_column_text(logStmt, 0));
                logEntry["action"] = reinterpret_cast<const char *>(sqlite3_column_text(logStmt, 1));
                logEntry["quantity"] = sqlite3_column_double(logStmt, 2);
                logEntry["notes"] = sqlite3_column_text(logStmt, 3) ? reinterpret_cast<const char *>(sqlite3_column_text(logStmt, 3)) : "";
                logEntry["logged_at"] = sqlite3_column_text(logStmt, 4) ? reinterpret_cast<const char *>(sqlite3_column_text(logStmt, 4)) : "";
                logs.append(logEntry);
            }
            sqlite3_finalize(logStmt);
        }

        response["success"] = true;
        response["stock"] = item;
        response["logs"] = logs;
    }
    else
    {
        response["error"] = "Stock item not found";
    }

    sqlite3_finalize(stmt);
    sqlite3_close(db);
    return response;
}
