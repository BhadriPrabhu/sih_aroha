-- AROHA Remote Server Flyway Migration V1: Central Database Schema

CREATE TABLE IF NOT EXISTS stations (
    station_id VARCHAR(50) PRIMARY KEY,
    station_name VARCHAR(100) NOT NULL,
    location VARCHAR(100) NOT NULL,
    latitude DOUBLE DEFAULT 0.0,
    longitude DOUBLE DEFAULT 0.0,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    last_sync_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS inventory_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    station_id VARCHAR(50) NOT NULL,
    item_id VARCHAR(50) NOT NULL,
    item_code VARCHAR(50) NOT NULL,
    name VARCHAR(150) NOT NULL,
    category VARCHAR(50) NOT NULL,
    quantity DOUBLE NOT NULL DEFAULT 0.0,
    unit VARCHAR(20) DEFAULT 'units',
    min_threshold DOUBLE DEFAULT 10.0,
    essentiality_score DOUBLE DEFAULT 0.5,
    lead_time_days INT DEFAULT 30,
    shelf_life_days INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uk_station_item UNIQUE (station_id, item_id),
    CONSTRAINT fk_inventory_station FOREIGN KEY (station_id) REFERENCES stations(station_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS stocks_master (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    station_id VARCHAR(50) NOT NULL,
    stock_id VARCHAR(50) NOT NULL,
    item_code VARCHAR(50),
    item_name VARCHAR(150) NOT NULL,
    category VARCHAR(50) NOT NULL,
    sub_category VARCHAR(50),
    unit VARCHAR(20) DEFAULT 'Units',
    stock_available DOUBLE NOT NULL DEFAULT 0.0,
    stock_consumed DOUBLE NOT NULL DEFAULT 0.0,
    present_stock DOUBLE NOT NULL DEFAULT 0.0,
    total_quantity INT NOT NULL DEFAULT 0,
    min_required_quantity INT NOT NULL DEFAULT 0,
    criticality_rate DOUBLE DEFAULT 0.5,
    criticality_score DOUBLE DEFAULT 0.0,
    essentiality_score DOUBLE DEFAULT 0.5,
    lead_time_days DOUBLE DEFAULT 30.0,
    forecast_daily_total DOUBLE,
    forecast_mae DOUBLE,
    analytics_updated_at TIMESTAMP NULL,
    criticality_status VARCHAR(20) DEFAULT 'MEDIUM',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uk_station_stock UNIQUE (station_id, stock_id),
    CONSTRAINT fk_stocks_station FOREIGN KEY (station_id) REFERENCES stations(station_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS stock_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    station_id VARCHAR(50) NOT NULL,
    log_id VARCHAR(50) NOT NULL,
    stock_id VARCHAR(50) NOT NULL,
    operation_type VARCHAR(20) NOT NULL,
    action VARCHAR(20),
    change_qty INT NOT NULL DEFAULT 0,
    quantity DOUBLE DEFAULT 0.0,
    reason VARCHAR(255),
    notes VARCHAR(255),
    logged_by VARCHAR(100),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_station_log UNIQUE (station_id, log_id),
    CONSTRAINT fk_logs_station FOREIGN KEY (station_id) REFERENCES stations(station_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS stock_demand_history (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    station_id VARCHAR(50) NOT NULL,
    demand_id VARCHAR(50) NOT NULL,
    stock_id VARCHAR(50) NOT NULL,
    quantity DOUBLE NOT NULL DEFAULT 0.0,
    observed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_station_demand UNIQUE (station_id, demand_id),
    CONSTRAINT fk_demand_station FOREIGN KEY (station_id) REFERENCES stations(station_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS teams_master (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    station_id VARCHAR(50) NOT NULL,
    team_id VARCHAR(50) NOT NULL,
    team_name VARCHAR(150) NOT NULL,
    active_status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uk_station_team UNIQUE (station_id, team_id),
    CONSTRAINT fk_teams_station FOREIGN KEY (station_id) REFERENCES stations(station_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS member_details (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    station_id VARCHAR(50) NOT NULL,
    member_id VARCHAR(50) NOT NULL,
    team_id VARCHAR(50) NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    role VARCHAR(100),
    status VARCHAR(20) DEFAULT 'ACTIVE',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uk_station_member UNIQUE (station_id, member_id),
    CONSTRAINT fk_members_station FOREIGN KEY (station_id) REFERENCES stations(station_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS cargo_shipments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    shipment_id VARCHAR(50) NOT NULL UNIQUE,
    title VARCHAR(150) NOT NULL,
    origin_station_id VARCHAR(50) NOT NULL,
    destination_station_id VARCHAR(50) NOT NULL,
    status VARCHAR(20) DEFAULT 'DRAFT',
    max_payload_weight_kg DOUBLE NOT NULL DEFAULT 0.0,
    max_payload_volume_m3 DOUBLE NOT NULL DEFAULT 0.0,
    departure_date VARCHAR(50),
    created_by VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_shipment_origin FOREIGN KEY (origin_station_id) REFERENCES stations(station_id) ON DELETE CASCADE,
    CONSTRAINT fk_shipment_dest FOREIGN KEY (destination_station_id) REFERENCES stations(station_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS cargo_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    cargo_item_id VARCHAR(50) NOT NULL UNIQUE,
    shipment_id VARCHAR(50) NOT NULL,
    inventory_item_id VARCHAR(50) NOT NULL,
    allocated_quantity DOUBLE NOT NULL DEFAULT 0.0,
    priority_score DOUBLE DEFAULT 0.0,
    risk_reduction_val DOUBLE DEFAULT 0.0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_cargo_shipment FOREIGN KEY (shipment_id) REFERENCES cargo_shipments(shipment_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS sync_audit_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    station_id VARCHAR(50) NOT NULL,
    sync_batch_id VARCHAR(100) NOT NULL,
    payload_type VARCHAR(50) NOT NULL,
    records_count INT DEFAULT 0,
    sync_status VARCHAR(20) DEFAULT 'SUCCESS',
    synced_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Seed Default Base Stations (Maitri & Bharati)
INSERT IGNORE INTO stations (station_id, station_name, location, latitude, longitude, status) 
VALUES ('STATION-MAITRI', 'Maitri Antarctic Base', 'Queen Maud Land, Antarctica', -70.7667, 11.7333, 'ACTIVE');

INSERT IGNORE INTO stations (station_id, station_name, location, latitude, longitude, status) 
VALUES ('STATION-BHARATI', 'Bharati Antarctic Base', 'Larsemann Hills, Antarctica', -69.4072, 76.1947, 'ACTIVE');

-- Seed Default Teams
INSERT IGNORE INTO teams_master (station_id, team_id, team_name, active_status) VALUES
('STATION-MAITRI', 'TEAM-ALPHA', 'Traverse Reconnaissance Alpha', 'ACTIVE'),
('STATION-MAITRI', 'TEAM-BETA', 'Ice Core Drilling Unit', 'ACTIVE'),
('STATION-MAITRI', 'TEAM-GAMMA', 'Station Maintenance Crew', 'INACTIVE'),
('STATION-BHARATI', 'TEAM-DELTA', 'Atmospheric & Meteorological Unit', 'ACTIVE'),
('STATION-BHARATI', 'TEAM-EPSILON', 'Emergency Rescue & Field Logistics', 'ACTIVE');

-- Seed Default Team Members
INSERT IGNORE INTO member_details (station_id, member_id, team_id, full_name, role, status) VALUES
('STATION-MAITRI', 'mem-001', 'TEAM-ALPHA', 'Dr. Aarav Sharma', 'Lead Glaciologist', 'OUT'),
('STATION-MAITRI', 'mem-002', 'TEAM-ALPHA', 'Captain Vikram Singh', 'Navigation Specialist', 'OUT'),
('STATION-MAITRI', 'mem-003', 'TEAM-BETA', 'Priya Patel', 'Drill Technician', 'IN'),
('STATION-MAITRI', 'mem-004', 'TEAM-BETA', 'Rohan Gupta', 'Equipment Engineer', 'IN'),
('STATION-BHARATI', 'mem-005', 'TEAM-DELTA', 'Dr. Sunita Menon', 'Chief Meteorologist', 'IN'),
('STATION-BHARATI', 'mem-006', 'TEAM-EPSILON', 'Major Rajesh Kumar', 'Field Operations Lead', 'OUT'),
('STATION-BHARATI', 'mem-007', 'TEAM-EPSILON', 'Dr. Meera Deshmukh', 'Medical Officer', 'IN');


