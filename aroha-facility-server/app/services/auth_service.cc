#include "auth_service.h"
#include <drogon/drogon.h>
#include <algorithm>

Json::Value AuthService::login(const std::string &name, const std::string &password)
{
    Json::Value response;
    if (name.empty() || password.empty())
    {
        response["success"] = false;
        response["error"] = "Both 'name' and 'password' (member ID) fields are required.";
        return response;
    }

    try
    {
        auto dbClient = drogon::app().getDbClient();

        // 1. Query member_details matching name (case-insensitive) and member id (password)
        auto result = dbClient->execSqlSync(
            "SELECT id, teamid, name, role, activity_status FROM member_details "
            "WHERE LOWER(TRIM(name)) = LOWER(TRIM(?)) AND (id = ? OR id = ?);",
            name, password, password
        );

        std::string stationId = "STATION-MAITRI";
        std::string stationName = "Maitri Antarctic Base";
        try
        {
            auto stnResult = dbClient->execSqlSync("SELECT id, name, code FROM stations WHERE is_local = 1 LIMIT 1;");
            if (!stnResult.empty())
            {
                std::string code = stnResult[0]["code"].as<std::string>();
                stationId = (code.rfind("STATION-", 0) == 0) ? code : ("STATION-" + code);
                stationName = stnResult[0]["name"].as<std::string>();
            }
        }
        catch (...) {}

        if (!result.empty())
        {
            auto row = result[0];
            response["success"] = true;
            response["message"] = "Login successful";
            response["user"]["id"] = row["id"].as<std::string>();
            response["user"]["teamid"] = row["teamid"].as<std::string>();
            response["user"]["name"] = row["name"].as<std::string>();
            response["user"]["role"] = row["role"].as<std::string>();
            response["user"]["activity_status"] = row["activity_status"].as<std::string>();
            response["user"]["station"] = stationId;
            response["user"]["station_id"] = stationId;
            response["user"]["station_name"] = stationName;
            return response;
        }

        // 2. Fallback check on users table if registered admin/manager user
        auto userResult = dbClient->execSqlSync(
            "SELECT id, username, full_name, role FROM users "
            "WHERE (LOWER(TRIM(full_name)) = LOWER(TRIM(?)) OR LOWER(TRIM(username)) = LOWER(TRIM(?))) "
            "AND (id = ? OR password_hash = ?);",
            name, name, password, password
        );

        if (!userResult.empty())
        {
            auto userRow = userResult[0];
            response["success"] = true;
            response["message"] = "Login successful";
            response["user"]["id"] = userRow["id"].as<std::string>();
            response["user"]["name"] = userRow["full_name"].as<std::string>();
            response["user"]["role"] = userRow["role"].as<std::string>();
            response["user"]["activity_status"] = "IN";
            response["user"]["station"] = stationId;
            response["user"]["station_id"] = stationId;
            response["user"]["station_name"] = stationName;
            return response;
        }

        // 3. Credentials did not match
        response["success"] = false;
        response["error"] = "Invalid credentials. Name or Member ID (password) does not match database records.";
    }
    catch (const std::exception &e)
    {
        response["success"] = false;
        response["error"] = std::string("Database error during authentication: ") + e.what();
    }

    return response;
}
