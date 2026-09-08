package com.nullhypothesis.aroha.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "stock_demand_history", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"station_id", "demand_id"})
})
public class StockDemandHistoryEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "station_id", length = 50, nullable = false)
    private String stationId;

    @Column(name = "demand_id", length = 50, nullable = false)
    private String demandId;

    @Column(name = "stock_id", length = 50, nullable = false)
    private String stockId;

    @Column(name = "quantity", nullable = false)
    private Double quantity = 0.0;

    @Column(name = "observed_at")
    private LocalDateTime observedAt;

    public StockDemandHistoryEntity() {}

    public StockDemandHistoryEntity(Long id, String stationId, String demandId, String stockId, Double quantity, LocalDateTime observedAt) {
        this.id = id;
        this.stationId = stationId;
        this.demandId = demandId;
        this.stockId = stockId;
        this.quantity = quantity;
        this.observedAt = observedAt;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getStationId() { return stationId; }
    public void setStationId(String stationId) { this.stationId = stationId; }
    public String getDemandId() { return demandId; }
    public void setDemandId(String demandId) { this.demandId = demandId; }
    public String getStockId() { return stockId; }
    public void setStockId(String stockId) { this.stockId = stockId; }
    public Double getQuantity() { return quantity; }
    public void setQuantity(Double quantity) { this.quantity = quantity; }
    public LocalDateTime getObservedAt() { return observedAt; }
    public void setObservedAt(LocalDateTime observedAt) { this.observedAt = observedAt; }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private Long id;
        private String stationId;
        private String demandId;
        private String stockId;
        private Double quantity = 0.0;
        private LocalDateTime observedAt;

        public Builder id(Long id) { this.id = id; return this; }
        public Builder stationId(String stationId) { this.stationId = stationId; return this; }
        public Builder demandId(String demandId) { this.demandId = demandId; return this; }
        public Builder stockId(String stockId) { this.stockId = stockId; return this; }
        public Builder quantity(Double quantity) { this.quantity = quantity; return this; }
        public Builder observedAt(LocalDateTime observedAt) { this.observedAt = observedAt; return this; }

        public StockDemandHistoryEntity build() {
            return new StockDemandHistoryEntity(id, stationId, demandId, stockId, quantity, observedAt);
        }
    }
}
