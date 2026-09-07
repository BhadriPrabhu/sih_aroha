#pragma once

#include <drogon/plugins/Plugin.h>
#include <drogon/drogon.h>
#include <trantor/net/EventLoop.h>
#include <string>
#include <atomic>
#include <vector>

class SyncPlugin : public drogon::Plugin<SyncPlugin>
{
public:
    SyncPlugin() = default;

    /// Called by Drogon during plugin initialization
    void initAndStart(const Json::Value &config) override;

    /// Called by Drogon during shutdown
    void shutdown() override;

private:
    std::string remoteServerUrl_{"http://127.0.0.1:8081"};
    std::string stationId_{"stn-maitri"};
    uint64_t syncIntervalSeconds_{5};

    std::atomic<bool> isSyncing_{false};

    void performSyncCycle();
    void markRecordsAsSynced(const std::vector<std::string> &stockIds,
                             const std::vector<std::string> &logIds,
                             const std::vector<std::string> &teamIds,
                             const std::vector<std::string> &memberIds);
};
