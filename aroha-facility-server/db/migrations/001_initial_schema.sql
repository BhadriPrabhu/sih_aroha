-- Initial Database Schema for AROHA Facility Server (SQLite)

-- 1. Stations Table
CREATE TABLE IF NOT EXISTS stations (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    code TEXT NOT NULL UNIQUE,
    latitude REAL,
    longitude REAL,
    is_local INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Seed Local & Remote Stations
INSERT OR IGNORE INTO stations (id, name, code, latitude, longitude, is_local) VALUES 
('stn-maitri', 'Maitri Station', 'MAITRI', -70.7667, 11.7333, 1),
('stn-bharati', 'Bharati Station', 'BHARATI', -69.4072, 76.1947, 0);

-- 2. Users Table
CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY,
    username TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    full_name TEXT NOT NULL,
    role TEXT NOT NULL CHECK(role IN ('ADMIN', 'STATION_MANAGER', 'LOGISTICS_OFFICER', 'RESEARCHER')),
    station_id TEXT REFERENCES stations(id),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Seed Default Admin User (hash for default password)
INSERT OR IGNORE INTO users (id, username, password_hash, full_name, role, station_id) VALUES
('usr-admin-01', 'station_admin', 'scrypt:32768:8:1$salt123$hash_placeholder', 'Station Administrator', 'ADMIN', 'stn-maitri');

-- 3. Inventory Items Table
CREATE TABLE IF NOT EXISTS inventory_items (
    id TEXT PRIMARY KEY,
    station_id TEXT NOT NULL REFERENCES stations(id),
    item_code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    category TEXT NOT NULL,
    quantity REAL NOT NULL DEFAULT 0,
    unit TEXT NOT NULL DEFAULT 'units',
    min_threshold REAL DEFAULT 10,
    essentiality_score REAL DEFAULT 0.5, -- [0.0 - 1.0] Criticality weighting
    lead_time_days INTEGER DEFAULT 30,
    shelf_life_days INTEGER,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 4. Cargo Shipments Table
CREATE TABLE IF NOT EXISTS cargo_shipments (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    origin_station_id TEXT NOT NULL REFERENCES stations(id),
    destination_station_id TEXT NOT NULL REFERENCES stations(id),
    status TEXT NOT NULL CHECK(status IN ('DRAFT', 'OPTIMIZED', 'APPROVED', 'IN_TRANSIT', 'DELIVERED')) DEFAULT 'DRAFT',
    max_payload_weight_kg REAL NOT NULL,
    max_payload_volume_m3 REAL NOT NULL,
    departure_date TEXT,
    created_by TEXT REFERENCES users(id),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 5. Cargo Items Table (Manifest items inside shipment)
CREATE TABLE IF NOT EXISTS cargo_items (
    id TEXT PRIMARY KEY,
    shipment_id TEXT NOT NULL REFERENCES cargo_shipments(id) ON DELETE CASCADE,
    inventory_item_id TEXT NOT NULL REFERENCES inventory_items(id),
    allocated_quantity REAL NOT NULL,
    priority_score REAL DEFAULT 0,
    risk_reduction_val REAL DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 6. SATCOM Low-Bandwidth Sync Audit Logs
CREATE TABLE IF NOT EXISTS sync_audit_logs (
    id TEXT PRIMARY KEY,
    station_id TEXT NOT NULL REFERENCES stations(id),
    payload_type TEXT NOT NULL,
    payload_hash TEXT NOT NULL,
    records_count INTEGER DEFAULT 0,
    status TEXT CHECK(status IN ('PENDING', 'SYNCED', 'FAILED')) DEFAULT 'PENDING',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    synced_at DATETIME
);
