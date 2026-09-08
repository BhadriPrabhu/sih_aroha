package com.nullhypothesis.aroha.service;

import com.nullhypothesis.aroha.dto.*;
import com.nullhypothesis.aroha.model.*;
import com.nullhypothesis.aroha.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
public class SyncService {

    private final StationRepository stationRepository;
    private final StockMasterRepository stockMasterRepository;
    private final StockLogRepository stockLogRepository;
    private final TeamRepository teamRepository;
    private final MemberRepository memberRepository;
    private final InventoryItemRepository inventoryItemRepository;
    private final StockDemandHistoryRepository demandHistoryRepository;
    private final CargoShipmentRepository shipmentRepository;
    private final CargoItemRepository cargoItemRepository;
    private final SyncAuditRepository syncAuditRepository;

    public SyncService(StationRepository stationRepository,
                       StockMasterRepository stockMasterRepository,
                       StockLogRepository stockLogRepository,
                       TeamRepository teamRepository,
                       MemberRepository memberRepository,
                       InventoryItemRepository inventoryItemRepository,
                       StockDemandHistoryRepository demandHistoryRepository,
                       CargoShipmentRepository shipmentRepository,
                       CargoItemRepository cargoItemRepository,
                       SyncAuditRepository syncAuditRepository) {
        this.stationRepository = stationRepository;
        this.stockMasterRepository = stockMasterRepository;
        this.stockLogRepository = stockLogRepository;
        this.teamRepository = teamRepository;
        this.memberRepository = memberRepository;
        this.inventoryItemRepository = inventoryItemRepository;
        this.demandHistoryRepository = demandHistoryRepository;
        this.shipmentRepository = shipmentRepository;
        this.cargoItemRepository = cargoItemRepository;
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

                entity.setItemCode(dto.getItemCode() != null ? dto.getItemCode() : dto.getStockId());
                entity.setItemName(dto.getItemName() != null ? dto.getItemName() : "Unnamed Item");
                entity.setCategory(dto.getCategory() != null ? dto.getCategory() : "GENERAL");
                entity.setSubCategory(dto.getSubCategory());
                entity.setUnit(dto.getUnit() != null ? dto.getUnit() : "Units");
                entity.setStockAvailable(dto.getStockAvailable() != null ? dto.getStockAvailable() : 0.0);
                entity.setStockConsumed(dto.getStockConsumed() != null ? dto.getStockConsumed() : 0.0);
                entity.setPresentStock(dto.getPresentStock() != null ? dto.getPresentStock() : 0.0);
                entity.setTotalQuantity(dto.getTotalQuantity() != null ? dto.getTotalQuantity() : 0);
                entity.setMinRequiredQuantity(dto.getMinRequiredQuantity() != null ? dto.getMinRequiredQuantity() : 0);
                entity.setCriticalityRate(dto.getCriticalityRate() != null ? dto.getCriticalityRate() : 0.5);
                entity.setCriticalityScore(dto.getCriticalityScore() != null ? dto.getCriticalityScore() : 0.0);
                entity.setEssentialityScore(dto.getEssentialityScore() != null ? dto.getEssentialityScore() : 0.5);
                entity.setLeadTimeDays(dto.getLeadTimeDays() != null ? dto.getLeadTimeDays() : 30.0);
                entity.setForecastDailyTotal(dto.getForecastDailyTotal());
                entity.setForecastMae(dto.getForecastMae());
                entity.setAnalyticsUpdatedAt(dto.getAnalyticsUpdatedAt());
                entity.setCriticalityStatus(dto.getCriticalityStatus() != null ? dto.getCriticalityStatus() : "MEDIUM");
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
                entity.setAction(dto.getAction());
                entity.setChangeQty(dto.getChangeQty() != null ? dto.getChangeQty() : 0);
                entity.setQuantity(dto.getQuantity() != null ? dto.getQuantity() : 0.0);
                entity.setReason(dto.getReason());
                entity.setNotes(dto.getNotes());
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

        // 6. Sync Inventory Items
        if (payload.getInventoryItems() != null) {
            for (InventoryItemDto dto : payload.getInventoryItems()) {
                if (dto.getItemId() == null || dto.getItemId().isEmpty()) continue;

                InventoryItemEntity entity = inventoryItemRepository.findByStationIdAndItemId(stationId, dto.getItemId())
                        .orElse(InventoryItemEntity.builder()
                                .stationId(stationId)
                                .itemId(dto.getItemId())
                                .build());

                entity.setItemCode(dto.getItemCode() != null ? dto.getItemCode() : dto.getItemId());
                entity.setName(dto.getName() != null ? dto.getName() : "Inventory Item");
                entity.setCategory(dto.getCategory() != null ? dto.getCategory() : "GENERAL");
                entity.setQuantity(dto.getQuantity() != null ? dto.getQuantity() : 0.0);
                entity.setUnit(dto.getUnit() != null ? dto.getUnit() : "units");
                entity.setMinThreshold(dto.getMinThreshold() != null ? dto.getMinThreshold() : 10.0);
                entity.setEssentialityScore(dto.getEssentialityScore() != null ? dto.getEssentialityScore() : 0.5);
                entity.setLeadTimeDays(dto.getLeadTimeDays() != null ? dto.getLeadTimeDays() : 30);
                entity.setShelfLifeDays(dto.getShelfLifeDays());
                entity.setCreatedAt(dto.getCreatedAt() != null ? dto.getCreatedAt() : LocalDateTime.now());
                entity.setUpdatedAt(dto.getUpdatedAt() != null ? dto.getUpdatedAt() : LocalDateTime.now());

                inventoryItemRepository.save(entity);
                totalRecords++;
            }
        }

        // 7. Sync Demand History
        if (payload.getDemandHistory() != null) {
            for (StockDemandHistoryDto dto : payload.getDemandHistory()) {
                if (dto.getDemandId() == null || dto.getDemandId().isEmpty()) continue;

                StockDemandHistoryEntity entity = demandHistoryRepository.findByStationIdAndDemandId(stationId, dto.getDemandId())
                        .orElse(StockDemandHistoryEntity.builder()
                                .stationId(stationId)
                                .demandId(dto.getDemandId())
                                .build());

                entity.setStockId(dto.getStockId());
                entity.setQuantity(dto.getQuantity() != null ? dto.getQuantity() : 0.0);
                entity.setObservedAt(dto.getObservedAt() != null ? dto.getObservedAt() : LocalDateTime.now());

                demandHistoryRepository.save(entity);
                totalRecords++;
            }
        }

        // 8. Record Audit Log
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

    @Transactional(readOnly = true)
    public List<SyncAuditEntity> getAllAuditLogs(String stationId) {
        return (stationId != null && !stationId.isEmpty())
                ? syncAuditRepository.findByStationId(stationId)
                : syncAuditRepository.findAll();
    }
}
