package com.nullhypothesis.aroha.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "stations")
public class StationEntity {

    @Id
    @Column(name = "station_id", length = 50, nullable = false)
    private String stationId;

    @Column(name = "station_name", length = 100, nullable = false)
    private String stationName;

    @Column(name = "location", length = 100, nullable = false)
    private String location;

    @Column(name = "latitude")
    private Double latitude = 0.0;

    @Column(name = "longitude")
    private Double longitude = 0.0;

    @Column(name = "status", length = 20)
    private String status;

    @Column(name = "last_sync_at")
    private LocalDateTime lastSyncAt;

    public StationEntity() {}

    public StationEntity(String stationId, String stationName, String location, Double latitude, Double longitude, String status, LocalDateTime lastSyncAt) {
        this.stationId = stationId;
        this.stationName = stationName;
        this.location = location;
        this.latitude = latitude;
        this.longitude = longitude;
        this.status = status;
        this.lastSyncAt = lastSyncAt;
    }

    public String getStationId() { return stationId; }
    public void setStationId(String stationId) { this.stationId = stationId; }
    public String getStationName() { return stationName; }
    public void setStationName(String stationName) { this.stationName = stationName; }
    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }
    public Double getLatitude() { return latitude; }
    public void setLatitude(Double latitude) { this.latitude = latitude; }
    public Double getLongitude() { return longitude; }
    public void setLongitude(Double longitude) { this.longitude = longitude; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public LocalDateTime getLastSyncAt() { return lastSyncAt; }
    public void setLastSyncAt(LocalDateTime lastSyncAt) { this.lastSyncAt = lastSyncAt; }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private String stationId;
        private String stationName;
        private String location;
        private Double latitude = 0.0;
        private Double longitude = 0.0;
        private String status;
        private LocalDateTime lastSyncAt;

        public Builder stationId(String stationId) { this.stationId = stationId; return this; }
        public Builder stationName(String stationName) { this.stationName = stationName; return this; }
        public Builder location(String location) { this.location = location; return this; }
        public Builder latitude(Double latitude) { this.latitude = latitude; return this; }
        public Builder longitude(Double longitude) { this.longitude = longitude; return this; }
        public Builder status(String status) { this.status = status; return this; }
        public Builder lastSyncAt(LocalDateTime lastSyncAt) { this.lastSyncAt = lastSyncAt; return this; }

        public StationEntity build() {
            return new StationEntity(stationId, stationName, location, latitude, longitude, status, lastSyncAt);
        }
    }
}
