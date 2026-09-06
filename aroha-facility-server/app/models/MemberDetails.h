#pragma once

#include <drogon/orm/Model.h>
#include <drogon/orm/Row.h>
#include <json/json.h>
#include <string>

namespace drogon_model
{
namespace aroha_facility
{

class MemberDetails
{
public:
    struct Cols
    {
        static const std::string _id;
        static const std::string _teamid;
        static const std::string _name;
        static const std::string _role;
        static const std::string _activity_status;
        static const std::string _created_at;
        static const std::string _updated_at;
    };

    const static std::string tableName;
    const static std::string primaryKeyName;
    const static bool hasPrimaryKey;

    MemberDetails() = default;
    explicit MemberDetails(const drogon::orm::Row &r) noexcept;

    // Getters
    const std::string &getValueOfId() const noexcept { return id_; }
    const std::string &getValueOfTeamid() const noexcept { return teamid_; }
    const std::string &getValueOfName() const noexcept { return name_; }
    const std::string &getValueOfRole() const noexcept { return role_; }
    const std::string &getValueOfActivityStatus() const noexcept { return activityStatus_; }
    const std::string &getValueOfCreatedAt() const noexcept { return createdAt_; }
    const std::string &getValueOfUpdatedAt() const noexcept { return updatedAt_; }

    // Setters
    void setId(const std::string &id) noexcept { id_ = id; }
    void setTeamid(const std::string &teamid) noexcept { teamid_ = teamid; }
    void setName(const std::string &name) noexcept { name_ = name; }
    void setRole(const std::string &role) noexcept { role_ = role; }
    void setActivityStatus(const std::string &status) noexcept { activityStatus_ = status; }
    void setCreatedAt(const std::string &created) noexcept { createdAt_ = created; }
    void setUpdatedAt(const std::string &updated) noexcept { updatedAt_ = updated; }

    Json::Value toJson() const;

private:
    std::string id_;
    std::string teamid_;
    std::string name_;
    std::string role_;
    std::string activityStatus_{"ON_STATION"};
    std::string createdAt_;
    std::string updatedAt_;
};

} // namespace aroha_facility
} // namespace drogon_model
