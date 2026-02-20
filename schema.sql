-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Mosque Display Settings
CREATE TABLE mosque_display_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    mosque_id UUID NOT NULL,
    mosque_name VARCHAR(255) NOT NULL,
    mosque_address TEXT NOT NULL,
    running_text TEXT,
    logo_url TEXT,
    iqomah_duration INT DEFAULT 300, -- Seconds
    sholat_duration INT DEFAULT 600, -- Seconds
    is_emergency_active BOOLEAN DEFAULT FALSE,
    emergency_message TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_mosque_settings_mosque_id UNIQUE (mosque_id)
);

-- 2. Mosque Slides
CREATE TABLE mosque_slides (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    mosque_id UUID NOT NULL,
    image_url TEXT NOT NULL,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index for faster retrieval of slides by mosque
CREATE INDEX idx_mosque_slides_mosque_id ON mosque_slides(mosque_id);

-- 3. Mosque Display Tokens
CREATE TABLE mosque_display_tokens (
    token VARCHAR(255) PRIMARY KEY, -- Can use UUID or random string
    mosque_id UUID NOT NULL,
    label VARCHAR(100), -- e.g., "Lobby TV", "Main Hall"
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_token_mosque FOREIGN KEY (mosque_id) REFERENCES mosque_display_settings(mosque_id) ON DELETE CASCADE
);

-- Trigger to update updated_at on settings change
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_mosque_display_settings_modtime
    BEFORE UPDATE ON mosque_display_settings
    FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column();
