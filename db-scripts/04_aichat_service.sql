-- ============================================================
-- AI Chat Service Database
-- DB Name: aichat_db
-- Handles: chatbot sessions, messages history, RAG document references
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE chat_sessions (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL, -- Tham chiếu tới UUID trong auth_db
    document_id     UUID,          -- Tham chiếu tới UUID trong document_db (nếu chat về tài liệu cụ thể)
    title           VARCHAR(255) NOT NULL,
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE chat_messages (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id      UUID NOT NULL REFERENCES chat_sessions(id) ON DELETE CASCADE,
    sender_type     VARCHAR(50) NOT NULL, -- User hoặc AI
    content         TEXT NOT NULL,
    prompt_tokens   INT DEFAULT 0,
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_chat_sessions_user  ON chat_sessions(user_id);
CREATE INDEX idx_chat_messages_sess  ON chat_messages(session_id);

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_chat_sessions_updated_at
    BEFORE UPDATE ON chat_sessions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
