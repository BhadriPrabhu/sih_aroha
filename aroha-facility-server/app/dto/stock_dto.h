#pragma once

#include <json/json.h>
#include <string>

struct CreateStockDto
{
    std::string station_id;
    std::string category;
    std::string name;
    double stock_available{0.0};
    double criticality_rate{0.5};
    double essentiality_score{0.5};
    double lead_time_days{30.0};

    static CreateStockDto fromJson(const Json::Value &json)
    {
        CreateStockDto dto;
        dto.station_id = json.get("station_id", "stn-maitri").asString();
        dto.category = json.get("category", "").asString();
        dto.name = json.get("name", "").asString();
        dto.stock_available = json.get("stock_available", 0.0).asDouble();
        dto.criticality_rate = json.get("criticality_rate", 0.5).asDouble();
        dto.essentiality_score = json.get("essentiality_score", 0.5).asDouble();
        dto.lead_time_days = json.get("lead_time_days", 30.0).asDouble();
        return dto;
    }
};

struct LogStockDto
{
    std::string stock_id;
    std::string action; // "ADDED" or "USED"
    double quantity{0.0};
    std::string notes;

    static LogStockDto fromJson(const Json::Value &json)
    {
        LogStockDto dto;
        dto.stock_id = json.get("stock_id", "").asString();
        dto.action = json.get("action", "").asString();
        dto.quantity = json.get("quantity", 0.0).asDouble();
        dto.notes = json.get("notes", "").asString();
        return dto;
    }
};
