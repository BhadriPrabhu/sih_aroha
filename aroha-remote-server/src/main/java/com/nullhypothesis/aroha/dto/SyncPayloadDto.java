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

    public SyncPayloadDto() {}

    public SyncPayloadDto(String stationId, String syncBatchId, List<StockDto> stocks, List<StockLogDto> stockLogs, List<TeamDto> teams, List<MemberDto> members) {
        this.stationId = stationId;
        this.syncBatchId = syncBatchId;
        this.stocks = stocks;
        this.stockLogs = stockLogs;
        this.teams = teams;
        this.members = members;
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

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private String stationId;
        private String syncBatchId;
        private List<StockDto> stocks;
        private List<StockLogDto> stockLogs;
        private List<TeamDto> teams;
        private List<MemberDto> members;

        public Builder stationId(String stationId) { this.stationId = stationId; return this; }
        public Builder syncBatchId(String syncBatchId) { this.syncBatchId = syncBatchId; return this; }
        public Builder stocks(List<StockDto> stocks) { this.stocks = stocks; return this; }
        public Builder stockLogs(List<StockLogDto> stockLogs) { this.stockLogs = stockLogs; return this; }
        public Builder teams(List<TeamDto> teams) { this.teams = teams; return this; }
        public Builder members(List<MemberDto> members) { this.members = members; return this; }

        public SyncPayloadDto build() {
            return new SyncPayloadDto(stationId, syncBatchId, stocks, stockLogs, teams, members);
        }
    }
}
