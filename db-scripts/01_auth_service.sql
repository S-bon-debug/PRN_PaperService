-- ============================================================
-- Auth Service Database
-- DB Name: auth_db
-- Handles: authentication, authorization, JWT, user profiles
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE users (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email           VARCHAR(255) NOT NULL UNIQUE,
    password_hash   VARCHAR(512) NOT NULL,
    full_name       VARCHAR(100) NOT NULL,
    avatar_url      VARCHAR(512),
    role            VARCHAR(50) NOT NULL DEFAULT 'Student', -- Student, Teacher, Admin
    status          VARCHAR(50) NOT NULL DEFAULT 'Active',  -- Active, Locked
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE refresh_tokens (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token           VARCHAR(512) NOT NULL UNIQUE,
    expires_at      TIMESTAMP WITH TIME ZONE NOT NULL,
    is_revoked      BOOLEAN NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_users_email         ON users(email);
CREATE INDEX idx_refresh_token       ON refresh_tokens(token);
CREATE INDEX idx_refresh_token_user  ON refresh_tokens(user_id);

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Seed: default admin
INSERT INTO users (id, email, password_hash, full_name, role, status)
VALUES (uuid_generate_v4(), 'admin@jts.com', 'hashed_password_placeholder', 'System Admin', 'Admin', 'Active');
