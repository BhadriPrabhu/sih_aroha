#include "stock_filter_controller.h"

void StockFilterController::filterStocks(const drogon::HttpRequestPtr &req,
                                          std::function<void(const drogon::HttpResponsePtr &)> &&callback)
{
    std::string category = req->getParameter("category");
    std::string stationId = req->getParameter("station_id");

    Json::Value result = stockService_.getFilteredStocks(category, stationId);
    auto resp = drogon::HttpResponse::newHttpJsonResponse(result);
    if (result.isMember("error"))
    {
        resp->setStatusCode(drogon::k500InternalServerError);
    }
    else
    {
        resp->setStatusCode(drogon::k200OK);
    }
    callback(resp);
}

void StockFilterController::getStocksByCategory(const drogon::HttpRequestPtr &req,
                                                 std::function<void(const drogon::HttpResponsePtr &)> &&callback,
                                                 const std::string &category)
{
    std::string stationId = req->getParameter("station_id");
    Json::Value result = stockService_.getFilteredStocks(category, stationId);
    auto resp = drogon::HttpResponse::newHttpJsonResponse(result);
    if (result.isMember("error"))
    {
        resp->setStatusCode(drogon::k500InternalServerError);
    }
    else
    {
        resp->setStatusCode(drogon::k200OK);
    }
    callback(resp);
}

void StockFilterController::getCategories(const drogon::HttpRequestPtr &req,
                                           std::function<void(const drogon::HttpResponsePtr &)> &&callback)
{
    std::string stationId = req->getParameter("station_id");
    Json::Value result = stockService_.getAllCategories(stationId);
    auto resp = drogon::HttpResponse::newHttpJsonResponse(result);
    if (result.isMember("error"))
    {
        resp->setStatusCode(drogon::k500InternalServerError);
    }
    else
    {
        resp->setStatusCode(drogon::k200OK);
    }
    callback(resp);
}
