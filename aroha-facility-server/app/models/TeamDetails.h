#pragma once

#include <drogon/orm/Model.h>
#include <drogon/orm/Row.h>
#include <json/json.h>
#include <string>

namespace drogon_model
{
namespace aroha_facility
{

class TeamDetails
{
public:
    struct Cols
    {
        static const std::string _id;
        static const std::string _teamid;
        static const std::string _teamname;
        static const std::string _active_status;
        static const std::string _created_at;
        static const std::string _updated_at;
    };

    const static std::string tableName;
    const static std::string primaryKeyName;
    const static bool hasPrimaryKey;

    TeamDetails() = default;
    explicit TeamDetails(const drogon::orm::Row &r) noexcept;

    // Getters
    const std::string &getValueOfId() const noexcept { return id_; }
    const std::string &getValueOfTeamid() const noexcept { return teamid_; }
    const std::string &getValueOfTeamname() const noexcept { return teamname_; }
    const std::string &getValueOfActiveStatus() const noexcept { return activeStatus_; }
    const std::string &getValueOfCreatedAt() const noexcept { return createdAt_; }
    const std::string &getValueOfUpdatedAt() const noexcept { return updatedAt_; }

    // Setters
    void setId(const std::string &id) noexcept { id_ = id; }
    void setTeamid(const std::string &teamid) noexcept { teamid_ = teamid; }
    void setTeamname(const std::string &name) noexcept { teamname_ = name; }
    void setActiveStatus(const std::string &status) noexcept { activeStatus_ = status; }
    void setCreatedAt(const std::string &created) noexcept { createdAt_ = created; }
    void setUpdatedAt(const std::string &updated) noexcept { updatedAt_ = updated; }

    Json::Value toJson() const;

private:
    std::string id_;
    std::string teamid_;
    std::string teamname_;
    std::string activeStatus_{"ACTIVE"};
    std::string createdAt_;
    std::string updatedAt_;
};

} // namespace aroha_facility
} // namespace drogon_model
