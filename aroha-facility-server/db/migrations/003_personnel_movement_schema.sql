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
    activity_status TEXT NOT NULL CHECK(activity_status IN ('IN', 'OUT')) DEFAULT 'IN',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Seed Sample Teams
INSERT OR IGNORE INTO team_details (id, teamid, teamname, active_status) VALUES
('tm-id-001', 'TEAM-ALPHA', 'Traverse Reconnaissance Alpha', 'ACTIVE'),
('tm-id-002', 'TEAM-BETA', 'Ice Core Drilling Unit', 'ACTIVE'),
('tm-id-003', 'TEAM-GAMMA', 'Station Maintenance Crew', 'INACTIVE'),
('tm-id-004', 'TEAM-DELTA', 'Atmospheric & Meteorological Unit', 'ACTIVE'),
('tm-id-005', 'TEAM-EPSILON', 'Emergency Rescue & Field Logistics', 'ACTIVE');

-- Seed Sample Team Members
INSERT OR IGNORE INTO member_details (id, teamid, name, role, activity_status) VALUES
('mem-001', 'TEAM-ALPHA', 'Dr. Aarav Sharma', 'Lead Glaciologist', 'OUT'),
('mem-002', 'TEAM-ALPHA', 'Captain Vikram Singh', 'Navigation Specialist', 'OUT'),
('mem-003', 'TEAM-BETA', 'Priya Patel', 'Drill Technician', 'IN'),
('mem-004', 'TEAM-BETA', 'Rohan Gupta', 'Equipment Engineer', 'IN'),
('mem-005', 'TEAM-DELTA', 'Dr. Sunita Menon', 'Chief Meteorologist', 'IN'),
('mem-006', 'TEAM-EPSILON', 'Major Rajesh Kumar', 'Field Operations Lead', 'OUT'),
('mem-007', 'TEAM-EPSILON', 'Dr. Meera Deshmukh', 'Medical Officer', 'IN');

