-- ============================================================
-- Trend Service Database
-- DB Name: trend_db
-- Handles: publication trend snapshots, analytics, reports
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- keyword_id tham chiếu sang paper_db (không FK xuyên DB, lưu UUID thôi)
CREATE TABLE trend_snapshots (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    keyword_id      UUID NOT NULL,                  -- ref paper_db.keywords.id
    keyword_term    VARCHAR(255) NOT NULL,           -- denormalized để tránh join xuyên DB
    year            SMALLINT NOT NULL,
    paper_count     INTEGER NOT NULL DEFAULT 0,
    citation_sum    INTEGER NOT NULL DEFAULT 0,
    growth_rate     FLOAT,                           -- % so với năm trước
    recorded_at     TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_trend UNIQUE (keyword_id, year)
);

-- Lưu snapshot trend theo journal
CREATE TABLE journal_trend_snapshots (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    journal_id      UUID NOT NULL,                  -- ref paper_db.journals.id
    journal_name    VARCHAR(500) NOT NULL,
    year            SMALLINT NOT NULL,
    paper_count     INTEGER NOT NULL DEFAULT 0,
    citation_sum    INTEGER NOT NULL DEFAULT 0,
    growth_rate     FLOAT,
    recorded_at     TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_journal_trend UNIQUE (journal_id, year)
);

-- Cache kết quả report đã generate
CREATE TABLE report_cache (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    report_type     VARCHAR(100) NOT NULL,           -- 'keyword_trend', 'top_journals', etc.
    params_hash     VARCHAR(64) NOT NULL,            -- MD5 của params để cache lookup
    result_json     JSONB NOT NULL,
    generated_at    TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    expires_at      TIMESTAMP WITH TIME ZONE NOT NULL,

    CONSTRAINT uq_report_cache UNIQUE (report_type, params_hash)
);

CREATE INDEX idx_trend_keyword      ON trend_snapshots(keyword_id);
CREATE INDEX idx_trend_keyword_term ON trend_snapshots(keyword_term);
CREATE INDEX idx_trend_year         ON trend_snapshots(year);
CREATE INDEX idx_journal_trend      ON journal_trend_snapshots(journal_id);
CREATE INDEX idx_journal_trend_year ON journal_trend_snapshots(year);
CREATE INDEX idx_report_cache_type  ON report_cache(report_type, params_hash);
CREATE INDEX idx_report_expires     ON report_cache(expires_at);
