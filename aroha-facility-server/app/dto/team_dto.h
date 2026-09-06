#pragma once

#include <json/json.h>
#include <string>

struct CreateTeamDto
{
    std::string teamid;
    std::string teamname;
    std::string active_status{"ACTIVE"};

    static CreateTeamDto fromJson(const Json::Value &json)
    {
        CreateTeamDto dto;
        dto.teamid = json.get("teamid", "").asString();
        dto.teamname = json.get("teamname", "").asString();
        dto.active_status = json.get("active_status", "ACTIVE").asString();
        return dto;
    }
};

struct CreateMemberDto
{
    std::string teamid;
    std::string name;
    std::string role;
    std::string activity_status{"ON_STATION"};

    static CreateMemberDto fromJson(const Json::Value &json)
    {
        CreateMemberDto dto;
        dto.teamid = json.get("teamid", "").asString();
        dto.name = json.get("name", "").asString();
        dto.role = json.get("role", "").asString();
        dto.activity_status = json.get("activity_status", "ON_STATION").asString();
        return dto;
    }
};
