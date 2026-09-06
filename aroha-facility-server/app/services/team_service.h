#pragma once

#include "dto/team_dto.h"
#include "models/TeamDetails.h"
#include "models/MemberDetails.h"
#include <drogon/orm/Mapper.h>
#include <json/json.h>
#include <string>

using namespace drogon_model::aroha_facility;

class TeamService
{
public:
    explicit TeamService() = default;

    /// Get all teams via Drogon ORM
    Json::Value getAllTeams();

    /// Create a new team via Drogon ORM
    Json::Value createTeam(const CreateTeamDto &dto);

    /// Get team details by teamid with members list via Drogon ORM
    Json::Value getTeamById(const std::string &teamid);

    /// Get member list of a specific teamid via Drogon ORM
    Json::Value getTeamMembers(const std::string &teamid);

    /// Add a new member to a team via Drogon ORM
    Json::Value addTeamMember(const CreateMemberDto &dto);

    /// Get all members across teams via Drogon ORM (optional filter by activity_status)
    Json::Value getAllMembers(const std::string &activityStatus = "");

private:
    std::string generateUuid(const std::string &prefix);
};
