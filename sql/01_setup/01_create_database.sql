-- 01_create_database.sql
-- Purpose: Ensure SNOWFLAKE_EXAMPLE database exists for the Event Intelligence Platform demo.
-- Safe to re-run; uses IF NOT EXISTS.
-- Author: SE Community | Created: 2025-12-10 | Expires: 2026-01-09

CREATE DATABASE IF NOT EXISTS SNOWFLAKE_EXAMPLE
  COMMENT = 'DEMO: Shared database for Event Intelligence Platform and other demos | Author: SE Community | Expires: 2026-01-09';

