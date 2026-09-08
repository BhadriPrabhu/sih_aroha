#pragma once

#include "services/stock_service.h"
#include <drogon/HttpController.h>

class StockFilterController : public drogon::HttpController<StockFilterController>
{
public:
    METHOD_LIST_BEGIN
    // GET /api/v1/stocks/filter?category={cat}&station_id={stn}
    ADD_METHOD_TO(StockFilterController::filterStocks, "/api/v1/stocks/filter", drogon::Get);
    ADD_METHOD_TO(StockFilterController::filterStocks, "/api/v1/facility/stocks/filter", drogon::Get);

    // GET /api/v1/stocks/category/{category} -> Get stocks by specific category
    ADD_METHOD_TO(StockFilterController::getStocksByCategory, "/api/v1/stocks/category/{1}", drogon::Get);
    ADD_METHOD_TO(StockFilterController::getStocksByCategory, "/api/v1/facility/stocks/category/{1}", drogon::Get);

    // GET /api/v1/stocks/categories -> Get all distinct category names
    ADD_METHOD_TO(StockFilterController::getCategories, "/api/v1/stocks/categories", drogon::Get);
    ADD_METHOD_TO(StockFilterController::getCategories, "/api/v1/facility/stocks/categories", drogon::Get);

    // GET /api/v1/stocks/sorted-criticality -> Get stocks sorted higher to lower criticality score
    ADD_METHOD_TO(StockFilterController::getStocksSortedByCriticality, "/api/v1/stocks/sorted-criticality", drogon::Get);
    ADD_METHOD_TO(StockFilterController::getStocksSortedByCriticality, "/api/v1/facility/stocks/sorted-criticality", drogon::Get);

    // GET /api/v1/stocks/top-critical -> Get top 5 utmost criticality score stocks
    ADD_METHOD_TO(StockFilterController::getTop5CriticalStocks, "/api/v1/stocks/top-critical", drogon::Get);
    ADD_METHOD_TO(StockFilterController::getTop5CriticalStocks, "/api/v1/stocks/top5-critical", drogon::Get);
    ADD_METHOD_TO(StockFilterController::getTop5CriticalStocks, "/api/v1/facility/stocks/top-critical", drogon::Get);
    ADD_METHOD_TO(StockFilterController::getTop5CriticalStocks, "/api/v1/facility/stocks/top5-critical", drogon::Get);

    // GET /api/v1/stocks/criticality/count -> Get total count of critical items
    ADD_METHOD_TO(StockFilterController::getCriticalItemCount, "/api/v1/stocks/criticality/count", drogon::Get);
    ADD_METHOD_TO(StockFilterController::getCriticalItemCount, "/api/v1/facility/stocks/criticality/count", drogon::Get);
    ADD_METHOD_TO(StockFilterController::getCriticalItemCount, "/api/v1/stocks/critical/count", drogon::Get);
    ADD_METHOD_TO(StockFilterController::getCriticalItemCount, "/api/v1/facility/stocks/critical/count", drogon::Get);
    ADD_METHOD_TO(StockFilterController::getCriticalItemCount, "/api/v1/facility/criticality/count", drogon::Get);

    // GET /api/v1/stocks/criticality -> Filter stocks by criticality status
    ADD_METHOD_TO(StockFilterController::getCriticalStocks, "/api/v1/stocks/criticality", drogon::Get);
    ADD_METHOD_TO(StockFilterController::getCriticalStocks, "/api/v1/facility/stocks/criticality", drogon::Get);
    METHOD_LIST_END

    void filterStocks(const drogon::HttpRequestPtr &req,
                      std::function<void(const drogon::HttpResponsePtr &)> &&callback);

    void getStocksByCategory(const drogon::HttpRequestPtr &req,
                             std::function<void(const drogon::HttpResponsePtr &)> &&callback,
                             const std::string &category);

    void getCategories(const drogon::HttpRequestPtr &req,
                       std::function<void(const drogon::HttpResponsePtr &)> &&callback);

    void getStocksSortedByCriticality(const drogon::HttpRequestPtr &req,
                                     std::function<void(const drogon::HttpResponsePtr &)> &&callback);

    void getTop5CriticalStocks(const drogon::HttpRequestPtr &req,
                               std::function<void(const drogon::HttpResponsePtr &)> &&callback);

    void getCriticalItemCount(const drogon::HttpRequestPtr &req,
                              std::function<void(const drogon::HttpResponsePtr &)> &&callback);

    void getCriticalStocks(const drogon::HttpRequestPtr &req,
                           std::function<void(const drogon::HttpResponsePtr &)> &&callback);

private:
    StockService stockService_;
};
