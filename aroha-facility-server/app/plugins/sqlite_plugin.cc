#include "sqlite_plugin.h"
#include <drogon/drogon.h>
#include <sqlite3.h>
#include <fstream>
#include <filesystem>
#include <iostream>

namespace fs = std::filesystem;

void SqlitePlugin::initAndStart(const Json::Value &config)
{
    if (config.isMember("db_path") && config["db_path"].isString())
    {
        dbPath_ = config["db_path"].asString();
    }
    if (config.isMember("migrations_dir") && config["migrations_dir"].isString())
    {
        migrationsDir_ = config["migrations_dir"].asString();
    }

    LOG_INFO << "SqlitePlugin starting using database path: " << dbPath_;
    runMigrations();
}

void SqlitePlugin::shutdown()
{
    LOG_INFO << "SqlitePlugin shutting down cleanly.";
}

void SqlitePlugin::runMigrations()
{
    sqlite3 *db = nullptr;
    int rc = sqlite3_open(dbPath_.c_str(), &db);
    if (rc != SQLITE_OK)
    {
        LOG_ERROR << "Failed to open SQLite database (" << dbPath_ << "): " << sqlite3_errmsg(db);
        if (db) sqlite3_close(db);
        return;
    }

    if (!fs::exists(migrationsDir_))
    {
        LOG_WARN << "Migrations directory not found: " << migrationsDir_;
        sqlite3_close(db);
        return;
    }

    for (const auto &entry : fs::directory_iterator(migrationsDir_))
    {
        if (entry.is_regular_file() && entry.path().extension() == ".sql")
        {
            LOG_INFO << "Applying SQL migration: " << entry.path().string();
            std::ifstream file(entry.path());
            if (!file.is_open())
            {
                LOG_ERROR << "Could not open migration file: " << entry.path();
                continue;
            }

            std::string sql((std::istreambuf_iterator<char>(file)), std::istreambuf_iterator<char>());
            char *errMsgs = nullptr;
            rc = sqlite3_exec(db, sql.c_str(), nullptr, nullptr, &errMsgs);
            if (rc != SQLITE_OK)
            {
                LOG_ERROR << "SQL Error in migration " << entry.path().filename().string() << ": " << (errMsgs ? errMsgs : "Unknown");
                if (errMsgs) sqlite3_free(errMsgs);
            }
            else
            {
                LOG_INFO << "Successfully applied migration: " << entry.path().filename().string();
            }
        }
    }

    sqlite3_close(db);
}
