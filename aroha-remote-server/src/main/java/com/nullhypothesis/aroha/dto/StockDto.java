package com.nullhypothesis.aroha.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import java.time.LocalDateTime;

public class StockDto {
    private Long id;
    private String stationId;
    
    @JsonProperty("stock_id")
    private String stockId;

    @JsonProperty("item_code")
    @NotBlank(message = "item_code is required")
    private String itemCode;

    @JsonProperty("item_name")
    @NotBlank(message = "item_name is required")
    private String itemName;

    private String category;

    @JsonProperty("sub_category")
    private String subCategory;

    private String unit;

    @JsonProperty("total_quantity")
    private Integer totalQuantity;

    @JsonProperty("min_required_quantity")
    private Integer minRequiredQuantity;

    @JsonProperty("criticality_score")
    private Double criticalityScore;

    @JsonProperty("updated_at")
    private LocalDateTime updatedAt;

    public StockDto() {}

    public StockDto(Long id, String stationId, String stockId, String itemCode, String itemName, String category, String subCategory, String unit, Integer totalQuantity, Integer minRequiredQuantity, Double criticalityScore, LocalDateTime updatedAt) {
        this.id = id;
        this.stationId = stationId;
        this.stockId = stockId;
        this.itemCode = itemCode;
        this.itemName = itemName;
        this.category = category;
        this.subCategory = subCategory;
        this.unit = unit;
        this.totalQuantity = totalQuantity;
        this.minRequiredQuantity = minRequiredQuantity;
        this.criticalityScore = criticalityScore;
        this.updatedAt = updatedAt;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getStationId() { return stationId; }
    public void setStationId(String stationId) { this.stationId = stationId; }

    public String getStockId() { return stockId; }
    public void setStockId(String stockId) { this.stockId = stockId; }

    public String getItemCode() { return itemCode; }
    public void setItemCode(String itemCode) { this.itemCode = itemCode; }

    public String getItemName() { return itemName; }
    public void setItemName(String itemName) { this.itemName = itemName; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getSubCategory() { return subCategory; }
    public void setSubCategory(String subCategory) { this.subCategory = subCategory; }

    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }

    public Integer getTotalQuantity() { return totalQuantity; }
    public void setTotalQuantity(Integer totalQuantity) { this.totalQuantity = totalQuantity; }

    public Integer getMinRequiredQuantity() { return minRequiredQuantity; }
    public void setMinRequiredQuantity(Integer minRequiredQuantity) { this.minRequiredQuantity = minRequiredQuantity; }

    public Double getCriticalityScore() { return criticalityScore; }
    public void setCriticalityScore(Double criticalityScore) { this.criticalityScore = criticalityScore; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private Long id;
        private String stationId;
        private String stockId;
        private String itemCode;
        private String itemName;
        private String category;
        private String subCategory;
        private String unit;
        private Integer totalQuantity;
        private Integer minRequiredQuantity;
        private Double criticalityScore;
        private LocalDateTime updatedAt;

        public Builder id(Long id) { this.id = id; return this; }
        public Builder stationId(String stationId) { this.stationId = stationId; return this; }
        public Builder stockId(String stockId) { this.stockId = stockId; return this; }
        public Builder itemCode(String itemCode) { this.itemCode = itemCode; return this; }
        public Builder itemName(String itemName) { this.itemName = itemName; return this; }
        public Builder category(String category) { this.category = category; return this; }
        public Builder subCategory(String subCategory) { this.subCategory = subCategory; return this; }
        public Builder unit(String unit) { this.unit = unit; return this; }
        public Builder totalQuantity(Integer totalQuantity) { this.totalQuantity = totalQuantity; return this; }
        public Builder minRequiredQuantity(Integer minRequiredQuantity) { this.minRequiredQuantity = minRequiredQuantity; return this; }
        public Builder criticalityScore(Double criticalityScore) { this.criticalityScore = criticalityScore; return this; }
        public Builder updatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; return this; }

        public StockDto build() {
            return new StockDto(id, stationId, stockId, itemCode, itemName, category, subCategory, unit, totalQuantity, minRequiredQuantity, criticalityScore, updatedAt);
        }
    }
}
