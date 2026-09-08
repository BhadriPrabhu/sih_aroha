package com.nullhypothesis.aroha.repository;

import com.nullhypothesis.aroha.model.InventoryItemEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface InventoryItemRepository extends JpaRepository<InventoryItemEntity, Long> {
    List<InventoryItemEntity> findByStationId(String stationId);
    List<InventoryItemEntity> findByCategory(String category);
    Optional<InventoryItemEntity> findByStationIdAndItemId(String stationId, String itemId);
    Optional<InventoryItemEntity> findByItemId(String itemId);
}
