package com.nullhypothesis.aroha.service;

import com.nullhypothesis.aroha.dto.MemberDto;
import com.nullhypothesis.aroha.dto.TeamDto;
import com.nullhypothesis.aroha.model.MemberEntity;
import com.nullhypothesis.aroha.model.TeamEntity;
import com.nullhypothesis.aroha.repository.MemberRepository;
import com.nullhypothesis.aroha.repository.TeamRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class CentralTeamService {

    private final TeamRepository teamRepository;
    private final MemberRepository memberRepository;

    public CentralTeamService(TeamRepository teamRepository, MemberRepository memberRepository) {
        this.teamRepository = teamRepository;
        this.memberRepository = memberRepository;
    }

    @Transactional(readOnly = true)
    public List<TeamDto> getTeams(String stationId) {
        List<TeamEntity> entities = (stationId != null && !stationId.isEmpty())
                ? teamRepository.findByStationId(stationId)
                : teamRepository.findAll();

        return entities.stream().map(this::mapTeamToDto).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<MemberDto> getMembers(String stationId, String teamId) {
        List<MemberEntity> entities;
        if (stationId != null && !stationId.isEmpty() && teamId != null && !teamId.isEmpty()) {
            entities = memberRepository.findByStationIdAndTeamId(stationId, teamId);
        } else if (stationId != null && !stationId.isEmpty()) {
            entities = memberRepository.findByStationId(stationId);
        } else {
            entities = memberRepository.findAll();
        }

        return entities.stream().map(this::mapMemberToDto).collect(Collectors.toList());
    }

    private TeamDto mapTeamToDto(TeamEntity entity) {
        return TeamDto.builder()
                .id(entity.getId())
                .stationId(entity.getStationId())
                .teamId(entity.getTeamId())
                .teamName(entity.getTeamName())
                .activeStatus(entity.getActiveStatus())
                .createdAt(entity.getCreatedAt())
                .build();
    }

    private MemberDto mapMemberToDto(MemberEntity entity) {
        return MemberDto.builder()
                .id(entity.getId())
                .stationId(entity.getStationId())
                .memberId(entity.getMemberId())
                .teamId(entity.getTeamId())
                .fullName(entity.getFullName())
                .role(entity.getRole())
                .status(entity.getStatus())
                .updatedAt(entity.getUpdatedAt())
                .build();
    }
}
