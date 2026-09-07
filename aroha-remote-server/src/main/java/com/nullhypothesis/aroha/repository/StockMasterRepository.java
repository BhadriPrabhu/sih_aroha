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
    Optional<StockMasterEntity> findByStationIdAndStockId(String stationId, String stockId);
}
