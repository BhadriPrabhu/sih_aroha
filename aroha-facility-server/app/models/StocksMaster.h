#pragma once

#include <drogon/orm/Model.h>
#include <drogon/orm/Row.h>
#include <json/json.h>
#include <string>
#include <memory>

namespace drogon_model
{
namespace aroha_facility
{

class StocksMaster
{
public:
    struct Cols
    {
        static const std::string _id;
        static const std::string _station_id;
        static const std::string _category;
        static const std::string _name;
        static const std::string _stock_available;
        static const std::string _stock_consumed;
        static const std::string _present_stock;
        static const std::string _criticality_rate;
        static const std::string _created_at;
        static const std::string _updated_at;
    };

    const static std::string tableName;
    const static std::string primaryKeyName;
    const static bool hasPrimaryKey;

    StocksMaster() = default;
    explicit StocksMaster(const drogon::orm::Row &r) noexcept;

    // Getters
    const std::string &getValueOfId() const noexcept { return id_; }
    const std::string &getValueOfStationId() const noexcept { return stationId_; }
    const std::string &getValueOfCategory() const noexcept { return category_; }
    const std::string &getValueOfName() const noexcept { return name_; }
    double getValueOfStockAvailable() const noexcept { return stockAvailable_; }
    double getValueOfStockConsumed() const noexcept { return stockConsumed_; }
    double getValueOfPresentStock() const noexcept { return presentStock_; }
    double getValueOfCriticalityRate() const noexcept { return criticalityRate_; }
    const std::string &getValueOfCreatedAt() const noexcept { return createdAt_; }
    const std::string &getValueOfUpdatedAt() const noexcept { return updatedAt_; }

    // Setters
    void setId(const std::string &id) noexcept { id_ = id; }
    void setStationId(const std::string &stationId) noexcept { stationId_ = stationId; }
    void setCategory(const std::string &category) noexcept { category_ = category; }
    void setName(const std::string &name) noexcept { name_ = name; }
    void setStockAvailable(double available) noexcept { stockAvailable_ = available; }
    void setStockConsumed(double consumed) noexcept { stockConsumed_ = consumed; }
    void setPresentStock(double present) noexcept { presentStock_ = present; }
    void setCriticalityRate(double rate) noexcept { criticalityRate_ = rate; }
    void setCreatedAt(const std::string &created) noexcept { createdAt_ = created; }
    void setUpdatedAt(const std::string &updated) noexcept { updatedAt_ = updated; }

    Json::Value toJson() const;

private:
    std::string id_;
    std::string stationId_;
    std::string category_;
    std::string name_;
    double stockAvailable_{0.0};
    double stockConsumed_{0.0};
    double presentStock_{0.0};
    double criticalityRate_{0.5};
    std::string createdAt_;
    std::string updatedAt_;
};

} // namespace aroha_facility
} // namespace drogon_model
