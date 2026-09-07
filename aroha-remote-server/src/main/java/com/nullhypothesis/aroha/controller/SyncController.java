package com.nullhypothesis.aroha.controller;

import com.nullhypothesis.aroha.dto.ApiResponse;
import com.nullhypothesis.aroha.dto.SyncPayloadDto;
import com.nullhypothesis.aroha.model.SyncAuditEntity;
import com.nullhypothesis.aroha.service.SyncService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/remote/sync")
public class SyncController {

    private final SyncService syncService;

    public SyncController(SyncService syncService) {
        this.syncService = syncService;
    }

    @PostMapping("/delta")
    public ResponseEntity<ApiResponse<SyncAuditEntity>> processDeltaSync(@Valid @RequestBody SyncPayloadDto payload) {
        SyncAuditEntity audit = syncService.processSyncPayload(payload);
        return ResponseEntity.ok(ApiResponse.success(audit, "Delta sync processed successfully"));
    }
}
