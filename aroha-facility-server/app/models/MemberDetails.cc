#include "MemberDetails.h"

namespace drogon_model
{
namespace aroha_facility
{

const std::string MemberDetails::Cols::_id = "id";
const std::string MemberDetails::Cols::_teamid = "teamid";
const std::string MemberDetails::Cols::_name = "name";
const std::string MemberDetails::Cols::_role = "role";
const std::string MemberDetails::Cols::_activity_status = "activity_status";
const std::string MemberDetails::Cols::_created_at = "created_at";
const std::string MemberDetails::Cols::_updated_at = "updated_at";

const std::string MemberDetails::tableName = "member_details";
const std::string MemberDetails::primaryKeyName = "id";
const bool MemberDetails::hasPrimaryKey = true;

MemberDetails::MemberDetails(const drogon::orm::Row &r) noexcept
{
    if (!r["id"].isNull()) id_ = r["id"].as<std::string>();
    if (!r["teamid"].isNull()) teamid_ = r["teamid"].as<std::string>();
    if (!r["name"].isNull()) name_ = r["name"].as<std::string>();
    if (!r["role"].isNull()) role_ = r["role"].as<std::string>();
    if (!r["activity_status"].isNull()) activityStatus_ = r["activity_status"].as<std::string>();
    if (!r["created_at"].isNull()) createdAt_ = r["created_at"].as<std::string>();
    if (!r["updated_at"].isNull()) updatedAt_ = r["updated_at"].as<std::string>();
}

Json::Value MemberDetails::toJson() const
{
    Json::Value ret;
    ret["id"] = id_;
    ret["teamid"] = teamid_;
    ret["name"] = name_;
    ret["role"] = role_;
    ret["activity_status"] = activityStatus_;
    ret["created_at"] = createdAt_;
    ret["updated_at"] = updatedAt_;
    return ret;
}

} // namespace aroha_facility
} // namespace drogon_model
