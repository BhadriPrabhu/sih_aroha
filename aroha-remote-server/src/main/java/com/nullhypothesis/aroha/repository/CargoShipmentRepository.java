package com.nullhypothesis.aroha.repository;

import com.nullhypothesis.aroha.model.CargoShipmentEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CargoShipmentRepository extends JpaRepository<CargoShipmentEntity, Long> {
    Optional<CargoShipmentEntity> findByShipmentId(String shipmentId);
    List<CargoShipmentEntity> findByOriginStationId(String originStationId);
    List<CargoShipmentEntity> findByDestinationStationId(String destinationStationId);
    List<CargoShipmentEntity> findByStatus(String status);
}
