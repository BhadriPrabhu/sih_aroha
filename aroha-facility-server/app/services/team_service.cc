#include "team_service.h"
#include <drogon/drogon.h>
#include <random>
#include <sstream>

std::string TeamService::generateUuid(const std::string &prefix)
{
    static std::random_device rd;
    static std::mt19937 gen(rd());
    static std::uniform_int_distribution<> dis(0, 15);
    std::stringstream ss;
    ss << prefix << "-";
    for (int i = 0; i < 8; ++i)
    {
        ss << std::hex << dis(gen);
    }
    return ss.str();
}

static void ensureTeamTablesExist()
{
    try
    {
        auto dbClient = drogon::app().getDbClient();
        dbClient->execSqlSync(
            "CREATE TABLE IF NOT EXISTS team_details ("
            "id TEXT PRIMARY KEY, "
            "teamid TEXT NOT NULL UNIQUE, "
            "teamname TEXT NOT NULL, "
            "active_status TEXT NOT NULL DEFAULT 'ACTIVE', "
            "created_at DATETIME DEFAULT CURRENT_TIMESTAMP, "
            "updated_at DATETIME DEFAULT CURRENT_TIMESTAMP);"
        );
        dbClient->execSqlSync(
            "CREATE TABLE IF NOT EXISTS member_details ("
            "id TEXT PRIMARY KEY, "
            "teamid TEXT NOT NULL REFERENCES team_details(teamid) ON DELETE CASCADE, "
            "name TEXT NOT NULL, "
            "role TEXT NOT NULL, "
            "activity_status TEXT NOT NULL DEFAULT 'ON_STATION', "
            "created_at DATETIME DEFAULT CURRENT_TIMESTAMP, "
            "updated_at DATETIME DEFAULT CURRENT_TIMESTAMP);"
        );

        // Auto-seed default sample teams
        dbClient->execSqlSync(
            "INSERT OR IGNORE INTO team_details (id, teamid, teamname, active_status) VALUES "
            "('tm-id-001', 'TEAM-ALPHA', 'Traverse Reconnaissance Alpha', 'ACTIVE'), "
            "('tm-id-002', 'TEAM-BETA', 'Ice Core Drilling Unit', 'ACTIVE'), "
            "('tm-id-003', 'TEAM-GAMMA', 'Station Maintenance Crew', 'INACTIVE');"
        );
        dbClient->execSqlSync(
            "INSERT OR IGNORE INTO member_details (id, teamid, name, role, activity_status) VALUES "
            "('mem-001', 'TEAM-ALPHA', 'Dr. Aarav Sharma', 'Lead Glaciologist', 'FIELD_MISSION'), "
            "('mem-002', 'TEAM-ALPHA', 'Captain Vikram Singh', 'Navigation Specialist', 'FIELD_MISSION'), "
            "('mem-003', 'TEAM-BETA', 'Priya Patel', 'Drill Technician', 'ON_STATION'), "
            "('mem-004', 'TEAM-BETA', 'Rohan Gupta', 'Equipment Engineer', 'ON_STATION');"
        );
    }
    catch (const std::exception &e)
    {
        LOG_ERROR << "Error ensuring team tables exist: " << e.what();
    }
}

Json::Value TeamService::getAllTeams()
{
    ensureTeamTablesExist();
    Json::Value response;
    try
    {
        auto dbClient = drogon::app().getDbClient();
        auto result = dbClient->execSqlSync("SELECT id, teamid, teamname, active_status, created_at, updated_at FROM team_details ORDER BY teamname ASC;");

        Json::Value list(Json::arrayValue);
        for (const auto &row : result)
        {
            Json::Value item;
            item["id"] = row["id"].as<std::string>();
            item["teamid"] = row["teamid"].as<std::string>();
            item["teamname"] = row["teamname"].as<std::string>();
            item["active_status"] = row["active_status"].as<std::string>();
            item["created_at"] = row["created_at"].as<std::string>();
            item["updated_at"] = row["updated_at"].as<std::string>();
            list.append(item);
        }

        response["success"] = true;
        response["count"] = list.size();
        response["teams"] = list;
    }
    catch (const std::exception &e)
    {
        response["error"] = e.what();
    }
    return response;
}

Json::Value TeamService::createTeam(const CreateTeamDto &dto)
{
    ensureTeamTablesExist();
    Json::Value response;
    try
    {
        auto dbClient = drogon::app().getDbClient();
        std::string id = generateUuid("tm");

        dbClient->execSqlSync(
            "INSERT INTO team_details (id, teamid, teamname, active_status) VALUES (?, ?, ?, ?);",
            id, dto.teamid, dto.teamname, dto.active_status
        );

        response["success"] = true;
        response["message"] = "Team created successfully";
        response["team"]["id"] = id;
        response["team"]["teamid"] = dto.teamid;
        response["team"]["teamname"] = dto.teamname;
        response["team"]["active_status"] = dto.active_status;
    }
    catch (const std::exception &e)
    {
        response["error"] = e.what();
    }
    return response;
}

Json::Value TeamService::getTeamById(const std::string &teamid)
{
    ensureTeamTablesExist();
    Json::Value response;
    try
    {
        auto dbClient = drogon::app().getDbClient();
        auto result = dbClient->execSqlSync("SELECT id, teamid, teamname, active_status, created_at, updated_at FROM team_details WHERE teamid = ?;", teamid);

        if (result.empty())
        {
            response["error"] = "Team not found";
            return response;
        }

        auto row = result[0];
        Json::Value team;
        team["id"] = row["id"].as<std::string>();
        team["teamid"] = row["teamid"].as<std::string>();
        team["teamname"] = row["teamname"].as<std::string>();
        team["active_status"] = row["active_status"].as<std::string>();
        team["created_at"] = row["created_at"].as<std::string>();
        team["updated_at"] = row["updated_at"].as<std::string>();

        auto memResult = dbClient->execSqlSync("SELECT id, teamid, name, role, activity_status, created_at FROM member_details WHERE teamid = ? ORDER BY name ASC;", teamid);
        Json::Value memberList(Json::arrayValue);
        for (const auto &memRow : memResult)
        {
            Json::Value member;
            member["id"] = memRow["id"].as<std::string>();
            member["teamid"] = memRow["teamid"].as<std::string>();
            member["name"] = memRow["name"].as<std::string>();
            member["role"] = memRow["role"].as<std::string>();
            member["activity_status"] = memRow["activity_status"].as<std::string>();
            member["created_at"] = memRow["created_at"].as<std::string>();
            memberList.append(member);
        }

        response["success"] = true;
        response["team"] = team;
        response["members"] = memberList;
    }
    catch (const std::exception &e)
    {
        response["error"] = e.what();
    }
    return response;
}

Json::Value TeamService::getTeamMembers(const std::string &teamid)
{
    ensureTeamTablesExist();
    Json::Value response;
    try
    {
        auto dbClient = drogon::app().getDbClient();
        auto result = dbClient->execSqlSync("SELECT id, teamid, name, role, activity_status, created_at FROM member_details WHERE teamid = ? ORDER BY name ASC;", teamid);

        Json::Value memberList(Json::arrayValue);
        for (const auto &row : result)
        {
            Json::Value member;
            member["id"] = row["id"].as<std::string>();
            member["teamid"] = row["teamid"].as<std::string>();
            member["name"] = row["name"].as<std::string>();
            member["role"] = row["role"].as<std::string>();
            member["activity_status"] = row["activity_status"].as<std::string>();
            member["created_at"] = row["created_at"].as<std::string>();
            memberList.append(member);
        }

        response["success"] = true;
        response["teamid"] = teamid;
        response["count"] = memberList.size();
        response["members"] = memberList;
    }
    catch (const std::exception &e)
    {
        response["error"] = e.what();
    }
    return response;
}

Json::Value TeamService::addTeamMember(const CreateMemberDto &dto)
{
    ensureTeamTablesExist();
    Json::Value response;
    try
    {
        auto dbClient = drogon::app().getDbClient();
        std::string id = generateUuid("mem");

        dbClient->execSqlSync(
            "INSERT INTO member_details (id, teamid, name, role, activity_status) VALUES (?, ?, ?, ?, ?);",
            id, dto.teamid, dto.name, dto.role, dto.activity_status
        );

        response["success"] = true;
        response["message"] = "Member added to team successfully";
        response["member"]["id"] = id;
        response["member"]["teamid"] = dto.teamid;
        response["member"]["name"] = dto.name;
        response["member"]["role"] = dto.role;
        response["member"]["activity_status"] = dto.activity_status;
    }
    catch (const std::exception &e)
    {
        response["error"] = e.what();
    }
    return response;
}

Json::Value TeamService::getAllMembers(const std::string &activityStatus)
{
    ensureTeamTablesExist();
    Json::Value response;
    try
    {
        auto dbClient = drogon::app().getDbClient();
        std::string sql = "SELECT id, teamid, name, role, activity_status, created_at FROM member_details";
        if (!activityStatus.empty())
        {
            sql += " WHERE LOWER(activity_status) = LOWER('" + activityStatus + "')";
        }
        sql += " ORDER BY name ASC;";

        auto result = dbClient->execSqlSync(sql);
        Json::Value memberList(Json::arrayValue);
        for (const auto &row : result)
        {
            Json::Value member;
            member["id"] = row["id"].as<std::string>();
            member["teamid"] = row["teamid"].as<std::string>();
            member["name"] = row["name"].as<std::string>();
            member["role"] = row["role"].as<std::string>();
            member["activity_status"] = row["activity_status"].as<std::string>();
            member["created_at"] = row["created_at"].as<std::string>();
            memberList.append(member);
        }

        response["success"] = true;
        response["count"] = memberList.size();
        response["members"] = memberList;
    }
    catch (const std::exception &e)
    {
        response["error"] = e.what();
    }
    return response;
}
