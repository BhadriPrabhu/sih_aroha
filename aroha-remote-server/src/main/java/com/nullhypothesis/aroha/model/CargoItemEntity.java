package com.nullhypothesis.aroha.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "cargo_items")
public class CargoItemEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "cargo_item_id", length = 50, nullable = false, unique = true)
    private String cargoItemId;

    @Column(name = "shipment_id", length = 50, nullable = false)
    private String shipmentId;

    @Column(name = "inventory_item_id", length = 50, nullable = false)
    private String inventoryItemId;

    @Column(name = "allocated_quantity", nullable = false)
    private Double allocatedQuantity = 0.0;

    @Column(name = "priority_score")
    private Double priorityScore = 0.0;

    @Column(name = "risk_reduction_val")
    private Double riskReductionVal = 0.0;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    public CargoItemEntity() {}

    public CargoItemEntity(Long id, String cargoItemId, String shipmentId, String inventoryItemId, Double allocatedQuantity, Double priorityScore, Double riskReductionVal, LocalDateTime createdAt) {
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
        private Double allocatedQuantity = 0.0;
        private Double priorityScore = 0.0;
        private Double riskReductionVal = 0.0;
        private LocalDateTime createdAt;

        public Builder id(Long id) { this.id = id; return this; }
        public Builder cargoItemId(String cargoItemId) { this.cargoItemId = cargoItemId; return this; }
        public Builder shipmentId(String shipmentId) { this.shipmentId = shipmentId; return this; }
        public Builder inventoryItemId(String inventoryItemId) { this.inventoryItemId = inventoryItemId; return this; }
        public Builder allocatedQuantity(Double allocatedQuantity) { this.allocatedQuantity = allocatedQuantity; return this; }
        public Builder priorityScore(Double priorityScore) { this.priorityScore = priorityScore; return this; }
        public Builder riskReductionVal(Double riskReductionVal) { this.riskReductionVal = riskReductionVal; return this; }
        public Builder createdAt(LocalDateTime createdAt) { this.createdAt = createdAt; return this; }

        public CargoItemEntity build() {
            return new CargoItemEntity(id, cargoItemId, shipmentId, inventoryItemId, allocatedQuantity, priorityScore, riskReductionVal, createdAt);
        }
    }
}
