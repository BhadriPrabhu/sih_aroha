package com.nullhypothesis.aroha.service;

import com.nullhypothesis.aroha.dto.StationDto;
import com.nullhypothesis.aroha.exception.ResourceNotFoundException;
import com.nullhypothesis.aroha.model.StationEntity;
import com.nullhypothesis.aroha.repository.StationRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class StationService {

    private final StationRepository stationRepository;

    public StationService(StationRepository stationRepository) {
        this.stationRepository = stationRepository;
    }

    @Transactional(readOnly = true)
    public List<StationDto> getAllStations() {
        return stationRepository.findAll().stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public StationDto getStationById(String stationId) {
        StationEntity station = stationRepository.findByStationId(stationId)
                .orElseThrow(() -> new ResourceNotFoundException("Station not found: " + stationId));
        return mapToDto(station);
    }

    @Transactional
    public StationDto registerOrUpdateStation(StationDto dto) {
        StationEntity station = stationRepository.findByStationId(dto.getStationId())
                .orElse(StationEntity.builder()
                        .stationId(dto.getStationId())
                        .build());

        station.setStationName(dto.getStationName());
        station.setLocation(dto.getLocation());
        station.setStatus(dto.getStatus() != null ? dto.getStatus() : "ACTIVE");
        station.setLastSyncAt(LocalDateTime.now());

        StationEntity saved = stationRepository.save(station);
        return mapToDto(saved);
    }

    private StationDto mapToDto(StationEntity entity) {
        return StationDto.builder()
                .stationId(entity.getStationId())
                .stationName(entity.getStationName())
                .location(entity.getLocation())
                .status(entity.getStatus())
                .lastSyncAt(entity.getLastSyncAt())
                .build();
    }
}
