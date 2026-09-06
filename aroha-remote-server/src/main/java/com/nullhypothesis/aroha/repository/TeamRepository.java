package com.nullhypothesis.aroha.repository;

import com.nullhypothesis.aroha.model.TeamEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TeamRepository extends JpaRepository<TeamEntity, Long> {
    List<TeamEntity> findByStationId(String stationId);
    Optional<TeamEntity> findByStationIdAndTeamId(String stationId, String teamId);
}
