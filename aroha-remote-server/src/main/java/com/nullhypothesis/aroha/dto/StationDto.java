package com.nullhypothesis.aroha.dto;

import jakarta.validation.constraints.NotBlank;
import java.time.LocalDateTime;

public class StationDto {
    @NotBlank(message = "Station ID cannot be blank")
    private String stationId;

    @NotBlank(message = "Station Name cannot be blank")
    private String stationName;

    @NotBlank(message = "Location cannot be blank")
    private String location;

    private String status;
    private LocalDateTime lastSyncAt;

    public StationDto() {}

    public StationDto(String stationId, String stationName, String location, String status, LocalDateTime lastSyncAt) {
        this.stationId = stationId;
        this.stationName = stationName;
        this.location = location;
        this.status = status;
        this.lastSyncAt = lastSyncAt;
    }

    public String getStationId() { return stationId; }
    public void setStationId(String stationId) { this.stationId = stationId; }

    public String getStationName() { return stationName; }
    public void setStationName(String stationName) { this.stationName = stationName; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getLastSyncAt() { return lastSyncAt; }
    public void setLastSyncAt(LocalDateTime lastSyncAt) { this.lastSyncAt = lastSyncAt; }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private String stationId;
        private String stationName;
        private String location;
        private String status;
        private LocalDateTime lastSyncAt;

        public Builder stationId(String stationId) { this.stationId = stationId; return this; }
        public Builder stationName(String stationName) { this.stationName = stationName; return this; }
        public Builder location(String location) { this.location = location; return this; }
        public Builder status(String status) { this.status = status; return this; }
        public Builder lastSyncAt(LocalDateTime lastSyncAt) { this.lastSyncAt = lastSyncAt; return this; }

        public StationDto build() {
            return new StationDto(stationId, stationName, location, status, lastSyncAt);
        }
    }
}
