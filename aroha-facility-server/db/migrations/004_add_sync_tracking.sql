-- Migration 004: Add sync tracking column to stock and personnel tables

ALTER TABLE stocks_master ADD COLUMN is_synced INTEGER DEFAULT 0;
ALTER TABLE stock_logs ADD COLUMN is_synced INTEGER DEFAULT 0;
ALTER TABLE team_details ADD COLUMN is_synced INTEGER DEFAULT 0;
ALTER TABLE member_details ADD COLUMN is_synced INTEGER DEFAULT 0;
