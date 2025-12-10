# Data Model - Event Intelligence Platform
Author: SE Community
Last Updated: 2025-12-10
Expires: 2026-01-09
Status: Reference Implementation

![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)

Reference Implementation: This code demonstrates production-grade architectural patterns and best practices. Review and customize security, networking, and logic for your organization's specific requirements before deployment.

## Overview
This diagram shows the layered data model for event intelligence: raw ingestion tables for attendees, sessions, booth visits, feedback, and sponsors; staging for validation/enrichment; and analytics/semantic-ready tables for engagement, ROI, and session performance.

```mermaid
erDiagram
    RAW_ATTENDEES ||--o{ RAW_SESSION_CHECKINS : attends
    RAW_ATTENDEES ||--o{ RAW_BOOTH_VISITS : visits
    RAW_ATTENDEES ||--o{ RAW_FEEDBACK : provides
    RAW_SESSIONS ||--o{ RAW_SESSION_CHECKINS : hosts
    RAW_SESSIONS ||--o{ RAW_FEEDBACK : receives
    RAW_SPONSORS ||--o{ RAW_BOOTH_VISITS : owns
    RAW_ATTENDEES ||--|| STG_ATTENDEES : "cleaned from"
    
    RAW_ATTENDEES {
        int attendee_id PK
        string first_name
        string last_name
        string email UK
        string specialty
        string organization
        timestamp registration_date
    }
    
    RAW_SESSIONS {
        int session_id PK
        string session_name
        string speaker
        timestamp start_time
        timestamp end_time
        string room
        int capacity
    }
    
    RAW_BOOTH_VISITS {
        int visit_id PK
        int attendee_id FK
        int booth_id
        string sponsor_name FK
        timestamp visit_timestamp
        int duration_seconds
    }
    
    RAW_SESSION_CHECKINS {
        int checkin_id PK
        int attendee_id FK
        int session_id FK
        timestamp checkin_timestamp
    }
    
    RAW_FEEDBACK {
        int feedback_id PK
        int attendee_id FK
        int session_id FK
        int rating
        string feedback_text
        timestamp submitted_at
        float sentiment_score "Cortex AI"
    }
    
    RAW_SPONSORS {
        int sponsor_id PK
        string sponsor_name UK
        string tier
        string booth_number
        decimal investment_amount
    }
    
    STG_ATTENDEES {
        int attendee_id PK
        string first_name "validated"
        string last_name "validated"
        string email UK "validated"
        string specialty "normalized"
        string organization
        timestamp registration_date
        string engagement_tier "enriched"
    }
    
    ATTENDEE_ENGAGEMENT_SUMMARY {
        int attendee_id PK
        int total_sessions_attended
        int total_booth_visits
        decimal avg_feedback_rating
        float engagement_score "ML derived"
        timestamp last_activity
    }
    
    SPONSOR_PERFORMANCE {
        string sponsor_name PK
        string tier
        int total_booth_visits
        int unique_visitors
        decimal avg_visit_duration
        decimal roi_score "calculated"
        timestamp last_updated
    }
    
    SESSION_ANALYTICS {
        int session_id PK
        string session_name
        int total_attendees
        decimal avg_rating
        decimal capacity_utilization
        string top_feedback_themes "Cortex AI"
        timestamp last_updated
    }
```

## Component Descriptions
- RAW layer: Landing tables for attendees, sessions, check-ins, booth visits, feedback, and sponsors ingested via Snowpipe Streaming.
- STG_ATTENDEES: Cleans and normalizes attendee profiles; seeds engagement tiering.
- Analytics tables: Engagement, sponsor performance, and session analytics for dashboards and semantic views.
- Sentiment fields: Feedback is enriched via Cortex AI sentiment scoring to feed engagement KPIs.

## Change History
See `.cursor/DIAGRAM_CHANGELOG.md` for vhistory.

