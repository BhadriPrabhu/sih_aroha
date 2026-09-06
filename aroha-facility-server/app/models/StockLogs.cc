#include "StockLogs.h"

namespace drogon_model
{
namespace aroha_facility
{

const std::string StockLogs::Cols::_id = "id";
const std::string StockLogs::Cols::_stock_id = "stock_id";
const std::string StockLogs::Cols::_action = "action";
const std::string StockLogs::Cols::_quantity = "quantity";
const std::string StockLogs::Cols::_notes = "notes";
const std::string StockLogs::Cols::_logged_at = "logged_at";

const std::string StockLogs::tableName = "stock_logs";
const std::string StockLogs::primaryKeyName = "id";
const bool StockLogs::hasPrimaryKey = true;

StockLogs::StockLogs(const drogon::orm::Row &r) noexcept
{
    if (!r["id"].isNull()) id_ = r["id"].as<std::string>();
    if (!r["stock_id"].isNull()) stockId_ = r["stock_id"].as<std::string>();
    if (!r["action"].isNull()) action_ = r["action"].as<std::string>();
    if (!r["quantity"].isNull()) quantity_ = r["quantity"].as<double>();
    if (!r["notes"].isNull()) notes_ = r["notes"].as<std::string>();
    if (!r["logged_at"].isNull()) loggedAt_ = r["logged_at"].as<std::string>();
}

Json::Value StockLogs::toJson() const
{
    Json::Value ret;
    ret["id"] = id_;
    ret["stock_id"] = stockId_;
    ret["action"] = action_;
    ret["quantity"] = quantity_;
    ret["notes"] = notes_;
    ret["logged_at"] = loggedAt_;
    return ret;
}

} // namespace aroha_facility
} // namespace drogon_model
