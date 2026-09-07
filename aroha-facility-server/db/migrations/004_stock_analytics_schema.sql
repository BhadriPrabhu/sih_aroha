-- Store consumption observations and the latest analytics result for each stock item.
-- A USED stock log becomes one demand observation. ADDED logs are replenishment
-- events and are intentionally excluded from this table.

ALTER TABLE stocks_master ADD COLUMN essentiality_score REAL NOT NULL DEFAULT 0.5;
ALTER TABLE stocks_master ADD COLUMN lead_time_days REAL NOT NULL DEFAULT 30;
ALTER TABLE stocks_master ADD COLUMN forecast_daily_total REAL;
ALTER TABLE stocks_master ADD COLUMN forecast_mae REAL;
ALTER TABLE stocks_master ADD COLUMN analytics_updated_at DATETIME;

CREATE TABLE IF NOT EXISTS stock_demand_history (
    id TEXT PRIMARY KEY,
    stock_id TEXT NOT NULL REFERENCES stocks_master(id) ON DELETE CASCADE,
    quantity REAL NOT NULL CHECK(quantity >= 0),
    observed_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_stock_demand_history_stock_observed
    ON stock_demand_history(stock_id, observed_at);
