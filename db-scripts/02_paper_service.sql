-- ============================================================
-- Paper Service Database
-- DB Name: paper_db
-- Handles: papers, authors, journals, keywords, search cache
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

CREATE TYPE paper_source AS ENUM ('openalex', 'semantic_scholar', 'crossref');
CREATE TYPE keyword_source AS ENUM ('user', 'api');

CREATE TABLE journals (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    external_id     VARCHAR(255) UNIQUE,
    name            VARCHAR(500) NOT NULL,
    issn            VARCHAR(20),
    e_issn          VARCHAR(20),
    publisher       VARCHAR(255),
    field           VARCHAR(255),
    homepage_url    TEXT,
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE authors (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    external_id     VARCHAR(255) UNIQUE,
    name            VARCHAR(255) NOT NULL,
    affiliation     VARCHAR(500),
    orcid           VARCHAR(50),
    homepage_url    TEXT,
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE keywords (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    term            VARCHAR(255) NOT NULL UNIQUE,
    normalized_term VARCHAR(255) NOT NULL,
    source          keyword_source NOT NULL DEFAULT 'api',
    usage_count     INTEGER NOT NULL DEFAULT 0,
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE papers (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    external_id     VARCHAR(255) NOT NULL,
    source          paper_source NOT NULL,
    title           TEXT NOT NULL,
    abstract        TEXT,
    publication_year SMALLINT,
    doi             VARCHAR(255),
    url             TEXT,
    citation_count  INTEGER NOT NULL DEFAULT 0,
    reference_count INTEGER NOT NULL DEFAULT 0,
    fields_of_study TEXT[],
    journal_id      UUID REFERENCES journals(id) ON DELETE SET NULL,
    raw_data        JSONB,
    synced_at       TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_paper_source UNIQUE (external_id, source)
);

CREATE TABLE paper_authors (
    paper_id        UUID NOT NULL REFERENCES papers(id) ON DELETE CASCADE,
    author_id       UUID NOT NULL REFERENCES authors(id) ON DELETE CASCADE,
    author_order    SMALLINT NOT NULL DEFAULT 0,
    PRIMARY KEY (paper_id, author_id)
);

CREATE TABLE paper_keywords (
    paper_id        UUID NOT NULL REFERENCES papers(id) ON DELETE CASCADE,
    keyword_id      UUID NOT NULL REFERENCES keywords(id) ON DELETE CASCADE,
    relevance_score FLOAT,
    PRIMARY KEY (paper_id, keyword_id)
);

-- Indexes
CREATE INDEX idx_papers_external_id  ON papers(external_id);
CREATE INDEX idx_papers_year         ON papers(publication_year);
CREATE INDEX idx_papers_journal      ON papers(journal_id);
CREATE INDEX idx_papers_doi          ON papers(doi) WHERE doi IS NOT NULL;
CREATE INDEX idx_papers_title        ON papers USING gin(title gin_trgm_ops);
CREATE INDEX idx_papers_abstract     ON papers USING gin(abstract gin_trgm_ops);
CREATE INDEX idx_papers_fields       ON papers USING gin(fields_of_study);
CREATE INDEX idx_journals_name       ON journals USING gin(name gin_trgm_ops);
CREATE INDEX idx_authors_name        ON authors USING gin(name gin_trgm_ops);
CREATE INDEX idx_authors_orcid       ON authors(orcid) WHERE orcid IS NOT NULL;
CREATE INDEX idx_keywords_term       ON keywords USING gin(term gin_trgm_ops);
CREATE INDEX idx_keywords_normalized ON keywords(normalized_term);
CREATE INDEX idx_paper_authors_auth  ON paper_authors(author_id);
CREATE INDEX idx_paper_keywords_kw   ON paper_keywords(keyword_id);

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_journals_updated_at
    BEFORE UPDATE ON journals FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_authors_updated_at
    BEFORE UPDATE ON authors  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_papers_updated_at
    BEFORE UPDATE ON papers   FOR EACH ROW EXECUTE FUNCTION update_updated_at();
