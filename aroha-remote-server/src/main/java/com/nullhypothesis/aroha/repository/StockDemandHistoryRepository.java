package com.nullhypothesis.aroha.repository;

import com.nullhypothesis.aroha.model.StockDemandHistoryEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface StockDemandHistoryRepository extends JpaRepository<StockDemandHistoryEntity, Long> {
    List<StockDemandHistoryEntity> findByStationId(String stationId);
    List<StockDemandHistoryEntity> findByStockId(String stockId);
    List<StockDemandHistoryEntity> findByStationIdAndStockId(String stationId, String stockId);
    Optional<StockDemandHistoryEntity> findByStationIdAndDemandId(String stationId, String demandId);
}
