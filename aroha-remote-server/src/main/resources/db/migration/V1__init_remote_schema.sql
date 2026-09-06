-- AROHA Remote Server Flyway Migration V1: Central Database Schema

CREATE TABLE IF NOT EXISTS stations (
    station_id VARCHAR(50) PRIMARY KEY,
    station_name VARCHAR(100) NOT NULL,
    location VARCHAR(100) NOT NULL,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    last_sync_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS stocks_master (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    station_id VARCHAR(50) NOT NULL,
    stock_id VARCHAR(50) NOT NULL,
    item_code VARCHAR(50) NOT NULL,
    item_name VARCHAR(150) NOT NULL,
    category VARCHAR(50) NOT NULL,
    sub_category VARCHAR(50),
    unit VARCHAR(20) DEFAULT 'Units',
    total_quantity INT NOT NULL DEFAULT 0,
    min_required_quantity INT NOT NULL DEFAULT 0,
    criticality_score DOUBLE DEFAULT 0.0,
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
    change_qty INT NOT NULL,
    reason VARCHAR(255),
    logged_by VARCHAR(100),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_station_log UNIQUE (station_id, log_id),
    CONSTRAINT fk_logs_station FOREIGN KEY (station_id) REFERENCES stations(station_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS teams_master (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    station_id VARCHAR(50) NOT NULL,
    team_id VARCHAR(50) NOT NULL,
    team_name VARCHAR(150) NOT NULL,
    active_status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
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
INSERT IGNORE INTO stations (station_id, station_name, location, status) 
VALUES ('STATION-MAITRI', 'Maitri Antarctic Base', 'Queen Maud Land, Antarctica', 'ACTIVE');

INSERT IGNORE INTO stations (station_id, station_name, location, status) 
VALUES ('STATION-BHARATI', 'Bharati Antarctic Base', 'Larsemann Hills, Antarctica', 'ACTIVE');
