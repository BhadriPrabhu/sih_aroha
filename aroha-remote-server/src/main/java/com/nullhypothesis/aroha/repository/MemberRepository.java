package com.nullhypothesis.aroha.repository;

import com.nullhypothesis.aroha.model.MemberEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface MemberRepository extends JpaRepository<MemberEntity, Long> {
    List<MemberEntity> findByStationId(String stationId);
    List<MemberEntity> findByStationIdAndTeamId(String stationId, String teamId);
    Optional<MemberEntity> findByStationIdAndMemberId(String stationId, String memberId);
}
