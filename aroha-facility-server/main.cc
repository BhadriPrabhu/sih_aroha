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

    // Migrations must only run once.  Several of them seed data and newer
    // migrations may contain ALTER TABLE statements, which are not safe to
    // execute on every server restart.
    char *migrationTableError = nullptr;
    sqlite3_exec(
        db,
        "CREATE TABLE IF NOT EXISTS schema_migrations (filename TEXT PRIMARY KEY, applied_at DATETIME DEFAULT CURRENT_TIMESTAMP);",
        nullptr,
        nullptr,
        &migrationTableError);
    if (migrationTableError)
    {
        std::cerr << "Unable to create migration table: " << migrationTableError << std::endl;
        sqlite3_free(migrationTableError);
        sqlite3_close(db);
        return;
    }

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
            const std::string filename = sqlPath.filename().string();
            sqlite3_stmt *migrationQuery = nullptr;
            bool alreadyApplied = false;
            if (sqlite3_prepare_v2(db, "SELECT 1 FROM schema_migrations WHERE filename = ?;", -1, &migrationQuery, nullptr) == SQLITE_OK)
            {
                sqlite3_bind_text(migrationQuery, 1, filename.c_str(), -1, SQLITE_TRANSIENT);
                alreadyApplied = sqlite3_step(migrationQuery) == SQLITE_ROW;
            }
            if (migrationQuery) sqlite3_finalize(migrationQuery);

            if (alreadyApplied)
            {
                continue;
            }

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
                    sqlite3_stmt *recordMigration = nullptr;
                    if (sqlite3_prepare_v2(db, "INSERT INTO schema_migrations (filename) VALUES (?);", -1, &recordMigration, nullptr) == SQLITE_OK)
                    {
                        sqlite3_bind_text(recordMigration, 1, filename.c_str(), -1, SQLITE_TRANSIENT);
                        sqlite3_step(recordMigration);
                    }
                    if (recordMigration) sqlite3_finalize(recordMigration);
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
