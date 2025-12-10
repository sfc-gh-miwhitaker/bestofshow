# Cleanup Guide - Event Intelligence Platform

**Author:** SE Community  
**Created:** 2025-12-10  
**Expires:** 2026-01-09

## Overview

This guide explains how to completely remove the Event Intelligence Platform demo from your Snowflake account.

## Quick Cleanup

The fastest way to clean up is to run the teardown script:

### Option 1: Execute from Git Repository

```sql
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE_GIT_REPOS.sfe_event_intelligence_repo/branches/main/sql/99_cleanup/teardown_all.sql;
```

### Option 2: Copy/Paste

1. Open `sql/99_cleanup/teardown_all.sql`
2. Copy the entire contents
3. Paste into a Snowsight worksheet
4. Click **Run All**

## What Gets Removed

### Removed Objects

| Object Type | Name | Notes |
|-------------|------|-------|
| Streamlit | `event_intelligence_dashboard` | Dashboard app |
| Agent | `event_intelligence_agent` | Cortex AI agent |
| Semantic View | `SV_EVENT_ANALYTICS` | From SEMANTIC_MODELS schema |
| Schema | `EVENT_INTELLIGENCE` | All tables, views, DTs cascade dropped |
| Schema | `EVENT_INTELLIGENCE_GIT_REPOS` | Git repository |
| Warehouse | `SFE_EVENT_INTELLIGENCE_WH` | Compute warehouse |

### Protected Objects (NOT Removed)

| Object Type | Name | Reason |
|-------------|------|--------|
| Database | `SNOWFLAKE_EXAMPLE` | Shared by other demos |
| Schema | `SEMANTIC_MODELS` | Other demos may use it |
| API Integration | `SFE_EVENT_INTELLIGENCE_GIT_API_INTEGRATION` | May be reused |

To remove the API Integration, uncomment the line in teardown_all.sql or run:

```sql
DROP API INTEGRATION IF EXISTS SFE_EVENT_INTELLIGENCE_GIT_API_INTEGRATION;
```

## Manual Cleanup

If the automated cleanup fails, run these commands in order:

```sql
-- 1. Drop Streamlit
DROP STREAMLIT IF EXISTS SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE.event_intelligence_dashboard;

-- 2. Drop Agent
DROP AGENT IF EXISTS SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE.event_intelligence_agent;

-- 3. Drop Semantic View
DROP SEMANTIC VIEW IF EXISTS SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS.SV_EVENT_ANALYTICS;

-- 4. Drop main schema (cascades all objects)
DROP SCHEMA IF EXISTS SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE CASCADE;

-- 5. Drop Git repos schema
DROP SCHEMA IF EXISTS SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE_GIT_REPOS CASCADE;

-- 6. Drop warehouse
DROP WAREHOUSE IF EXISTS SFE_EVENT_INTELLIGENCE_WH;

-- 7. (Optional) Drop API Integration
-- DROP API INTEGRATION IF EXISTS SFE_EVENT_INTELLIGENCE_GIT_API_INTEGRATION;
```

## Verification

After cleanup, verify objects are removed:

```sql
-- Check for remaining schemas
SHOW SCHEMAS IN DATABASE SNOWFLAKE_EXAMPLE LIKE '%EVENT%';

-- Check for remaining warehouses
SHOW WAREHOUSES LIKE 'SFE_EVENT%';

-- Check for remaining integrations
SHOW API INTEGRATIONS LIKE 'SFE_EVENT%';
```

Expected result: No rows returned for any of the above queries.

## Cost Considerations

After cleanup:
- Warehouse compute charges stop immediately
- Dynamic Table refresh charges stop immediately
- Storage charges for Time Travel data continue for retention period (default 1 day)
- Cortex AI charges only apply during active usage

## Re-Deployment

To deploy again after cleanup:

1. Ensure cleanup completed successfully
2. Run `deploy_all.sql` again
3. All objects will be recreated fresh

## Troubleshooting

### "Object does not exist"
This is expected if objects were already deleted. The `IF EXISTS` clause prevents errors.

### "Insufficient privileges to drop"
Ensure you're using a role with ownership or appropriate privileges on the objects.

### "Cannot drop schema with dependencies"
Use `CASCADE` to force drop all dependent objects:
```sql
DROP SCHEMA SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE CASCADE;
```

### Time Travel data still visible
Data remains in Time Travel for the configured retention period. To purge immediately:
```sql
ALTER SCHEMA SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE SET DATA_RETENTION_TIME_IN_DAYS = 0;
DROP SCHEMA SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE CASCADE;
```

---

*This is a demonstration project. Data shown is synthetic.*
