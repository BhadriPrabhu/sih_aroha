#include <drogon/drogon.h>
#include <sqlite3.h>
#include <filesystem>
#include <fstream>
#include <iostream>

namespace fs = std::filesystem;

void runDbMigrations(const std::string &dbPath, const std::string &migrationsDir)
{
    sqlite3 *db = nullptr;
    if (sqlite3_open(dbPath.c_str(), &db) != SQLITE_OK)
    {
        LOG_ERROR << "Failed to open SQLite database: " << dbPath;
        if (db) sqlite3_close(db);
        return;
    }

    if (fs::exists(migrationsDir))
    {
        for (const auto &entry : fs::directory_iterator(migrationsDir))
        {
            if (entry.is_regular_file() && entry.path().extension() == ".sql")
            {
                LOG_INFO << "Applying SQL migration: " << entry.path().string();
                std::ifstream file(entry.path());
                if (file.is_open())
                {
                    std::string sql((std::istreambuf_iterator<char>(file)), std::istreambuf_iterator<char>());
                    char *errMsgs = nullptr;
                    if (sqlite3_exec(db, sql.c_str(), nullptr, nullptr, &errMsgs) != SQLITE_OK)
                    {
                        LOG_ERROR << "SQL Migration error (" << entry.path().filename().string() << "): " << (errMsgs ? errMsgs : "");
                        if (errMsgs) sqlite3_free(errMsgs);
                    }
                    else
                    {
                        LOG_INFO << "Successfully applied migration: " << entry.path().filename().string();
                    }
                }
            }
        }
    }
    sqlite3_close(db);
}

int main()
{
    fs::create_directories("./logs");

    LOG_INFO << "Starting AROHA Facility Server (Polar Expedition Logistics Node)...";

    // Load Drogon configuration file
    std::string configPath = "config/config.json";
    drogon::app().loadConfigFile(configPath);

    LOG_INFO << "Loaded configuration from " << configPath;

    // Apply database migrations
    runDbMigrations("aroha_facility.db", "db/migrations");

    // Run the Drogon asynchronous HTTP event loop
    drogon::app().run();

    return 0;
}
