#include "sync_controller.h"
#include "plugins/sync_plugin.h"

void SyncController::getSyncStatus(const drogon::HttpRequestPtr &req,
                                   std::function<void(const drogon::HttpResponsePtr &)> &&callback)
{
    auto *syncPlugin = drogon::app().getPlugin<SyncPlugin>();
    if (!syncPlugin)
    {
        Json::Value err;
        err["error"] = "SyncPlugin not loaded or unavailable";
        auto resp = drogon::HttpResponse::newHttpJsonResponse(err);
        resp->setStatusCode(drogon::k500InternalServerError);
        callback(resp);
        return;
    }

    Json::Value status = syncPlugin->getSyncStatus();
    auto resp = drogon::HttpResponse::newHttpJsonResponse(status);
    resp->setStatusCode(drogon::k200OK);
    callback(resp);
}

void SyncController::triggerPush(const drogon::HttpRequestPtr &req,
                                  std::function<void(const drogon::HttpResponsePtr &)> &&callback)
{
    auto *syncPlugin = drogon::app().getPlugin<SyncPlugin>();
    if (!syncPlugin)
    {
        Json::Value err;
        err["error"] = "SyncPlugin not loaded or unavailable";
        auto resp = drogon::HttpResponse::newHttpJsonResponse(err);
        resp->setStatusCode(drogon::k500InternalServerError);
        callback(resp);
        return;
    }

    // Trigger immediate internet check & push cycle
    syncPlugin->performSyncCycle();

    Json::Value res = syncPlugin->getSyncStatus();
    res["message"] = "Manual internet connectivity check & delta push cycle initiated successfully.";
    auto resp = drogon::HttpResponse::newHttpJsonResponse(res);
    resp->setStatusCode(drogon::k200OK);
    callback(resp);
}
