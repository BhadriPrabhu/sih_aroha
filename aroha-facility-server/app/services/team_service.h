#pragma once

#include "team_dto.h"
#include <json/json.h>
#include <sqlite3.h>
#include <string>

class TeamService
{
public:
    explicit TeamService(const std::string &dbPath = "aroha_facility.db");

    /// Get all teams
    Json::Value getAllTeams();

    /// Create a new team
    Json::Value createTeam(const CreateTeamDto &dto);

    /// Get team details by teamid with members list
    Json::Value getTeamById(const std::string &teamid);

    /// Get member list of a specific teamid
    Json::Value getTeamMembers(const std::string &teamid);

    /// Add a new member to a team
    Json::Value addTeamMember(const CreateMemberDto &dto);

    /// Get all members across teams (optional filter by activity_status)
    Json::Value getAllMembers(const std::string &activityStatus = "");

private:
    std::string dbPath_;
    std::string generateUuid(const std::string &prefix);
};
