package com.nullhypothesis.aroha.dto;

import com.fasterxml.jackson.annotation.JsonAlias;
import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.LocalDateTime;

public class MemberDto {
    private Long id;

    @JsonProperty("station_id")
    @JsonAlias({"station_id", "stationId", "station"})
    private String stationId;

    @JsonProperty("memberid")
    @JsonAlias({"memberid", "member_id", "memberId"})
    private String memberId;

    @JsonProperty("teamid")
    @JsonAlias({"teamid", "team_id", "teamId"})
    private String teamId;

    @JsonProperty("fullname")
    @JsonAlias({"fullname", "full_name", "fullName", "name"})
    private String fullName;

    private String role;
    private String status;

    @JsonProperty("updated_at")
    @JsonAlias({"updated_at", "updatedAt"})
    private LocalDateTime updatedAt;

    public MemberDto() {}

    public MemberDto(Long id, String stationId, String memberId, String teamId, String fullName, String role, String status, LocalDateTime updatedAt) {
        this.id = id;
        this.stationId = stationId;
        this.memberId = memberId;
        this.teamId = teamId;
        this.fullName = fullName;
        this.role = role;
        this.status = status;
        this.updatedAt = updatedAt;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getStationId() { return stationId; }
    public void setStationId(String stationId) { this.stationId = stationId; }

    public String getMemberId() { return memberId; }
    public void setMemberId(String memberId) { this.memberId = memberId; }

    public String getTeamId() { return teamId; }
    public void setTeamId(String teamId) { this.teamId = teamId; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private Long id;
        private String stationId;
        private String memberId;
        private String teamId;
        private String fullName;
        private String role;
        private String status;
        private LocalDateTime updatedAt;

        public Builder id(Long id) { this.id = id; return this; }
        public Builder stationId(String stationId) { this.stationId = stationId; return this; }
        public Builder memberId(String memberId) { this.memberId = memberId; return this; }
        public Builder teamId(String teamId) { this.teamId = teamId; return this; }
        public Builder fullName(String fullName) { this.fullName = fullName; return this; }
        public Builder role(String role) { this.role = role; return this; }
        public Builder status(String status) { this.status = status; return this; }
        public Builder updatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; return this; }

        public MemberDto build() {
            return new MemberDto(id, stationId, memberId, teamId, fullName, role, status, updatedAt);
        }
    }
}
