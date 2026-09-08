package com.nullhypothesis.aroha.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.LocalDateTime;

public class StockLogDto {
    private Long id;
    @JsonProperty("station_id")
    private String stationId;

    @JsonProperty("log_id")
    private String logId;

    @JsonProperty("stock_id")
    private String stockId;

    @JsonProperty("operation_type")
    private String operationType;

    private String action;

    @JsonProperty("change_qty")
    private Integer changeQty;

    private Double quantity;
    private String reason;
    private String notes;

    @JsonProperty("logged_by")
    private String loggedBy;

    private LocalDateTime timestamp;

    public StockLogDto() {}

    public StockLogDto(Long id, String stationId, String logId, String stockId, String operationType, String action, Integer changeQty, Double quantity, String reason, String notes, String loggedBy, LocalDateTime timestamp) {
        this.id = id;
        this.stationId = stationId;
        this.logId = logId;
        this.stockId = stockId;
        this.operationType = operationType;
        this.action = action;
        this.changeQty = changeQty;
        this.quantity = quantity;
        this.reason = reason;
        this.notes = notes;
        this.loggedBy = loggedBy;
        this.timestamp = timestamp;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getStationId() { return stationId; }
    public void setStationId(String stationId) { this.stationId = stationId; }
    public String getLogId() { return logId; }
    public void setLogId(String logId) { this.logId = logId; }
    public String getStockId() { return stockId; }
    public void setStockId(String stockId) { this.stockId = stockId; }
    public String getOperationType() { return operationType; }
    public void setOperationType(String operationType) { this.operationType = operationType; }
    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }
    public Integer getChangeQty() { return changeQty; }
    public void setChangeQty(Integer changeQty) { this.changeQty = changeQty; }
    public Double getQuantity() { return quantity; }
    public void setQuantity(Double quantity) { this.quantity = quantity; }
    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }
    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
    public String getLoggedBy() { return loggedBy; }
    public void setLoggedBy(String loggedBy) { this.loggedBy = loggedBy; }
    public LocalDateTime getTimestamp() { return timestamp; }
    public void setTimestamp(LocalDateTime timestamp) { this.timestamp = timestamp; }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private Long id;
        private String stationId;
        private String logId;
        private String stockId;
        private String operationType;
        private String action;
        private Integer changeQty;
        private Double quantity;
        private String reason;
        private String notes;
        private String loggedBy;
        private LocalDateTime timestamp;

        public Builder id(Long id) { this.id = id; return this; }
        public Builder stationId(String stationId) { this.stationId = stationId; return this; }
        public Builder logId(String logId) { this.logId = logId; return this; }
        public Builder stockId(String stockId) { this.stockId = stockId; return this; }
        public Builder operationType(String operationType) { this.operationType = operationType; return this; }
        public Builder action(String action) { this.action = action; return this; }
        public Builder changeQty(Integer changeQty) { this.changeQty = changeQty; return this; }
        public Builder quantity(Double quantity) { this.quantity = quantity; return this; }
        public Builder reason(String reason) { this.reason = reason; return this; }
        public Builder notes(String notes) { this.notes = notes; return this; }
        public Builder loggedBy(String loggedBy) { this.loggedBy = loggedBy; return this; }
        public Builder timestamp(LocalDateTime timestamp) { this.timestamp = timestamp; return this; }

        public StockLogDto build() {
            return new StockLogDto(id, stationId, logId, stockId, operationType, action, changeQty, quantity, reason, notes, loggedBy, timestamp);
        }
    }
}
