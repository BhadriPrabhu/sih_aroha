package com.nullhypothesis.aroha.service;

import com.nullhypothesis.aroha.dto.*;
import com.nullhypothesis.aroha.model.*;
import com.nullhypothesis.aroha.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.UUID;

@Service
public class SyncService {

    private final StationRepository stationRepository;
    private final StockMasterRepository stockMasterRepository;
    private final StockLogRepository stockLogRepository;
    private final TeamRepository teamRepository;
    private final MemberRepository memberRepository;
    private final SyncAuditRepository syncAuditRepository;

    public SyncService(StationRepository stationRepository,
                       StockMasterRepository stockMasterRepository,
                       StockLogRepository stockLogRepository,
                       TeamRepository teamRepository,
                       MemberRepository memberRepository,
                       SyncAuditRepository syncAuditRepository) {
        this.stationRepository = stationRepository;
        this.stockMasterRepository = stockMasterRepository;
        this.stockLogRepository = stockLogRepository;
        this.teamRepository = teamRepository;
        this.memberRepository = memberRepository;
        this.syncAuditRepository = syncAuditRepository;
    }

    @Transactional
    public SyncAuditEntity processSyncPayload(SyncPayloadDto payload) {
        String stationId = payload.getStationId();
        String batchId = payload.getSyncBatchId() != null ? payload.getSyncBatchId() : UUID.randomUUID().toString();

        // 1. Ensure Station Exists and Update Last Sync Time
        StationEntity station = stationRepository.findByStationId(stationId)
                .orElseGet(() -> StationEntity.builder()
                        .stationId(stationId)
                        .stationName("Base Station (" + stationId + ")")
                        .location("Antarctica")
                        .status("ACTIVE")
                        .build());
        station.setLastSyncAt(LocalDateTime.now());
        stationRepository.save(station);

        int totalRecords = 0;

        // 2. Sync Stocks
        if (payload.getStocks() != null) {
            for (StockDto dto : payload.getStocks()) {
                if (dto.getStockId() == null || dto.getStockId().isEmpty()) continue;

                StockMasterEntity entity = stockMasterRepository.findByStationIdAndStockId(stationId, dto.getStockId())
                        .orElse(StockMasterEntity.builder()
                                .stationId(stationId)
                                .stockId(dto.getStockId())
                                .build());

                entity.setItemCode(dto.getItemCode() != null ? dto.getItemCode() : "N/A");
                entity.setItemName(dto.getItemName() != null ? dto.getItemName() : "Unnamed Item");
                entity.setCategory(dto.getCategory() != null ? dto.getCategory() : "GENERAL");
                entity.setSubCategory(dto.getSubCategory());
                entity.setUnit(dto.getUnit() != null ? dto.getUnit() : "Units");
                entity.setTotalQuantity(dto.getTotalQuantity() != null ? dto.getTotalQuantity() : 0);
                entity.setMinRequiredQuantity(dto.getMinRequiredQuantity() != null ? dto.getMinRequiredQuantity() : 0);
                entity.setCriticalityScore(dto.getCriticalityScore() != null ? dto.getCriticalityScore() : 0.0);
                entity.setUpdatedAt(dto.getUpdatedAt() != null ? dto.getUpdatedAt() : LocalDateTime.now());

                stockMasterRepository.save(entity);
                totalRecords++;
            }
        }

        // 3. Sync Stock Logs
        if (payload.getStockLogs() != null) {
            for (StockLogDto dto : payload.getStockLogs()) {
                if (dto.getLogId() == null || dto.getLogId().isEmpty()) continue;

                StockLogEntity entity = stockLogRepository.findByStationIdAndLogId(stationId, dto.getLogId())
                        .orElse(StockLogEntity.builder()
                                .stationId(stationId)
                                .logId(dto.getLogId())
                                .build());

                entity.setStockId(dto.getStockId());
                entity.setOperationType(dto.getOperationType() != null ? dto.getOperationType() : "LOG");
                entity.setChangeQty(dto.getChangeQty() != null ? dto.getChangeQty() : 0);
                entity.setReason(dto.getReason());
                entity.setLoggedBy(dto.getLoggedBy());
                entity.setTimestamp(dto.getTimestamp() != null ? dto.getTimestamp() : LocalDateTime.now());

                stockLogRepository.save(entity);
                totalRecords++;
            }
        }

        // 4. Sync Teams
        if (payload.getTeams() != null) {
            for (TeamDto dto : payload.getTeams()) {
                if (dto.getTeamId() == null || dto.getTeamId().isEmpty()) continue;

                TeamEntity entity = teamRepository.findByStationIdAndTeamId(stationId, dto.getTeamId())
                        .orElse(TeamEntity.builder()
                                .stationId(stationId)
                                .teamId(dto.getTeamId())
                                .build());

                entity.setTeamName(dto.getTeamName() != null ? dto.getTeamName() : "Unnamed Team");
                entity.setActiveStatus(dto.getActiveStatus() != null ? dto.getActiveStatus() : "ACTIVE");
                entity.setCreatedAt(dto.getCreatedAt() != null ? dto.getCreatedAt() : LocalDateTime.now());

                teamRepository.save(entity);
                totalRecords++;
            }
        }

        // 5. Sync Members
        if (payload.getMembers() != null) {
            for (MemberDto dto : payload.getMembers()) {
                if (dto.getMemberId() == null || dto.getMemberId().isEmpty()) continue;

                MemberEntity entity = memberRepository.findByStationIdAndMemberId(stationId, dto.getMemberId())
                        .orElse(MemberEntity.builder()
                                .stationId(stationId)
                                .memberId(dto.getMemberId())
                                .build());

                entity.setTeamId(dto.getTeamId() != null ? dto.getTeamId() : "UNASSIGNED");
                entity.setFullName(dto.getFullName() != null ? dto.getFullName() : "Anonymous Member");
                entity.setRole(dto.getRole());
                entity.setStatus(dto.getStatus() != null ? dto.getStatus() : "ACTIVE");
                entity.setUpdatedAt(dto.getUpdatedAt() != null ? dto.getUpdatedAt() : LocalDateTime.now());

                memberRepository.save(entity);
                totalRecords++;
            }
        }

        // 6. Record Audit Log
        SyncAuditEntity audit = SyncAuditEntity.builder()
                .stationId(stationId)
                .syncBatchId(batchId)
                .payloadType("DELTA_SYNC")
                .recordsCount(totalRecords)
                .syncStatus("SUCCESS")
                .syncedAt(LocalDateTime.now())
                .build();

        return syncAuditRepository.save(audit);
    }
}
