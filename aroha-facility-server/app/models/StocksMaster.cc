#include "StocksMaster.h"

namespace drogon_model
{
namespace aroha_facility
{

const std::string StocksMaster::Cols::_id = "id";
const std::string StocksMaster::Cols::_station_id = "station_id";
const std::string StocksMaster::Cols::_category = "category";
const std::string StocksMaster::Cols::_name = "name";
const std::string StocksMaster::Cols::_stock_available = "stock_available";
const std::string StocksMaster::Cols::_stock_consumed = "stock_consumed";
const std::string StocksMaster::Cols::_present_stock = "present_stock";
const std::string StocksMaster::Cols::_criticality_rate = "criticality_rate";
const std::string StocksMaster::Cols::_created_at = "created_at";
const std::string StocksMaster::Cols::_updated_at = "updated_at";

const std::string StocksMaster::tableName = "stocks_master";
const std::string StocksMaster::primaryKeyName = "id";
const bool StocksMaster::hasPrimaryKey = true;

StocksMaster::StocksMaster(const drogon::orm::Row &r) noexcept
{
    if (!r["id"].isNull()) id_ = r["id"].as<std::string>();
    if (!r["station_id"].isNull()) stationId_ = r["station_id"].as<std::string>();
    if (!r["category"].isNull()) category_ = r["category"].as<std::string>();
    if (!r["name"].isNull()) name_ = r["name"].as<std::string>();
    if (!r["stock_available"].isNull()) stockAvailable_ = r["stock_available"].as<double>();
    if (!r["stock_consumed"].isNull()) stockConsumed_ = r["stock_consumed"].as<double>();
    if (!r["present_stock"].isNull()) presentStock_ = r["present_stock"].as<double>();
    if (!r["criticality_rate"].isNull()) criticalityRate_ = r["criticality_rate"].as<double>();
    if (!r["created_at"].isNull()) createdAt_ = r["created_at"].as<std::string>();
    if (!r["updated_at"].isNull()) updatedAt_ = r["updated_at"].as<std::string>();
}

Json::Value StocksMaster::toJson() const
{
    Json::Value ret;
    ret["id"] = id_;
    ret["station_id"] = stationId_;
    ret["category"] = category_;
    ret["name"] = name_;
    ret["stock_available"] = stockAvailable_;
    ret["stock_consumed"] = stockConsumed_;
    ret["present_stock"] = presentStock_;
    ret["criticality_rate"] = criticalityRate_;
    ret["created_at"] = createdAt_;
    ret["updated_at"] = updatedAt_;
    return ret;
}

} // namespace aroha_facility
} // namespace drogon_model
