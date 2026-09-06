#pragma once

#include <drogon/plugins/Plugin.h>
#include <string>

class SqlitePlugin : public drogon::Plugin<SqlitePlugin>
{
public:
    SqlitePlugin() = default;

    /// Called by Drogon during plugin initialization
    void initAndStart(const Json::Value &config) override;

    /// Called by Drogon during shutdown
    void shutdown() override;

private:
    std::string dbPath_{"aroha_facility.db"};
    std::string migrationsDir_{"db/migrations"};

    void runMigrations();
};
