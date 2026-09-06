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
        std::cerr << "Failed to open SQLite database: " << dbPath << std::endl;
        if (db) sqlite3_close(db);
        return;
    }

    if (fs::exists(migrationsDir))
    {
        for (const auto &entry : fs::directory_iterator(migrationsDir))
        {
            if (entry.is_regular_file() && entry.path().extension() == ".sql")
            {
                std::cout << "Applying SQL migration: " << entry.path().string() << std::endl;
                std::ifstream file(entry.path());
                if (file.is_open())
                {
                    std::string sql((std::istreambuf_iterator<char>(file)), std::istreambuf_iterator<char>());
                    char *errMsgs = nullptr;
                    if (sqlite3_exec(db, sql.c_str(), nullptr, nullptr, &errMsgs) != SQLITE_OK)
                    {
                        std::cerr << "SQL Migration error (" << entry.path().filename().string() << "): " << (errMsgs ? errMsgs : "") << std::endl;
                        if (errMsgs) sqlite3_free(errMsgs);
                    }
                    else
                    {
                        std::cout << "Successfully applied migration: " << entry.path().filename().string() << std::endl;
                    }
                }
            }
        }
    }
    sqlite3_close(db);
}

int main()
{
    // Create logs directory before any Drogon logging
    try {
        fs::create_directories("./logs");
        fs::create_directories("logs");
    } catch (...) {}

    std::cout << "==================================================" << std::endl;
    std::cout << " Starting AROHA Facility Server (C++ Drogon Node)" << std::endl;
    std::cout << "==================================================" << std::endl;

    // Load Drogon configuration file
    std::string configPath = "config/config.json";
    drogon::app().loadConfigFile(configPath);

    std::cout << "Loaded configuration from " << configPath << std::endl;

    // Apply database migrations
    runDbMigrations("aroha_facility.db", "db/migrations");

    // Run the Drogon asynchronous HTTP event loop
    drogon::app().run();

    return 0;
}
