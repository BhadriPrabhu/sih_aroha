package com.nullhypothesis.aroha.controller;

import com.nullhypothesis.aroha.dto.ApiResponse;
import com.nullhypothesis.aroha.dto.CargoShipmentDto;
import com.nullhypothesis.aroha.service.CentralCargoService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/remote/cargo")
public class CentralCargoController {

    private final CentralCargoService cargoService;

    public CentralCargoController(CentralCargoService cargoService) {
        this.cargoService = cargoService;
    }

    @GetMapping("/shipments")
    public ResponseEntity<ApiResponse<List<CargoShipmentDto>>> getShipments(
            @RequestParam(required = false) String origin_station_id,
            @RequestParam(required = false) String destination_station_id,
            @RequestParam(required = false) String status) {
        List<CargoShipmentDto> shipments = cargoService.getAllShipments(origin_station_id, destination_station_id, status);
        return ResponseEntity.ok(ApiResponse.success(shipments, "Retrieved cargo shipments"));
    }

    @GetMapping("/shipments/{shipmentId}")
    public ResponseEntity<ApiResponse<CargoShipmentDto>> getShipmentById(@PathVariable String shipmentId) {
        CargoShipmentDto shipment = cargoService.getShipmentById(shipmentId);
        return ResponseEntity.ok(ApiResponse.success(shipment, "Retrieved cargo shipment details"));
    }

    @PostMapping("/shipments")
    public ResponseEntity<ApiResponse<CargoShipmentDto>> createShipment(@Valid @RequestBody CargoShipmentDto shipmentDto) {
        CargoShipmentDto created = cargoService.createShipment(shipmentDto);
        return ResponseEntity.ok(ApiResponse.success(created, "Cargo shipment created successfully"));
    }
}
