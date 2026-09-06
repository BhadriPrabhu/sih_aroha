package com.nullhypothesis.aroha.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "sync_audit_logs")
public class SyncAuditEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "station_id", length = 50, nullable = false)
    private String stationId;

    @Column(name = "sync_batch_id", length = 100, nullable = false)
    private String syncBatchId;

    @Column(name = "payload_type", length = 50, nullable = false)
    private String payloadType;

    @Column(name = "records_count")
    private Integer recordsCount;

    @Column(name = "sync_status", length = 20)
    private String syncStatus;

    @Column(name = "synced_at")
    private LocalDateTime syncedAt;

    public SyncAuditEntity() {}

    public SyncAuditEntity(Long id, String stationId, String syncBatchId, String payloadType, Integer recordsCount, String syncStatus, LocalDateTime syncedAt) {
        this.id = id;
        this.stationId = stationId;
        this.syncBatchId = syncBatchId;
        this.payloadType = payloadType;
        this.recordsCount = recordsCount;
        this.syncStatus = syncStatus;
        this.syncedAt = syncedAt;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getStationId() { return stationId; }
    public void setStationId(String stationId) { this.stationId = stationId; }

    public String getSyncBatchId() { return syncBatchId; }
    public void setSyncBatchId(String syncBatchId) { this.syncBatchId = syncBatchId; }

    public String getPayloadType() { return payloadType; }
    public void setPayloadType(String payloadType) { this.payloadType = payloadType; }

    public Integer getRecordsCount() { return recordsCount; }
    public void setRecordsCount(Integer recordsCount) { this.recordsCount = recordsCount; }

    public String getSyncStatus() { return syncStatus; }
    public void setSyncStatus(String syncStatus) { this.syncStatus = syncStatus; }

    public LocalDateTime getSyncedAt() { return syncedAt; }
    public void setSyncedAt(LocalDateTime syncedAt) { this.syncedAt = syncedAt; }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private Long id;
        private String stationId;
        private String syncBatchId;
        private String payloadType;
        private Integer recordsCount;
        private String syncStatus;
        private LocalDateTime syncedAt;

        public Builder id(Long id) { this.id = id; return this; }
        public Builder stationId(String stationId) { this.stationId = stationId; return this; }
        public Builder syncBatchId(String syncBatchId) { this.syncBatchId = syncBatchId; return this; }
        public Builder payloadType(String payloadType) { this.payloadType = payloadType; return this; }
        public Builder recordsCount(Integer recordsCount) { this.recordsCount = recordsCount; return this; }
        public Builder syncStatus(String syncStatus) { this.syncStatus = syncStatus; return this; }
        public Builder syncedAt(LocalDateTime syncedAt) { this.syncedAt = syncedAt; return this; }

        public SyncAuditEntity build() {
            return new SyncAuditEntity(id, stationId, syncBatchId, payloadType, recordsCount, syncStatus, syncedAt);
        }
    }
}
