#pragma once

#include "stock_dto.h"
#include <json/json.h>
#include <sqlite3.h>
#include <string>
#include <vector>

class StockService
{
public:
    explicit StockService(const std::string &dbPath = "aroha_facility.db");

    /// Creates a new stock item record in stocks_master
    Json::Value createStock(const CreateStockDto &dto);

    /// Logs stock action ("ADDED" or "USED") and updates present_stock
    Json::Value logStock(const LogStockDto &dto);

    /// Retrieves all stock records from stocks_master
    Json::Value getAllStocks();

    /// Retrieves a single stock item and its transaction log history
    Json::Value getStockById(const std::string &id);

private:
    std::string dbPath_;
    std::string generateUuid();
};
