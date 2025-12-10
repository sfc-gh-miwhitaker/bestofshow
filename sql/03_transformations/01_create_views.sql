/*
 * ============================================================================
 * EVENT INTELLIGENCE PLATFORM - CREATE VIEWS
 * ============================================================================
 * Author: SE Community
 * Created: 2025-12-10
 * Expires: 2026-01-09
 * Purpose: Create analytical views for real-time event insights
 * ============================================================================
 */

USE DATABASE SNOWFLAKE_EXAMPLE;
USE SCHEMA EVENT_INTELLIGENCE;

-- =============================================================================
-- V_ATTENDEE_ENGAGEMENT: Real-time attendee engagement metrics
-- =============================================================================
CREATE OR REPLACE VIEW V_ATTENDEE_ENGAGEMENT AS
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
    -- Engagement score: weighted combination of activities
    ROUND(
        (COALESCE(sc.sessions_attended, 0) * 10) + 
        (COALESCE(bv.booth_visits, 0) * 5) + 
        (COALESCE(fb.feedback_count, 0) * 15), 2
    ) AS engagement_score,
    GREATEST(
        COALESCE(sc.last_checkin, a.registration_date),
        COALESCE(bv.last_visit, a.registration_date),
        COALESCE(fb.last_feedback, a.registration_date)
    ) AS last_activity
FROM RAW_ATTENDEES a
LEFT JOIN (
    SELECT attendee_id, 
           COUNT(*) AS sessions_attended,
           MAX(checkin_timestamp) AS last_checkin
    FROM RAW_SESSION_CHECKINS 
    GROUP BY attendee_id
) sc ON a.attendee_id = sc.attendee_id
LEFT JOIN (
    SELECT attendee_id, 
           COUNT(*) AS booth_visits,
           MAX(visit_timestamp) AS last_visit
    FROM RAW_BOOTH_VISITS 
    GROUP BY attendee_id
) bv ON a.attendee_id = bv.attendee_id
LEFT JOIN (
    SELECT attendee_id, 
           COUNT(*) AS feedback_count,
           AVG(rating) AS avg_rating,
           MAX(submitted_at) AS last_feedback
    FROM RAW_FEEDBACK 
    GROUP BY attendee_id
) fb ON a.attendee_id = fb.attendee_id
COMMENT = 'DEMO: Real-time attendee engagement metrics | Author: SE Community | Expires: 2026-01-09';

-- =============================================================================
-- V_SESSION_PERFORMANCE: Session attendance and feedback metrics
-- =============================================================================
CREATE OR REPLACE VIEW V_SESSION_PERFORMANCE AS
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
    fb.sample_feedback
FROM RAW_SESSIONS s
LEFT JOIN (
    SELECT session_id, COUNT(DISTINCT attendee_id) AS attendance_count
    FROM RAW_SESSION_CHECKINS 
    GROUP BY session_id
) sc ON s.session_id = sc.session_id
LEFT JOIN (
    SELECT session_id, 
           COUNT(*) AS feedback_count,
           AVG(rating) AS avg_rating,
           LISTAGG(feedback_text, ' | ') WITHIN GROUP (ORDER BY submitted_at DESC) AS sample_feedback
    FROM (SELECT * FROM RAW_FEEDBACK QUALIFY ROW_NUMBER() OVER (PARTITION BY session_id ORDER BY submitted_at DESC) <= 3)
    GROUP BY session_id
) fb ON s.session_id = fb.session_id
COMMENT = 'DEMO: Session attendance and feedback metrics | Author: SE Community | Expires: 2026-01-09';

-- =============================================================================
-- V_SPONSOR_ROI: Sponsor booth performance and ROI metrics
-- =============================================================================
CREATE OR REPLACE VIEW V_SPONSOR_ROI AS
SELECT 
    sp.sponsor_id,
    sp.sponsor_name,
    sp.tier,
    sp.booth_number,
    sp.investment_amount,
    COALESCE(bv.total_visits, 0) AS total_booth_visits,
    COALESCE(bv.unique_visitors, 0) AS unique_visitors,
    ROUND(COALESCE(bv.avg_duration, 0), 1) AS avg_visit_duration_sec,
    -- Cost per visit
    ROUND(sp.investment_amount / NULLIF(bv.total_visits, 0), 2) AS cost_per_visit,
    -- Cost per unique visitor
    ROUND(sp.investment_amount / NULLIF(bv.unique_visitors, 0), 2) AS cost_per_unique_visitor,
    -- ROI Score (higher is better): visitors * avg_duration / investment * 1000
    ROUND(
        (COALESCE(bv.unique_visitors, 0) * COALESCE(bv.avg_duration, 0)) / 
        NULLIF(sp.investment_amount, 0) * 1000, 2
    ) AS roi_score,
    bv.peak_hour
FROM RAW_SPONSORS sp
LEFT JOIN (
    SELECT 
        sponsor_name,
        COUNT(*) AS total_visits,
        COUNT(DISTINCT attendee_id) AS unique_visitors,
        AVG(duration_seconds) AS avg_duration,
        MODE(HOUR(visit_timestamp)) AS peak_hour
    FROM RAW_BOOTH_VISITS 
    GROUP BY sponsor_name
) bv ON sp.sponsor_name = bv.sponsor_name
COMMENT = 'DEMO: Sponsor booth ROI metrics | Author: SE Community | Expires: 2026-01-09';

-- =============================================================================
-- V_HOURLY_EVENT_METRICS: Time-series metrics for dashboards
-- =============================================================================
CREATE OR REPLACE VIEW V_HOURLY_EVENT_METRICS AS
SELECT 
    DATE_TRUNC('hour', event_timestamp) AS hour,
    event_type,
    COUNT(*) AS event_count,
    COUNT(DISTINCT attendee_id) AS unique_attendees
FROM (
    SELECT checkin_timestamp AS event_timestamp, 'SESSION_CHECKIN' AS event_type, attendee_id FROM RAW_SESSION_CHECKINS
    UNION ALL
    SELECT visit_timestamp, 'BOOTH_VISIT', attendee_id FROM RAW_BOOTH_VISITS
    UNION ALL
    SELECT submitted_at, 'FEEDBACK', attendee_id FROM RAW_FEEDBACK
)
GROUP BY 1, 2
ORDER BY 1, 2
COMMENT = 'DEMO: Hourly event metrics for dashboards | Author: SE Community | Expires: 2026-01-09';

-- =============================================================================
-- V_SPECIALTY_BREAKDOWN: Attendee specialty analytics
-- =============================================================================
CREATE OR REPLACE VIEW V_SPECIALTY_BREAKDOWN AS
SELECT 
    specialty,
    COUNT(*) AS attendee_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pct_of_total,
    AVG(engagement_score) AS avg_engagement_score
FROM V_ATTENDEE_ENGAGEMENT
GROUP BY specialty
ORDER BY attendee_count DESC
COMMENT = 'DEMO: Attendee breakdown by specialty | Author: SE Community | Expires: 2026-01-09';

-- Verify views created
SELECT 'Views created successfully' AS status;

