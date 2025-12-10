# Usage Guide - Event Intelligence Platform

**Author:** SE Community  
**Created:** 2025-12-10  
**Expires:** 2026-01-09

## Overview

This guide explains how to use the Event Intelligence Platform to analyze event data, sponsor ROI, and attendee engagement.

## Components

### 1. Streamlit Dashboard

The primary interface for event operations staff.

**Access:** Snowsight > Projects > Streamlit > `event_intelligence_dashboard`

**Features:**
- **Live Metrics Row:** Total registered, checked in, booth visitors, avg rating, feedback count
- **Session Performance:** Top sessions by attendance, ratings distribution
- **Sponsor ROI:** Booth visits, unique visitors, ROI scores by sponsor
- **Attendee Engagement:** Engagement tier distribution, specialty breakdown
- **AI Sentiment:** Cortex-powered feedback sentiment analysis

**Filters:**
- Date (All Days, Day 1, Day 2, Day 3)
- Session Track (Clinical Excellence, Research & Innovation, etc.)
- Sponsor Tier (Platinum, Gold, Silver, Bronze)

### 2. Cortex Agent

Natural language interface for ad-hoc analytics queries.

**Access:** Snowsight > AI & ML > Cortex Agents > `event_intelligence_agent`

**Sample Questions:**
- "What were the top 5 sessions by attendance?"
- "Which sponsors had the most booth visits?"
- "Show me average feedback ratings by track"
- "What specialties are most represented among attendees?"
- "How is sponsor ROI calculated and who has the best ROI?"
- "Which attendees are most engaged?"

**Tips:**
- Be specific with your questions
- Ask follow-up questions to drill down
- Request data in table format for detailed views

### 3. Semantic View

For direct SQL queries with business-friendly names.

**Location:** `SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS.SV_EVENT_ANALYTICS`

**Domains:**
- `sessions` - Session performance metrics
- `attendees` - Attendee engagement metrics
- `sponsors` - Sponsor ROI metrics

**Example Queries:**

```sql
-- Top sessions by attendance
SELECT session_name, speaker, attendance_count, avg_rating
FROM SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE.DT_SESSION_ANALYTICS
ORDER BY attendance_count DESC
LIMIT 10;

-- Sponsor ROI comparison
SELECT sponsor_name, tier, total_booth_visits, unique_visitors, roi_score
FROM SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE.DT_SPONSOR_PERFORMANCE
ORDER BY roi_score DESC;

-- Attendee engagement by specialty
SELECT specialty, COUNT(*) AS count, AVG(engagement_score) AS avg_engagement
FROM SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE.DT_ATTENDEE_ENGAGEMENT
GROUP BY specialty
ORDER BY avg_engagement DESC;
```

### 4. Dynamic Tables

Auto-refreshing analytics that power the dashboard.

| Table | Refresh Lag | Purpose |
|-------|-------------|---------|
| `DT_ATTENDEE_ENGAGEMENT` | 5 min | Per-attendee engagement metrics |
| `DT_SESSION_ANALYTICS` | 10 min | Session attendance and ratings |
| `DT_SPONSOR_PERFORMANCE` | 15 min | Sponsor booth ROI |
| `DT_LIVE_EVENT_PULSE` | 1 min | Real-time event summary |

**Monitoring:**
```sql
-- Check refresh status
SHOW DYNAMIC TABLES IN SCHEMA SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE;

-- Force refresh
ALTER DYNAMIC TABLE DT_LIVE_EVENT_PULSE REFRESH;
```

### 5. Cortex AI Features

**Sentiment Analysis:**
```sql
-- View feedback with sentiment
SELECT feedback_text, rating, sentiment_score, sentiment_category
FROM SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE.FEEDBACK_WITH_SENTIMENT
ORDER BY sentiment_score DESC
LIMIT 20;
```

**AI Summaries:**
```sql
-- Session feedback summaries
SELECT session_name, feedback_count, avg_rating, ai_summary
FROM SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE.SESSION_FEEDBACK_SUMMARIES;
```

**Sponsor Insights:**
```sql
-- AI-generated sponsor insights
SELECT sponsor_name, tier, roi_score, ai_insight
FROM SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE.SPONSOR_AI_INSIGHTS
ORDER BY roi_score DESC;
```

## Key Metrics Explained

### Engagement Score
Calculated as: `(sessions_attended × 10) + (booth_visits × 5) + (feedback_given × 15)`

**Tiers:**
- Highly Engaged: ≥100 points
- Engaged: 50-99 points
- Participating: 1-49 points
- Not Yet Active: 0 points

### Sponsor ROI Score
Calculated as: `(unique_visitors × avg_visit_duration_sec) / investment_amount × 1000`

Higher scores indicate better return on sponsorship investment.

### Capacity Utilization
Percentage of room capacity filled: `(attendance_count / capacity) × 100`

## Common Workflows

### 1. Morning Operations Check
1. Open Streamlit dashboard
2. Review live metrics row
3. Check which sessions are filling up
4. Identify any low-rated sessions needing attention

### 2. Sponsor Report
1. Query Cortex Agent: "Give me a summary of all Gold tier sponsor performance"
2. Export DT_SPONSOR_PERFORMANCE to CSV for sponsors
3. Review AI insights for talking points

### 3. Attendee Follow-Up
1. Identify highly engaged attendees from DT_ATTENDEE_ENGAGEMENT
2. Cross-reference with feedback to find advocates
3. Export for post-event nurture campaigns

### 4. Session Improvement
1. Review SESSION_FEEDBACK_SUMMARIES for AI-generated insights
2. Identify common themes in low-rated sessions
3. Share feedback with speakers for future improvement

## Data Refresh

- **RAW tables:** Simulated as batch/streaming (demo uses static sample data)
- **Dynamic Tables:** Automatic refresh based on TARGET_LAG
- **Cortex AI tables:** Generated once during deployment

To simulate real-time updates:
```sql
-- Add a new booth visit
INSERT INTO SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE.RAW_BOOTH_VISITS 
(visit_id, attendee_id, booth_id, sponsor_name, visit_timestamp, duration_seconds)
VALUES (99999, 1, 1, 'WoundCare Technologies Inc', CURRENT_TIMESTAMP(), 300);

-- Dynamic tables will auto-refresh within their TARGET_LAG
```

---

*This is a demonstration project. Data shown is synthetic.*
