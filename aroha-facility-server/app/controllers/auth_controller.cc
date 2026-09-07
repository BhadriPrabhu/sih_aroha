#include "auth_controller.h"

void AuthController::login(const drogon::HttpRequestPtr &req,
                           std::function<void(const drogon::HttpResponsePtr &)> &&callback)
{
    auto jsonPtr = req->getJsonObject();
    if (!jsonPtr)
    {
        Json::Value err;
        err["success"] = false;
        err["error"] = "Invalid JSON body";
        auto resp = drogon::HttpResponse::newHttpJsonResponse(err);
        resp->setStatusCode(drogon::k400BadRequest);
        callback(resp);
        return;
    }

    // Support both 'name' and 'username', and both 'password' and 'member_id'
    std::string name = jsonPtr->get("name", "").asString();
    if (name.empty())
    {
        name = jsonPtr->get("username", "").asString();
    }

    std::string password = jsonPtr->get("password", "").asString();
    if (password.empty())
    {
        password = jsonPtr->get("member_id", "").asString();
    }
    if (password.empty())
    {
        password = jsonPtr->get("memberid", "").asString();
    }

    Json::Value result = authService_.login(name, password);

    auto resp = drogon::HttpResponse::newHttpJsonResponse(result);
    if (result.get("success", false).asBool())
    {
        resp->setStatusCode(drogon::k200OK);
    }
    else
    {
        resp->setStatusCode(drogon::k401Unauthorized);
    }
    callback(resp);
}
