#include "stock_service.h"
#include <drogon/drogon.h>
#include <drogon/orm/Criteria.h>
#include <random>
#include <sstream>

using namespace drogon::orm;
using namespace drogon_model::aroha_facility;

std::string StockService::generateUuid()
{
    static std::random_device rd;
    static std::mt19937 gen(rd());
    static std::uniform_int_distribution<> dis(0, 15);
    std::stringstream ss;
    ss << "stk-";
    for (int i = 0; i < 8; ++i)
    {
        ss << std::hex << dis(gen);
    }
    return ss.str();
}

Json::Value StockService::createStock(const CreateStockDto &dto)
{
    Json::Value response;
    try
    {
        auto dbClient = drogon::app().getDbClient();
        Mapper<StocksMaster> mapper(dbClient);

        StocksMaster stock;
        std::string stockId = generateUuid();
        double initialAvailable = dto.stock_available;
        double initialConsumed = 0.0;
        double presentStock = initialAvailable - initialConsumed;

        stock.setId(stockId);
        stock.setStationId(dto.station_id);
        stock.setCategory(dto.category);
        stock.setName(dto.name);
        stock.setStockAvailable(initialAvailable);
        stock.setStockConsumed(initialConsumed);
        stock.setPresentStock(presentStock);
        stock.setCriticalityRate(dto.criticality_rate);

        mapper.insert(stock);

        response["success"] = true;
        response["message"] = "Stock record created successfully via Drogon ORM";
        response["stock"] = stock.toJson();
    }
    catch (const std::exception &e)
    {
        response["error"] = e.what();
    }
    return response;
}

Json::Value StockService::logStock(const LogStockDto &dto)
{
    Json::Value response;
    try
    {
        auto dbClient = drogon::app().getDbClient();
        Mapper<StocksMaster> masterMapper(dbClient);
        Mapper<StockLogs> logMapper(dbClient);

        StocksMaster stock = masterMapper.findByPrimaryKey(dto.stock_id);

        double newAvailable = stock.getValueOfStockAvailable();
        double newConsumed = stock.getValueOfStockConsumed();

        if (dto.action == "ADDED")
        {
            newAvailable += dto.quantity;
        }
        else if (dto.action == "USED")
        {
            newConsumed += dto.quantity;
        }
        else
        {
            response["error"] = "Invalid action. Must be 'ADDED' or 'USED'";
            return response;
        }

        double newPresent = newAvailable - newConsumed;
        stock.setStockAvailable(newAvailable);
        stock.setStockConsumed(newConsumed);
        stock.setPresentStock(newPresent);

        masterMapper.update(stock);

        // Insert audit log
        StockLogs logEntry;
        static std::random_device rd;
        static std::mt19937 gen(rd());
        static std::uniform_int_distribution<> dis(0, 15);
        std::stringstream ss;
        ss << "log-";
        for (int i = 0; i < 8; ++i) ss << std::hex << dis(gen);

        logEntry.setId(ss.str());
        logEntry.setStockId(dto.stock_id);
        logEntry.setAction(dto.action);
        logEntry.setQuantity(dto.quantity);
        logEntry.setNotes(dto.notes);

        logMapper.insert(logEntry);

        response["success"] = true;
        response["message"] = "Stock logged successfully via Drogon ORM (" + dto.action + ")";
        response["stock"] = stock.toJson();
    }
    catch (const std::exception &e)
    {
        response["error"] = e.what();
    }
    return response;
}

Json::Value StockService::getAllStocks()
{
    Json::Value response;
    try
    {
        auto dbClient = drogon::app().getDbClient();
        Mapper<StocksMaster> mapper(dbClient);

        auto stocks = mapper.orderBy(StocksMaster::Cols::_name).findAll();

        Json::Value list(Json::arrayValue);
        for (const auto &item : stocks)
        {
            list.append(item.toJson());
        }

        response["success"] = true;
        response["count"] = list.size();
        response["stocks"] = list;
    }
    catch (const std::exception &e)
    {
        response["error"] = e.what();
    }
    return response;
}

Json::Value StockService::getStockById(const std::string &id)
{
    Json::Value response;
    try
    {
        auto dbClient = drogon::app().getDbClient();
        Mapper<StocksMaster> masterMapper(dbClient);
        Mapper<StockLogs> logMapper(dbClient);

        StocksMaster stock = masterMapper.findByPrimaryKey(id);

        auto logs = logMapper.findBy(Criteria(StockLogs::Cols::_stock_id, CompareOperator::EQ, id));

        Json::Value logList(Json::arrayValue);
        for (const auto &logItem : logs)
        {
            logList.append(logItem.toJson());
        }

        response["success"] = true;
        response["stock"] = stock.toJson();
        response["logs"] = logList;
    }
    catch (const std::exception &e)
    {
        response["error"] = "Stock item not found: " + std::string(e.what());
    }
    return response;
}

Json::Value StockService::getFilteredStocks(const std::string &category, const std::string &stationId)
{
    Json::Value response;
    try
    {
        auto dbClient = drogon::app().getDbClient();
        Mapper<StocksMaster> mapper(dbClient);

        Criteria criteria;
        bool hasCriteria = false;

        if (!category.empty())
        {
            criteria = Criteria(StocksMaster::Cols::_category, CompareOperator::EQ, category);
            hasCriteria = true;
        }

        if (!stationId.empty())
        {
            Criteria stationCrit(StocksMaster::Cols::_station_id, CompareOperator::EQ, stationId);
            if (hasCriteria)
            {
                criteria = criteria && stationCrit;
            }
            else
            {
                criteria = stationCrit;
                hasCriteria = true;
            }
        }

        std::vector<StocksMaster> stocks;
        if (hasCriteria)
        {
            stocks = mapper.orderBy(StocksMaster::Cols::_name).findBy(criteria);
        }
        else
        {
            stocks = mapper.orderBy(StocksMaster::Cols::_name).findAll();
        }

        Json::Value list(Json::arrayValue);
        for (const auto &item : stocks)
        {
            list.append(item.toJson());
        }

        response["success"] = true;
        response["filter"]["category"] = category;
        response["filter"]["station_id"] = stationId;
        response["count"] = list.size();
        response["stocks"] = list;
    }
    catch (const std::exception &e)
    {
        response["error"] = e.what();
    }
    return response;
}

Json::Value StockService::getStocksByCategory(const std::string &category)
{
    return getFilteredStocks(category, "");
}

Json::Value StockService::getAllCategories(const std::string &stationId)
{
    Json::Value response;
    try
    {
        auto dbClient = drogon::app().getDbClient();
        Mapper<StocksMaster> mapper(dbClient);

        std::vector<StocksMaster> stocks;
        if (!stationId.empty())
        {
            stocks = mapper.findBy(Criteria(StocksMaster::Cols::_station_id, CompareOperator::EQ, stationId));
        }
        else
        {
            stocks = mapper.findAll();
        }

        std::set<std::string> categorySet;
        for (const auto &item : stocks)
        {
            if (!item.getValueOfCategory().empty())
            {
                categorySet.insert(item.getValueOfCategory());
            }
        }

        Json::Value categories(Json::arrayValue);
        for (const auto &cat : categorySet)
        {
            categories.append(cat);
        }

        response["success"] = true;
        response["count"] = categories.size();
        response["categories"] = categories;
    }
    catch (const std::exception &e)
    {
        response["error"] = e.what();
    }
    return response;
}
