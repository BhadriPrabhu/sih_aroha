#pragma once

#include "services/stock_service.h"
#include <drogon/HttpController.h>

class StockFilterController : public drogon::HttpController<StockFilterController>
{
public:
    METHOD_LIST_BEGIN
    // GET /api/v1/stocks/filter?category={cat}&station_id={stn}
    ADD_METHOD_TO(StockFilterController::filterStocks, "/api/v1/stocks/filter", drogon::Get);

    // GET /api/v1/stocks/category/{category} -> Get stocks by specific category
    ADD_METHOD_TO(StockFilterController::getStocksByCategory, "/api/v1/stocks/category/{1}", drogon::Get);

    // GET /api/v1/stocks/categories -> Get all distinct category names
    ADD_METHOD_TO(StockFilterController::getCategories, "/api/v1/stocks/categories", drogon::Get);
    METHOD_LIST_END

    void filterStocks(const drogon::HttpRequestPtr &req,
                      std::function<void(const drogon::HttpResponsePtr &)> &&callback);

    void getStocksByCategory(const drogon::HttpRequestPtr &req,
                             std::function<void(const drogon::HttpResponsePtr &)> &&callback,
                             const std::string &category);

    void getCategories(const drogon::HttpRequestPtr &req,
                       std::function<void(const drogon::HttpResponsePtr &)> &&callback);

private:
    StockService stockService_;
};
