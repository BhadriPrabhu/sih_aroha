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

    CreateTeamDto dto = CreateTeamDto::fromJson(*json);
    if (dto.teamid.empty() || dto.teamname.empty())
    {
        Json::Value err;
        err["error"] = "Fields 'teamid' and 'teamname' are required";
        auto resp = drogon::HttpResponse::newHttpJsonResponse(err);
        resp->setStatusCode(drogon::k400BadRequest);
        callback(resp);
        return;
    }

    Json::Value result = teamService_.createTeam(dto);
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

    CreateMemberDto dto = CreateMemberDto::fromJson(*json);
    dto.teamid = teamid;

    if (dto.name.empty() || dto.role.empty())
    {
        Json::Value err;
        err["error"] = "Fields 'name' and 'role' are required";
        auto resp = drogon::HttpResponse::newHttpJsonResponse(err);
        resp->setStatusCode(drogon::k400BadRequest);
        callback(resp);
        return;
    }

    Json::Value result = teamService_.addTeamMember(dto);
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
