#include "team_service.h"
#include <drogon/drogon.h>
#include <drogon/orm/Criteria.h>
#include <random>
#include <sstream>

using namespace drogon::orm;
using namespace drogon_model::aroha_facility;

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
    try
    {
        auto dbClient = drogon::app().getDbClient();
        Mapper<TeamDetails> mapper(dbClient);

        auto teams = mapper.orderBy(TeamDetails::Cols::_teamname).findAll();

        Json::Value list(Json::arrayValue);
        for (const auto &item : teams)
        {
            list.append(item.toJson());
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
    Json::Value response;
    try
    {
        auto dbClient = drogon::app().getDbClient();
        Mapper<TeamDetails> mapper(dbClient);

        TeamDetails team;
        std::string id = generateUuid("tm");
        team.setId(id);
        team.setTeamid(dto.teamid);
        team.setTeamname(dto.teamname);
        team.setActiveStatus(dto.active_status);

        mapper.insert(team);

        response["success"] = true;
        response["message"] = "Team created successfully via Drogon ORM";
        response["team"] = team.toJson();
    }
    catch (const std::exception &e)
    {
        response["error"] = e.what();
    }
    return response;
}

Json::Value TeamService::getTeamById(const std::string &teamid)
{
    Json::Value response;
    try
    {
        auto dbClient = drogon::app().getDbClient();
        Mapper<TeamDetails> teamMapper(dbClient);
        Mapper<MemberDetails> memberMapper(dbClient);

        auto teams = teamMapper.findBy(Criteria(TeamDetails::Cols::_teamid, CompareOperator::EQ, teamid));
        if (teams.empty())
        {
            response["error"] = "Team not found";
            return response;
        }

        TeamDetails team = teams[0];
        auto members = memberMapper.orderBy(MemberDetails::Cols::_name)
                           .findBy(Criteria(MemberDetails::Cols::_teamid, CompareOperator::EQ, teamid));

        Json::Value memberList(Json::arrayValue);
        for (const auto &mem : members)
        {
            memberList.append(mem.toJson());
        }

        response["success"] = true;
        response["team"] = team.toJson();
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
    Json::Value response;
    try
    {
        auto dbClient = drogon::app().getDbClient();
        Mapper<MemberDetails> mapper(dbClient);

        auto members = mapper.orderBy(MemberDetails::Cols::_name)
                           .findBy(Criteria(MemberDetails::Cols::_teamid, CompareOperator::EQ, teamid));

        Json::Value memberList(Json::arrayValue);
        for (const auto &mem : members)
        {
            memberList.append(mem.toJson());
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
    Json::Value response;
    try
    {
        auto dbClient = drogon::app().getDbClient();
        Mapper<MemberDetails> mapper(dbClient);

        MemberDetails member;
        std::string id = generateUuid("mem");
        member.setId(id);
        member.setTeamid(dto.teamid);
        member.setName(dto.name);
        member.setRole(dto.role);
        member.setActivityStatus(dto.activity_status);

        mapper.insert(member);

        response["success"] = true;
        response["message"] = "Member added to team successfully via Drogon ORM";
        response["member"] = member.toJson();
    }
    catch (const std::exception &e)
    {
        response["error"] = e.what();
    }
    return response;
}

Json::Value TeamService::getAllMembers(const std::string &activityStatus)
{
    Json::Value response;
    try
    {
        auto dbClient = drogon::app().getDbClient();
        Mapper<MemberDetails> mapper(dbClient);

        std::vector<MemberDetails> members;
        if (!activityStatus.empty())
        {
            members = mapper.orderBy(MemberDetails::Cols::_name)
                          .findBy(Criteria(MemberDetails::Cols::_activity_status, CompareOperator::EQ, activityStatus));
        }
        else
        {
            members = mapper.orderBy(MemberDetails::Cols::_name).findAll();
        }

        Json::Value memberList(Json::arrayValue);
        for (const auto &mem : members)
        {
            memberList.append(mem.toJson());
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
