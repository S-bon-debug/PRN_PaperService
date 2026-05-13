-- ============================================================
-- Notification Service Database
-- DB Name: notification_db
-- Handles: in-app notifications, email queue, delivery tracking
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TYPE notification_type AS ENUM ('new_paper', 'trend_alert', 'system');
CREATE TYPE delivery_channel AS ENUM ('inapp', 'email');
CREATE TYPE delivery_status AS ENUM ('pending', 'sent', 'failed');

CREATE TABLE notifications (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL,                  -- ref identity_db.users.id
    type            notification_type NOT NULL,
    title           VARCHAR(500) NOT NULL,
    body            TEXT,
    related_id      UUID,                           -- paper_id / keyword_id liên quan
    related_type    VARCHAR(50),                    -- 'paper', 'keyword', 'journal'
    is_read         BOOLEAN NOT NULL DEFAULT FALSE,
    read_at         TIMESTAMP WITH TIME ZONE,
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Queue gửi email (worker xử lý async)
CREATE TABLE email_queue (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL,
    to_email        VARCHAR(255) NOT NULL,
    subject         VARCHAR(500) NOT NULL,
    body_html       TEXT NOT NULL,
    status          delivery_status NOT NULL DEFAULT 'pending',
    attempts        SMALLINT NOT NULL DEFAULT 0,
    last_attempted  TIMESTAMP WITH TIME ZONE,
    sent_at         TIMESTAMP WITH TIME ZONE,
    error_message   TEXT,
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notif_user         ON notifications(user_id, is_read);
CREATE INDEX idx_notif_created      ON notifications(created_at DESC);
CREATE INDEX idx_notif_related      ON notifications(related_type, related_id);
CREATE INDEX idx_email_status       ON email_queue(status, attempts);
CREATE INDEX idx_email_user         ON email_queue(user_id);
