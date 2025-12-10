# Network Flow - Event Intelligence Platform
Author: SE Community
Last Updated: 2025-12-10
Expires: 2026-01-09
Status: Reference Implementation

![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)

Reference Implementation: This code demonstrates production-grade architectural patterns and best practices. Review and customize security, networking, and logic for your organization's specific requirements before deployment.

## Overview
Network architecture showing external producers, GitHub integration, Snowflake services (compute, storage, AI), and Streamlit app delivery over HTTPS with RBAC-enforced access.

```mermaid
graph TB
    subgraph "External Systems"
        User[Event Operators<br/>Web Browser]
        Mobile[Mobile App<br/>Real-Time Events]
        GitHub[GitHub Repository<br/>bestofshow]
    end
    
    subgraph "Snowflake Account"
        subgraph "Network Layer"
            LB[Load Balancer<br/>*.snowflakecomputing.com<br/>HTTPS :443]
        end
        
        subgraph "Compute Layer"
            WH[Warehouse<br/>SFE_EVENT_INTELLIGENCE_WH<br/>X-SMALL]
            StreamWH[Streamlit Compute<br/>Managed by Snowflake]
        end
        
        subgraph "Storage Layer - SNOWFLAKE_EXAMPLE"
            DB[(Database<br/>EVENT_INTELLIGENCE schema)]
            SemDB[(SEMANTIC_MODELS schema)]
            GitDB[(EVENT_INTELLIGENCE_GIT_REPOS)]
        end
        
        subgraph "AI Services - Serverless"
            Cortex[Cortex AI Functions<br/>SENTIMENT, SUMMARIZE]
            Analyst[Cortex Analyst<br/>Semantic View Queries]
            AgentSvc[Cortex Agent Service<br/>event_intelligence_agent]
        end
        
        subgraph "Data Integration"
            PipeAPI[Snowpipe Streaming API<br/>High-Performance Ingestion]
            GitAPI[Git API Integration<br/>SFE_EVENT_INTELLIGENCE_GIT]
        end
        
        subgraph "Application Layer"
            Streamlit[Streamlit App<br/>event_intelligence_dashboard]
        end
    end
    
    User -->|HTTPS :443| LB
    Mobile -->|HTTPS :443<br/>REST API| PipeAPI
    GitHub -->|HTTPS :443<br/>Git Protocol| GitAPI
    
    LB --> Streamlit
    LB --> AgentSvc
    
    PipeAPI -->|Low Latency<br/>Writes| DB
    GitAPI -->|Source Code<br/>Read| GitDB
    
    Streamlit -->|SQL Queries| StreamWH
    StreamWH -->|Read Data| DB
    StreamWH -->|Read Data| SemDB
    
    AgentSvc -->|Orchestration| Analyst
    Analyst -->|SQL Generation| WH
    WH -->|Query Execution| SemDB
    
    DB -->|Transform| Cortex
    Cortex -->|Enriched Data| DB
    
    GitDB -->|Deploy SQL| WH
    WH -->|DDL/DML| DB
    WH -->|DDL/DML| SemDB
    
    style PipeAPI fill:#29B5E8
    style Cortex fill:#FF6B6B
    style Analyst fill:#4ECDC4
    style AgentSvc fill:#4ECDC4
    style Streamlit fill:#95E1D3
```

## Component Descriptions
- External producers: Mobile apps and badge scanners send HTTPS events to Snowpipe Streaming API.
- Data integration: Git API integration pulls SQL/Streamlit assets from GitHub into Snowflake git repo schema.
- Compute & AI: Warehouse for SQL/Dynamic Tables; serverless Cortex services for sentiment and agent orchestration.
- Delivery: Streamlit served via Snowflake over HTTPS; load balancer fronts Streamlit and agent endpoints.

## Change History
See `.cursor/DIAGRAM_CHANGELOG.md` for vhistory.

