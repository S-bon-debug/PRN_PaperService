-- ============================================================
-- Storage Service Database
-- DB Name: storage_db
-- Handles: cloud file metadata, upload tracking, download/preview links
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE storage_files (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id         UUID NOT NULL, -- Tham chiếu tới UUID trong document_db
    original_file_name  VARCHAR(500) NOT NULL,
    cloud_file_key      VARCHAR(500) NOT NULL,
    file_size           BIGINT NOT NULL,
    mime_type           VARCHAR(100) NOT NULL,
    upload_status       VARCHAR(50) NOT NULL DEFAULT 'Completed', -- Uploading, Completed, Failed
    preview_url         VARCHAR(1000),
    download_url        VARCHAR(1000),
    created_at          TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_storage_files_doc   ON storage_files(document_id);
CREATE INDEX idx_storage_files_status ON storage_files(upload_status);

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_storage_files_updated_at
    BEFORE UPDATE ON storage_files
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
