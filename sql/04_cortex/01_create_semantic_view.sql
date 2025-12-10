/*
 * ============================================================================
 * EVENT INTELLIGENCE PLATFORM - CORTEX AI SEMANTIC VIEW
 * ============================================================================
 * Author: SE Community
 * Created: 2025-12-10
 * Expires: 2026-01-09
 * Purpose: Create Semantic View for Cortex Analyst natural language queries
 * 
 * Location: SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS.SV_EVENT_ANALYTICS
 * 
 * Enables questions like:
 *   - "What were the top 5 sessions by attendance?"
 *   - "Which sponsors had the most booth visits?"
 *   - "Show me average feedback ratings by session"
 *   - "What specialties are most represented among attendees?"
 * ============================================================================
 */

USE DATABASE SNOWFLAKE_EXAMPLE;
USE SCHEMA SEMANTIC_MODELS;

-- =============================================================================
-- CREATE SEMANTIC VIEW: SV_EVENT_ANALYTICS
-- =============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_EVENT_ANALYTICS
  COMMENT = 'DEMO: Event Intelligence semantic view for Cortex Analyst | Author: SE Community | Expires: 2026-01-09'
  
  -- Define the logical tables
  TABLES (
    -- Session analytics table
    sessions AS SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE.DT_SESSION_ANALYTICS
      PRIMARY KEY (session_id)
      WITH SYNONYMS = ('session', 'presentation', 'talk', 'lecture', 'workshop')
      COMMENT = 'Session performance metrics including attendance, capacity utilization, and feedback ratings for the International Wound Care Symposium',
    
    -- Attendee engagement table
    attendees AS SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE.DT_ATTENDEE_ENGAGEMENT
      PRIMARY KEY (attendee_id)
      WITH SYNONYMS = ('attendee', 'participant', 'registrant', 'delegate', 'guest')
      COMMENT = 'Attendee engagement metrics including session attendance, booth visits, and feedback activity for conference participants',
    
    -- Sponsor performance table
    sponsors AS SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE.DT_SPONSOR_PERFORMANCE
      PRIMARY KEY (sponsor_id)
      WITH SYNONYMS = ('sponsor', 'exhibitor', 'vendor', 'partner', 'booth')
      COMMENT = 'Sponsor ROI metrics including booth visits, visitor engagement, and cost efficiency for exhibition partners'
  )
  
  -- Define dimensions (categorical fields for grouping/filtering)
  DIMENSIONS (
    -- Session dimensions
    sessions.session_id
      WITH SYNONYMS = ('session id', 'presentation id')
      COMMENT = 'Unique identifier for each session',
    sessions.session_name
      WITH SYNONYMS = ('session title', 'presentation name', 'talk title')
      COMMENT = 'Full name of the session or presentation',
    sessions.speaker
      WITH SYNONYMS = ('presenter', 'lecturer', 'faculty')
      COMMENT = 'Name of the session speaker or presenter',
    sessions.track
      WITH SYNONYMS = ('category', 'theme', 'topic area', 'session type')
      COMMENT = 'Conference track or category the session belongs to',
    sessions.room
      WITH SYNONYMS = ('venue', 'location', 'hall')
      COMMENT = 'Physical room or venue where the session takes place',
    
    -- Attendee dimensions
    attendees.attendee_id
      WITH SYNONYMS = ('participant id', 'registrant id')
      COMMENT = 'Unique identifier for each attendee',
    attendees.full_name
      WITH SYNONYMS = ('name', 'attendee name', 'participant name')
      COMMENT = 'Full name of the attendee',
    attendees.specialty
      WITH SYNONYMS = ('profession', 'role', 'job title', 'clinical specialty')
      COMMENT = 'Medical specialty or professional role of the attendee',
    attendees.organization
      WITH SYNONYMS = ('company', 'hospital', 'institution', 'employer')
      COMMENT = 'Organization or institution the attendee represents',
    attendees.engagement_tier
      WITH SYNONYMS = ('engagement level', 'activity level', 'participation level')
      COMMENT = 'Categorized engagement level: Highly Engaged, Engaged, Participating, Not Yet Active',
    
    -- Sponsor dimensions
    sponsors.sponsor_id
      WITH SYNONYMS = ('exhibitor id', 'vendor id')
      COMMENT = 'Unique identifier for each sponsor',
    sponsors.sponsor_name
      WITH SYNONYMS = ('company name', 'exhibitor name', 'vendor name')
      COMMENT = 'Name of the sponsor or exhibiting company',
    sponsors.tier
      WITH SYNONYMS = ('sponsorship level', 'package', 'sponsorship tier')
      COMMENT = 'Sponsorship tier: Platinum, Gold, Silver, Bronze',
    sponsors.booth_number
      WITH SYNONYMS = ('booth id', 'exhibit location', 'stand number')
      COMMENT = 'Booth or exhibit location identifier'
  )
  
  -- Define facts (numeric measures for aggregation)
  FACTS (
    -- Session facts
    sessions.capacity
      WITH SYNONYMS = ('room capacity', 'max attendees', 'seats')
      COMMENT = 'Maximum capacity of the session room in number of seats',
    sessions.attendance_count
      WITH SYNONYMS = ('attendees', 'participants', 'headcount', 'people attended')
      COMMENT = 'Number of attendees who checked into the session',
    sessions.capacity_utilization_pct
      WITH SYNONYMS = ('utilization', 'fill rate', 'occupancy')
      COMMENT = 'Percentage of room capacity used (0-100%)',
    sessions.feedback_count
      WITH SYNONYMS = ('reviews', 'responses', 'evaluations')
      COMMENT = 'Number of feedback responses received for the session',
    sessions.avg_rating
      WITH SYNONYMS = ('rating', 'score', 'satisfaction score', 'average score')
      COMMENT = 'Average feedback rating (1-5 scale) for the session',
    
    -- Attendee facts
    attendees.sessions_attended
      WITH SYNONYMS = ('session count', 'presentations attended')
      COMMENT = 'Total number of sessions the attendee checked into',
    attendees.booth_visits
      WITH SYNONYMS = ('exhibit visits', 'sponsor visits', 'vendor visits')
      COMMENT = 'Total number of sponsor booths the attendee visited',
    attendees.feedback_given
      WITH SYNONYMS = ('reviews given', 'evaluations submitted')
      COMMENT = 'Total number of feedback responses submitted by the attendee',
    attendees.engagement_score
      WITH SYNONYMS = ('activity score', 'participation score')
      COMMENT = 'Calculated engagement score based on sessions, booth visits, and feedback',
    
    -- Sponsor facts
    sponsors.investment_amount
      WITH SYNONYMS = ('sponsorship cost', 'package price', 'spend')
      COMMENT = 'Total investment amount for the sponsorship package in USD',
    sponsors.total_booth_visits
      WITH SYNONYMS = ('total visits', 'booth traffic', 'foot traffic')
      COMMENT = 'Total number of booth visits received',
    sponsors.unique_visitors
      WITH SYNONYMS = ('unique attendees', 'distinct visitors')
      COMMENT = 'Number of unique attendees who visited the booth',
    sponsors.avg_visit_duration_sec
      WITH SYNONYMS = ('average visit time', 'dwell time', 'time spent')
      COMMENT = 'Average duration of booth visits in seconds',
    sponsors.cost_per_visit
      WITH SYNONYMS = ('cpv', 'cost efficiency')
      COMMENT = 'Cost per booth visit (investment / total visits)',
    sponsors.cost_per_unique_visitor
      WITH SYNONYMS = ('cost per lead', 'acquisition cost')
      COMMENT = 'Cost per unique visitor (investment / unique visitors)',
    sponsors.roi_score
      WITH SYNONYMS = ('return on investment', 'roi', 'effectiveness score')
      COMMENT = 'ROI score calculated as (unique visitors * avg duration) / investment * 1000'
  )
  
  -- Define pre-calculated metrics
  METRICS (
    -- Aggregate session metrics
    total_sessions AS COUNT(sessions.session_id)
      WITH SYNONYMS = ('session count', 'number of sessions')
      COMMENT = 'Total number of sessions in the conference',
    
    avg_session_attendance AS AVG(sessions.attendance_count)
      WITH SYNONYMS = ('average attendance', 'mean attendance')
      COMMENT = 'Average number of attendees per session',
    
    avg_session_rating AS AVG(sessions.avg_rating)
      WITH SYNONYMS = ('overall rating', 'conference rating')
      COMMENT = 'Average feedback rating across all sessions',
    
    total_session_capacity AS SUM(sessions.capacity)
      WITH SYNONYMS = ('total capacity', 'total seats')
      COMMENT = 'Sum of all session room capacities',
    
    -- Aggregate attendee metrics
    total_attendees AS COUNT(attendees.attendee_id)
      WITH SYNONYMS = ('registrations', 'participant count')
      COMMENT = 'Total number of registered attendees',
    
    avg_engagement_score AS AVG(attendees.engagement_score)
      WITH SYNONYMS = ('average engagement', 'mean engagement')
      COMMENT = 'Average engagement score across all attendees',
    
    highly_engaged_count AS COUNT_IF(attendees.engagement_tier = 'Highly Engaged')
      WITH SYNONYMS = ('power users', 'super engaged')
      COMMENT = 'Number of attendees in the Highly Engaged tier',
    
    -- Aggregate sponsor metrics
    total_sponsors AS COUNT(sponsors.sponsor_id)
      WITH SYNONYMS = ('exhibitor count', 'vendor count')
      COMMENT = 'Total number of sponsors/exhibitors',
    
    total_sponsorship_revenue AS SUM(sponsors.investment_amount)
      WITH SYNONYMS = ('sponsorship revenue', 'exhibit revenue')
      COMMENT = 'Total sponsorship investment across all sponsors',
    
    avg_sponsor_roi AS AVG(sponsors.roi_score)
      WITH SYNONYMS = ('average roi', 'mean roi')
      COMMENT = 'Average ROI score across all sponsors'
  );

-- Verify semantic view created
DESCRIBE SEMANTIC VIEW SV_EVENT_ANALYTICS;
SHOW SEMANTIC VIEWS IN SCHEMA SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS;

