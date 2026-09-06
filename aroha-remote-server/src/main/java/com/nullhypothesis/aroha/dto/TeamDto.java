package com.nullhypothesis.aroha.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.LocalDateTime;

public class TeamDto {
    private Long id;
    private String stationId;

    @JsonProperty("teamid")
    private String teamId;

    @JsonProperty("teamname")
    private String teamName;

    @JsonProperty("active_status")
    private String activeStatus;

    @JsonProperty("created_at")
    private LocalDateTime createdAt;

    public TeamDto() {}

    public TeamDto(Long id, String stationId, String teamId, String teamName, String activeStatus, LocalDateTime createdAt) {
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

        public TeamDto build() {
            return new TeamDto(id, stationId, teamId, teamName, activeStatus, createdAt);
        }
    }
}
