package com.nullhypothesis.aroha.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "teams_master", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"station_id", "team_id"})
})
public class TeamEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "station_id", length = 50, nullable = false)
    private String stationId;

    @Column(name = "team_id", length = 50, nullable = false)
    private String teamId;

    @Column(name = "team_name", length = 150, nullable = false)
    private String teamName;

    @Column(name = "active_status", length = 20)
    private String activeStatus;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    public TeamEntity() {}

    public TeamEntity(Long id, String stationId, String teamId, String teamName, String activeStatus, LocalDateTime createdAt) {
        this.id = id;
        this.stationId = stationId;
        this.teamId = teamId;
        this.teamName = teamName;
        this.activeStatus = activeStatus;
        this.createdAt = createdAt;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getStationId() { return stationId; }
    public void setStationId(String stationId) { this.stationId = stationId; }

    public String getTeamId() { return teamId; }
    public void setTeamId(String teamId) { this.teamId = teamId; }

    public String getTeamName() { return teamName; }
    public void setTeamName(String teamName) { this.teamName = teamName; }

    public String getActiveStatus() { return activeStatus; }
    public void setActiveStatus(String activeStatus) { this.activeStatus = activeStatus; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private Long id;
        private String stationId;
        private String teamId;
        private String teamName;
        private String activeStatus;
        private LocalDateTime createdAt;

        public Builder id(Long id) { this.id = id; return this; }
        public Builder stationId(String stationId) { this.stationId = stationId; return this; }
        public Builder teamId(String teamId) { this.teamId = teamId; return this; }
        public Builder teamName(String teamName) { this.teamName = teamName; return this; }
        public Builder activeStatus(String activeStatus) { this.activeStatus = activeStatus; return this; }
        public Builder createdAt(LocalDateTime createdAt) { this.createdAt = createdAt; return this; }

        public TeamEntity build() {
            return new TeamEntity(id, stationId, teamId, teamName, activeStatus, createdAt);
        }
    }
}
