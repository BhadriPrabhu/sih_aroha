-- Migration 002: Stocks Master and Stock Transaction Audit Logs

-- 1. Stocks Master Table
CREATE TABLE IF NOT EXISTS stocks_master (
    id TEXT PRIMARY KEY,
    station_id TEXT NOT NULL REFERENCES stations(id),
    category TEXT NOT NULL,
    name TEXT NOT NULL,
    stock_available REAL NOT NULL DEFAULT 0,
    stock_consumed REAL NOT NULL DEFAULT 0,
    present_stock REAL NOT NULL DEFAULT 0,
    criticality_rate REAL NOT NULL DEFAULT 0.5 CHECK(criticality_rate >= 0.0 AND criticality_rate <= 1.0),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 2. Stock Audit Transaction Log Table
CREATE TABLE IF NOT EXISTS stock_logs (
    id TEXT PRIMARY KEY,
    stock_id TEXT NOT NULL REFERENCES stocks_master(id) ON DELETE CASCADE,
    action TEXT NOT NULL CHECK(action IN ('ADDED', 'USED')),
    quantity REAL NOT NULL CHECK(quantity > 0),
    notes TEXT,
    logged_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Seed Initial Sample Stock Data
INSERT OR IGNORE INTO stocks_master (id, station_id, category, name, stock_available, stock_consumed, present_stock, criticality_rate) VALUES
('stk-001', 'stn-maitri', 'Medical', 'Emergency Oxygen Canisters', 50.0, 5.0, 45.0, 0.95),
('stk-002', 'stn-maitri', 'Rations', 'High-Calorie Freeze Dried Meals', 500.0, 120.0, 380.0, 0.80),
('stk-003', 'stn-bharati', 'Fuel', 'Jet-A1 Sub-Zero Fuel Drums', 200.0, 40.0, 160.0, 0.90);
