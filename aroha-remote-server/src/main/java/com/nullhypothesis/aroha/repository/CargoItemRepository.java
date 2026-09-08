package com.nullhypothesis.aroha.repository;

import com.nullhypothesis.aroha.model.CargoItemEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CargoItemRepository extends JpaRepository<CargoItemEntity, Long> {
    Optional<CargoItemEntity> findByCargoItemId(String cargoItemId);
    List<CargoItemEntity> findByShipmentId(String shipmentId);
    List<CargoItemEntity> findByInventoryItemId(String inventoryItemId);
}
