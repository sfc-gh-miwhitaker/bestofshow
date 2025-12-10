![Reference Implementation](https://img.shields.io/badge/Reference-Implementation-blue)
![Ready to Run](https://img.shields.io/badge/Ready%20to%20Run-Yes-green)
![Expires](https://img.shields.io/badge/Expires-2026--01--09-orange)
![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?style=flat&logo=snowflake&logoColor=white)

# Event Intelligence Platform

> **DEMONSTRATION PROJECT - EXPIRES: 2026-01-09**  
> This demo uses Snowflake features current as of December 2025.  
> After expiration, this repository will be archived and made private.

**Author:** SE Community  
**Purpose:** Reference implementation for medical education event analytics with real-time engagement tracking, sponsor ROI analysis, and AI-powered insights  
**Created:** 2025-12-10 | **Expires:** 2026-01-09 (30 days) | **Status:** ACTIVE

---

## 👋 First Time Here?

Deploy the complete demo in **one step**:

| Step | Action | Time |
|------|--------|------|
| 1 | Open `deploy_all.sql` | - |
| 2 | Copy entire file into Snowsight worksheet | - |
| 3 | Click **Run All** | ~5-10 min |
| 4 | Access dashboard: Snowsight > Projects > Streamlit > `event_intelligence_dashboard` | - |

**Total setup time: ~10 minutes**

---

## Overview

The **Event Intelligence Platform** demonstrates Snowflake's capabilities for managing medical education events like the International Wound Care Symposium. It showcases:

- **Real-time event tracking** with Snowpipe Streaming patterns
- **Auto-refreshing analytics** with Dynamic Tables
- **AI-powered insights** with Cortex LLM functions and Cortex Agent
- **Natural language queries** with Semantic Views and Cortex Analyst
- **Operations dashboard** with Streamlit in Snowflake

### Use Case: HMP Global Training Storyline

This demo implements the data journey narrative for HMP Global's flagship medical education event, covering:

1. **Data Ingestion:** Registration, badge scans, booth visits, session check-ins, feedback
2. **Data Transformation:** Layered architecture (RAW → STG → Analytics)
3. **Cortex AI:** Sentiment analysis, feedback summarization, AI agent
4. **Orchestration:** Dynamic Tables with configurable refresh rates
5. **Visualization:** Real-time Streamlit dashboard

---

## Architecture

### Data Model

```
SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE
├── RAW Layer
│   ├── RAW_ATTENDEES (500 attendees)
│   ├── RAW_SESSIONS (25 sessions)
│   ├── RAW_SPONSORS (15 exhibitors)
│   ├── RAW_BOOTH_VISITS (~2000 events)
│   ├── RAW_SESSION_CHECKINS (~1500 events)
│   └── RAW_FEEDBACK (~800 responses)
├── Staging Layer
│   └── STG_ATTENDEES
├── Analytics Layer (Dynamic Tables)
│   ├── DT_ATTENDEE_ENGAGEMENT (5-min lag)
│   ├── DT_SESSION_ANALYTICS (10-min lag)
│   ├── DT_SPONSOR_PERFORMANCE (15-min lag)
│   └── DT_LIVE_EVENT_PULSE (1-min lag)
└── Cortex AI
    ├── FEEDBACK_WITH_SENTIMENT
    ├── SESSION_FEEDBACK_SUMMARIES
    └── SPONSOR_AI_INSIGHTS

SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS
└── SV_EVENT_ANALYTICS (Semantic View)
```

### Key Components

| Component | Description |
|-----------|-------------|
| `deploy_all.sql` | One-click deployment script |
| `event_intelligence_agent` | Cortex AI agent for natural language queries |
| `SV_EVENT_ANALYTICS` | Semantic view for Cortex Analyst |
| `event_intelligence_dashboard` | Streamlit operations dashboard |
| Dynamic Tables | Auto-refreshing analytics (1-15 min lag) |

---

## Features Demonstrated

### Snowflake Capabilities

| Feature | Implementation |
|---------|---------------|
| **Git Integration** | Deploy SQL from GitHub repository |
| **Dynamic Tables** | Auto-refreshing analytics with TARGET_LAG |
| **Semantic Views** | Business-friendly data model for Cortex Analyst |
| **Cortex Agent** | Natural language event analytics assistant |
| **Cortex LLM** | SENTIMENT, SUMMARIZE, COMPLETE functions |
| **Streamlit** | In-Snowflake dashboard with real-time data |

### Sample Cortex Agent Questions

- "What were the top 5 sessions by attendance?"
- "Which sponsors had the most booth visits?"
- "Show me average feedback ratings by track"
- "What specialties are most represented among attendees?"
- "How is sponsor ROI calculated and who has the best ROI?"

---

## Project Structure

```
bestofshow/
├── deploy_all.sql              # Primary deployment (copy/paste to Snowsight)
├── README.md                   # This file
├── LICENSE
├── diagrams/                   # Architecture diagrams (Mermaid)
│   ├── data-model.md
│   ├── data-flow.md
│   ├── network-flow.md
│   └── auth-flow.md
├── docs/                       # User documentation
│   ├── 01-DEPLOYMENT.md
│   ├── 02-USAGE.md
│   └── 03-CLEANUP.md
├── sql/
│   ├── 01_setup/              # Database & schema setup
│   ├── 02_data/               # Tables & sample data
│   ├── 03_transformations/    # Views & Dynamic Tables
│   ├── 04_cortex/             # Semantic View, LLM, Agent
│   ├── 05_streamlit/          # Dashboard deployment
│   └── 99_cleanup/            # Teardown script
└── streamlit/
    └── streamlit_app.py       # Dashboard source code
```

---

## Requirements

- **Snowflake Edition:** Enterprise (for Dynamic Tables)
- **Role Privileges:** Create Warehouse, API Integration, Git Repository
- **Estimated Cost:** ~$15-20/month for light demo usage

---

## Cleanup

When finished, run the cleanup script:

```sql
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE_GIT_REPOS.sfe_event_intelligence_repo/branches/main/sql/99_cleanup/teardown_all.sql;
```

---

## Documentation

| Guide | Description |
|-------|-------------|
| [01-DEPLOYMENT.md](docs/01-DEPLOYMENT.md) | Step-by-step deployment instructions |
| [02-USAGE.md](docs/02-USAGE.md) | How to use the dashboard and agent |
| [03-CLEANUP.md](docs/03-CLEANUP.md) | Complete cleanup instructions |

---

## Architecture Diagrams

- [Data Model](diagrams/data-model.md) - Entity relationships
- [Data Flow](diagrams/data-flow.md) - Ingestion to consumption
- [Network Flow](diagrams/network-flow.md) - Components and connections
- [Auth Flow](diagrams/auth-flow.md) - RBAC and access patterns

---

*Reference Implementation: This code demonstrates production-grade architectural patterns and best practices. Review and customize security, networking, and logic for your organization's specific requirements before deployment.*
