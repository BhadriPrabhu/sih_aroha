#include "get_teams_controller.h"

void GetTeamsController::getAllTeams(const drogon::HttpRequestPtr &req,
                                       std::function<void(const drogon::HttpResponsePtr &)> &&callback)
{
    Json::Value result = teamService_.getAllTeams();
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
