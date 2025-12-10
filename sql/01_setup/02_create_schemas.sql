-- 02_create_schemas.sql
-- Purpose: Create project schemas for Event Intelligence Platform.
-- Safe to re-run; uses IF NOT EXISTS.
-- Author: SE Community | Created: 2025-12-10 | Expires: 2026-01-09

USE DATABASE SNOWFLAKE_EXAMPLE;

CREATE SCHEMA IF NOT EXISTS EVENT_INTELLIGENCE
  COMMENT = 'DEMO: Event Intelligence Platform | Author: SE Community | Expires: 2026-01-09';

CREATE SCHEMA IF NOT EXISTS EVENT_INTELLIGENCE_GIT_REPOS
  COMMENT = 'DEMO: Git repos for Event Intelligence Platform | Author: SE Community | Expires: 2026-01-09';

CREATE SCHEMA IF NOT EXISTS SEMANTIC_MODELS
  COMMENT = 'DEMO: Shared semantic models | Author: SE Community | Expires: 2026-01-09';

