/*
 * ============================================================================
 * EVENT INTELLIGENCE PLATFORM - TEARDOWN / CLEANUP
 * ============================================================================
 * Author: SE Community
 * Created: 2025-12-10
 * Expires: 2026-01-09
 * Purpose: Complete cleanup of all demo objects
 * 
 * ⚠️ WARNING: This script will DROP all Event Intelligence demo objects!
 * 
 * Objects Removed:
 *   - Streamlit application
 *   - Cortex Agent
 *   - Semantic View
 *   - All tables, views, dynamic tables
 *   - Schemas: EVENT_INTELLIGENCE, EVENT_INTELLIGENCE_GIT_REPOS
 *   - Warehouse: SFE_EVENT_INTELLIGENCE_WH
 *   - API Integration (if exclusive to this demo)
 * 
 * Protected (NOT removed):
 *   - SNOWFLAKE_EXAMPLE database
 *   - SEMANTIC_MODELS schema (other demos may use it)
 *   - Shared API integrations
 * ============================================================================
 */

-- ============================================================================
-- CONTEXT SETTING (MANDATORY)
-- ============================================================================
USE ROLE SYSADMIN;

-- =============================================================================
-- STEP 1: DROP STREAMLIT APPLICATION
-- =============================================================================
DROP STREAMLIT IF EXISTS SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE.event_intelligence_dashboard;

-- =============================================================================
-- STEP 2: DROP CORTEX AGENT
-- =============================================================================
DROP AGENT IF EXISTS SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE.event_intelligence_agent;

-- =============================================================================
-- STEP 3: DROP SEMANTIC VIEW (from SEMANTIC_MODELS schema)
-- =============================================================================
DROP SEMANTIC VIEW IF EXISTS SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS.SV_EVENT_ANALYTICS;

-- =============================================================================
-- STEP 4: DROP EVENT_INTELLIGENCE SCHEMA (cascades all objects)
-- =============================================================================
-- This drops all tables, views, dynamic tables, streams, tasks, procedures
DROP SCHEMA IF EXISTS SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE CASCADE;

-- =============================================================================
-- STEP 5: DROP GIT REPOSITORY SCHEMA
-- =============================================================================
DROP SCHEMA IF EXISTS SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE_GIT_REPOS CASCADE;

-- =============================================================================
-- STEP 6: DROP WAREHOUSE
-- =============================================================================
DROP WAREHOUSE IF EXISTS SFE_EVENT_INTELLIGENCE_WH;

-- =============================================================================
-- STEP 7: DROP API INTEGRATION (if exclusive to this demo)
-- =============================================================================
-- Note: Only drop if this integration is NOT shared with other demos
-- Uncomment if you want to remove the Git API integration
-- DROP API INTEGRATION IF EXISTS SFE_EVENT_INTELLIGENCE_GIT_API_INTEGRATION;

-- =============================================================================
-- VERIFICATION
-- =============================================================================
SELECT 'Event Intelligence Platform cleanup complete' AS status;

-- Verify objects are removed
SELECT 'Remaining schemas in SNOWFLAKE_EXAMPLE:' AS check_type;
SHOW SCHEMAS IN DATABASE SNOWFLAKE_EXAMPLE;

SELECT 'Remaining warehouses with SFE_ prefix:' AS check_type;
SHOW WAREHOUSES LIKE 'SFE_%';

