-- =============================================================================
-- MySQL bootstrap — OmniCommerce "catalog" database
-- Owns: categories, products, inventory (tables arrive on Day 2).
--
-- The official mysql image runs files in /docker-entrypoint-initdb.d/ ONLY when
-- the data directory is empty, against the database named by MYSQL_DATABASE.
-- Editing this file later has no effect until the volume is recreated.
-- =============================================================================

-- Records which init scripts have been applied to this database.
-- Same idea as the history table used by migration tools (Flyway, Alembic).
CREATE TABLE IF NOT EXISTS schema_migrations (
    version     VARCHAR(50)  NOT NULL PRIMARY KEY,
    description VARCHAR(255) NOT NULL,
    applied_at  TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
) ENGINE = InnoDB;

INSERT INTO schema_migrations (version, description)
VALUES ('001', 'bootstrap: migration history');
