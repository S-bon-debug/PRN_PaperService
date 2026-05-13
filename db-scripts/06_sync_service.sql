-- ============================================================
-- Sync Service Database
-- DB Name: sync_db
-- Handles: scheduled API sync jobs, crawl logs, job tracking
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TYPE sync_status AS ENUM ('running', 'success', 'failed', 'cancelled');

CREATE TABLE api_sync_jobs (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    source_name         VARCHAR(100) NOT NULL,       -- 'OpenAlex', 'SemanticScholar'
    source_base_url     TEXT NOT NULL,
    query_params        JSONB,                        -- filter gì, field gì
    scheduled_at        TIMESTAMP WITH TIME ZONE,
    started_at          TIMESTAMP WITH TIME ZONE,
    finished_at         TIMESTAMP WITH TIME ZONE,
    status              sync_status NOT NULL DEFAULT 'running',
    papers_fetched      INTEGER NOT NULL DEFAULT 0,
    papers_inserted     INTEGER NOT NULL DEFAULT 0,
    papers_updated      INTEGER NOT NULL DEFAULT 0,
    error_message       TEXT,
    created_at          TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Chi tiết lỗi từng record khi sync
CREATE TABLE sync_errors (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_id          UUID NOT NULL REFERENCES api_sync_jobs(id) ON DELETE CASCADE,
    external_id     VARCHAR(255),
    error_type      VARCHAR(100),
    error_detail    TEXT,
    occurred_at     TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Checkpoint để tiếp tục sync nếu bị gián đoạn
CREATE TABLE sync_cursors (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    source_name     VARCHAR(100) NOT NULL UNIQUE,
    last_cursor     TEXT,                            -- cursor / offset / page token
    last_synced_at  TIMESTAMP WITH TIME ZONE,
    updated_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_sync_jobs_status   ON api_sync_jobs(status);
CREATE INDEX idx_sync_jobs_source   ON api_sync_jobs(source_name);
CREATE INDEX idx_sync_jobs_started  ON api_sync_jobs(started_at DESC);
CREATE INDEX idx_sync_errors_job    ON sync_errors(job_id);

-- Seed cursors
INSERT INTO sync_cursors (source_name) VALUES
    ('OpenAlex'),
    ('SemanticScholar'),
    ('Crossref');
