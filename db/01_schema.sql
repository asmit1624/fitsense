-- FitSense Database Schema
-- Run this first: sets up all tables

CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    telegram_id BIGINT UNIQUE NOT NULL,
    username TEXT,
    top_size TEXT,
    bottom_size TEXT,
    fit_feel TEXT,               -- snug / true-to-size / relaxed
    chest_min_cm INTEGER,
    chest_max_cm INTEGER,
    skin_tone TEXT,              -- warm_light / warm_medium / cool_light / cool_medium / deep
    style_preferences TEXT[],   -- e.g. {casual_western, ethnic}
    budget_band TEXT,            -- e.g. 500_1500
    onboarding_done BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS product_catalog (
    id SERIAL PRIMARY KEY,
    url TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    brand TEXT NOT NULL,
    price INTEGER,
    fabric TEXT,
    colours TEXT[],
    category TEXT,               -- top / bottom / coord / ethnic / etc.
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS brand_size_guides (
    id SERIAL PRIMARY KEY,
    brand TEXT NOT NULL,
    category TEXT NOT NULL,      -- top / bottom
    size_chart JSONB NOT NULL,   -- {"S": {"chest_cm": 96}, "M": {"chest_cm": 101}, ...}
    fit_note TEXT,               -- e.g. "Snitch runs slim. Size up for relaxed fit."
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(brand, category)
);

CREATE TABLE IF NOT EXISTS recommendations (
    id SERIAL PRIMARY KEY,
    telegram_id BIGINT REFERENCES users(telegram_id),
    product_url TEXT,
    product_name TEXT,
    fit_score INTEGER,
    size_recommendation TEXT,
    verdict TEXT,                -- Buy / Maybe / Skip
    full_response JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS onboarding_sessions (
    id SERIAL PRIMARY KEY,
    telegram_id BIGINT UNIQUE REFERENCES users(telegram_id),
    current_question INTEGER DEFAULT 1,
    answers JSONB DEFAULT '{}',
    started_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS wishlists (
    id SERIAL PRIMARY KEY,
    telegram_id BIGINT REFERENCES users(telegram_id),
    product_url TEXT,
    product_name TEXT,
    price INTEGER,
    added_at TIMESTAMPTZ DEFAULT NOW()
);
