package com.nullhypothesis.aroha.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.LocalDateTime;
import java.util.List;

public class CargoShipmentDto {
    private Long id;
    @JsonProperty("shipment_id")
    private String shipmentId;
    private String title;
    @JsonProperty("origin_station_id")
    private String originStationId;
    @JsonProperty("destination_station_id")
    private String destinationStationId;
    private String status;
    @JsonProperty("max_payload_weight_kg")
    private Double maxPayloadWeightKg;
    @JsonProperty("max_payload_volume_m3")
    private Double maxPayloadVolumeM3;
    @JsonProperty("departure_date")
    private String departureDate;
    @JsonProperty("created_by")
    private String createdBy;
    @JsonProperty("created_at")
    private LocalDateTime createdAt;
    @JsonProperty("updated_at")
    private LocalDateTime updatedAt;
    private List<CargoItemDto> items;

    public CargoShipmentDto() {}

    public CargoShipmentDto(Long id, String shipmentId, String title, String originStationId, String destinationStationId, String status, Double maxPayloadWeightKg, Double maxPayloadVolumeM3, String departureDate, String createdBy, LocalDateTime createdAt, LocalDateTime updatedAt, List<CargoItemDto> items) {
        this.id = id;
        this.shipmentId = shipmentId;
        this.title = title;
        this.originStationId = originStationId;
        this.destinationStationId = destinationStationId;
        this.status = status;
        this.maxPayloadWeightKg = maxPayloadWeightKg;
        this.maxPayloadVolumeM3 = maxPayloadVolumeM3;
        this.departureDate = departureDate;
        this.createdBy = createdBy;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
        this.items = items;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getShipmentId() { return shipmentId; }
    public void setShipmentId(String shipmentId) { this.shipmentId = shipmentId; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getOriginStationId() { return originStationId; }
    public void setOriginStationId(String originStationId) { this.originStationId = originStationId; }
    public String getDestinationStationId() { return destinationStationId; }
    public void setDestinationStationId(String destinationStationId) { this.destinationStationId = destinationStationId; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Double getMaxPayloadWeightKg() { return maxPayloadWeightKg; }
    public void setMaxPayloadWeightKg(Double maxPayloadWeightKg) { this.maxPayloadWeightKg = maxPayloadWeightKg; }
    public Double getMaxPayloadVolumeM3() { return maxPayloadVolumeM3; }
    public void setMaxPayloadVolumeM3(Double maxPayloadVolumeM3) { this.maxPayloadVolumeM3 = maxPayloadVolumeM3; }
    public String getDepartureDate() { return departureDate; }
    public void setDepartureDate(String departureDate) { this.departureDate = departureDate; }
    public String getCreatedBy() { return createdBy; }
    public void setCreatedBy(String createdBy) { this.createdBy = createdBy; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
    public List<CargoItemDto> getItems() { return items; }
    public void setItems(List<CargoItemDto> items) { this.items = items; }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private Long id;
        private String shipmentId;
        private String title;
        private String originStationId;
        private String destinationStationId;
        private String status;
        private Double maxPayloadWeightKg;
        private Double maxPayloadVolumeM3;
        private String departureDate;
        private String createdBy;
        private LocalDateTime createdAt;
        private LocalDateTime updatedAt;
        private List<CargoItemDto> items;

        public Builder id(Long id) { this.id = id; return this; }
        public Builder shipmentId(String shipmentId) { this.shipmentId = shipmentId; return this; }
        public Builder title(String title) { this.title = title; return this; }
        public Builder originStationId(String originStationId) { this.originStationId = originStationId; return this; }
        public Builder destinationStationId(String destinationStationId) { this.destinationStationId = destinationStationId; return this; }
        public Builder status(String status) { this.status = status; return this; }
        public Builder maxPayloadWeightKg(Double maxPayloadWeightKg) { this.maxPayloadWeightKg = maxPayloadWeightKg; return this; }
        public Builder maxPayloadVolumeM3(Double maxPayloadVolumeM3) { this.maxPayloadVolumeM3 = maxPayloadVolumeM3; return this; }
        public Builder departureDate(String departureDate) { this.departureDate = departureDate; return this; }
        public Builder createdBy(String createdBy) { this.createdBy = createdBy; return this; }
        public Builder createdAt(LocalDateTime createdAt) { this.createdAt = createdAt; return this; }
        public Builder updatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; return this; }
        public Builder items(List<CargoItemDto> items) { this.items = items; return this; }

        public CargoShipmentDto build() {
            return new CargoShipmentDto(id, shipmentId, title, originStationId, destinationStationId, status, maxPayloadWeightKg, maxPayloadVolumeM3, departureDate, createdBy, createdAt, updatedAt, items);
        }
    }
}
