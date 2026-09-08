package com.nullhypothesis.aroha.service;

import com.nullhypothesis.aroha.dto.InventoryItemDto;
import com.nullhypothesis.aroha.dto.StockDemandHistoryDto;
import com.nullhypothesis.aroha.dto.StockDto;
import com.nullhypothesis.aroha.dto.StockLogDto;
import com.nullhypothesis.aroha.model.InventoryItemEntity;
import com.nullhypothesis.aroha.model.StockDemandHistoryEntity;
import com.nullhypothesis.aroha.model.StockLogEntity;
import com.nullhypothesis.aroha.model.StockMasterEntity;
import com.nullhypothesis.aroha.repository.InventoryItemRepository;
import com.nullhypothesis.aroha.repository.StockDemandHistoryRepository;
import com.nullhypothesis.aroha.repository.StockLogRepository;
import com.nullhypothesis.aroha.repository.StockMasterRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class CentralStockService {

    private final StockMasterRepository stockMasterRepository;
    private final StockLogRepository stockLogRepository;
    private final InventoryItemRepository inventoryItemRepository;
    private final StockDemandHistoryRepository demandHistoryRepository;

    public CentralStockService(StockMasterRepository stockMasterRepository,
                               StockLogRepository stockLogRepository,
                               InventoryItemRepository inventoryItemRepository,
                               StockDemandHistoryRepository demandHistoryRepository) {
        this.stockMasterRepository = stockMasterRepository;
        this.stockLogRepository = stockLogRepository;
        this.inventoryItemRepository = inventoryItemRepository;
        this.demandHistoryRepository = demandHistoryRepository;
    }

    @Transactional(readOnly = true)
    public List<StockDto> getAllStocks(String stationId, String category, String criticalityStatus) {
        List<StockMasterEntity> entities;
        if (criticalityStatus != null && !criticalityStatus.isEmpty()) {
            if (stationId != null && !stationId.isEmpty()) {
                entities = stockMasterRepository.findByStationIdAndCriticalityStatus(stationId, criticalityStatus.toUpperCase());
            } else {
                entities = stockMasterRepository.findByCriticalityStatus(criticalityStatus.toUpperCase());
            }
        } else if (stationId != null && !stationId.isEmpty() && category != null && !category.isEmpty()) {
            entities = stockMasterRepository.findByStationIdAndCategoryIgnoreCase(stationId, category);
        } else if (stationId != null && !stationId.isEmpty()) {
            entities = stockMasterRepository.findByStationId(stationId);
        } else if (category != null && !category.isEmpty()) {
            entities = stockMasterRepository.findByCategoryIgnoreCase(category);
        } else {
            entities = stockMasterRepository.findAll();
        }

        return entities.stream().map(this::mapStockToDto).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<StockDto> getStocksSortedByCriticality(String stationId) {
        List<StockMasterEntity> entities = (stationId != null && !stationId.isEmpty())
                ? stockMasterRepository.findByStationIdOrderByCriticalityScoreDesc(stationId)
                : stockMasterRepository.findAllByOrderByCriticalityScoreDesc();
        return entities.stream().map(this::mapStockToDto).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<StockDto> getTop5CriticalStocks(String stationId) {
        List<StockMasterEntity> entities = (stationId != null && !stationId.isEmpty())
                ? stockMasterRepository.findTop5ByStationIdOrderByCriticalityScoreDesc(stationId)
                : stockMasterRepository.findTop5ByOrderByCriticalityScoreDesc();
        return entities.stream().map(this::mapStockToDto).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<StockLogDto> getStockLogs(String stationId, String stockId) {
        List<StockLogEntity> entities;
        if (stationId != null && !stationId.isEmpty() && stockId != null && !stockId.isEmpty()) {
            entities = stockLogRepository.findByStationIdAndStockId(stationId, stockId);
        } else if (stationId != null && !stationId.isEmpty()) {
            entities = stockLogRepository.findByStationId(stationId);
        } else {
            entities = stockLogRepository.findAll();
        }

        return entities.stream().map(this::mapLogToDto).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<InventoryItemDto> getInventoryItems(String stationId, String category) {
        List<InventoryItemEntity> entities;
        if (stationId != null && !stationId.isEmpty()) {
            entities = inventoryItemRepository.findByStationId(stationId);
        } else if (category != null && !category.isEmpty()) {
            entities = inventoryItemRepository.findByCategory(category);
        } else {
            entities = inventoryItemRepository.findAll();
        }

        return entities.stream().map(this::mapInventoryToDto).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<StockDemandHistoryDto> getDemandHistory(String stationId, String stockId) {
        List<StockDemandHistoryEntity> entities;
        if (stationId != null && !stationId.isEmpty() && stockId != null && !stockId.isEmpty()) {
            entities = demandHistoryRepository.findByStationIdAndStockId(stationId, stockId);
        } else if (stockId != null && !stockId.isEmpty()) {
            entities = demandHistoryRepository.findByStockId(stockId);
        } else if (stationId != null && !stationId.isEmpty()) {
            entities = demandHistoryRepository.findByStationId(stationId);
        } else {
            entities = demandHistoryRepository.findAll();
        }

        return entities.stream().map(this::mapDemandToDto).collect(Collectors.toList());
    }

    private StockDto mapStockToDto(StockMasterEntity entity) {
        return StockDto.builder()
                .id(entity.getId())
                .stationId(entity.getStationId())
                .stockId(entity.getStockId())
                .itemCode(entity.getItemCode())
                .itemName(entity.getItemName())
                .category(entity.getCategory())
                .subCategory(entity.getSubCategory())
                .unit(entity.getUnit())
                .stockAvailable(entity.getStockAvailable())
                .stockConsumed(entity.getStockConsumed())
                .presentStock(entity.getPresentStock())
                .totalQuantity(entity.getTotalQuantity())
                .minRequiredQuantity(entity.getMinRequiredQuantity())
                .criticalityRate(entity.getCriticalityRate())
                .criticalityScore(entity.getCriticalityScore())
                .essentialityScore(entity.getEssentialityScore())
                .leadTimeDays(entity.getLeadTimeDays())
                .forecastDailyTotal(entity.getForecastDailyTotal())
                .forecastMae(entity.getForecastMae())
                .analyticsUpdatedAt(entity.getAnalyticsUpdatedAt())
                .criticalityStatus(entity.getCriticalityStatus())
                .updatedAt(entity.getUpdatedAt())
                .build();
    }

    private StockLogDto mapLogToDto(StockLogEntity entity) {
        return StockLogDto.builder()
                .id(entity.getId())
                .stationId(entity.getStationId())
                .logId(entity.getLogId())
                .stockId(entity.getStockId())
                .operationType(entity.getOperationType())
                .action(entity.getAction())
                .changeQty(entity.getChangeQty())
                .quantity(entity.getQuantity())
                .reason(entity.getReason())
                .notes(entity.getNotes())
                .loggedBy(entity.getLoggedBy())
                .timestamp(entity.getTimestamp())
                .build();
    }

    private InventoryItemDto mapInventoryToDto(InventoryItemEntity entity) {
        return InventoryItemDto.builder()
                .id(entity.getId())
                .stationId(entity.getStationId())
                .itemId(entity.getItemId())
                .itemCode(entity.getItemCode())
                .name(entity.getName())
                .category(entity.getCategory())
                .quantity(entity.getQuantity())
                .unit(entity.getUnit())
                .minThreshold(entity.getMinThreshold())
                .essentialityScore(entity.getEssentialityScore())
                .leadTimeDays(entity.getLeadTimeDays())
                .shelfLifeDays(entity.getShelfLifeDays())
                .createdAt(entity.getCreatedAt())
                .updatedAt(entity.getUpdatedAt())
                .build();
    }

    private StockDemandHistoryDto mapDemandToDto(StockDemandHistoryEntity entity) {
        return StockDemandHistoryDto.builder()
                .id(entity.getId())
                .stationId(entity.getStationId())
                .demandId(entity.getDemandId())
                .stockId(entity.getStockId())
                .quantity(entity.getQuantity())
                .observedAt(entity.getObservedAt())
                .build();
    }
}
