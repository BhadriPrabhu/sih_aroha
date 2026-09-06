#pragma once

#include <drogon/orm/Model.h>
#include <drogon/orm/Row.h>
#include <json/json.h>
#include <string>

namespace drogon_model
{
namespace aroha_facility
{

class StockLogs
{
public:
    struct Cols
    {
        static const std::string _id;
        static const std::string _stock_id;
        static const std::string _action;
        static const std::string _quantity;
        static const std::string _notes;
        static const std::string _logged_at;
    };

    const static std::string tableName;
    const static std::string primaryKeyName;
    const static bool hasPrimaryKey;

    StockLogs() = default;
    explicit StockLogs(const drogon::orm::Row &r) noexcept;

    // Getters
    const std::string &getValueOfId() const noexcept { return id_; }
    const std::string &getValueOfStockId() const noexcept { return stockId_; }
    const std::string &getValueOfAction() const noexcept { return action_; }
    double getValueOfQuantity() const noexcept { return quantity_; }
    const std::string &getValueOfNotes() const noexcept { return notes_; }
    const std::string &getValueOfLoggedAt() const noexcept { return loggedAt_; }

    // Setters
    void setId(const std::string &id) noexcept { id_ = id; }
    void setStockId(const std::string &stockId) noexcept { stockId_ = stockId; }
    void setAction(const std::string &action) noexcept { action_ = action; }
    void setQuantity(double qty) noexcept { quantity_ = qty; }
    void setNotes(const std::string &notes) noexcept { notes_ = notes; }
    void setLoggedAt(const std::string &loggedAt) noexcept { loggedAt_ = loggedAt; }

    Json::Value toJson() const;

private:
    std::string id_;
    std::string stockId_;
    std::string action_;
    double quantity_{0.0};
    std::string notes_;
    std::string loggedAt_;
};

} // namespace aroha_facility
} // namespace drogon_model
