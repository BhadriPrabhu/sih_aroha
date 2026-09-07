#pragma once

#include <json/json.h>
#include <string>
#include <vector>

struct AnalyticsResult
{
    double forecastDailyDemand{5.0};
    double forecastMae{2.0};
    double criticalityScore{0.5};
    std::string criticalityStatus{"MEDIUM"};
    bool success{false};
};

class PythonAnalyticsClient
{
public:
    explicit PythonAnalyticsClient(std::string pythonUrl = "http://127.0.0.1:8000");

    /// Computes two-step analytics (/forecast -> /criticality)
    AnalyticsResult computeItemAnalytics(const std::string &itemId,
                                         const std::string &stationId,
                                         double currentStock,
                                         const std::vector<double> &historicalDemand,
                                         double essentiality = 1.0);

private:
    std::string pythonUrl_;
};
