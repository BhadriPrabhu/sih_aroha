-- Migration 005: Add criticality_status column to stocks_master table

ALTER TABLE stocks_master ADD COLUMN criticality_status TEXT DEFAULT 'MEDIUM';
