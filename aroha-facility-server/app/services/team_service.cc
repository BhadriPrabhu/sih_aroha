#include "team_service.h"
#include <drogon/drogon.h>
#include <sqlite3.h>
#include <random>
#include <sstream>

TeamService::TeamService(const std::string &dbPath)
    : dbPath_(dbPath)
{
}

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

Json::Value TeamService::getAllTeams()
{
    Json::Value response;
    Json::Value list(Json::arrayValue);
    sqlite3 *db = nullptr;

    if (sqlite3_open(dbPath_.c_str(), &db) != SQLITE_OK)
    {
        response["error"] = "Failed to connect to SQLite database";
        if (db) sqlite3_close(db);
        return response;
    }

    std::string sql = "SELECT id, teamid, teamname, active_status, created_at, updated_at FROM team_details ORDER BY teamname ASC;";
    sqlite3_stmt *stmt = nullptr;

    if (sqlite3_prepare_v2(db, sql.c_str(), -1, &stmt, nullptr) == SQLITE_OK)
    {
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            Json::Value item;
            item["id"] = reinterpret_cast<const char *>(sqlite3_column_text(stmt, 0));
            item["teamid"] = reinterpret_cast<const char *>(sqlite3_column_text(stmt, 1));
            item["teamname"] = reinterpret_cast<const char *>(sqlite3_column_text(stmt, 2));
            item["active_status"] = reinterpret_cast<const char *>(sqlite3_column_text(stmt, 3));
            item["created_at"] = sqlite3_column_text(stmt, 4) ? reinterpret_cast<const char *>(sqlite3_column_text(stmt, 4)) : "";
            item["updated_at"] = sqlite3_column_text(stmt, 5) ? reinterpret_cast<const char *>(sqlite3_column_text(stmt, 5)) : "";
            list.append(item);
        }
        sqlite3_finalize(stmt);
    }

    sqlite3_close(db);

    response["success"] = true;
    response["count"] = list.size();
    response["teams"] = list;
    return response;
}

Json::Value TeamService::createTeam(const CreateTeamDto &dto)
{
    Json::Value response;
    sqlite3 *db = nullptr;

    if (sqlite3_open(dbPath_.c_str(), &db) != SQLITE_OK)
    {
        response["error"] = "Failed to connect to SQLite database";
        if (db) sqlite3_close(db);
        return response;
    }

    std::string id = generateUuid("tm");
    std::string sql = "INSERT INTO team_details (id, teamid, teamname, active_status) VALUES (?, ?, ?, ?);";
    sqlite3_stmt *stmt = nullptr;

    if (sqlite3_prepare_v2(db, sql.c_str(), -1, &stmt, nullptr) != SQLITE_OK)
    {
        response["error"] = sqlite3_errmsg(db);
        sqlite3_close(db);
        return response;
    }

    sqlite3_bind_text(stmt, 1, id.c_str(), -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 2, dto.teamid.c_str(), -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 3, dto.teamname.c_str(), -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 4, dto.active_status.c_str(), -1, SQLITE_TRANSIENT);

    if (sqlite3_step(stmt) == SQLITE_DONE)
    {
        response["success"] = true;
        response["message"] = "Team created successfully";
        response["team"]["id"] = id;
        response["team"]["teamid"] = dto.teamid;
        response["team"]["teamname"] = dto.teamname;
        response["team"]["active_status"] = dto.active_status;
    }
    else
    {
        response["error"] = sqlite3_errmsg(db);
    }

    sqlite3_finalize(stmt);
    sqlite3_close(db);
    return response;
}

Json::Value TeamService::getTeamById(const std::string &teamid)
{
    Json::Value response;
    sqlite3 *db = nullptr;

    if (sqlite3_open(dbPath_.c_str(), &db) != SQLITE_OK)
    {
        response["error"] = "Failed to connect to SQLite database";
        if (db) sqlite3_close(db);
        return response;
    }

    std::string sql = "SELECT id, teamid, teamname, active_status, created_at, updated_at FROM team_details WHERE teamid = ?;";
    sqlite3_stmt *stmt = nullptr;

    if (sqlite3_prepare_v2(db, sql.c_str(), -1, &stmt, nullptr) != SQLITE_OK)
    {
        response["error"] = sqlite3_errmsg(db);
        sqlite3_close(db);
        return response;
    }

    sqlite3_bind_text(stmt, 1, teamid.c_str(), -1, SQLITE_TRANSIENT);

    if (sqlite3_step(stmt) == SQLITE_ROW)
    {
        Json::Value team;
        team["id"] = reinterpret_cast<const char *>(sqlite3_column_text(stmt, 0));
        team["teamid"] = reinterpret_cast<const char *>(sqlite3_column_text(stmt, 1));
        team["teamname"] = reinterpret_cast<const char *>(sqlite3_column_text(stmt, 2));
        team["active_status"] = reinterpret_cast<const char *>(sqlite3_column_text(stmt, 3));
        team["created_at"] = sqlite3_column_text(stmt, 4) ? reinterpret_cast<const char *>(sqlite3_column_text(stmt, 4)) : "";
        team["updated_at"] = sqlite3_column_text(stmt, 5) ? reinterpret_cast<const char *>(sqlite3_column_text(stmt, 5)) : "";
        sqlite3_finalize(stmt);

        // Fetch members
        Json::Value members(Json::arrayValue);
        std::string memSql = "SELECT id, teamid, name, role, activity_status, created_at FROM member_details WHERE teamid = ? ORDER BY name ASC;";
        sqlite3_stmt *memStmt = nullptr;

        if (sqlite3_prepare_v2(db, memSql.c_str(), -1, &memStmt, nullptr) == SQLITE_OK)
        {
            sqlite3_bind_text(memStmt, 1, teamid.c_str(), -1, SQLITE_TRANSIENT);
            while (sqlite3_step(memStmt) == SQLITE_ROW)
            {
                Json::Value member;
                member["id"] = reinterpret_cast<const char *>(sqlite3_column_text(memStmt, 0));
                member["teamid"] = reinterpret_cast<const char *>(sqlite3_column_text(memStmt, 1));
                member["name"] = reinterpret_cast<const char *>(sqlite3_column_text(memStmt, 2));
                member["role"] = reinterpret_cast<const char *>(sqlite3_column_text(memStmt, 3));
                member["activity_status"] = reinterpret_cast<const char *>(sqlite3_column_text(memStmt, 4));
                member["created_at"] = sqlite3_column_text(memStmt, 5) ? reinterpret_cast<const char *>(sqlite3_column_text(memStmt, 5)) : "";
                members.append(member);
            }
            sqlite3_finalize(memStmt);
        }

        response["success"] = true;
        response["team"] = team;
        response["members"] = members;
    }
    else
    {
        response["error"] = "Team not found";
        sqlite3_finalize(stmt);
    }

    sqlite3_close(db);
    return response;
}

Json::Value TeamService::getTeamMembers(const std::string &teamid)
{
    Json::Value response;
    Json::Value members(Json::arrayValue);
    sqlite3 *db = nullptr;

    if (sqlite3_open(dbPath_.c_str(), &db) != SQLITE_OK)
    {
        response["error"] = "Failed to connect to SQLite database";
        if (db) sqlite3_close(db);
        return response;
    }

    std::string sql = "SELECT id, teamid, name, role, activity_status, created_at FROM member_details WHERE teamid = ? ORDER BY name ASC;";
    sqlite3_stmt *stmt = nullptr;

    if (sqlite3_prepare_v2(db, sql.c_str(), -1, &stmt, nullptr) == SQLITE_OK)
    {
        sqlite3_bind_text(stmt, 1, teamid.c_str(), -1, SQLITE_TRANSIENT);
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            Json::Value member;
            member["id"] = reinterpret_cast<const char *>(sqlite3_column_text(stmt, 0));
            member["teamid"] = reinterpret_cast<const char *>(sqlite3_column_text(stmt, 1));
            member["name"] = reinterpret_cast<const char *>(sqlite3_column_text(stmt, 2));
            member["role"] = reinterpret_cast<const char *>(sqlite3_column_text(stmt, 3));
            member["activity_status"] = reinterpret_cast<const char *>(sqlite3_column_text(stmt, 4));
            member["created_at"] = sqlite3_column_text(stmt, 5) ? reinterpret_cast<const char *>(sqlite3_column_text(stmt, 5)) : "";
            members.append(member);
        }
        sqlite3_finalize(stmt);
    }

    sqlite3_close(db);

    response["success"] = true;
    response["teamid"] = teamid;
    response["count"] = members.size();
    response["members"] = members;
    return response;
}

Json::Value TeamService::addTeamMember(const CreateMemberDto &dto)
{
    Json::Value response;
    sqlite3 *db = nullptr;

    if (sqlite3_open(dbPath_.c_str(), &db) != SQLITE_OK)
    {
        response["error"] = "Failed to connect to SQLite database";
        if (db) sqlite3_close(db);
        return response;
    }

    std::string id = generateUuid("mem");
    std::string sql = "INSERT INTO member_details (id, teamid, name, role, activity_status) VALUES (?, ?, ?, ?, ?);";
    sqlite3_stmt *stmt = nullptr;

    if (sqlite3_prepare_v2(db, sql.c_str(), -1, &stmt, nullptr) != SQLITE_OK)
    {
        response["error"] = sqlite3_errmsg(db);
        sqlite3_close(db);
        return response;
    }

    sqlite3_bind_text(stmt, 1, id.c_str(), -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 2, dto.teamid.c_str(), -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 3, dto.name.c_str(), -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 4, dto.role.c_str(), -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 5, dto.activity_status.c_str(), -1, SQLITE_TRANSIENT);

    if (sqlite3_step(stmt) == SQLITE_DONE)
    {
        response["success"] = true;
        response["message"] = "Member added to team successfully";
        response["member"]["id"] = id;
        response["member"]["teamid"] = dto.teamid;
        response["member"]["name"] = dto.name;
        response["member"]["role"] = dto.role;
        response["member"]["activity_status"] = dto.activity_status;
    }
    else
    {
        response["error"] = sqlite3_errmsg(db);
    }

    sqlite3_finalize(stmt);
    sqlite3_close(db);
    return response;
}

Json::Value TeamService::getAllMembers(const std::string &activityStatus)
{
    Json::Value response;
    Json::Value members(Json::arrayValue);
    sqlite3 *db = nullptr;

    if (sqlite3_open(dbPath_.c_str(), &db) != SQLITE_OK)
    {
        response["error"] = "Failed to connect to SQLite database";
        if (db) sqlite3_close(db);
        return response;
    }

    std::string sql = "SELECT id, teamid, name, role, activity_status, created_at FROM member_details";
    if (!activityStatus.empty())
    {
        sql += " WHERE LOWER(activity_status) = LOWER(?)";
    }
    sql += " ORDER BY name ASC;";

    sqlite3_stmt *stmt = nullptr;
    if (sqlite3_prepare_v2(db, sql.c_str(), -1, &stmt, nullptr) == SQLITE_OK)
    {
        if (!activityStatus.empty())
        {
            sqlite3_bind_text(stmt, 1, activityStatus.c_str(), -1, SQLITE_TRANSIENT);
        }

        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            Json::Value member;
            member["id"] = reinterpret_cast<const char *>(sqlite3_column_text(stmt, 0));
            member["teamid"] = reinterpret_cast<const char *>(sqlite3_column_text(stmt, 1));
            member["name"] = reinterpret_cast<const char *>(sqlite3_column_text(stmt, 2));
            member["role"] = reinterpret_cast<const char *>(sqlite3_column_text(stmt, 3));
            member["activity_status"] = reinterpret_cast<const char *>(sqlite3_column_text(stmt, 4));
            member["created_at"] = sqlite3_column_text(stmt, 5) ? reinterpret_cast<const char *>(sqlite3_column_text(stmt, 5)) : "";
            members.append(member);
        }
        sqlite3_finalize(stmt);
    }

    sqlite3_close(db);

    response["success"] = true;
    response["count"] = members.size();
    response["members"] = members;
    return response;
}
