package com.nullhypothesis.aroha.controller;

import com.nullhypothesis.aroha.dto.ApiResponse;
import com.nullhypothesis.aroha.dto.StationDto;
import com.nullhypothesis.aroha.service.StationService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/remote/stations")
public class StationController {

    private final StationService stationService;

    public StationController(StationService stationService) {
        this.stationService = stationService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<StationDto>>> getAllStations() {
        List<StationDto> stations = stationService.getAllStations();
        return ResponseEntity.ok(ApiResponse.success(stations, "Retrieved all station records"));
    }

    @GetMapping("/{stationId}")
    public ResponseEntity<ApiResponse<StationDto>> getStationById(@PathVariable String stationId) {
        StationDto station = stationService.getStationById(stationId);
        return ResponseEntity.ok(ApiResponse.success(station, "Retrieved station details"));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<StationDto>> registerStation(@Valid @RequestBody StationDto stationDto) {
        StationDto saved = stationService.registerOrUpdateStation(stationDto);
        return ResponseEntity.ok(ApiResponse.success(saved, "Station registered/updated successfully"));
    }
}
