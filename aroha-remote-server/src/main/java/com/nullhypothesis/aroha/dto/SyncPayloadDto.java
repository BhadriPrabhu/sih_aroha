package com.nullhypothesis.aroha.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import java.util.List;

public class SyncPayloadDto {
    @JsonProperty("station_id")
    @NotBlank(message = "station_id is required")
    private String stationId;

    @JsonProperty("sync_batch_id")
    private String syncBatchId;

    private List<StockDto> stocks;

    @JsonProperty("stock_logs")
    private List<StockLogDto> stockLogs;

    private List<TeamDto> teams;
    private List<MemberDto> members;

    @JsonProperty("inventory_items")
    private List<InventoryItemDto> inventoryItems;

    @JsonProperty("demand_history")
    private List<StockDemandHistoryDto> demandHistory;

    @JsonProperty("cargo_shipments")
    private List<CargoShipmentDto> cargoShipments;

    public SyncPayloadDto() {}

    public SyncPayloadDto(String stationId, String syncBatchId, List<StockDto> stocks, List<StockLogDto> stockLogs, List<TeamDto> teams, List<MemberDto> members, List<InventoryItemDto> inventoryItems, List<StockDemandHistoryDto> demandHistory, List<CargoShipmentDto> cargoShipments) {
        this.stationId = stationId;
        this.syncBatchId = syncBatchId;
        this.stocks = stocks;
        this.stockLogs = stockLogs;
        this.teams = teams;
        this.members = members;
        this.inventoryItems = inventoryItems;
        this.demandHistory = demandHistory;
        this.cargoShipments = cargoShipments;
    }

    public String getStationId() { return stationId; }
    public void setStationId(String stationId) { this.stationId = stationId; }
    public String getSyncBatchId() { return syncBatchId; }
    public void setSyncBatchId(String syncBatchId) { this.syncBatchId = syncBatchId; }
    public List<StockDto> getStocks() { return stocks; }
    public void setStocks(List<StockDto> stocks) { this.stocks = stocks; }
    public List<StockLogDto> getStockLogs() { return stockLogs; }
    public void setStockLogs(List<StockLogDto> stockLogs) { this.stockLogs = stockLogs; }
    public List<TeamDto> getTeams() { return teams; }
    public void setTeams(List<TeamDto> teams) { this.teams = teams; }
    public List<MemberDto> getMembers() { return members; }
    public void setMembers(List<MemberDto> members) { this.members = members; }
    public List<InventoryItemDto> getInventoryItems() { return inventoryItems; }
    public void setInventoryItems(List<InventoryItemDto> inventoryItems) { this.inventoryItems = inventoryItems; }
    public List<StockDemandHistoryDto> getDemandHistory() { return demandHistory; }
    public void setDemandHistory(List<StockDemandHistoryDto> demandHistory) { this.demandHistory = demandHistory; }
    public List<CargoShipmentDto> getCargoShipments() { return cargoShipments; }
    public void setCargoShipments(List<CargoShipmentDto> cargoShipments) { this.cargoShipments = cargoShipments; }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private String stationId;
        private String syncBatchId;
        private List<StockDto> stocks;
        private List<StockLogDto> stockLogs;
        private List<TeamDto> teams;
        private List<MemberDto> members;
        private List<InventoryItemDto> inventoryItems;
        private List<StockDemandHistoryDto> demandHistory;
        private List<CargoShipmentDto> cargoShipments;

        public Builder stationId(String stationId) { this.stationId = stationId; return this; }
        public Builder syncBatchId(String syncBatchId) { this.syncBatchId = syncBatchId; return this; }
        public Builder stocks(List<StockDto> stocks) { this.stocks = stocks; return this; }
        public Builder stockLogs(List<StockLogDto> stockLogs) { this.stockLogs = stockLogs; return this; }
        public Builder teams(List<TeamDto> teams) { this.teams = teams; return this; }
        public Builder members(List<MemberDto> members) { this.members = members; return this; }
        public Builder inventoryItems(List<InventoryItemDto> inventoryItems) { this.inventoryItems = inventoryItems; return this; }
        public Builder demandHistory(List<StockDemandHistoryDto> demandHistory) { this.demandHistory = demandHistory; return this; }
        public Builder cargoShipments(List<CargoShipmentDto> cargoShipments) { this.cargoShipments = cargoShipments; return this; }

        public SyncPayloadDto build() {
            return new SyncPayloadDto(stationId, syncBatchId, stocks, stockLogs, teams, members, inventoryItems, demandHistory, cargoShipments);
        }
    }
}
