#include "sqlite_plugin.h"
#include <drogon/drogon.h>
#include <sqlite3.h>
#include <fstream>
#include <filesystem>
#include <iostream>
#include <vector>
#include <algorithm>

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

    // Create schema_migrations audit table if it does not exist
    const char *createTableSql = 
        "CREATE TABLE IF NOT EXISTS schema_migrations ("
        "version TEXT PRIMARY KEY, "
        "applied_at DATETIME DEFAULT CURRENT_TIMESTAMP"
        ");";
    sqlite3_exec(db, createTableSql, nullptr, nullptr, nullptr);

    if (!fs::exists(migrationsDir_))
    {
        LOG_WARN << "Migrations directory not found: " << migrationsDir_;
        sqlite3_close(db);
        return;
    }

    std::vector<fs::path> sqlFiles;
    for (const auto &entry : fs::directory_iterator(migrationsDir_))
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
        std::string filename = sqlPath.filename().string();

        // Check if migration has already been executed
        std::string checkSql = "SELECT COUNT(*) FROM schema_migrations WHERE version = '" + filename + "';";
        sqlite3_stmt *stmt = nullptr;
        bool alreadyApplied = false;
        if (sqlite3_prepare_v2(db, checkSql.c_str(), -1, &stmt, nullptr) == SQLITE_OK)
        {
            if (sqlite3_step(stmt) == SQLITE_ROW)
            {
                alreadyApplied = (sqlite3_column_int(stmt, 0) > 0);
            }
            sqlite3_finalize(stmt);
        }

        if (alreadyApplied)
        {
            LOG_INFO << "Skipping migration (already applied): " << filename;
            continue;
        }

        LOG_INFO << "Applying SQL migration: " << filename;
        std::ifstream file(sqlPath);
        if (!file.is_open())
        {
            LOG_ERROR << "Could not open migration file: " << sqlPath;
            continue;
        }

        std::string sql((std::istreambuf_iterator<char>(file)), std::istreambuf_iterator<char>());
        char *errMsgs = nullptr;
        rc = sqlite3_exec(db, sql.c_str(), nullptr, nullptr, &errMsgs);
        if (rc != SQLITE_OK)
        {
            LOG_ERROR << "SQL Error in migration " << filename << ": " << (errMsgs ? errMsgs : "Unknown");
            if (errMsgs) sqlite3_free(errMsgs);
        }
        else
        {
            std::string recordSql = "INSERT INTO schema_migrations (version) VALUES ('" + filename + "');";
            sqlite3_exec(db, recordSql.c_str(), nullptr, nullptr, nullptr);
            LOG_INFO << "Successfully applied migration: " << filename;
        }
    }

    sqlite3_close(db);
}
