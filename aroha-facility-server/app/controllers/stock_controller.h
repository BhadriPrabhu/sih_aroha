#pragma once

#include "services/stock_service.h"
#include <drogon/HttpController.h>

class StockController : public drogon::HttpController<StockController>
{
public:
    METHOD_LIST_BEGIN
    // GET /api/v1/stocks -> List all stocks
    ADD_METHOD_TO(StockController::getAllStocks, "/api/v1/stocks", drogon::Get);

    // POST /api/v1/stocks -> Create a new stock item record (ADD initial stock)
    ADD_METHOD_TO(StockController::createStock, "/api/v1/stocks", drogon::Post);

    // GET /api/v1/stocks/{id} -> Get stock item details and log history
    ADD_METHOD_TO(StockController::getStockById, "/api/v1/stocks/{1}", drogon::Get);

    // POST /api/v1/stocks/log -> Log stock movement (ADDED or USED)
    ADD_METHOD_TO(StockController::logStock, "/api/v1/stocks/log", drogon::Post);
    METHOD_LIST_END

    void getAllStocks(const drogon::HttpRequestPtr &req,
                      std::function<void(const drogon::HttpResponsePtr &)> &&callback);

    void createStock(const drogon::HttpRequestPtr &req,
                     std::function<void(const drogon::HttpResponsePtr &)> &&callback);

    void getStockById(const drogon::HttpRequestPtr &req,
                      std::function<void(const drogon::HttpResponsePtr &)> &&callback,
                      const std::string &id);

    void logStock(const drogon::HttpRequestPtr &req,
                  std::function<void(const drogon::HttpResponsePtr &)> &&callback);

private:
    StockService stockService_;
};
