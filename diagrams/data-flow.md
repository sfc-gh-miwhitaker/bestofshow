# Data Flow - Event Intelligence Platform
Author: SE Community
Last Updated: 2025-12-10
Expires: 2026-01-09
Status: Reference Implementation

![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)

Reference Implementation: This code demonstrates production-grade architectural patterns and best practices. Review and customize security, networking, and logic for your organization's specific requirements before deployment.

## Overview
End-to-end flow from real-time event signals into Snowflake via Snowpipe Streaming, through Dynamic Tables and Cortex AI enrichment, into semantic views consumed by Cortex Agent and Streamlit dashboards, with secure sponsor sharing.

```mermaid
graph TB
    subgraph "Data Sources"
        Mobile[Mobile App Events]
        Badge[Badge Scanners]
        Survey[Survey Platform]
        Reg[Registration System]
    end
    
    subgraph "Real-Time Ingestion"
        Stream[Snowpipe Streaming API]
        Pipe[CREATE PIPE with STREAMING]
    end
    
    subgraph "Raw Layer - SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE"
        RawAtt[RAW_ATTENDEES]
        RawSess[RAW_SESSIONS]
        RawCheckin[RAW_SESSION_CHECKINS]
        RawBooth[RAW_BOOTH_VISITS]
        RawFeedback[RAW_FEEDBACK]
        RawSponsors[RAW_SPONSORS]
    end
    
    subgraph "Transformation - Dynamic Tables"
        DT1[STG_ATTENDEES<br/>TARGET_LAG: 5 min]
        DT2[ATTENDEE_ENGAGEMENT<br/>TARGET_LAG: 10 min]
        DT3[SPONSOR_PERFORMANCE<br/>TARGET_LAG: 15 min]
    end
    
    subgraph "Cortex AI Enhancement"
        Sentiment[SENTIMENT Function]
        Summarize[SUMMARIZE Function]
    end
    
    subgraph "Semantic Layer - SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS"
        SV[SV_EVENT_ANALYTICS<br/>Semantic View]
    end
    
    subgraph "Consumption Layer"
        Agent[Cortex Agent<br/>event_intelligence_agent]
        Dashboard[Streamlit Dashboard<br/>event_intelligence_dashboard]
        Share[Secure Share<br/>Sponsor ROI Views]
    end
    
    Mobile -->|JSON Events| Stream
    Badge -->|Scan Events| Stream
    Survey -->|Feedback| Stream
    Reg -->|Registrations| Stream
    
    Stream -->|Low Latency| Pipe
    Pipe --> RawAtt
    Pipe --> RawSess
    Pipe --> RawCheckin
    Pipe --> RawBooth
    Pipe --> RawFeedback
    Pipe --> RawSponsors
    
    RawAtt -->|Clean & Validate| DT1
    RawCheckin -->|Aggregate| DT2
    RawBooth -->|Calculate ROI| DT3
    RawFeedback -->|Analyze| Sentiment
    RawFeedback -->|Summarize| Summarize
    
    Sentiment -->|Sentiment Scores| DT2
    Summarize -->|Summary Text| DT3
    
    DT1 -->|Curated Data| SV
    DT2 -->|Engagement Metrics| SV
    DT3 -->|ROI Metrics| SV
    
    SV -->|Natural Language Queries| Agent
    DT2 -->|Real-Time Metrics| Dashboard
    DT3 -->|Filtered Views| Share
    
    style Stream fill:#29B5E8
    style Pipe fill:#29B5E8
    style Sentiment fill:#FF6B6B
    style Summarize fill:#FF6B6B
    style SV fill:#4ECDC4
    style Agent fill:#4ECDC4
```

## Component Descriptions
- Ingestion: Snowpipe Streaming API + streaming pipe landing into raw tables.
- Transformation: Dynamic Tables with target lags (5–15 min) for curated engagement/ROI metrics.
- AI Enrichment: Cortex SENTIMENT/SUMMARIZE add qualitative signals to metrics.
- Semantic & Consumption: Semantic view feeds Cortex Agent; dashboards and secure shares consume curated metrics.

## Change History
See `.cursor/DIAGRAM_CHANGELOG.md` for vhistory.

