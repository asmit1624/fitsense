-- Migration: add onboarding session tracking columns
-- Run after 01_schema.sql if upgrading from an earlier version

ALTER TABLE users
  ADD COLUMN IF NOT EXISTS onboarding_done BOOLEAN DEFAULT FALSE;

ALTER TABLE onboarding_sessions
  ADD COLUMN IF NOT EXISTS answers JSONB DEFAULT '{}';

-- Index for fast telegram_id lookups
CREATE INDEX IF NOT EXISTS idx_users_telegram_id ON users(telegram_id);
CREATE INDEX IF NOT EXISTS idx_onboarding_telegram_id ON onboarding_sessions(telegram_id);
CREATE INDEX IF NOT EXISTS idx_recommendations_telegram_id ON recommendations(telegram_id);
