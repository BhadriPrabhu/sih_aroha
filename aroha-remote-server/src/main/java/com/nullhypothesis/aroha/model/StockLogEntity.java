package com.nullhypothesis.aroha.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "stock_logs", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"station_id", "log_id"})
})
public class StockLogEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "station_id", length = 50, nullable = false)
    private String stationId;

    @Column(name = "log_id", length = 50, nullable = false)
    private String logId;

    @Column(name = "stock_id", length = 50, nullable = false)
    private String stockId;

    @Column(name = "operation_type", length = 20)
    private String operationType;

    @Column(name = "action", length = 20)
    private String action;

    @Column(name = "change_qty")
    private Integer changeQty = 0;

    @Column(name = "quantity")
    private Double quantity = 0.0;

    @Column(name = "reason", length = 255)
    private String reason;

    @Column(name = "notes", length = 255)
    private String notes;

    @Column(name = "logged_by", length = 100)
    private String loggedBy;

    @Column(name = "timestamp")
    private LocalDateTime timestamp;

    public StockLogEntity() {}

    public StockLogEntity(Long id, String stationId, String logId, String stockId, String operationType, String action, Integer changeQty, Double quantity, String reason, String notes, String loggedBy, LocalDateTime timestamp) {
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
        private Integer changeQty = 0;
        private Double quantity = 0.0;
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

        public StockLogEntity build() {
            return new StockLogEntity(id, stationId, logId, stockId, operationType, action, changeQty, quantity, reason, notes, loggedBy, timestamp);
        }
    }
}
