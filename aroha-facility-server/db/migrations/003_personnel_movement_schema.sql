-- Migration 003: Personnel Movement (team_details & member_details)

-- 1. Team Details Table
CREATE TABLE IF NOT EXISTS team_details (
    id TEXT PRIMARY KEY,
    teamid TEXT NOT NULL UNIQUE,
    teamname TEXT NOT NULL,
    active_status TEXT NOT NULL CHECK(active_status IN ('ACTIVE', 'INACTIVE')) DEFAULT 'ACTIVE',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 2. Member Details Table
CREATE TABLE IF NOT EXISTS member_details (
    id TEXT PRIMARY KEY,
    teamid TEXT NOT NULL REFERENCES team_details(teamid) ON DELETE CASCADE,
    name TEXT NOT NULL,
    role TEXT NOT NULL,
    activity_status TEXT NOT NULL DEFAULT 'ON_STATION',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Seed Sample Teams
INSERT OR IGNORE INTO team_details (id, teamid, teamname, active_status) VALUES
('tm-id-001', 'TEAM-ALPHA', 'Traverse Reconnaissance Alpha', 'ACTIVE'),
('tm-id-002', 'TEAM-BETA', 'Ice Core Drilling Unit', 'ACTIVE'),
('tm-id-003', 'TEAM-GAMMA', 'Station Maintenance Crew', 'INACTIVE');

-- Seed Sample Team Members
INSERT OR IGNORE INTO member_details (id, teamid, name, role, activity_status) VALUES
('mem-001', 'TEAM-ALPHA', 'Dr. Aarav Sharma', 'Lead Glaciologist', 'FIELD_MISSION'),
('mem-002', 'TEAM-ALPHA', 'Captain Vikram Singh', 'Navigation Specialist', 'FIELD_MISSION'),
('mem-003', 'TEAM-BETA', 'Priya Patel', 'Drill Technician', 'ON_STATION'),
('mem-004', 'TEAM-BETA', 'Rohan Gupta', 'Equipment Engineer', 'ON_STATION');
