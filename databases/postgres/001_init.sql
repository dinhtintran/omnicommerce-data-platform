-- =============================================================================
-- PostgreSQL bootstrap — OmniCommerce "commerce" database
-- Owns: customers, orders, order_items, payments (tables arrive on Day 2).
--
-- The official postgres image runs files in /docker-entrypoint-initdb.d/
-- ONLY when the data directory is empty (first start of a fresh volume).
-- Editing this file later has no effect until the volume is recreated.
-- =============================================================================

-- Store and display timestamps in UTC regardless of the client's timezone.
DO $$
BEGIN
    EXECUTE format('ALTER DATABASE %I SET timezone TO %L', current_database(), 'UTC');
END
$$;

-- Records which init scripts have been applied to this database.
-- Same idea as the history table used by migration tools (Flyway, Alembic).
CREATE TABLE IF NOT EXISTS schema_migrations (
    version     TEXT        PRIMARY KEY,
    description TEXT        NOT NULL,
    applied_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO schema_migrations (version, description)
VALUES ('001', 'bootstrap: timezone and migration history');
