package com.nullhypothesis.aroha.repository;

import com.nullhypothesis.aroha.model.StationEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface StationRepository extends JpaRepository<StationEntity, String> {
    Optional<StationEntity> findByStationId(String stationId);
}
