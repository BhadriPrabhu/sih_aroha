#include <drogon/drogon.h>
#include <iostream>

int main()
{
    LOG_INFO << "Starting AROHA Facility Server (Polar Expedition Logistics Node)...";

    // Load Drogon configuration file
    std::string configPath = "config/config.json";
    drogon::app().loadConfigFile(configPath);

    LOG_INFO << "Loaded configuration from " << configPath;

    // Run the Drogon asynchronous HTTP event loop
    drogon::app().run();

    return 0;
}
