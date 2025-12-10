/*
 * ============================================================================
 * EVENT INTELLIGENCE PLATFORM - CREATE STREAMLIT DASHBOARD
 * ============================================================================
 * Author: SE Community
 * Created: 2025-12-10
 * Expires: 2026-01-09
 * Purpose: Deploy Streamlit dashboard for real-time event operations
 * 
 * Dashboard: event_intelligence_dashboard
 * Location: SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE
 * Source: streamlit/streamlit_app.py (from Git repository)
 * ============================================================================
 */

-- ============================================================================
-- CONTEXT SETTING (MANDATORY)
-- ============================================================================
USE ROLE SYSADMIN;
USE DATABASE SNOWFLAKE_EXAMPLE;
USE SCHEMA EVENT_INTELLIGENCE;

-- =============================================================================
-- CREATE STREAMLIT APPLICATION
-- =============================================================================
CREATE OR REPLACE STREAMLIT event_intelligence_dashboard
    ROOT_LOCATION = '@SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE_GIT_REPOS.sfe_event_intelligence_repo/branches/main/streamlit'
    MAIN_FILE = 'streamlit_app.py'
    QUERY_WAREHOUSE = 'SFE_EVENT_INTELLIGENCE_WH'
    COMMENT = 'DEMO: Event Intelligence real-time dashboard | Author: SE Community | Expires: 2026-01-09';

-- =============================================================================
-- VERIFY STREAMLIT DEPLOYMENT
-- =============================================================================
SHOW STREAMLITS IN SCHEMA SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE;

-- =============================================================================
-- GRANT ACCESS (for demo users)
-- =============================================================================
-- Note: Uncomment and modify these grants based on your role structure
-- GRANT USAGE ON STREAMLIT event_intelligence_dashboard TO ROLE PUBLIC;

SELECT 
    'Streamlit dashboard deployed successfully' AS status,
    'Access via: Snowsight > Projects > Streamlit > event_intelligence_dashboard' AS access_path;

