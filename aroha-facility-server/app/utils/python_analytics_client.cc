#include "python_analytics_client.h"
#include <drogon/drogon.h>
#include <drogon/HttpClient.h>
#include <future>
#include <chrono>

#include <cstdlib>

PythonAnalyticsClient::PythonAnalyticsClient(std::string pythonUrl)
    : pythonUrl_(std::move(pythonUrl))
{
    if (const char *envUrl = std::getenv("PYTHON_BACKEND_URL"))
    {
        if (std::string(envUrl).length() > 0)
        {
            pythonUrl_ = envUrl;
        }
    }
    if (pythonUrl_.empty())
    {
        pythonUrl_ = "http://127.0.0.1:8000";
    }
}

AnalyticsResult PythonAnalyticsClient::computeItemAnalytics(const std::string &itemId,
                                                             const std::string &stationId,
                                                             double currentStock,
                                                             const std::vector<double> &historicalDemand,
                                                             double essentiality)
{
    AnalyticsResult res;
    res.forecastDailyDemand = 5.0;
    res.forecastMae = 2.0;
    res.criticalityScore = essentiality >= 0.8 ? 0.85 : 0.5;
    res.criticalityStatus = essentiality >= 0.8 ? "HIGH" : "MEDIUM";
    res.success = false;

    try
    {
        auto client = drogon::HttpClient::newHttpClient(pythonUrl_);

        // --- Step 1: Call /forecast ---
        Json::Value forecastPayload;
        forecastPayload["item_id"] = itemId.empty() ? "ITEM-001" : itemId;
        forecastPayload["station_id"] = stationId.empty() ? "MAITRI" : stationId;

        Json::Value histArray(Json::arrayValue);
        if (historicalDemand.size() >= 3)
        {
            for (double val : historicalDemand)
            {
                histArray.append(val);
            }
        }
        else
        {
            // Default mock history
            std::vector<double> mockVals = {10, 12, 11, 13, 12, 14, 13, 15, 14, 16, 15, 17, 16, 18};
            for (double v : mockVals)
            {
                histArray.append(v);
            }
        }
        // Always include current stock / consumed data at the end of historical_demand
        histArray.append(currentStock);
        forecastPayload["historical_demand"] = histArray;
        forecastPayload["forecast_horizon_days"] = 30;
        forecastPayload["expedition_requirement"] = 50;
        forecastPayload["expedition_duration_days"] = 10;
        forecastPayload["demand_mode"] = "auto";
        forecastPayload["tune_alpha"] = true;

        auto forecastReq = drogon::HttpRequest::newHttpJsonRequest(forecastPayload);
        forecastReq->setMethod(drogon::Post);
        forecastReq->setPath("/forecast");

        std::promise<std::shared_ptr<Json::Value>> forecastPromise;
        auto forecastFuture = forecastPromise.get_future();

        client->sendRequest(forecastReq, [&forecastPromise](drogon::ReqResult result, const drogon::HttpResponsePtr &resp) {
            if (result == drogon::ReqResult::Ok && resp && resp->getStatusCode() == drogon::k200OK && resp->getJsonObject())
            {
                forecastPromise.set_value(resp->getJsonObject());
            }
            else
            {
                forecastPromise.set_value(nullptr);
            }
        });

        if (forecastFuture.wait_for(std::chrono::seconds(3)) != std::future_status::ready)
        {
            LOG_WARN << "[PythonAnalyticsClient] Timeout calling /forecast on " << pythonUrl_;
            return res;
        }

        auto forecastJson = forecastFuture.get();
        if (!forecastJson)
        {
            LOG_WARN << "[PythonAnalyticsClient] Failed or non-200 response from /forecast on " << pythonUrl_;
            return res;
        }

        if (forecastJson->isMember("forecast_daily_total"))
        {
            res.forecastDailyDemand = (*forecastJson)["forecast_daily_total"].asDouble();
        }
        if (forecastJson->isMember("forecast_mae"))
        {
            res.forecastMae = (*forecastJson)["forecast_mae"].asDouble();
        }

        // --- Step 2: Call /criticality ---
        Json::Value criticalityPayload;
        criticalityPayload["item_id"] = itemId.empty() ? "ITEM-001" : itemId;
        criticalityPayload["station_id"] = stationId.empty() ? "MAITRI" : stationId;
        criticalityPayload["current_stock"] = currentStock;
        criticalityPayload["forecast_daily_demand"] = res.forecastDailyDemand;
        criticalityPayload["essentiality"] = essentiality;
        criticalityPayload["lead_time_days"] = 40.0;
        criticalityPayload["expedition_requirement"] = 30.0;
        criticalityPayload["days_until_expedition"] = 5.0;
        criticalityPayload["expedition_priority"] = 1.0;
        criticalityPayload["forecast_mae"] = res.forecastMae;
        criticalityPayload["urgency_threshold_days"] = 10.0;
        criticalityPayload["reference_lead_time_days"] = 30.0;
        criticalityPayload["reference_error"] = 10.0;

        Json::Value weights;
        weights["essentiality"] = 0.35;
        weights["urgency"] = 0.30;
        weights["lead_time"] = 0.15;
        weights["expedition"] = 0.10;
        weights["uncertainty"] = 0.10;
        criticalityPayload["weights"] = weights;

        auto criticalityReq = drogon::HttpRequest::newHttpJsonRequest(criticalityPayload);
        criticalityReq->setMethod(drogon::Post);
        criticalityReq->setPath("/criticality");

        std::promise<std::shared_ptr<Json::Value>> criticalityPromise;
        auto criticalityFuture = criticalityPromise.get_future();

        client->sendRequest(criticalityReq, [&criticalityPromise](drogon::ReqResult result, const drogon::HttpResponsePtr &resp) {
            if (result == drogon::ReqResult::Ok && resp && resp->getStatusCode() == drogon::k200OK && resp->getJsonObject())
            {
                criticalityPromise.set_value(resp->getJsonObject());
            }
            else
            {
                criticalityPromise.set_value(nullptr);
            }
        });

        if (criticalityFuture.wait_for(std::chrono::seconds(3)) != std::future_status::ready)
        {
            LOG_WARN << "[PythonAnalyticsClient] Timeout calling /criticality on " << pythonUrl_;
            return res;
        }

        auto criticalityJson = criticalityFuture.get();
        if (!criticalityJson)
        {
            LOG_WARN << "[PythonAnalyticsClient] Failed or non-200 response from /criticality on " << pythonUrl_;
            return res;
        }

        if (criticalityJson->isMember("criticality_score"))
        {
            res.criticalityScore = (*criticalityJson)["criticality_score"].asDouble();
        }
        if (criticalityJson->isMember("risk_category"))
        {
            res.criticalityStatus = (*criticalityJson)["risk_category"].asString();
        }

        res.success = true;
        LOG_INFO << "[PythonAnalyticsClient] Analytics computed successfully for " << itemId 
                 << " | Forecast Daily: " << res.forecastDailyDemand
                 << " | Criticality Score: " << res.criticalityScore 
                 << " (" << res.criticalityStatus << ")";
    }
    catch (const std::exception &e)
    {
        LOG_ERROR << "[PythonAnalyticsClient] Exception in computeItemAnalytics: " << e.what();
    }

    return res;
}
