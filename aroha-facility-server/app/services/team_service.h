#pragma once

#include "dto/team_dto.h"
#include <drogon/drogon.h>
#include <json/json.h>
#include <string>

class TeamService
{
public:
    explicit TeamService() = default;

    /// Get all teams via Drogon DB Client
    Json::Value getAllTeams();

    /// Create a new team via Drogon DB Client
    Json::Value createTeam(const CreateTeamDto &dto);

    /// Get team details by teamid with members list via Drogon DB Client
    Json::Value getTeamById(const std::string &teamid);

    /// Get member list of a specific teamid via Drogon DB Client
    Json::Value getTeamMembers(const std::string &teamid);

    /// Add a new member to a team via Drogon DB Client
    Json::Value addTeamMember(const CreateMemberDto &dto);

    /// Get all members across teams via Drogon DB Client (optional filter by activity_status)
    Json::Value getAllMembers(const std::string &activityStatus = "");

private:
    std::string generateUuid(const std::string &prefix);
};
