#pragma once

#include "dto/stock_dto.h"
#include <drogon/drogon.h>
#include <json/json.h>
#include <string>

class StockService
{
public:
    explicit StockService() = default;

    /// Creates a new stock item record using Drogon DB Client
    Json::Value createStock(const CreateStockDto &dto);

    /// Logs stock action ("ADDED" or "USED") and updates present_stock via Drogon DB Client
    Json::Value logStock(const LogStockDto &dto);

    /// Retrieves all stock records using Drogon DB Client
    Json::Value getAllStocks();

    /// Retrieves a single stock item and its transaction log history via Drogon DB Client
    Json::Value getStockById(const std::string &id);

    /// Retrieves stocks filtered by category and/or station_id via Drogon DB Client
    Json::Value getFilteredStocks(const std::string &category, const std::string &stationId);

    /// Retrieves stocks for a specific category via Drogon DB Client
    Json::Value getStocksByCategory(const std::string &category);

    /// Retrieves all distinct categories present in stocks_master
    Json::Value getAllCategories(const std::string &stationId = "");

    /// Retrieves stocks sorted from higher criticality score to lower criticality score
    Json::Value getStocksSortedByCriticality(const std::string &stationId = "");

    /// Retrieves top 5 utmost criticality score stocks
    Json::Value getTop5CriticalStocks(const std::string &stationId = "");

    /// Retrieves count of total critical items with category breakdown
    Json::Value getCriticalItemCount(const std::string &stationId = "");

    /// Retrieves stocks filtered by criticality status or threshold
    Json::Value getCriticalStocks(const std::string &status = "HIGH", const std::string &stationId = "");

    /// Triggers asynchronous analytics calculation for a given stock item
    void triggerAnalytics(const std::string &stockId);

private:
    std::string generateUuid();
};
