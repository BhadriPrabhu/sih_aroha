#include "team_controller.h"

void TeamController::getAllTeams(const drogon::HttpRequestPtr &req,
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

void TeamController::createTeam(const drogon::HttpRequestPtr &req,
                                 std::function<void(const drogon::HttpResponsePtr &)> &&callback)
{
    Json::Value err;
    err["error"] = "Forbidden: Team creation and member management are restricted to central remote admin server only.";
    auto resp = drogon::HttpResponse::newHttpJsonResponse(err);
    resp->setStatusCode(drogon::k403Forbidden);
    callback(resp);
}

void TeamController::getTeamById(const drogon::HttpRequestPtr &req,
                                  std::function<void(const drogon::HttpResponsePtr &)> &&callback,
                                  const std::string &teamid)
{
    Json::Value result = teamService_.getTeamById(teamid);
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

void TeamController::getTeamMembers(const drogon::HttpRequestPtr &req,
                                     std::function<void(const drogon::HttpResponsePtr &)> &&callback,
                                     const std::string &teamid)
{
    Json::Value result = teamService_.getTeamMembers(teamid);
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

void TeamController::addTeamMember(const drogon::HttpRequestPtr &req,
                                    std::function<void(const drogon::HttpResponsePtr &)> &&callback,
                                    const std::string &teamid)
{
    Json::Value err;
    err["error"] = "Forbidden: Member addition and team management are restricted to central remote admin server only.";
    auto resp = drogon::HttpResponse::newHttpJsonResponse(err);
    resp->setStatusCode(drogon::k403Forbidden);
    callback(resp);
}

void TeamController::getAllMembers(const drogon::HttpRequestPtr &req,
                                    std::function<void(const drogon::HttpResponsePtr &)> &&callback)
{
    std::string activityStatus = req->getParameter("activity_status");
    Json::Value result = teamService_.getAllMembers(activityStatus);
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
