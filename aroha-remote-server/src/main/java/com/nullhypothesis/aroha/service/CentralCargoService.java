package com.nullhypothesis.aroha.service;

import com.nullhypothesis.aroha.dto.CargoItemDto;
import com.nullhypothesis.aroha.dto.CargoShipmentDto;
import com.nullhypothesis.aroha.exception.ResourceNotFoundException;
import com.nullhypothesis.aroha.model.CargoItemEntity;
import com.nullhypothesis.aroha.model.CargoShipmentEntity;
import com.nullhypothesis.aroha.repository.CargoItemRepository;
import com.nullhypothesis.aroha.repository.CargoShipmentRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class CentralCargoService {

    private final CargoShipmentRepository shipmentRepository;
    private final CargoItemRepository cargoItemRepository;

    public CentralCargoService(CargoShipmentRepository shipmentRepository, CargoItemRepository cargoItemRepository) {
        this.shipmentRepository = shipmentRepository;
        this.cargoItemRepository = cargoItemRepository;
    }

    @Transactional(readOnly = true)
    public List<CargoShipmentDto> getAllShipments(String originStationId, String destinationStationId, String status) {
        List<CargoShipmentEntity> shipments;
        if (originStationId != null && !originStationId.isEmpty()) {
            shipments = shipmentRepository.findByOriginStationId(originStationId);
        } else if (destinationStationId != null && !destinationStationId.isEmpty()) {
            shipments = shipmentRepository.findByDestinationStationId(destinationStationId);
        } else if (status != null && !status.isEmpty()) {
            shipments = shipmentRepository.findByStatus(status);
        } else {
            shipments = shipmentRepository.findAll();
        }

        return shipments.stream().map(this::mapShipmentToDto).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public CargoShipmentDto getShipmentById(String shipmentId) {
        CargoShipmentEntity entity = shipmentRepository.findByShipmentId(shipmentId)
                .orElseThrow(() -> new ResourceNotFoundException("Cargo shipment not found: " + shipmentId));
        return mapShipmentToDto(entity);
    }

    @Transactional
    public CargoShipmentDto createShipment(CargoShipmentDto dto) {
        String shipmentId = (dto.getShipmentId() != null && !dto.getShipmentId().isEmpty())
                ? dto.getShipmentId()
                : "SHIP-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();

        CargoShipmentEntity entity = CargoShipmentEntity.builder()
                .shipmentId(shipmentId)
                .title(dto.getTitle() != null ? dto.getTitle() : "Antarctic Expedition Cargo Manifest")
                .originStationId(dto.getOriginStationId() != null ? dto.getOriginStationId() : "STATION-MAITRI")
                .destinationStationId(dto.getDestinationStationId() != null ? dto.getDestinationStationId() : "STATION-BHARATI")
                .status(dto.getStatus() != null ? dto.getStatus() : "DRAFT")
                .maxPayloadWeightKg(dto.getMaxPayloadWeightKg() != null ? dto.getMaxPayloadWeightKg() : 1000.0)
                .maxPayloadVolumeM3(dto.getMaxPayloadVolumeM3() != null ? dto.getMaxPayloadVolumeM3() : 20.0)
                .departureDate(dto.getDepartureDate())
                .createdBy(dto.getCreatedBy() != null ? dto.getCreatedBy() : "Central Remote Logistics Officer")
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();

        CargoShipmentEntity saved = shipmentRepository.save(entity);

        if (dto.getItems() != null && !dto.getItems().isEmpty()) {
            for (CargoItemDto itemDto : dto.getItems()) {
                String itemId = (itemDto.getCargoItemId() != null && !itemDto.getCargoItemId().isEmpty())
                        ? itemDto.getCargoItemId()
                        : "ITEM-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();

                CargoItemEntity itemEntity = CargoItemEntity.builder()
                        .cargoItemId(itemId)
                        .shipmentId(saved.getShipmentId())
                        .inventoryItemId(itemDto.getInventoryItemId() != null ? itemDto.getInventoryItemId() : "ITEM-001")
                        .allocatedQuantity(itemDto.getAllocatedQuantity() != null ? itemDto.getAllocatedQuantity() : 1.0)
                        .priorityScore(itemDto.getPriorityScore() != null ? itemDto.getPriorityScore() : 0.5)
                        .riskReductionVal(itemDto.getRiskReductionVal() != null ? itemDto.getRiskReductionVal() : 0.0)
                        .createdAt(LocalDateTime.now())
                        .build();

                cargoItemRepository.save(itemEntity);
            }
        }

        return mapShipmentToDto(saved);
    }

    private CargoShipmentDto mapShipmentToDto(CargoShipmentEntity entity) {
        List<CargoItemDto> itemDtos = cargoItemRepository.findByShipmentId(entity.getShipmentId()).stream()
                .map(item -> CargoItemDto.builder()
                        .id(item.getId())
                        .cargoItemId(item.getCargoItemId())
                        .shipmentId(item.getShipmentId())
                        .inventoryItemId(item.getInventoryItemId())
                        .allocatedQuantity(item.getAllocatedQuantity())
                        .priorityScore(item.getPriorityScore())
                        .riskReductionVal(item.getRiskReductionVal())
                        .createdAt(item.getCreatedAt())
                        .build())
                .collect(Collectors.toList());

        return CargoShipmentDto.builder()
                .id(entity.getId())
                .shipmentId(entity.getShipmentId())
                .title(entity.getTitle())
                .originStationId(entity.getOriginStationId())
                .destinationStationId(entity.getDestinationStationId())
                .status(entity.getStatus())
                .maxPayloadWeightKg(entity.getMaxPayloadWeightKg())
                .maxPayloadVolumeM3(entity.getMaxPayloadVolumeM3())
                .departureDate(entity.getDepartureDate())
                .createdBy(entity.getCreatedBy())
                .createdAt(entity.getCreatedAt())
                .updatedAt(entity.getUpdatedAt())
                .items(itemDtos)
                .build();
    }
}
