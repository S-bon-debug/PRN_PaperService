-- ============================================================
-- User Service Database
-- DB Name: user_db
-- Handles: bookmarks, follows, search history, user profile
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

CREATE TYPE bookmark_entity AS ENUM ('paper', 'keyword', 'journal');
CREATE TYPE follow_type AS ENUM ('keyword', 'journal', 'topic');

-- Profile mở rộng (auth info nằm ở identity_db)
-- user_id tham chiếu identity_db.users.id — không FK xuyên DB
CREATE TABLE user_profiles (
    user_id         UUID PRIMARY KEY,               -- ref identity_db.users.id
    bio             TEXT,
    institution     VARCHAR(255),
    research_fields TEXT[],
    website_url     TEXT,
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE bookmarks (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL,                  -- ref identity_db.users.id
    entity_type     bookmark_entity NOT NULL,
    entity_id       UUID NOT NULL,                  -- paper_id / keyword_id / journal_id
    entity_title    TEXT,                           -- denormalized để hiện nhanh
    note            TEXT,
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_bookmark UNIQUE (user_id, entity_type, entity_id)
);

CREATE TABLE follows (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL,                  -- ref identity_db.users.id
    follow_type     follow_type NOT NULL,
    target_id       UUID NOT NULL,                  -- keyword_id / journal_id
    target_name     VARCHAR(500),                   -- denormalized
    notify_email    BOOLEAN NOT NULL DEFAULT TRUE,
    notify_inapp    BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_follow UNIQUE (user_id, follow_type, target_id)
);

CREATE TABLE search_history (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID,                           -- NULL nếu guest
    query           TEXT NOT NULL,
    search_type     VARCHAR(50),                    -- keyword, author, journal
    result_count    INTEGER,
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_bookmarks_user     ON bookmarks(user_id);
CREATE INDEX idx_bookmarks_entity   ON bookmarks(entity_type, entity_id);
CREATE INDEX idx_follows_user       ON follows(user_id);
CREATE INDEX idx_follows_target     ON follows(follow_type, target_id);
CREATE INDEX idx_search_user        ON search_history(user_id);
CREATE INDEX idx_search_created     ON search_history(created_at DESC);
CREATE INDEX idx_search_query       ON search_history USING gin(query gin_trgm_ops);

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_profile_updated_at
    BEFORE UPDATE ON user_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at();
