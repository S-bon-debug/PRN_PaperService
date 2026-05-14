-- ============================================================
-- Document Service Database
-- DB Name: document_db
-- Handles: document metadata, academic papers from Semantic Scholar/OpenAlex, subjects, filtering
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE subjects (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code            VARCHAR(50) NOT NULL UNIQUE,
    name            VARCHAR(255) NOT NULL,
    description     TEXT
);

CREATE TABLE documents (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title               VARCHAR(500) NOT NULL,
    abstract_text       TEXT,
    authors             VARCHAR(500),
    journal_name        VARCHAR(255),
    publication_year    INT,
    subject_id          UUID NOT NULL REFERENCES subjects(id) ON DELETE RESTRICT,
    uploader_id         UUID, -- Nullable nếu là bài báo tự động kéo từ API về
    storage_file_id     UUID, -- Nullable nếu chỉ kéo metadata từ Semantic Scholar
    external_api_source VARCHAR(50) DEFAULT 'LocalUpload', -- LocalUpload, SemanticScholar, OpenAlex, Crossref
    external_id         VARCHAR(255), -- ID bài báo từ bên thứ 3
    status              VARCHAR(50) NOT NULL DEFAULT 'Approved', -- Pending, Approved, Rejected
    view_count          INT NOT NULL DEFAULT 0,
    download_count      INT NOT NULL DEFAULT 0,
    created_at          TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_subjects_code       ON subjects(code);
CREATE INDEX idx_documents_subject   ON documents(subject_id);
CREATE INDEX idx_documents_source    ON documents(external_api_source);
CREATE INDEX idx_documents_status    ON documents(status);

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_documents_updated_at
    BEFORE UPDATE ON documents
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Seed: Danh sách môn học mẫu
INSERT INTO subjects (id, code, name, description) VALUES
(uuid_generate_v4(), 'CS101', 'Computer Science & AI', 'Khoa học máy tính và Trí tuệ nhân tạo'),
(uuid_generate_v4(), 'PRN232', 'Building Advanced Web Services with .NET', 'Khóa học lập trình C# Web API nâng cao'),
(uuid_generate_v4(), 'EXE201', 'Experiential Entrepreneurship 1', 'Khóa học khởi nghiệp thực tế');

-- Seed: Bài báo mẫu từ Semantic Scholar
INSERT INTO documents (id, title, abstract_text, authors, journal_name, publication_year, subject_id, external_api_source, external_id) VALUES
(uuid_generate_v4(), 'Attention Is All You Need', 'The dominant sequence transduction models are based on complex recurrent or convolutional neural networks...', 'Vaswani et al.', 'NeurIPS', 2017, (SELECT id FROM subjects WHERE code = 'CS101'), 'SemanticScholar', 'arXiv:1706.03762');
