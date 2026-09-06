package com.nullhypothesis.aroha.service;

import com.nullhypothesis.aroha.dto.StockDto;
import com.nullhypothesis.aroha.dto.StockLogDto;
import com.nullhypothesis.aroha.model.StockLogEntity;
import com.nullhypothesis.aroha.model.StockMasterEntity;
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

    public CentralStockService(StockMasterRepository stockMasterRepository, StockLogRepository stockLogRepository) {
        this.stockMasterRepository = stockMasterRepository;
        this.stockLogRepository = stockLogRepository;
    }

    @Transactional(readOnly = true)
    public List<StockDto> getAllStocks(String stationId, String category) {
        List<StockMasterEntity> entities;
        if (stationId != null && !stationId.isEmpty() && category != null && !category.isEmpty()) {
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
                .totalQuantity(entity.getTotalQuantity())
                .minRequiredQuantity(entity.getMinRequiredQuantity())
                .criticalityScore(entity.getCriticalityScore())
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
                .changeQty(entity.getChangeQty())
                .reason(entity.getReason())
                .loggedBy(entity.getLoggedBy())
                .timestamp(entity.getTimestamp())
                .build();
    }
}
