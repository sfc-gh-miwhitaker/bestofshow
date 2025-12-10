# Deployment Guide - Event Intelligence Platform

**Author:** SE Community  
**Created:** 2025-12-10  
**Expires:** 2026-01-09

## Overview

This guide covers deploying the Event Intelligence Platform to your Snowflake account.

## Prerequisites

Before deploying, ensure you have:

1. **Snowflake Account** with Enterprise edition (required for Dynamic Tables)
2. **Role** with privileges to create:
   - Warehouses
   - API Integrations
   - Git Repositories
   - Databases and Schemas
3. **GitHub Access** - The repository must be publicly accessible

## Deployment Method: Snowsight Copy/Paste

### Step 1: Open Snowsight

Navigate to your Snowflake account's Snowsight interface.

### Step 2: Create a New Worksheet

1. Click **+ Worksheet** in the top right
2. Give it a name like "Deploy Event Intelligence"

### Step 3: Copy the Deployment Script

1. Open `deploy_all.sql` from the repository root
2. Copy the **entire** contents of the file
3. Paste into the Snowsight worksheet

### Step 4: Run the Deployment

1. Click **Run All** (or Cmd/Ctrl + Shift + Enter)
2. Wait approximately **5-10 minutes** for completion
3. Verify the success message: "✅ Event Intelligence Platform deployed successfully!"

## What Gets Created

### Account-Level Objects
| Object | Name | Type |
|--------|------|------|
| Warehouse | `SFE_EVENT_INTELLIGENCE_WH` | X-SMALL, auto-suspend 60s |
| API Integration | `SFE_EVENT_INTELLIGENCE_GIT_API_INTEGRATION` | GitHub HTTPS |

### Database Objects (in SNOWFLAKE_EXAMPLE)
| Schema | Objects |
|--------|---------|
| `EVENT_INTELLIGENCE` | RAW tables (6), STG tables (1), Analytics tables (3), Views (5), Dynamic Tables (4), Cortex Agent (1), Streamlit (1) |
| `EVENT_INTELLIGENCE_GIT_REPOS` | Git Repository |
| `SEMANTIC_MODELS` | Semantic View (SV_EVENT_ANALYTICS) |

### Tables Created
- `RAW_ATTENDEES` - 500 sample attendees
- `RAW_SESSIONS` - 25 conference sessions
- `RAW_SPONSORS` - 15 exhibitors
- `RAW_BOOTH_VISITS` - ~2000 booth visit events
- `RAW_SESSION_CHECKINS` - ~1500 session check-ins
- `RAW_FEEDBACK` - ~800 feedback entries

### Dynamic Tables (Auto-Refreshing)
| Name | Target Lag | Purpose |
|------|------------|---------|
| `DT_ATTENDEE_ENGAGEMENT` | 5 minutes | Attendee engagement metrics |
| `DT_SESSION_ANALYTICS` | 10 minutes | Session performance |
| `DT_SPONSOR_PERFORMANCE` | 15 minutes | Sponsor ROI |
| `DT_LIVE_EVENT_PULSE` | 1 minute | Real-time event pulse |

### Cortex AI Features
- **Semantic View:** `SV_EVENT_ANALYTICS` for natural language queries
- **Cortex Agent:** `event_intelligence_agent` for conversational analytics
- **LLM Functions:** Sentiment analysis and summarization on feedback

## Post-Deployment Verification

Run these queries to verify deployment:

```sql
-- Check tables
SELECT COUNT(*) FROM SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE.RAW_ATTENDEES;

-- Check Dynamic Tables
SHOW DYNAMIC TABLES IN SCHEMA SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE;

-- Check Semantic View
DESCRIBE SEMANTIC VIEW SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS.SV_EVENT_ANALYTICS;

-- Check Agent
SHOW AGENTS IN SCHEMA SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE;

-- Check Streamlit
SHOW STREAMLITS IN SCHEMA SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE;
```

## Accessing the Demo

### Streamlit Dashboard
1. Navigate to: **Snowsight > Projects > Streamlit**
2. Find and click: `event_intelligence_dashboard`
3. The dashboard will load with live data

### Cortex Agent
1. Navigate to: **Snowsight > AI & ML > Cortex Agents**
2. Find: `event_intelligence_agent`
3. Try asking: "What were the top 5 sessions by attendance?"

## Estimated Costs

| Component | Estimated Monthly Cost |
|-----------|----------------------|
| Warehouse (X-SMALL, 2 hrs/day) | ~$6 |
| Dynamic Tables | ~$5 |
| Cortex AI (1000 calls) | ~$2 |
| Storage (<1GB) | ~$0.50 |
| **Total** | **~$15-20** |

## Troubleshooting

### "Insufficient privileges"
Ensure your role has ACCOUNTADMIN or equivalent privileges to create:
- API Integrations
- Warehouses
- Git Repositories

### "Git fetch failed"
1. Verify the repository URL is correct
2. Ensure the repository is publicly accessible
3. Check the API integration allowed prefixes

### "Demo expired"
The demo includes a 30-day expiration check. Contact the SE team for an updated version.

### Dynamic Tables not refreshing
1. Ensure the warehouse is not suspended
2. Check TARGET_LAG settings
3. Run: `ALTER DYNAMIC TABLE <name> REFRESH;`

## Cleanup

When finished with the demo, run the cleanup script:

```sql
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE_GIT_REPOS.sfe_event_intelligence_repo/branches/main/sql/99_cleanup/teardown_all.sql;
```

Or copy/paste the contents of `sql/99_cleanup/teardown_all.sql` into a worksheet.

---

*This is a demonstration project. Data shown is synthetic.*
