package com.nullhypothesis.aroha.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "member_details", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"station_id", "member_id"})
})
public class MemberEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "station_id", length = 50, nullable = false)
    private String stationId;

    @Column(name = "member_id", length = 50, nullable = false)
    private String memberId;

    @Column(name = "team_id", length = 50, nullable = false)
    private String teamId;

    @Column(name = "full_name", length = 150, nullable = false)
    private String fullName;

    @Column(name = "role", length = 100)
    private String role;

    @Column(name = "status", length = 20)
    private String status;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    public MemberEntity() {}

    public MemberEntity(Long id, String stationId, String memberId, String teamId, String fullName, String role, String status, LocalDateTime updatedAt) {
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

        public MemberEntity build() {
            return new MemberEntity(id, stationId, memberId, teamId, fullName, role, status, updatedAt);
        }
    }
}
