#pragma once

#include <drogon/HttpController.h>

class SyncController : public drogon::HttpController<SyncController>
{
public:
    METHOD_LIST_BEGIN
    // GET /api/v1/facility/sync/status -> Get current connectivity & unsynced records status
    ADD_METHOD_TO(SyncController::getSyncStatus, "/api/v1/facility/sync/status", drogon::Get);

    // POST /api/v1/facility/sync/push -> Manually trigger immediate connectivity check & push to Spring Boot
    ADD_METHOD_TO(SyncController::triggerPush, "/api/v1/facility/sync/push", drogon::Post);
    METHOD_LIST_END

    void getSyncStatus(const drogon::HttpRequestPtr &req,
                       std::function<void(const drogon::HttpResponsePtr &)> &&callback);

    void triggerPush(const drogon::HttpRequestPtr &req,
                     std::function<void(const drogon::HttpResponsePtr &)> &&callback);
};
