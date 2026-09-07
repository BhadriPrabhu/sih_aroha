#include "sync_plugin.h"
#include <drogon/drogon.h>
#include <drogon/HttpClient.h>
#include <trantor/net/EventLoop.h>
#include <random>
#include <sstream>
#include <chrono>
#include <cstdlib>
#include <cstdint>

void SyncPlugin::initAndStart(const Json::Value &config)
{
    if (const char *envUrl = std::getenv("REMOTE_SERVER_URL"))
    {
        if (std::string(envUrl).length() > 0)
        {
            remoteServerUrl_ = envUrl;
        }
    }
    else if (config.isMember("remote_server_url") && config["remote_server_url"].isString())
    {
        remoteServerUrl_ = config["remote_server_url"].asString();
    }

    if (config.isMember("station_id") && config["station_id"].isString())
    {
        stationId_ = config["station_id"].asString();
    }
    if (config.isMember("sync_interval_seconds") && config["sync_interval_seconds"].isUInt64())
    {
        syncIntervalSeconds_ = config["sync_interval_seconds"].asUInt64();
    }

    LOG_INFO << "SyncPlugin initialized. Primary Remote Server URL: " << remoteServerUrl_ 
             << " | Station ID: " << stationId_ 
             << " | Polling Interval: " << syncIntervalSeconds_ << "s";

    // Schedule periodic polling task using Drogon app framework
    drogon::app().getLoop()->runEvery(static_cast<double>(syncIntervalSeconds_), [this]() {
        performSyncCycle();
    });
}

void SyncPlugin::shutdown()
{
    LOG_INFO << "SyncPlugin shutting down cleanly.";
}

static void ensureAllSyncTablesExist(const drogon::orm::DbClientPtr &dbClient)
{
    if (!dbClient) return;
    try
    {
        dbClient->execSqlSync(
            "CREATE TABLE IF NOT EXISTS stocks_master ("
            "id TEXT PRIMARY KEY, "
            "station_id TEXT NOT NULL DEFAULT 'stn-maitri', "
            "category TEXT NOT NULL, "
            "name TEXT NOT NULL, "
            "stock_available REAL NOT NULL DEFAULT 0, "
            "stock_consumed REAL NOT NULL DEFAULT 0, "
            "present_stock REAL NOT NULL DEFAULT 0, "
            "criticality_rate REAL NOT NULL DEFAULT 0.5, "
            "criticality_status TEXT DEFAULT 'MEDIUM', "
            "is_synced INTEGER DEFAULT 0, "
            "created_at DATETIME DEFAULT CURRENT_TIMESTAMP, "
            "updated_at DATETIME DEFAULT CURRENT_TIMESTAMP);"
        );
        dbClient->execSqlSync(
            "CREATE TABLE IF NOT EXISTS stock_logs ("
            "id TEXT PRIMARY KEY, "
            "stock_id TEXT NOT NULL REFERENCES stocks_master(id) ON DELETE CASCADE, "
            "action TEXT NOT NULL, "
            "quantity REAL NOT NULL, "
            "notes TEXT, "
            "is_synced INTEGER DEFAULT 0, "
            "logged_at DATETIME DEFAULT CURRENT_TIMESTAMP);"
        );
        dbClient->execSqlSync(
            "CREATE TABLE IF NOT EXISTS team_details ("
            "id TEXT PRIMARY KEY, "
            "teamid TEXT NOT NULL UNIQUE, "
            "teamname TEXT NOT NULL, "
            "active_status TEXT NOT NULL DEFAULT 'ACTIVE', "
            "is_synced INTEGER DEFAULT 0, "
            "created_at DATETIME DEFAULT CURRENT_TIMESTAMP, "
            "updated_at DATETIME DEFAULT CURRENT_TIMESTAMP);"
        );
        dbClient->execSqlSync(
            "CREATE TABLE IF NOT EXISTS member_details ("
            "id TEXT PRIMARY KEY, "
            "teamid TEXT NOT NULL REFERENCES team_details(teamid) ON DELETE CASCADE, "
            "name TEXT NOT NULL, "
            "role TEXT NOT NULL, "
            "activity_status TEXT NOT NULL DEFAULT 'ON_STATION', "
            "is_synced INTEGER DEFAULT 0, "
            "created_at DATETIME DEFAULT CURRENT_TIMESTAMP, "
            "updated_at DATETIME DEFAULT CURRENT_TIMESTAMP);"
        );
    }
    catch (const std::exception &e)
    {
        LOG_WARN << "[SyncPlugin] Exception ensuring sync tables exist: " << e.what();
    }
}

void SyncPlugin::performSyncCycle()
{
    bool expected = false;
    if (!isSyncing_.compare_exchange_strong(expected, true))
    {
        return; // Already in progress
    }

    std::string targetUrl = remoteServerUrl_;

    auto client = drogon::HttpClient::newHttpClient(targetUrl);
    auto req = drogon::HttpRequest::newHttpRequest();
    req->setMethod(drogon::Get);
    req->setPath("/api/v1/remote/stations");

    client->sendRequest(req, [this, targetUrl, client](drogon::ReqResult result, const drogon::HttpResponsePtr &resp) {
        if (result != drogon::ReqResult::Ok || !resp || resp->getStatusCode() != drogon::k200OK)
        {
            // If primary target 127.0.0.1 failed, attempt host.docker.internal fallback for Docker containers
            if (targetUrl.find("127.0.0.1") != std::string::npos || targetUrl.find("localhost") != std::string::npos)
            {
                std::string dockerFallbackUrl = "http://host.docker.internal:8081";
                auto fallbackClient = drogon::HttpClient::newHttpClient(dockerFallbackUrl);
                auto fallbackReq = drogon::HttpRequest::newHttpRequest();
                fallbackReq->setMethod(drogon::Get);
                fallbackReq->setPath("/api/v1/remote/stations");

                fallbackClient->sendRequest(fallbackReq, [this, dockerFallbackUrl](drogon::ReqResult fbResult, const drogon::HttpResponsePtr &fbResp) {
                    if (fbResult == drogon::ReqResult::Ok && fbResp && fbResp->getStatusCode() == drogon::k200OK)
                    {
                        LOG_INFO << "[SyncPlugin] Connected to remote server via Docker host gateway: " << dockerFallbackUrl;
                        remoteServerUrl_ = dockerFallbackUrl; // Auto-switch to working docker gateway URL
                    }
                    else
                    {
                        LOG_DEBUG << "[SyncPlugin] Remote server unreachable (" << remoteServerUrl_ << " / " << dockerFallbackUrl << "). Working in offline mode...";
                    }
                    isSyncing_.store(false);
                });
                return;
            }

            LOG_DEBUG << "[SyncPlugin] Remote server unreachable (" << targetUrl << "). Working in offline mode...";
            isSyncing_.store(false);
            return;
        }

        // Internet/Remote server connectivity detected! Gather unprocessed data
        try
        {
            auto dbClient = drogon::app().getDbClient();
            if (!dbClient)
            {
                isSyncing_.store(false);
                return;
            }

            ensureAllSyncTablesExist(dbClient);

            std::vector<std::string> stockIds;
            std::vector<std::string> logIds;
            std::vector<std::string> teamIds;
            std::vector<std::string> memberIds;

            Json::Value payload;
            payload["station_id"] = stationId_;

            auto nowMs = std::chrono::duration_cast<std::chrono::milliseconds>(
                std::chrono::system_clock::now().time_since_epoch()).count();
            payload["sync_batch_id"] = "batch-" + std::to_string(nowMs);

            // 1. Fetch Unsynced Stocks (with criticality_rate)
            Json::Value stocksArray(Json::arrayValue);
            auto stockRows = dbClient->execSqlSync(
                "SELECT id, station_id, category, name, stock_available, criticality_rate "
                "FROM stocks_master WHERE is_synced = 0 OR is_synced IS NULL;"
            );
            for (const auto &row : stockRows)
            {
                std::string stkId = row["id"].as<std::string>();
                stockIds.push_back(stkId);

                double stockAvailableDouble = row["stock_available"].as<double>();
                double criticalityRateDouble = row["criticality_rate"].as<double>();

                Json::Value item;
                item["stock_id"] = stkId;
                item["item_code"] = stkId;
                item["item_name"] = row["name"].as<std::string>();
                item["category"] = row["category"].as<std::string>();
                item["total_quantity"] = static_cast<int>(stockAvailableDouble);
                item["min_required_quantity"] = 5;
                item["criticality_score"] = criticalityRateDouble;
                stocksArray.append(item);
            }
            payload["stocks"] = stocksArray;

            // 2. Fetch Unsynced Stock Logs
            Json::Value logsArray(Json::arrayValue);
            auto logRows = dbClient->execSqlSync(
                "SELECT id, stock_id, action, quantity, notes "
                "FROM stock_logs WHERE is_synced = 0 OR is_synced IS NULL;"
            );
            for (const auto &row : logRows)
            {
                std::string lgId = row["id"].as<std::string>();
                logIds.push_back(lgId);

                double qtyDouble = row["quantity"].as<double>();
                std::string notesStr = row["notes"].as<std::string>();

                Json::Value logItem;
                logItem["log_id"] = lgId;
                logItem["stock_id"] = row["stock_id"].as<std::string>();
                logItem["operation_type"] = row["action"].as<std::string>();
                logItem["change_qty"] = static_cast<int>(qtyDouble);
                logItem["reason"] = notesStr.empty() ? "Logged action" : notesStr;
                logItem["logged_by"] = "Station Operator";
                logsArray.append(logItem);
            }
            payload["stock_logs"] = logsArray;

            // 3. Fetch Unsynced Team Details
            Json::Value teamsArray(Json::arrayValue);
            auto teamRows = dbClient->execSqlSync(
                "SELECT id, teamid, teamname, active_status "
                "FROM team_details WHERE is_synced = 0 OR is_synced IS NULL;"
            );
            for (const auto &row : teamRows)
            {
                std::string tId = row["id"].as<std::string>();
                teamIds.push_back(tId);

                Json::Value teamItem;
                teamItem["teamid"] = row["teamid"].as<std::string>();
                teamItem["teamname"] = row["teamname"].as<std::string>();
                teamItem["active_status"] = row["active_status"].as<std::string>();
                teamsArray.append(teamItem);
            }
            payload["teams"] = teamsArray;

            // 4. Fetch Unsynced Personnel Movement Records (member_details)
            Json::Value membersArray(Json::arrayValue);
            auto memberRows = dbClient->execSqlSync(
                "SELECT id, teamid, name, role, activity_status "
                "FROM member_details WHERE is_synced = 0 OR is_synced IS NULL;"
            );
            for (const auto &row : memberRows)
            {
                std::string mId = row["id"].as<std::string>();
                memberIds.push_back(mId);

                Json::Value memberItem;
                memberItem["memberid"] = mId;
                memberItem["teamid"] = row["teamid"].as<std::string>();
                memberItem["fullname"] = row["name"].as<std::string>();
                memberItem["role"] = row["role"].as<std::string>();
                memberItem["status"] = row["activity_status"].as<std::string>();
                membersArray.append(memberItem);
            }
            payload["members"] = membersArray;

            size_t totalUnsynced = stockIds.size() + logIds.size() + teamIds.size() + memberIds.size();
            if (totalUnsynced == 0)
            {
                LOG_DEBUG << "[SyncPlugin] Connectivity online. All local records are up to date.";
                isSyncing_.store(false);
                return;
            }

            LOG_INFO << "[SyncPlugin] Transmitting delta sync payload (" << totalUnsynced 
                     << " records) to " << remoteServerUrl_ << "/api/v1/remote/sync/delta ...";

            // Post delta sync payload to remote server
            auto syncReq = drogon::HttpRequest::newHttpJsonRequest(payload);
            syncReq->setMethod(drogon::Post);
            syncReq->setPath("/api/v1/remote/sync/delta");

            client->sendRequest(syncReq, [this, stockIds, logIds, teamIds, memberIds, totalUnsynced]
                (drogon::ReqResult syncRes, const drogon::HttpResponsePtr &syncResp) {
                if (syncRes == drogon::ReqResult::Ok && syncResp && syncResp->getStatusCode() == drogon::k200OK)
                {
                    LOG_INFO << "[SyncPlugin] Delta synchronization successful! Marking " 
                             << totalUnsynced << " local records as SYNCED.";
                    markRecordsAsSynced(stockIds, logIds, teamIds, memberIds);
                }
                else
                {
                    LOG_WARN << "[SyncPlugin] Delta sync push failed or rejected by remote server. Will retry on next cycle.";
                }
                isSyncing_.store(false);
            });
        }
        catch (const std::exception &e)
        {
            LOG_ERROR << "[SyncPlugin] Exception during sync processing: " << e.what();
            isSyncing_.store(false);
        }
    });
}

void SyncPlugin::markRecordsAsSynced(const std::vector<std::string> &stockIds,
                                    const std::vector<std::string> &logIds,
                                    const std::vector<std::string> &teamIds,
                                    const std::vector<std::string> &memberIds)
{
    try
    {
        auto dbClient = drogon::app().getDbClient();
        if (!dbClient) return;

        for (const auto &id : stockIds)
        {
            dbClient->execSqlSync("UPDATE stocks_master SET is_synced = 1 WHERE id = ?;", id);
        }
        for (const auto &id : logIds)
        {
            dbClient->execSqlSync("UPDATE stock_logs SET is_synced = 1 WHERE id = ?;", id);
        }
        for (const auto &id : teamIds)
        {
            dbClient->execSqlSync("UPDATE team_details SET is_synced = 1 WHERE id = ?;", id);
        }
        for (const auto &id : memberIds)
        {
            dbClient->execSqlSync("UPDATE member_details SET is_synced = 1 WHERE id = ?;", id);
        }
    }
    catch (const std::exception &e)
    {
        LOG_ERROR << "[SyncPlugin] Error updating is_synced flags: " << e.what();
    }
}
