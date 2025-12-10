/*
 * ============================================================================
 * EVENT INTELLIGENCE PLATFORM - MASTER DEPLOYMENT SCRIPT
 * ============================================================================
 * 
 * DEPLOYMENT: Copy this entire file into a Snowsight worksheet and click "Run All"
 * 
 * Metadata:
 *  * PROJECT_NAME: Event Intelligence Platform
 *  * AUTHOR: SE Community
 *  * PURPOSE: Reference implementation for event intelligence (real-time engagement, sponsor ROI, AI insights)
 *  * CREATED_DATE: 2025-12-10
 *  * EXPIRATION_DATE: 2026-01-09
 *  * LAST_UPDATED_DATE: 2025-12-10
 *  * GITHUB_REPO: https://github.com/sfc-gh-miwhitaker/bestofshow
 *  * GITHUB_ALLOWED_PREFIX: https://github.com/sfc-gh-miwhitaker/
 *  * DATABASE_NAME: SNOWFLAKE_EXAMPLE
 *  * PROJECT_SCHEMA: EVENT_INTELLIGENCE
 *  * GIT_SCHEMA_NAME: EVENT_INTELLIGENCE_GIT_REPOS
 *  * GIT_REPO_NAME: sfe_event_intelligence_repo
 *  * API_INTEGRATION_NAME: SFE_EVENT_INTELLIGENCE_GIT_API_INTEGRATION
 *  * WAREHOUSE_NAME: SFE_EVENT_INTELLIGENCE_WH
 * 
 * Safe to re-run: All statements use OR REPLACE or IF NOT EXISTS
 * Expected runtime: ~5-10 minutes
 * ============================================================================
 */

-- ============================================================================
-- STEP 0: EXPIRATION GUARD
-- ============================================================================
-- Halts execution if demo is past expiration date
EXECUTE IMMEDIATE
$$
DECLARE
    v_expiration_date DATE := '2026-01-09';
    demo_expired EXCEPTION (-20001, 'DEMO EXPIRED: This project expired on 2026-01-09. Please contact the SE team for an updated version.');
BEGIN
    IF (CURRENT_DATE() > v_expiration_date) THEN
        RAISE demo_expired;
    END IF;
END;
$$;

-- ============================================================================
-- STEP 1: CREATE WAREHOUSE (Account-level, SFE_ prefix)
-- ============================================================================
CREATE OR REPLACE WAREHOUSE SFE_EVENT_INTELLIGENCE_WH
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'DEMO: Event Intelligence Platform | Author: SE Community | Expires: 2026-01-09';

-- ============================================================================
-- STEP 2: CREATE GIT API INTEGRATION (Account-level, SFE_ prefix)
-- ============================================================================
CREATE OR REPLACE API INTEGRATION SFE_EVENT_INTELLIGENCE_GIT_API_INTEGRATION
    API_PROVIDER = GIT_HTTPS_API
    API_ALLOWED_PREFIXES = ('https://github.com/sfc-gh-miwhitaker/')
    ENABLED = TRUE
    COMMENT = 'DEMO: Git integration for Event Intelligence Platform | Author: SE Community | Expires: 2026-01-09';

-- ============================================================================
-- STEP 3: CREATE DATABASE AND SCHEMAS
-- ============================================================================
CREATE DATABASE IF NOT EXISTS SNOWFLAKE_EXAMPLE
    COMMENT = 'DEMO: Shared database for SE demos | Author: SE Community';

USE DATABASE SNOWFLAKE_EXAMPLE;

CREATE SCHEMA IF NOT EXISTS EVENT_INTELLIGENCE
    COMMENT = 'DEMO: Event Intelligence Platform | Author: SE Community | Expires: 2026-01-09';

CREATE SCHEMA IF NOT EXISTS EVENT_INTELLIGENCE_GIT_REPOS
    COMMENT = 'DEMO: Git repos for Event Intelligence Platform | Author: SE Community | Expires: 2026-01-09';

CREATE SCHEMA IF NOT EXISTS SEMANTIC_MODELS
    COMMENT = 'DEMO: Shared semantic models for Cortex Analyst | Author: SE Community';

-- ============================================================================
-- STEP 4: CREATE GIT REPOSITORY
-- ============================================================================
CREATE OR REPLACE GIT REPOSITORY EVENT_INTELLIGENCE_GIT_REPOS.sfe_event_intelligence_repo
    API_INTEGRATION = SFE_EVENT_INTELLIGENCE_GIT_API_INTEGRATION
    ORIGIN = 'https://github.com/sfc-gh-miwhitaker/bestofshow'
    COMMENT = 'DEMO: Event Intelligence Platform source code | Author: SE Community | Expires: 2026-01-09';

-- Fetch latest from repository
ALTER GIT REPOSITORY EVENT_INTELLIGENCE_GIT_REPOS.sfe_event_intelligence_repo FETCH;

-- ============================================================================
-- STEP 5: SET EXECUTION CONTEXT
-- ============================================================================
USE WAREHOUSE SFE_EVENT_INTELLIGENCE_WH;
USE SCHEMA EVENT_INTELLIGENCE;

-- ============================================================================
-- STEP 6: EXECUTE SQL SCRIPTS FROM GIT REPOSITORY
-- ============================================================================

-- 6.1: Setup Scripts
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE_GIT_REPOS.sfe_event_intelligence_repo/branches/main/sql/01_setup/01_create_database.sql;
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE_GIT_REPOS.sfe_event_intelligence_repo/branches/main/sql/01_setup/02_create_schemas.sql;

-- 6.2: Data Tables & Sample Data
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE_GIT_REPOS.sfe_event_intelligence_repo/branches/main/sql/02_data/01_create_tables.sql;
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE_GIT_REPOS.sfe_event_intelligence_repo/branches/main/sql/02_data/02_load_sample_data.sql;

-- 6.3: Transformations (Views & Dynamic Tables)
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE_GIT_REPOS.sfe_event_intelligence_repo/branches/main/sql/03_transformations/01_create_views.sql;
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE_GIT_REPOS.sfe_event_intelligence_repo/branches/main/sql/03_transformations/02_create_dynamic_tables.sql;

-- 6.4: Cortex AI Features
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE_GIT_REPOS.sfe_event_intelligence_repo/branches/main/sql/04_cortex/01_create_semantic_view.sql;
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE_GIT_REPOS.sfe_event_intelligence_repo/branches/main/sql/04_cortex/02_cortex_llm_functions.sql;
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE_GIT_REPOS.sfe_event_intelligence_repo/branches/main/sql/04_cortex/03_create_agent.sql;

-- 6.5: Streamlit Dashboard
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE_GIT_REPOS.sfe_event_intelligence_repo/branches/main/sql/05_streamlit/01_create_dashboard.sql;

-- ============================================================================
-- STEP 7: DEPLOYMENT VERIFICATION
-- ============================================================================
SELECT '✅ Event Intelligence Platform deployed successfully!' AS status;

-- Show created objects
-- Note: DYNAMIC_TABLES is a table function, use TABLES view with IS_DYNAMIC filter
SELECT 'Tables' AS object_type, COUNT(*) AS count FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'EVENT_INTELLIGENCE' AND IS_DYNAMIC = 'NO'
UNION ALL SELECT 'Views', COUNT(*) FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_SCHEMA = 'EVENT_INTELLIGENCE'
UNION ALL SELECT 'Dynamic Tables', COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'EVENT_INTELLIGENCE' AND IS_DYNAMIC = 'YES';

-- ============================================================================
-- NEXT STEPS
-- ============================================================================
-- 1. Access Streamlit Dashboard:
--    Snowsight > Projects > Streamlit > event_intelligence_dashboard
--
-- 2. Try the Cortex Agent:
--    Snowsight > AI & ML > Cortex Agent > event_intelligence_agent
--    Ask: "What were the top 5 sessions by attendance?"
--
-- 3. Explore the Semantic View:
--    SELECT * FROM SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS.SV_EVENT_ANALYTICS;
--
-- 4. Review Dynamic Tables:
--    SHOW DYNAMIC TABLES IN SCHEMA SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE;
--
-- 5. Cleanup when done:
--    Run: sql/99_cleanup/teardown_all.sql
-- ============================================================================

-- ============================================================================
-- TROUBLESHOOTING
-- ============================================================================
-- * "Insufficient privileges": Ensure your role can create API INTEGRATION, 
--   WAREHOUSE, and GIT REPOSITORY objects.
--
-- * "Git fetch failed": Verify the repository URL is correct and publicly 
--   accessible, or check the API integration allowed prefixes.
--
-- * "Demo expired": This demo has passed its 30-day expiration. Contact the 
--   SE team for an updated version.
--
-- * Dynamic Tables not refreshing: Check warehouse is not suspended and 
--   TARGET_LAG settings are appropriate.
-- ============================================================================
