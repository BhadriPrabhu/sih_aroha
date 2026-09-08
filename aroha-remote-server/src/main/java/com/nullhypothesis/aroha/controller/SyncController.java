package com.nullhypothesis.aroha.controller;

import com.nullhypothesis.aroha.dto.ApiResponse;
import com.nullhypothesis.aroha.dto.SyncPayloadDto;
import com.nullhypothesis.aroha.model.SyncAuditEntity;
import com.nullhypothesis.aroha.service.DrogonFetchService;
import com.nullhypothesis.aroha.service.SyncService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/remote/sync")
public class SyncController {

    private final SyncService syncService;
    private final DrogonFetchService drogonFetchService;

    public SyncController(SyncService syncService, DrogonFetchService drogonFetchService) {
        this.syncService = syncService;
        this.drogonFetchService = drogonFetchService;
    }

    @PostMapping("/delta")
    public ResponseEntity<ApiResponse<SyncAuditEntity>> processDeltaSync(@Valid @RequestBody SyncPayloadDto payload) {
        SyncAuditEntity audit = syncService.processSyncPayload(payload);
        return ResponseEntity.ok(ApiResponse.success(audit, "Delta sync processed successfully"));
    }

    @PostMapping("/fetch-from-drogon")
    public ResponseEntity<ApiResponse<SyncAuditEntity>> fetchFromDrogon(
            @RequestParam(required = false, defaultValue = "STATION-MAITRI") String station_id) {
        SyncAuditEntity audit = drogonFetchService.fetchAllFromDrogon(station_id);
        return ResponseEntity.ok(ApiResponse.success(audit, "Successfully fetched and synchronized all Drogon table records into central MySQL DB"));
    }

    @GetMapping("/logs")
    public ResponseEntity<ApiResponse<List<SyncAuditEntity>>> getSyncAuditLogs(
            @RequestParam(required = false) String station_id) {
        List<SyncAuditEntity> logs = syncService.getAllAuditLogs(station_id);
        return ResponseEntity.ok(ApiResponse.success(logs, "Retrieved sync audit logs"));
    }
}
