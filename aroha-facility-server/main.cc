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

    // Create schema_migrations audit table if it does not exist
    const char *createTableSql = 
        "CREATE TABLE IF NOT EXISTS schema_migrations ("
        "version TEXT PRIMARY KEY, "
        "applied_at DATETIME DEFAULT CURRENT_TIMESTAMP"
        ");";
    sqlite3_exec(db, createTableSql, nullptr, nullptr, nullptr);

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
                std::cout << "Skipping migration (already applied): " << filename << std::endl;
                continue;
            }

            std::cout << "Applying SQL migration: " << filename << std::endl;
            std::ifstream file(sqlPath);
            if (file.is_open())
            {
                std::string sql((std::istreambuf_iterator<char>(file)), std::istreambuf_iterator<char>());
                char *errMsgs = nullptr;
                if (sqlite3_exec(db, sql.c_str(), nullptr, nullptr, &errMsgs) != SQLITE_OK)
                {
                    std::cerr << "SQL Migration error (" << filename << "): " << (errMsgs ? errMsgs : "") << std::endl;
                    if (errMsgs) sqlite3_free(errMsgs);
                }
                else
                {
                    std::string recordSql = "INSERT INTO schema_migrations (version) VALUES ('" + filename + "');";
                    sqlite3_exec(db, recordSql.c_str(), nullptr, nullptr, nullptr);
                    std::cout << "Successfully applied migration: " << filename << std::endl;
                }
            }
        }
    }
    sqlite3_close(db);
}

int main()
{
    // Create data and logs directory before Drogon init
    try {
        fs::create_directories("./data");
        fs::create_directories("data");
        fs::create_directories("./logs");
        fs::create_directories("logs");
    } catch (...) {}

    std::cout << "==================================================" << std::endl;
    std::cout << " Starting AROHA Facility Server (C++ Drogon Node)" << std::endl;
    std::cout << "==================================================" << std::endl;

    // Apply database migrations BEFORE server init
    runDbMigrations("/app/data/aroha_facility.db", "db/migrations");

    // Load Drogon configuration file
    std::string configPath = "config/config.json";
    drogon::app().loadConfigFile(configPath);

    std::cout << "Loaded configuration from " << configPath << std::endl;

    // Run the Drogon asynchronous HTTP event loop
    drogon::app().run();

    return 0;
}
