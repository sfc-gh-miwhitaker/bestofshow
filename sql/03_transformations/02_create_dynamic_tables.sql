/*
 * ============================================================================
 * EVENT INTELLIGENCE PLATFORM - CREATE DYNAMIC TABLES
 * ============================================================================
 * Author: SE Community
 * Created: 2025-12-10
 * Expires: 2026-01-09
 * Purpose: Create auto-refreshing Dynamic Tables for real-time analytics
 * 
 * Dynamic Tables:
 *   - DT_ATTENDEE_ENGAGEMENT: 5-minute lag, attendee engagement metrics
 *   - DT_SESSION_ANALYTICS: 10-minute lag, session performance
 *   - DT_SPONSOR_PERFORMANCE: 15-minute lag, sponsor ROI
 *   - DT_LIVE_EVENT_PULSE: 1-minute lag, real-time event pulse
 * ============================================================================
 */

-- ============================================================================
-- CONTEXT SETTING (MANDATORY)
-- ============================================================================
USE ROLE SYSADMIN;
USE DATABASE SNOWFLAKE_EXAMPLE;
USE SCHEMA EVENT_INTELLIGENCE;
USE WAREHOUSE SFE_EVENT_INTELLIGENCE_WH;

-- =============================================================================
-- DT_ATTENDEE_ENGAGEMENT: Auto-refreshing attendee engagement metrics
-- =============================================================================
CREATE OR REPLACE DYNAMIC TABLE DT_ATTENDEE_ENGAGEMENT
    TARGET_LAG = '5 minutes'
    WAREHOUSE = SFE_EVENT_INTELLIGENCE_WH
    REFRESH_MODE = AUTO
    INITIALIZE = ON_CREATE
    COMMENT = 'DEMO: Auto-refreshing attendee engagement | Author: SE Community | Expires: 2026-01-09'
AS
SELECT 
    a.attendee_id,
    a.first_name || ' ' || a.last_name AS full_name,
    a.email,
    a.specialty,
    a.organization,
    a.registration_date,
    COALESCE(sc.sessions_attended, 0) AS sessions_attended,
    COALESCE(bv.booth_visits, 0) AS booth_visits,
    COALESCE(fb.feedback_count, 0) AS feedback_given,
    COALESCE(fb.avg_rating, 0) AS avg_rating_given,
    ROUND(
        (COALESCE(sc.sessions_attended, 0) * 10) + 
        (COALESCE(bv.booth_visits, 0) * 5) + 
        (COALESCE(fb.feedback_count, 0) * 15), 2
    ) AS engagement_score,
    CASE 
        WHEN (COALESCE(sc.sessions_attended, 0) * 10) + (COALESCE(bv.booth_visits, 0) * 5) + (COALESCE(fb.feedback_count, 0) * 15) >= 100 THEN 'Highly Engaged'
        WHEN (COALESCE(sc.sessions_attended, 0) * 10) + (COALESCE(bv.booth_visits, 0) * 5) + (COALESCE(fb.feedback_count, 0) * 15) >= 50 THEN 'Engaged'
        WHEN (COALESCE(sc.sessions_attended, 0) * 10) + (COALESCE(bv.booth_visits, 0) * 5) + (COALESCE(fb.feedback_count, 0) * 15) > 0 THEN 'Participating'
        ELSE 'Not Yet Active'
    END AS engagement_tier,
    CURRENT_TIMESTAMP() AS _refreshed_at
FROM RAW_ATTENDEES a
LEFT JOIN (
    SELECT attendee_id, COUNT(*) AS sessions_attended
    FROM RAW_SESSION_CHECKINS GROUP BY attendee_id
) sc ON a.attendee_id = sc.attendee_id
LEFT JOIN (
    SELECT attendee_id, COUNT(*) AS booth_visits
    FROM RAW_BOOTH_VISITS GROUP BY attendee_id
) bv ON a.attendee_id = bv.attendee_id
LEFT JOIN (
    SELECT attendee_id, COUNT(*) AS feedback_count, AVG(rating) AS avg_rating
    FROM RAW_FEEDBACK GROUP BY attendee_id
) fb ON a.attendee_id = fb.attendee_id;

-- =============================================================================
-- DT_SESSION_ANALYTICS: Auto-refreshing session performance
-- =============================================================================
CREATE OR REPLACE DYNAMIC TABLE DT_SESSION_ANALYTICS
    TARGET_LAG = '10 minutes'
    WAREHOUSE = SFE_EVENT_INTELLIGENCE_WH
    REFRESH_MODE = AUTO
    INITIALIZE = ON_CREATE
    COMMENT = 'DEMO: Auto-refreshing session analytics | Author: SE Community | Expires: 2026-01-09'
AS
SELECT 
    s.session_id,
    s.session_name,
    s.speaker,
    s.track,
    s.room,
    s.capacity,
    s.start_time,
    s.end_time,
    COALESCE(sc.attendance_count, 0) AS attendance_count,
    ROUND(COALESCE(sc.attendance_count, 0) * 100.0 / NULLIF(s.capacity, 0), 1) AS capacity_utilization_pct,
    COALESCE(fb.feedback_count, 0) AS feedback_count,
    ROUND(COALESCE(fb.avg_rating, 0), 2) AS avg_rating,
    COALESCE(fb.min_rating, 0) AS min_rating,
    COALESCE(fb.max_rating, 0) AS max_rating,
    CURRENT_TIMESTAMP() AS _refreshed_at
FROM RAW_SESSIONS s
LEFT JOIN (
    SELECT session_id, COUNT(DISTINCT attendee_id) AS attendance_count
    FROM RAW_SESSION_CHECKINS GROUP BY session_id
) sc ON s.session_id = sc.session_id
LEFT JOIN (
    SELECT session_id, 
           COUNT(*) AS feedback_count,
           AVG(rating) AS avg_rating,
           MIN(rating) AS min_rating,
           MAX(rating) AS max_rating
    FROM RAW_FEEDBACK GROUP BY session_id
) fb ON s.session_id = fb.session_id;

-- =============================================================================
-- DT_SPONSOR_PERFORMANCE: Auto-refreshing sponsor ROI metrics
-- =============================================================================
CREATE OR REPLACE DYNAMIC TABLE DT_SPONSOR_PERFORMANCE
    TARGET_LAG = '15 minutes'
    WAREHOUSE = SFE_EVENT_INTELLIGENCE_WH
    REFRESH_MODE = AUTO
    INITIALIZE = ON_CREATE
    COMMENT = 'DEMO: Auto-refreshing sponsor ROI | Author: SE Community | Expires: 2026-01-09'
AS
SELECT 
    sp.sponsor_id,
    sp.sponsor_name,
    sp.tier,
    sp.booth_number,
    sp.investment_amount,
    COALESCE(bv.total_visits, 0) AS total_booth_visits,
    COALESCE(bv.unique_visitors, 0) AS unique_visitors,
    ROUND(COALESCE(bv.avg_duration, 0), 1) AS avg_visit_duration_sec,
    ROUND(sp.investment_amount / NULLIF(bv.total_visits, 0), 2) AS cost_per_visit,
    ROUND(sp.investment_amount / NULLIF(bv.unique_visitors, 0), 2) AS cost_per_unique_visitor,
    ROUND(
        (COALESCE(bv.unique_visitors, 0) * COALESCE(bv.avg_duration, 0)) / 
        NULLIF(sp.investment_amount, 0) * 1000, 2
    ) AS roi_score,
    CASE sp.tier
        WHEN 'Platinum' THEN 1
        WHEN 'Gold' THEN 2
        WHEN 'Silver' THEN 3
        WHEN 'Bronze' THEN 4
        ELSE 5
    END AS tier_rank,
    CURRENT_TIMESTAMP() AS _refreshed_at
FROM RAW_SPONSORS sp
LEFT JOIN (
    SELECT 
        sponsor_name,
        COUNT(*) AS total_visits,
        COUNT(DISTINCT attendee_id) AS unique_visitors,
        AVG(duration_seconds) AS avg_duration
    FROM RAW_BOOTH_VISITS GROUP BY sponsor_name
) bv ON sp.sponsor_name = bv.sponsor_name;

-- =============================================================================
-- DT_LIVE_EVENT_PULSE: Real-time event activity pulse (1-minute lag)
-- =============================================================================
CREATE OR REPLACE DYNAMIC TABLE DT_LIVE_EVENT_PULSE
    TARGET_LAG = '1 minute'
    WAREHOUSE = SFE_EVENT_INTELLIGENCE_WH
    REFRESH_MODE = AUTO
    INITIALIZE = ON_CREATE
    COMMENT = 'DEMO: Real-time event pulse | Author: SE Community | Expires: 2026-01-09'
AS
SELECT 
    DATE_TRUNC('minute', CURRENT_TIMESTAMP()) AS pulse_time,
    (SELECT COUNT(*) FROM RAW_ATTENDEES) AS total_registered,
    (SELECT COUNT(DISTINCT attendee_id) FROM RAW_SESSION_CHECKINS) AS total_session_attendees,
    (SELECT COUNT(DISTINCT attendee_id) FROM RAW_BOOTH_VISITS) AS total_booth_visitors,
    (SELECT COUNT(*) FROM RAW_FEEDBACK) AS total_feedback,
    (SELECT ROUND(AVG(rating), 2) FROM RAW_FEEDBACK) AS overall_avg_rating,
    (SELECT COUNT(*) FROM RAW_SESSION_CHECKINS 
     WHERE checkin_timestamp >= DATEADD('hour', -1, CURRENT_TIMESTAMP())) AS checkins_last_hour,
    (SELECT COUNT(*) FROM RAW_BOOTH_VISITS 
     WHERE visit_timestamp >= DATEADD('hour', -1, CURRENT_TIMESTAMP())) AS booth_visits_last_hour,
    CURRENT_TIMESTAMP() AS _refreshed_at;

-- Verify Dynamic Tables created
SELECT 'Dynamic Tables created successfully' AS status;
SHOW DYNAMIC TABLES IN SCHEMA SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE;

