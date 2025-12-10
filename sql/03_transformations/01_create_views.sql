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

-- ============================================================================
-- CONTEXT SETTING (MANDATORY)
-- ============================================================================
USE ROLE SYSADMIN;
USE DATABASE SNOWFLAKE_EXAMPLE;
USE SCHEMA EVENT_INTELLIGENCE;

-- =============================================================================
-- V_ATTENDEE_ENGAGEMENT: Real-time attendee engagement metrics
-- =============================================================================
CREATE OR REPLACE VIEW V_ATTENDEE_ENGAGEMENT
COMMENT
= 'DEMO: Real-time attendee engagement metrics | Author: SE Community | Expires: 2026-01-09'
AS
WITH BV AS (
    SELECT
        ATTENDEE_ID,
        COUNT(*) AS BOOTH_VISITS,
        MAX(VISIT_TIMESTAMP) AS LAST_VISIT
    FROM RAW_BOOTH_VISITS
    GROUP BY ATTENDEE_ID
),
SC AS (
    SELECT
        ATTENDEE_ID,
        COUNT(*) AS SESSIONS_ATTENDED,
        MAX(CHECKIN_TIMESTAMP) AS LAST_CHECKIN
    FROM RAW_SESSION_CHECKINS
    GROUP BY ATTENDEE_ID
),
FB AS (
    SELECT
        ATTENDEE_ID,
        COUNT(*) AS FEEDBACK_COUNT,
        AVG(RATING) AS AVG_RATING,
        MAX(SUBMITTED_AT) AS LAST_FEEDBACK
    FROM RAW_FEEDBACK
    GROUP BY ATTENDEE_ID
)
SELECT
    A.ATTENDEE_ID,
    A.EMAIL,
    A.SPECIALTY,
    A.ORGANIZATION,
    A.REGISTRATION_DATE,
    A.FIRST_NAME || ' ' || A.LAST_NAME AS FULL_NAME,
    COALESCE(SC.SESSIONS_ATTENDED, 0) AS SESSIONS_ATTENDED,
    COALESCE(BV.BOOTH_VISITS, 0) AS BOOTH_VISITS,
    COALESCE(FB.FEEDBACK_COUNT, 0) AS FEEDBACK_GIVEN,
    COALESCE(FB.AVG_RATING, 0) AS AVG_RATING_GIVEN,
    -- Engagement score: weighted combination of activities
    ROUND(
        (COALESCE(SC.SESSIONS_ATTENDED, 0) * 10)
        + (COALESCE(BV.BOOTH_VISITS, 0) * 5)
        + (COALESCE(FB.FEEDBACK_COUNT, 0) * 15), 2
    ) AS ENGAGEMENT_SCORE,
    GREATEST(
        COALESCE(SC.LAST_CHECKIN, A.REGISTRATION_DATE),
        COALESCE(BV.LAST_VISIT, A.REGISTRATION_DATE),
        COALESCE(FB.LAST_FEEDBACK, A.REGISTRATION_DATE)
    ) AS LAST_ACTIVITY
FROM RAW_ATTENDEES AS A
LEFT JOIN SC ON A.ATTENDEE_ID = SC.ATTENDEE_ID
LEFT JOIN BV ON A.ATTENDEE_ID = BV.ATTENDEE_ID
LEFT JOIN FB ON A.ATTENDEE_ID = FB.ATTENDEE_ID;

-- =============================================================================
-- V_SESSION_PERFORMANCE: Session attendance and feedback metrics
-- =============================================================================
CREATE OR REPLACE VIEW V_SESSION_PERFORMANCE
COMMENT
= 'DEMO: Session attendance and feedback metrics | Author: SE Community | Expires: 2026-01-09'
AS
WITH SC AS (
    SELECT
        SESSION_ID,
        COUNT(DISTINCT ATTENDEE_ID) AS ATTENDANCE_COUNT
    FROM RAW_SESSION_CHECKINS
    GROUP BY SESSION_ID
),
FB AS (
    SELECT
        SESSION_ID,
        COUNT(*) AS FEEDBACK_COUNT,
        AVG(RATING) AS AVG_RATING,
        LISTAGG(FEEDBACK_TEXT, ' | ') WITHIN GROUP (
            ORDER BY SUBMITTED_AT DESC
        ) AS SAMPLE_FEEDBACK
    FROM (
        SELECT
            SESSION_ID,
            RATING,
            FEEDBACK_TEXT,
            SUBMITTED_AT
        FROM RAW_FEEDBACK
        QUALIFY
            ROW_NUMBER()
                OVER (PARTITION BY SESSION_ID ORDER BY SUBMITTED_AT DESC)
            <= 3
    )
    GROUP BY SESSION_ID
)
SELECT
    S.SESSION_ID,
    S.SESSION_NAME,
    S.SPEAKER,
    S.TRACK,
    S.ROOM,
    S.CAPACITY,
    S.START_TIME,
    S.END_TIME,
    FB.SAMPLE_FEEDBACK,
    COALESCE(SC.ATTENDANCE_COUNT, 0) AS ATTENDANCE_COUNT,
    ROUND(COALESCE(SC.ATTENDANCE_COUNT, 0) * 100.0 / NULLIF(S.CAPACITY, 0), 1)
        AS CAPACITY_UTILIZATION_PCT,
    COALESCE(FB.FEEDBACK_COUNT, 0) AS FEEDBACK_COUNT,
    ROUND(COALESCE(FB.AVG_RATING, 0), 2) AS AVG_RATING
FROM RAW_SESSIONS AS S
LEFT JOIN SC ON S.SESSION_ID = SC.SESSION_ID
LEFT JOIN FB ON S.SESSION_ID = FB.SESSION_ID;

-- =============================================================================
-- V_SPONSOR_ROI: Sponsor booth performance and ROI metrics
-- =============================================================================
CREATE OR REPLACE VIEW V_SPONSOR_ROI
COMMENT
= 'DEMO: Sponsor booth ROI metrics | Author: SE Community | Expires: 2026-01-09'
AS
WITH BV AS (
    SELECT
        SPONSOR_NAME,
        COUNT(*) AS TOTAL_VISITS,
        COUNT(DISTINCT ATTENDEE_ID) AS UNIQUE_VISITORS,
        AVG(DURATION_SECONDS) AS AVG_DURATION,
        MODE(HOUR(VISIT_TIMESTAMP)) AS PEAK_HOUR
    FROM RAW_BOOTH_VISITS
    GROUP BY SPONSOR_NAME
)
SELECT
    SP.SPONSOR_ID,
    SP.SPONSOR_NAME,
    SP.TIER,
    SP.BOOTH_NUMBER,
    SP.INVESTMENT_AMOUNT,
    BV.PEAK_HOUR,
    COALESCE(BV.TOTAL_VISITS, 0) AS TOTAL_BOOTH_VISITS,
    COALESCE(BV.UNIQUE_VISITORS, 0) AS UNIQUE_VISITORS,
    -- Cost per visit
    ROUND(COALESCE(BV.AVG_DURATION, 0), 1) AS AVG_VISIT_DURATION_SEC,
    -- Cost per unique visitor
    ROUND(SP.INVESTMENT_AMOUNT / NULLIF(BV.TOTAL_VISITS, 0), 2)
        AS COST_PER_VISIT,
    -- ROI Score (higher is better): visitors * avg_duration / investment * 1000
    ROUND(SP.INVESTMENT_AMOUNT / NULLIF(BV.UNIQUE_VISITORS, 0), 2)
        AS COST_PER_UNIQUE_VISITOR,
    ROUND(
        (COALESCE(BV.UNIQUE_VISITORS, 0) * COALESCE(BV.AVG_DURATION, 0))
        / NULLIF(SP.INVESTMENT_AMOUNT, 0) * 1000, 2
    ) AS ROI_SCORE
FROM RAW_SPONSORS AS SP
LEFT JOIN BV ON SP.SPONSOR_NAME = BV.SPONSOR_NAME;

-- =============================================================================
-- V_HOURLY_EVENT_METRICS: Time-series metrics for dashboards
-- =============================================================================
CREATE OR REPLACE VIEW V_HOURLY_EVENT_METRICS
COMMENT
= 'DEMO: Hourly event metrics for dashboards | Author: SE Community | Expires: 2026-01-09'
AS
SELECT
    DATE_TRUNC('hour', EVENT_TIMESTAMP) AS HOUR,
    EVENT_TYPE,
    COUNT(*) AS EVENT_COUNT,
    COUNT(DISTINCT ATTENDEE_ID) AS UNIQUE_ATTENDEES
FROM (
    SELECT
        CHECKIN_TIMESTAMP AS EVENT_TIMESTAMP,
        'SESSION_CHECKIN' AS EVENT_TYPE,
        ATTENDEE_ID
    FROM RAW_SESSION_CHECKINS
    UNION ALL
    SELECT
        VISIT_TIMESTAMP,
        'BOOTH_VISIT',
        ATTENDEE_ID
    FROM RAW_BOOTH_VISITS
    UNION ALL
    SELECT
        SUBMITTED_AT,
        'FEEDBACK',
        ATTENDEE_ID
    FROM RAW_FEEDBACK
)
GROUP BY 1, 2
ORDER BY 1, 2;

-- =============================================================================
-- V_SPECIALTY_BREAKDOWN: Attendee specialty analytics
-- =============================================================================
CREATE OR REPLACE VIEW V_SPECIALTY_BREAKDOWN
COMMENT
= 'DEMO: Attendee breakdown by specialty | Author: SE Community | Expires: 2026-01-09'
AS
SELECT
    SPECIALTY,
    COUNT(*) AS ATTENDEE_COUNT,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS PCT_OF_TOTAL,
    AVG(ENGAGEMENT_SCORE) AS AVG_ENGAGEMENT_SCORE
FROM V_ATTENDEE_ENGAGEMENT
GROUP BY SPECIALTY
ORDER BY ATTENDEE_COUNT DESC;

-- Verify views created
SELECT 'Views created successfully' AS STATUS;
