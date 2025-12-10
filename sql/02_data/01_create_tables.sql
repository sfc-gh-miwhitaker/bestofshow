/*
 * ============================================================================
 * EVENT INTELLIGENCE PLATFORM - CREATE TABLES
 * ============================================================================
 * Author: SE Community
 * Created: 2025-12-10
 * Expires: 2026-01-09
 * Purpose: Create all RAW, STG, and analytics layer tables for event tracking
 * 
 * Tables Created:
 *   RAW Layer: RAW_ATTENDEES, RAW_SESSIONS, RAW_SPONSORS, RAW_BOOTH_VISITS,
 *              RAW_SESSION_CHECKINS, RAW_FEEDBACK
 *   STG Layer: STG_ATTENDEES
 *   Analytics: ATTENDEE_ENGAGEMENT_SUMMARY, SPONSOR_PERFORMANCE, SESSION_ANALYTICS
 * ============================================================================
 */

-- ============================================================================
-- CONTEXT SETTING (MANDATORY)
-- ============================================================================
USE ROLE SYSADMIN;
USE DATABASE SNOWFLAKE_EXAMPLE;
USE SCHEMA EVENT_INTELLIGENCE;

-- =============================================================================
-- RAW LAYER TABLES
-- =============================================================================

-- RAW_ATTENDEES: Event attendee registration data
CREATE OR REPLACE TABLE RAW_ATTENDEES (
    attendee_id         NUMBER(10) NOT NULL,
    first_name          VARCHAR(100),
    last_name           VARCHAR(100),
    email               VARCHAR(255),
    specialty           VARCHAR(100),
    organization        VARCHAR(200),
    registration_date   TIMESTAMP_NTZ,
    _loaded_at          TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    _source             VARCHAR(50) DEFAULT 'STREAMING',
    CONSTRAINT pk_raw_attendees PRIMARY KEY (attendee_id)
)
COMMENT = 'DEMO: Event Intelligence | RAW attendee registrations | Author: SE Community | Expires: 2026-01-09';

-- RAW_SESSIONS: Event session schedule
CREATE OR REPLACE TABLE RAW_SESSIONS (
    session_id          NUMBER(10) NOT NULL,
    session_name        VARCHAR(500),
    speaker             VARCHAR(200),
    start_time          TIMESTAMP_NTZ,
    end_time            TIMESTAMP_NTZ,
    room                VARCHAR(100),
    capacity            NUMBER(5),
    track               VARCHAR(100),
    _loaded_at          TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    _source             VARCHAR(50) DEFAULT 'BATCH',
    CONSTRAINT pk_raw_sessions PRIMARY KEY (session_id)
)
COMMENT = 'DEMO: Event Intelligence | RAW session schedule | Author: SE Community | Expires: 2026-01-09';

-- RAW_SPONSORS: Event sponsors and exhibitors
CREATE OR REPLACE TABLE RAW_SPONSORS (
    sponsor_id          NUMBER(10) NOT NULL,
    sponsor_name        VARCHAR(200),
    tier                VARCHAR(50),
    booth_number        VARCHAR(20),
    investment_amount   NUMBER(12,2),
    contact_email       VARCHAR(255),
    _loaded_at          TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    _source             VARCHAR(50) DEFAULT 'BATCH',
    CONSTRAINT pk_raw_sponsors PRIMARY KEY (sponsor_id)
)
COMMENT = 'DEMO: Event Intelligence | RAW sponsor/exhibitor data | Author: SE Community | Expires: 2026-01-09';

-- RAW_BOOTH_VISITS: Real-time booth visit tracking
CREATE OR REPLACE TABLE RAW_BOOTH_VISITS (
    visit_id            NUMBER(15) NOT NULL,
    attendee_id         NUMBER(10),
    booth_id            NUMBER(10),
    sponsor_name        VARCHAR(200),
    visit_timestamp     TIMESTAMP_NTZ,
    duration_seconds    NUMBER(10),
    _loaded_at          TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    _source             VARCHAR(50) DEFAULT 'STREAMING',
    CONSTRAINT pk_raw_booth_visits PRIMARY KEY (visit_id)
)
COMMENT = 'DEMO: Event Intelligence | RAW booth visit events | Author: SE Community | Expires: 2026-01-09';

-- RAW_SESSION_CHECKINS: Session attendance tracking
CREATE OR REPLACE TABLE RAW_SESSION_CHECKINS (
    checkin_id          NUMBER(15) NOT NULL,
    attendee_id         NUMBER(10),
    session_id          NUMBER(10),
    checkin_timestamp   TIMESTAMP_NTZ,
    checkin_method      VARCHAR(50) DEFAULT 'BADGE_SCAN',
    _loaded_at          TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    _source             VARCHAR(50) DEFAULT 'STREAMING',
    CONSTRAINT pk_raw_session_checkins PRIMARY KEY (checkin_id)
)
COMMENT = 'DEMO: Event Intelligence | RAW session check-ins | Author: SE Community | Expires: 2026-01-09';

-- RAW_FEEDBACK: Attendee feedback and ratings
CREATE OR REPLACE TABLE RAW_FEEDBACK (
    feedback_id         NUMBER(15) NOT NULL,
    attendee_id         NUMBER(10),
    session_id          NUMBER(10),
    rating              NUMBER(1),
    feedback_text       VARCHAR(2000),
    submitted_at        TIMESTAMP_NTZ,
    _loaded_at          TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    _source             VARCHAR(50) DEFAULT 'SURVEY',
    CONSTRAINT pk_raw_feedback PRIMARY KEY (feedback_id)
)
COMMENT = 'DEMO: Event Intelligence | RAW feedback/ratings | Author: SE Community | Expires: 2026-01-09';

-- =============================================================================
-- STAGING LAYER TABLES
-- =============================================================================

-- STG_ATTENDEES: Cleaned and validated attendee data
CREATE OR REPLACE TABLE STG_ATTENDEES (
    attendee_id         NUMBER(10) NOT NULL,
    first_name          VARCHAR(100),
    last_name           VARCHAR(100),
    full_name           VARCHAR(200),
    email               VARCHAR(255),
    specialty           VARCHAR(100),
    specialty_normalized VARCHAR(100),
    organization        VARCHAR(200),
    registration_date   TIMESTAMP_NTZ,
    engagement_tier     VARCHAR(20),
    _validated_at       TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT pk_stg_attendees PRIMARY KEY (attendee_id)
)
COMMENT = 'DEMO: Event Intelligence | STG cleaned attendees | Author: SE Community | Expires: 2026-01-09';

-- =============================================================================
-- ANALYTICS LAYER TABLES
-- =============================================================================

-- ATTENDEE_ENGAGEMENT_SUMMARY: Per-attendee engagement metrics
CREATE OR REPLACE TABLE ATTENDEE_ENGAGEMENT_SUMMARY (
    attendee_id             NUMBER(10) NOT NULL,
    full_name               VARCHAR(200),
    specialty               VARCHAR(100),
    organization            VARCHAR(200),
    total_sessions_attended NUMBER(5),
    total_booth_visits      NUMBER(5),
    total_feedback_given    NUMBER(5),
    avg_feedback_rating     NUMBER(3,2),
    engagement_score        NUMBER(5,2),
    last_activity           TIMESTAMP_NTZ,
    _calculated_at          TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT pk_attendee_engagement PRIMARY KEY (attendee_id)
)
COMMENT = 'DEMO: Event Intelligence | Attendee engagement summary | Author: SE Community | Expires: 2026-01-09';

-- SPONSOR_PERFORMANCE: Sponsor ROI metrics
CREATE OR REPLACE TABLE SPONSOR_PERFORMANCE (
    sponsor_id              NUMBER(10) NOT NULL,
    sponsor_name            VARCHAR(200),
    tier                    VARCHAR(50),
    booth_number            VARCHAR(20),
    investment_amount       NUMBER(12,2),
    total_booth_visits      NUMBER(10),
    unique_visitors         NUMBER(10),
    avg_visit_duration_sec  NUMBER(10,2),
    total_leads_captured    NUMBER(10),
    roi_score               NUMBER(5,2),
    feedback_summary        VARCHAR(2000),
    _calculated_at          TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT pk_sponsor_performance PRIMARY KEY (sponsor_id)
)
COMMENT = 'DEMO: Event Intelligence | Sponsor ROI metrics | Author: SE Community | Expires: 2026-01-09';

-- SESSION_ANALYTICS: Session performance metrics
CREATE OR REPLACE TABLE SESSION_ANALYTICS (
    session_id              NUMBER(10) NOT NULL,
    session_name            VARCHAR(500),
    speaker                 VARCHAR(200),
    track                   VARCHAR(100),
    room                    VARCHAR(100),
    capacity                NUMBER(5),
    total_attendees         NUMBER(5),
    capacity_utilization    NUMBER(5,2),
    avg_rating              NUMBER(3,2),
    total_feedback          NUMBER(5),
    top_feedback_themes     VARCHAR(2000),
    sentiment_score         NUMBER(4,3),
    _calculated_at          TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT pk_session_analytics PRIMARY KEY (session_id)
)
COMMENT = 'DEMO: Event Intelligence | Session analytics | Author: SE Community | Expires: 2026-01-09';

-- Verify table creation
SELECT 'Tables created successfully' AS status, COUNT(*) AS table_count
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'EVENT_INTELLIGENCE' 
  AND TABLE_CATALOG = 'SNOWFLAKE_EXAMPLE';

