#include "stock_controller.h"

void StockController::getAllStocks(const drogon::HttpRequestPtr &req,
                                    std::function<void(const drogon::HttpResponsePtr &)> &&callback)
{
    Json::Value result = stockService_.getAllStocks();
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

void StockController::createStock(const drogon::HttpRequestPtr &req,
                                   std::function<void(const drogon::HttpResponsePtr &)> &&callback)
{
    auto json = req->getJsonObject();
    if (!json)
    {
        Json::Value err;
        err["error"] = "Invalid or missing JSON payload";
        auto resp = drogon::HttpResponse::newHttpJsonResponse(err);
        resp->setStatusCode(drogon::k400BadRequest);
        callback(resp);
        return;
    }

    CreateStockDto dto = CreateStockDto::fromJson(*json);
    if (dto.name.empty() || dto.category.empty())
    {
        Json::Value err;
        err["error"] = "Fields 'name' and 'category' are required";
        auto resp = drogon::HttpResponse::newHttpJsonResponse(err);
        resp->setStatusCode(drogon::k400BadRequest);
        callback(resp);
        return;
    }

    Json::Value result = stockService_.createStock(dto);
    auto resp = drogon::HttpResponse::newHttpJsonResponse(result);
    if (result.isMember("error"))
    {
        resp->setStatusCode(drogon::k500InternalServerError);
    }
    else
    {
        resp->setStatusCode(drogon::k201Created);
    }
    callback(resp);
}

void StockController::getStockById(const drogon::HttpRequestPtr &req,
                                    std::function<void(const drogon::HttpResponsePtr &)> &&callback,
                                    const std::string &id)
{
    Json::Value result = stockService_.getStockById(id);
    auto resp = drogon::HttpResponse::newHttpJsonResponse(result);
    if (result.isMember("error"))
    {
        resp->setStatusCode(drogon::k404NotFound);
    }
    else
    {
        resp->setStatusCode(drogon::k200OK);
    }
    callback(resp);
}

void StockController::logStock(const drogon::HttpRequestPtr &req,
                               std::function<void(const drogon::HttpResponsePtr &)> &&callback)
{
    auto json = req->getJsonObject();
    if (!json)
    {
        Json::Value err;
        err["error"] = "Invalid or missing JSON payload";
        auto resp = drogon::HttpResponse::newHttpJsonResponse(err);
        resp->setStatusCode(drogon::k400BadRequest);
        callback(resp);
        return;
    }

    LogStockDto dto = LogStockDto::fromJson(*json);
    if (dto.stock_id.empty() || dto.action.empty() || dto.quantity <= 0)
    {
        Json::Value err;
        err["error"] = "Fields 'stock_id', 'action' ('ADDED'|'USED'), and positive 'quantity' are required";
        auto resp = drogon::HttpResponse::newHttpJsonResponse(err);
        resp->setStatusCode(drogon::k400BadRequest);
        callback(resp);
        return;
    }

    Json::Value result = stockService_.logStock(dto);
    auto resp = drogon::HttpResponse::newHttpJsonResponse(result);
    if (result.isMember("error"))
    {
        resp->setStatusCode(drogon::k400BadRequest);
    }
    else
    {
        resp->setStatusCode(drogon::k200OK);
    }
    callback(resp);
}
