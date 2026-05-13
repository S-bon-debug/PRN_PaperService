-- ============================================================
-- Admin Service Database
-- DB Name: admin_db
-- Handles: API source config, system settings, audit logs
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE api_sources (
    id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name                    VARCHAR(100) NOT NULL UNIQUE,
    base_url                TEXT NOT NULL,
    api_key_encrypted       TEXT,                   -- mã hóa ở app layer
    rate_limit_per_sec      INTEGER NOT NULL DEFAULT 10,
    is_active               BOOLEAN NOT NULL DEFAULT TRUE,
    sync_interval_hours     INTEGER NOT NULL DEFAULT 24,
    supported_fields        TEXT[],                 -- ['Computer Science', 'AI']
    last_synced_at          TIMESTAMP WITH TIME ZONE,
    created_at              TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE system_settings (
    key             VARCHAR(100) PRIMARY KEY,
    value           TEXT NOT NULL,
    description     TEXT,
    updated_by      UUID,                           -- ref identity_db.users.id
    updated_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Audit log mọi hành động admin
CREATE TABLE audit_logs (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    admin_user_id   UUID NOT NULL,                  -- ref identity_db.users.id
    action          VARCHAR(100) NOT NULL,           -- 'UPDATE_API_SOURCE', 'DISABLE_USER'
    entity_type     VARCHAR(100),
    entity_id       UUID,
    old_value       JSONB,
    new_value       JSONB,
    ip_address      VARCHAR(45),
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_admin        ON audit_logs(admin_user_id);
CREATE INDEX idx_audit_entity       ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_created      ON audit_logs(created_at DESC);

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_api_sources_updated_at
    BEFORE UPDATE ON api_sources FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Seed API sources
INSERT INTO api_sources (name, base_url, rate_limit_per_sec, is_active, sync_interval_hours, supported_fields) VALUES
    ('OpenAlex',        'https://api.openalex.org',                10, TRUE,  24, ARRAY['Computer Science', 'Artificial Intelligence']),
    ('SemanticScholar', 'https://api.semanticscholar.org/graph/v1', 1, TRUE,  24, ARRAY['Computer Science']),
    ('Crossref',        'https://api.crossref.org',                50, FALSE, 48, ARRAY[]::TEXT[]);

-- Seed system settings
INSERT INTO system_settings (key, value, description) VALUES
    ('max_search_results',      '50',    'Số kết quả tối đa mỗi lần search'),
    ('trend_snapshot_schedule', '0 2 * * *', 'Cron schedule tính trend snapshot'),
    ('email_from',              'noreply@journal-tracker.com', 'Email gửi notification');
