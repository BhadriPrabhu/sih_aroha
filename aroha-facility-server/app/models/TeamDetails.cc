#include "TeamDetails.h"

namespace drogon_model
{
namespace aroha_facility
{

const std::string TeamDetails::Cols::_id = "id";
const std::string TeamDetails::Cols::_teamid = "teamid";
const std::string TeamDetails::Cols::_teamname = "teamname";
const std::string TeamDetails::Cols::_active_status = "active_status";
const std::string TeamDetails::Cols::_created_at = "created_at";
const std::string TeamDetails::Cols::_updated_at = "updated_at";

const std::string TeamDetails::tableName = "team_details";
const std::string TeamDetails::primaryKeyName = "id";
const bool TeamDetails::hasPrimaryKey = true;

TeamDetails::TeamDetails(const drogon::orm::Row &r) noexcept
{
    if (!r["id"].isNull()) id_ = r["id"].as<std::string>();
    if (!r["teamid"].isNull()) teamid_ = r["teamid"].as<std::string>();
    if (!r["teamname"].isNull()) teamname_ = r["teamname"].as<std::string>();
    if (!r["active_status"].isNull()) activeStatus_ = r["active_status"].as<std::string>();
    if (!r["created_at"].isNull()) createdAt_ = r["created_at"].as<std::string>();
    if (!r["updated_at"].isNull()) updatedAt_ = r["updated_at"].as<std::string>();
}

Json::Value TeamDetails::toJson() const
{
    Json::Value ret;
    ret["id"] = id_;
    ret["teamid"] = teamid_;
    ret["teamname"] = teamname_;
    ret["active_status"] = activeStatus_;
    ret["created_at"] = createdAt_;
    ret["updated_at"] = updatedAt_;
    return ret;
}

} // namespace aroha_facility
} // namespace drogon_model
