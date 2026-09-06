package com.nullhypothesis.aroha.repository;

import com.nullhypothesis.aroha.model.StockLogEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface StockLogRepository extends JpaRepository<StockLogEntity, Long> {
    List<StockLogEntity> findByStationId(String stationId);
    List<StockLogEntity> findByStationIdAndStockId(String stationId, String stockId);
    Optional<StockLogEntity> findByStationIdAndLogId(String stationId, String logId);
}
