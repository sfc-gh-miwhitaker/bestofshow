# Auth Flow - Event Intelligence Platform
Author: SE Community
Last Updated: 2025-12-10
Expires: 2026-01-09
Status: Reference Implementation

![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)

Reference Implementation: This code demonstrates production-grade architectural patterns and best practices. Review and customize security, networking, and logic for your organization's specific requirements before deployment.

## Overview
Authentication and authorization for Streamlit dashboard users and Cortex Agent requests, including role checks, RLS for sponsors, and semantic-view-based queries.

```mermaid
sequenceDiagram
    actor User as Event Manager
    participant Streamlit as Streamlit Dashboard
    participant SF as Snowflake Auth
    participant RBAC as Role-Based Access
    participant Agent as Cortex Agent
    participant Analyst as Cortex Analyst
    participant SV as Semantic View<br/>SV_EVENT_ANALYTICS
    participant WH as Warehouse
    participant DB as Database Tables
    
    User->>Streamlit: Access Dashboard
    Streamlit->>SF: Authenticate User
    SF->>RBAC: Check User Roles
    
    alt Has EVENT_MANAGER_ROLE
        RBAC-->>SF: Grant Full Access
        SF-->>Streamlit: Session Established
        Streamlit-->>User: Dashboard Loaded
    else Has SPONSOR_ROLE
        RBAC-->>SF: Grant Limited Access (Row-Level Security)
        SF-->>Streamlit: Restricted Session
        Streamlit-->>User: Sponsor Dashboard Loaded
    else Insufficient Privileges
        RBAC-->>SF: Deny Access
        SF-->>Streamlit: Auth Failed
        Streamlit-->>User: Access Denied
    end
    
    User->>Streamlit: Query Event Metrics
    Streamlit->>WH: Execute SQL Query
    WH->>RBAC: Verify USAGE on Warehouse
    RBAC-->>WH: Granted
    WH->>DB: Read Tables (with RLS filters)
    DB-->>WH: Filtered Results
    WH-->>Streamlit: Query Results
    Streamlit-->>User: Display Metrics
    
    User->>Agent: Ask: "Which sessions had highest attendance?"
    Agent->>SF: Validate User Session
    SF->>RBAC: Check USAGE on Agent
    RBAC-->>SF: Granted
    Agent->>Analyst: Natural Language Query
    Analyst->>RBAC: Check USAGE on Semantic View
    RBAC-->>Analyst: Granted
    Analyst->>SV: Parse Semantic Model
    SV-->>Analyst: Table Mappings
    Analyst->>WH: Generate & Execute SQL
    WH->>DB: Query RAW_SESSIONS, RAW_SESSION_CHECKINS
    DB-->>WH: Results
    WH-->>Analyst: Query Results
    Analyst-->>Agent: Formatted Response
    Agent-->>User: "Top 5 sessions: ..."
    
    Note over User,DB: Row-Level Security (RLS) Policy
    Note over RBAC,DB: sponsor_name = CURRENT_USER() for SPONSOR_ROLE
    Note over SF,RBAC: Key Roles: ACCOUNTADMIN, EVENT_MANAGER_ROLE,<br/>SPONSOR_ROLE, PUBLIC
```

## Component Descriptions
- Authentication: Snowflake authenticates dashboard and agent requests via HTTPS; sessions inherit RBAC.
- Authorization: Roles gate access; sponsors receive RLS-filtered data; managers get full event view.
- Semantic access: Agent and Analyst operate only through semantic view `SV_EVENT_ANALYTICS`, not raw tables.
- Warehouse policy: Queries execute on `SFE_EVENT_INTELLIGENCE_WH` with role checks for USAGE.

## Change History
See `.cursor/DIAGRAM_CHANGELOG.md` for vhistory.

