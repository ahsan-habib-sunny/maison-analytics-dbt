-- Catalogs
CREATE CATALOG IF NOT EXISTS maison_raw  COMMENT 'Raw files, bronze tables, pipeline control';     -- shared by all environments; only ingestion writes here
CREATE CATALOG IF NOT EXISTS maison_dev  COMMENT 'Development and CI';                             -- my dev schemas + one per pull request (CI)
CREATE CATALOG IF NOT EXISTS maison_prod COMMENT 'Production, written only by the scheduled job';  -- what end users or applications read

-- maison_raw schemas
CREATE SCHEMA IF NOT EXISTS maison_raw.landing;     -- volumes holding the source data files (landing zone for ingestion)
CREATE SCHEMA IF NOT EXISTS maison_raw.bronze;      -- BRONZE: raw files loaded as append-only Delta tables + ingest metadata
CREATE SCHEMA IF NOT EXISTS maison_raw.ops;         -- control tables: config, batch registry, checkpoints, file/run/error logs

-- maison_prod schemas
CREATE SCHEMA IF NOT EXISTS maison_prod.silver;     -- SILVER: cleaned, deduplicated, typed data; current state of each entity
CREATE SCHEMA IF NOT EXISTS maison_prod.snapshots;  -- SCD Type 2 history (dbt snapshots of customers and products)
CREATE SCHEMA IF NOT EXISTS maison_prod.gold;       -- GOLD: star schema (facts, dimensions) and aggregates for Power BI
CREATE SCHEMA IF NOT EXISTS maison_prod.audit;      -- dbt run results and rows that failed tests

-- Volumes (folders for files inside landing)
CREATE VOLUME IF NOT EXISTS maison_raw.landing.vendor_outbox;  -- every batch folder uploaded once (simulated supplier)
CREATE VOLUME IF NOT EXISTS maison_raw.landing.inbox;          -- files released for loading; ingestion reads only from here