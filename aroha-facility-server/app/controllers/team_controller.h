#pragma once

#include "services/team_service.h"
#include <drogon/HttpController.h>

class TeamController : public drogon::HttpController<TeamController>
{
public:
    METHOD_LIST_BEGIN
    // GET /api/v1/teams -> List all teams
    ADD_METHOD_TO(TeamController::getAllTeams, "/api/v1/teams", drogon::Get);

    // POST /api/v1/teams -> Create a new team
    ADD_METHOD_TO(TeamController::createTeam, "/api/v1/teams", drogon::Post);

    // GET /api/v1/teams/{teamid} -> Get team info & member list
    ADD_METHOD_TO(TeamController::getTeamById, "/api/v1/teams/{1}", drogon::Get);

    // GET /api/v1/teams/{teamid}/members -> Get team members for a team ID
    ADD_METHOD_TO(TeamController::getTeamMembers, "/api/v1/teams/{1}/members", drogon::Get);

    // POST /api/v1/teams/{teamid}/members -> Add a member to a team
    ADD_METHOD_TO(TeamController::addTeamMember, "/api/v1/teams/{1}/members", drogon::Post);

    // GET /api/v1/members -> List all personnel members
    ADD_METHOD_TO(TeamController::getAllMembers, "/api/v1/members", drogon::Get);
    METHOD_LIST_END

    void getAllTeams(const drogon::HttpRequestPtr &req,
                     std::function<void(const drogon::HttpResponsePtr &)> &&callback);

    void createTeam(const drogon::HttpRequestPtr &req,
                    std::function<void(const drogon::HttpResponsePtr &)> &&callback);

    void getTeamById(const drogon::HttpRequestPtr &req,
                     std::function<void(const drogon::HttpResponsePtr &)> &&callback,
                     const std::string &teamid);

    void getTeamMembers(const drogon::HttpRequestPtr &req,
                        std::function<void(const drogon::HttpResponsePtr &)> &&callback,
                        const std::string &teamid);

    void addTeamMember(const drogon::HttpRequestPtr &req,
                       std::function<void(const drogon::HttpResponsePtr &)> &&callback,
                       const std::string &teamid);

    void getAllMembers(const drogon::HttpRequestPtr &req,
                       std::function<void(const drogon::HttpResponsePtr &)> &&callback);

private:
    TeamService teamService_;
};
