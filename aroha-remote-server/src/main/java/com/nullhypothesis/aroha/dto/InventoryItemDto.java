package com.nullhypothesis.aroha.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.LocalDateTime;

public class InventoryItemDto {
    private Long id;
    @JsonProperty("station_id")
    private String stationId;
    @JsonProperty("item_id")
    private String itemId;
    @JsonProperty("item_code")
    private String itemCode;
    private String name;
    private String category;
    private Double quantity;
    private String unit;
    @JsonProperty("min_threshold")
    private Double minThreshold;
    @JsonProperty("essentiality_score")
    private Double essentialityScore;
    @JsonProperty("lead_time_days")
    private Integer leadTimeDays;
    @JsonProperty("shelf_life_days")
    private Integer shelfLifeDays;
    @JsonProperty("created_at")
    private LocalDateTime createdAt;
    @JsonProperty("updated_at")
    private LocalDateTime updatedAt;

    public InventoryItemDto() {}

    public InventoryItemDto(Long id, String stationId, String itemId, String itemCode, String name, String category, Double quantity, String unit, Double minThreshold, Double essentialityScore, Integer leadTimeDays, Integer shelfLifeDays, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.id = id;
        this.stationId = stationId;
        this.itemId = itemId;
        this.itemCode = itemCode;
        this.name = name;
        this.category = category;
        this.quantity = quantity;
        this.unit = unit;
        this.minThreshold = minThreshold;
        this.essentialityScore = essentialityScore;
        this.leadTimeDays = leadTimeDays;
        this.shelfLifeDays = shelfLifeDays;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getStationId() { return stationId; }
    public void setStationId(String stationId) { this.stationId = stationId; }
    public String getItemId() { return itemId; }
    public void setItemId(String itemId) { this.itemId = itemId; }
    public String getItemCode() { return itemCode; }
    public void setItemCode(String itemCode) { this.itemCode = itemCode; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public Double getQuantity() { return quantity; }
    public void setQuantity(Double quantity) { this.quantity = quantity; }
    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }
    public Double getMinThreshold() { return minThreshold; }
    public void setMinThreshold(Double minThreshold) { this.minThreshold = minThreshold; }
    public Double getEssentialityScore() { return essentialityScore; }
    public void setEssentialityScore(Double essentialityScore) { this.essentialityScore = essentialityScore; }
    public Integer getLeadTimeDays() { return leadTimeDays; }
    public void setLeadTimeDays(Integer leadTimeDays) { this.leadTimeDays = leadTimeDays; }
    public Integer getShelfLifeDays() { return shelfLifeDays; }
    public void setShelfLifeDays(Integer shelfLifeDays) { this.shelfLifeDays = shelfLifeDays; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private Long id;
        private String stationId;
        private String itemId;
        private String itemCode;
        private String name;
        private String category;
        private Double quantity;
        private String unit;
        private Double minThreshold;
        private Double essentialityScore;
        private Integer leadTimeDays;
        private Integer shelfLifeDays;
        private LocalDateTime createdAt;
        private LocalDateTime updatedAt;

        public Builder id(Long id) { this.id = id; return this; }
        public Builder stationId(String stationId) { this.stationId = stationId; return this; }
        public Builder itemId(String itemId) { this.itemId = itemId; return this; }
        public Builder itemCode(String itemCode) { this.itemCode = itemCode; return this; }
        public Builder name(String name) { this.name = name; return this; }
        public Builder category(String category) { this.category = category; return this; }
        public Builder quantity(Double quantity) { this.quantity = quantity; return this; }
        public Builder unit(String unit) { this.unit = unit; return this; }
        public Builder minThreshold(Double minThreshold) { this.minThreshold = minThreshold; return this; }
        public Builder essentialityScore(Double essentialityScore) { this.essentialityScore = essentialityScore; return this; }
        public Builder leadTimeDays(Integer leadTimeDays) { this.leadTimeDays = leadTimeDays; return this; }
        public Builder shelfLifeDays(Integer shelfLifeDays) { this.shelfLifeDays = shelfLifeDays; return this; }
        public Builder createdAt(LocalDateTime createdAt) { this.createdAt = createdAt; return this; }
        public Builder updatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; return this; }

        public InventoryItemDto build() {
            return new InventoryItemDto(id, stationId, itemId, itemCode, name, category, quantity, unit, minThreshold, essentialityScore, leadTimeDays, shelfLifeDays, createdAt, updatedAt);
        }
    }
}
