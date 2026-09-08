package com.nullhypothesis.aroha.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.LocalDateTime;

public class StockDto {
    private Long id;
    @JsonProperty("station_id")
    private String stationId;
    
    @JsonProperty("stock_id")
    private String stockId;

    @JsonProperty("item_code")
    private String itemCode;

    @JsonProperty("item_name")
    private String itemName;

    @JsonProperty("name")
    public String getNameAlias() { return itemName; }
    @JsonProperty("name")
    public void setNameAlias(String name) { if (this.itemName == null || this.itemName.isEmpty()) this.itemName = name; }

    private String category;

    @JsonProperty("sub_category")
    private String subCategory;

    private String unit;

    @JsonProperty("stock_available")
    private Double stockAvailable;

    @JsonProperty("stock_consumed")
    private Double stockConsumed;

    @JsonProperty("present_stock")
    private Double presentStock;

    @JsonProperty("total_quantity")
    private Integer totalQuantity;

    @JsonProperty("min_required_quantity")
    private Integer minRequiredQuantity;

    @JsonProperty("criticality_rate")
    private Double criticalityRate;

    @JsonProperty("criticality_score")
    private Double criticalityScore;

    @JsonProperty("essentiality_score")
    private Double essentialityScore;

    @JsonProperty("lead_time_days")
    private Double leadTimeDays;

    @JsonProperty("forecast_daily_total")
    private Double forecastDailyTotal;

    @JsonProperty("forecast_mae")
    private Double forecastMae;

    @JsonProperty("analytics_updated_at")
    private LocalDateTime analyticsUpdatedAt;

    @JsonProperty("criticality_status")
    private String criticalityStatus;

    @JsonProperty("updated_at")
    private LocalDateTime updatedAt;

    public StockDto() {}

    public StockDto(Long id, String stationId, String stockId, String itemCode, String itemName, String category, String subCategory, String unit, Double stockAvailable, Double stockConsumed, Double presentStock, Integer totalQuantity, Integer minRequiredQuantity, Double criticalityRate, Double criticalityScore, Double essentialityScore, Double leadTimeDays, Double forecastDailyTotal, Double forecastMae, LocalDateTime analyticsUpdatedAt, String criticalityStatus, LocalDateTime updatedAt) {
        this.id = id;
        this.stationId = stationId;
        this.stockId = stockId;
        this.itemCode = itemCode;
        this.itemName = itemName;
        this.category = category;
        this.subCategory = subCategory;
        this.unit = unit;
        this.stockAvailable = stockAvailable;
        this.stockConsumed = stockConsumed;
        this.presentStock = presentStock;
        this.totalQuantity = totalQuantity;
        this.minRequiredQuantity = minRequiredQuantity;
        this.criticalityRate = criticalityRate;
        this.criticalityScore = criticalityScore;
        this.essentialityScore = essentialityScore;
        this.leadTimeDays = leadTimeDays;
        this.forecastDailyTotal = forecastDailyTotal;
        this.forecastMae = forecastMae;
        this.analyticsUpdatedAt = analyticsUpdatedAt;
        this.criticalityStatus = criticalityStatus;
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
    public Double getStockAvailable() { return stockAvailable; }
    public void setStockAvailable(Double stockAvailable) { this.stockAvailable = stockAvailable; }
    public Double getStockConsumed() { return stockConsumed; }
    public void setStockConsumed(Double stockConsumed) { this.stockConsumed = stockConsumed; }
    public Double getPresentStock() { return presentStock; }
    public void setPresentStock(Double presentStock) { this.presentStock = presentStock; }
    public Integer getTotalQuantity() { return totalQuantity; }
    public void setTotalQuantity(Integer totalQuantity) { this.totalQuantity = totalQuantity; }
    public Integer getMinRequiredQuantity() { return minRequiredQuantity; }
    public void setMinRequiredQuantity(Integer minRequiredQuantity) { this.minRequiredQuantity = minRequiredQuantity; }
    public Double getCriticalityRate() { return criticalityRate; }
    public void setCriticalityRate(Double criticalityRate) { this.criticalityRate = criticalityRate; }
    public Double getCriticalityScore() { return criticalityScore; }
    public void setCriticalityScore(Double criticalityScore) { this.criticalityScore = criticalityScore; }
    public Double getEssentialityScore() { return essentialityScore; }
    public void setEssentialityScore(Double essentialityScore) { this.essentialityScore = essentialityScore; }
    public Double getLeadTimeDays() { return leadTimeDays; }
    public void setLeadTimeDays(Double leadTimeDays) { this.leadTimeDays = leadTimeDays; }
    public Double getForecastDailyTotal() { return forecastDailyTotal; }
    public void setForecastDailyTotal(Double forecastDailyTotal) { this.forecastDailyTotal = forecastDailyTotal; }
    public Double getForecastMae() { return forecastMae; }
    public void setForecastMae(Double forecastMae) { this.forecastMae = forecastMae; }
    public LocalDateTime getAnalyticsUpdatedAt() { return analyticsUpdatedAt; }
    public void setAnalyticsUpdatedAt(LocalDateTime analyticsUpdatedAt) { this.analyticsUpdatedAt = analyticsUpdatedAt; }
    public String getCriticalityStatus() { return criticalityStatus; }
    public void setCriticalityStatus(String criticalityStatus) { this.criticalityStatus = criticalityStatus; }
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
        private Double stockAvailable;
        private Double stockConsumed;
        private Double presentStock;
        private Integer totalQuantity;
        private Integer minRequiredQuantity;
        private Double criticalityRate;
        private Double criticalityScore;
        private Double essentialityScore;
        private Double leadTimeDays;
        private Double forecastDailyTotal;
        private Double forecastMae;
        private LocalDateTime analyticsUpdatedAt;
        private String criticalityStatus;
        private LocalDateTime updatedAt;

        public Builder id(Long id) { this.id = id; return this; }
        public Builder stationId(String stationId) { this.stationId = stationId; return this; }
        public Builder stockId(String stockId) { this.stockId = stockId; return this; }
        public Builder itemCode(String itemCode) { this.itemCode = itemCode; return this; }
        public Builder itemName(String itemName) { this.itemName = itemName; return this; }
        public Builder category(String category) { this.category = category; return this; }
        public Builder subCategory(String subCategory) { this.subCategory = subCategory; return this; }
        public Builder unit(String unit) { this.unit = unit; return this; }
        public Builder stockAvailable(Double stockAvailable) { this.stockAvailable = stockAvailable; return this; }
        public Builder stockConsumed(Double stockConsumed) { this.stockConsumed = stockConsumed; return this; }
        public Builder presentStock(Double presentStock) { this.presentStock = presentStock; return this; }
        public Builder totalQuantity(Integer totalQuantity) { this.totalQuantity = totalQuantity; return this; }
        public Builder minRequiredQuantity(Integer minRequiredQuantity) { this.minRequiredQuantity = minRequiredQuantity; return this; }
        public Builder criticalityRate(Double criticalityRate) { this.criticalityRate = criticalityRate; return this; }
        public Builder criticalityScore(Double criticalityScore) { this.criticalityScore = criticalityScore; return this; }
        public Builder essentialityScore(Double essentialityScore) { this.essentialityScore = essentialityScore; return this; }
        public Builder leadTimeDays(Double leadTimeDays) { this.leadTimeDays = leadTimeDays; return this; }
        public Builder forecastDailyTotal(Double forecastDailyTotal) { this.forecastDailyTotal = forecastDailyTotal; return this; }
        public Builder forecastMae(Double forecastMae) { this.forecastMae = forecastMae; return this; }
        public Builder analyticsUpdatedAt(LocalDateTime analyticsUpdatedAt) { this.analyticsUpdatedAt = analyticsUpdatedAt; return this; }
        public Builder criticalityStatus(String criticalityStatus) { this.criticalityStatus = criticalityStatus; return this; }
        public Builder updatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; return this; }

        public StockDto build() {
            return new StockDto(id, stationId, stockId, itemCode, itemName, category, subCategory, unit, stockAvailable, stockConsumed, presentStock, totalQuantity, minRequiredQuantity, criticalityRate, criticalityScore, essentialityScore, leadTimeDays, forecastDailyTotal, forecastMae, analyticsUpdatedAt, criticalityStatus, updatedAt);
        }
    }
}
