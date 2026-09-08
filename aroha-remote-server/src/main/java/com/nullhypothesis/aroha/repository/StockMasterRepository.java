package com.nullhypothesis.aroha.repository;

import com.nullhypothesis.aroha.model.StockMasterEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface StockMasterRepository extends JpaRepository<StockMasterEntity, Long> {
    List<StockMasterEntity> findByStationId(String stationId);
    List<StockMasterEntity> findByCategoryIgnoreCase(String category);
    List<StockMasterEntity> findByStationIdAndCategoryIgnoreCase(String stationId, String category);
    List<StockMasterEntity> findByCriticalityStatus(String criticalityStatus);
    List<StockMasterEntity> findByStationIdAndCriticalityStatus(String stationId, String criticalityStatus);
    Optional<StockMasterEntity> findByStationIdAndStockId(String stationId, String stockId);
    Optional<StockMasterEntity> findByStockId(String stockId);

    // Criticality Score Filtering & Top 5 Utmost Criticality Queries
    List<StockMasterEntity> findAllByOrderByCriticalityScoreDesc();
    List<StockMasterEntity> findByStationIdOrderByCriticalityScoreDesc(String stationId);
    List<StockMasterEntity> findTop5ByOrderByCriticalityScoreDesc();
    List<StockMasterEntity> findTop5ByStationIdOrderByCriticalityScoreDesc(String stationId);
}
