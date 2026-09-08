package com.nullhypothesis.aroha.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.LocalDateTime;

public class CargoItemDto {
    private Long id;
    @JsonProperty("cargo_item_id")
    private String cargoItemId;
    @JsonProperty("shipment_id")
    private String shipmentId;
    @JsonProperty("inventory_item_id")
    private String inventoryItemId;
    @JsonProperty("allocated_quantity")
    private Double allocatedQuantity;
    @JsonProperty("priority_score")
    private Double priorityScore;
    @JsonProperty("risk_reduction_val")
    private Double riskReductionVal;
    @JsonProperty("created_at")
    private LocalDateTime createdAt;

    public CargoItemDto() {}

    public CargoItemDto(Long id, String cargoItemId, String shipmentId, String inventoryItemId, Double allocatedQuantity, Double priorityScore, Double riskReductionVal, LocalDateTime createdAt) {
        this.id = id;
        this.cargoItemId = cargoItemId;
        this.shipmentId = shipmentId;
        this.inventoryItemId = inventoryItemId;
        this.allocatedQuantity = allocatedQuantity;
        this.priorityScore = priorityScore;
        this.riskReductionVal = riskReductionVal;
        this.createdAt = createdAt;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getCargoItemId() { return cargoItemId; }
    public void setCargoItemId(String cargoItemId) { this.cargoItemId = cargoItemId; }
    public String getShipmentId() { return shipmentId; }
    public void setShipmentId(String shipmentId) { this.shipmentId = shipmentId; }
    public String getInventoryItemId() { return inventoryItemId; }
    public void setInventoryItemId(String inventoryItemId) { this.inventoryItemId = inventoryItemId; }
    public Double getAllocatedQuantity() { return allocatedQuantity; }
    public void setAllocatedQuantity(Double allocatedQuantity) { this.allocatedQuantity = allocatedQuantity; }
    public Double getPriorityScore() { return priorityScore; }
    public void setPriorityScore(Double priorityScore) { this.priorityScore = priorityScore; }
    public Double getRiskReductionVal() { return riskReductionVal; }
    public void setRiskReductionVal(Double riskReductionVal) { this.riskReductionVal = riskReductionVal; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private Long id;
        private String cargoItemId;
        private String shipmentId;
        private String inventoryItemId;
        private Double allocatedQuantity;
        private Double priorityScore;
        private Double riskReductionVal;
        private LocalDateTime createdAt;

        public Builder id(Long id) { this.id = id; return this; }
        public Builder cargoItemId(String cargoItemId) { this.cargoItemId = cargoItemId; return this; }
        public Builder shipmentId(String shipmentId) { this.shipmentId = shipmentId; return this; }
        public Builder inventoryItemId(String inventoryItemId) { this.inventoryItemId = inventoryItemId; return this; }
        public Builder allocatedQuantity(Double allocatedQuantity) { this.allocatedQuantity = allocatedQuantity; return this; }
        public Builder priorityScore(Double priorityScore) { this.priorityScore = priorityScore; return this; }
        public Builder riskReductionVal(Double riskReductionVal) { this.riskReductionVal = riskReductionVal; return this; }
        public Builder createdAt(LocalDateTime createdAt) { this.createdAt = createdAt; return this; }

        public CargoItemDto build() {
            return new CargoItemDto(id, cargoItemId, shipmentId, inventoryItemId, allocatedQuantity, priorityScore, riskReductionVal, createdAt);
        }
    }
}
