#include <drogon/drogon.h>
#include <sqlite3.h>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <vector>
#include <algorithm>

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

    // Enable foreign keys in SQLite connection
    char *errPragma = nullptr;
    sqlite3_exec(db, "PRAGMA foreign_keys = ON;", nullptr, nullptr, &errPragma);
    if (errPragma) sqlite3_free(errPragma);

    if (fs::exists(migrationsDir))
    {
        std::vector<fs::path> sqlFiles;
        for (const auto &entry : fs::directory_iterator(migrationsDir))
        {
            if (entry.is_regular_file() && entry.path().extension() == ".sql")
            {
                sqlFiles.push_back(entry.path());
            }
        }

        // Sort migration files numerically/alphabetically (001, 002, 003...)
        std::sort(sqlFiles.begin(), sqlFiles.end());

        for (const auto &sqlPath : sqlFiles)
        {
            std::cout << "Applying SQL migration: " << sqlPath.string() << std::endl;
            std::ifstream file(sqlPath);
            if (file.is_open())
            {
                std::string sql((std::istreambuf_iterator<char>(file)), std::istreambuf_iterator<char>());
                char *errMsgs = nullptr;
                if (sqlite3_exec(db, sql.c_str(), nullptr, nullptr, &errMsgs) != SQLITE_OK)
                {
                    std::cerr << "SQL Migration error (" << sqlPath.filename().string() << "): " << (errMsgs ? errMsgs : "") << std::endl;
                    if (errMsgs) sqlite3_free(errMsgs);
                }
                else
                {
                    std::cout << "Successfully applied migration: " << sqlPath.filename().string() << std::endl;
                }
            }
        }
    }
    sqlite3_close(db);
}

int main()
{
    // Create logs directory before Drogon init
    try {
        fs::create_directories("./logs");
        fs::create_directories("logs");
    } catch (...) {}

    std::cout << "==================================================" << std::endl;
    std::cout << " Starting AROHA Facility Server (C++ Drogon Node)" << std::endl;
    std::cout << "==================================================" << std::endl;

    // Apply database migrations BEFORE server init
    runDbMigrations("aroha_facility.db", "db/migrations");

    // Load Drogon configuration file
    std::string configPath = "config/config.json";
    drogon::app().loadConfigFile(configPath);

    std::cout << "Loaded configuration from " << configPath << std::endl;

    // Run the Drogon asynchronous HTTP event loop
    drogon::app().run();

    return 0;
}
