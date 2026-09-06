#pragma once

#include "services/team_service.h"
#include <drogon/HttpController.h>

class GetTeamsController : public drogon::HttpController<GetTeamsController>
{
public:
    METHOD_LIST_BEGIN
    // GET /api/v1/getallteams -> List all teams
    ADD_METHOD_TO(GetTeamsController::getAllTeams, "/api/v1/getallteams", drogon::Get);

    // GET /api/v1/teams/all -> List all teams alias
    ADD_METHOD_TO(GetTeamsController::getAllTeams, "/api/v1/teams/all", drogon::Get);
    METHOD_LIST_END

    void getAllTeams(const drogon::HttpRequestPtr &req,
                     std::function<void(const drogon::HttpResponsePtr &)> &&callback);

private:
    TeamService teamService_;
};
