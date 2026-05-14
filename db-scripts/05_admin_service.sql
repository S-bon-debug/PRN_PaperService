-- ============================================================
-- Admin Service Database
-- DB Name: admin_db
-- Handles: system configurations, audit logging, analytics
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE system_configs (
    config_key      VARCHAR(100) PRIMARY KEY,
    config_value    VARCHAR(1000) NOT NULL,
    description     TEXT,
    updated_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE audit_logs (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL, -- Người thực hiện thao tác
    action          VARCHAR(255) NOT NULL, -- vd: DELETE_DOCUMENT, LOCK_USER
    target_id       UUID NOT NULL, -- ID của Document hoặc User bị tác động
    details         TEXT,
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_logs_user     ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_action   ON audit_logs(action);

-- Seed: Cấu hình mặc định
INSERT INTO system_configs (config_key, config_value, description) VALUES
('MAX_UPLOAD_SIZE_MB', '50', 'Dung lượng upload file tối đa (MB)'),
('AI_PROVIDER', 'Gemini', 'Nhà cung cấp dịch vụ AI mặc định'),
('ALLOW_REGISTRATION', 'True', 'Cho phép đăng ký tài khoản mới');
