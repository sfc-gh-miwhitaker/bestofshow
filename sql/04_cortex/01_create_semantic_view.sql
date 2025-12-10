/*
 * ============================================================================
 * EVENT INTELLIGENCE PLATFORM - CORTEX AI SEMANTIC VIEW
 * ============================================================================
 * Author: SE Community
 * Created: 2025-12-10
 * Expires: 2026-01-09
 * Purpose: Create Semantic View for Cortex Analyst natural language queries
 * Location: SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS.SV_EVENT_ANALYTICS
 * ============================================================================
 */

USE DATABASE SNOWFLAKE_EXAMPLE;
USE SCHEMA SEMANTIC_MODELS;

CREATE OR REPLACE SEMANTIC VIEW SV_EVENT_ANALYTICS
  TABLES (
    sessions AS SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE.DT_SESSION_ANALYTICS
      PRIMARY KEY (session_id),
    attendees AS SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE.DT_ATTENDEE_ENGAGEMENT
      PRIMARY KEY (attendee_id),
    sponsors AS SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE.DT_SPONSOR_PERFORMANCE
      PRIMARY KEY (sponsor_id)
  )
  DIMENSIONS (
    sessions.session_name AS sessions.session_name,
    sessions.speaker AS sessions.speaker,
    sessions.track AS sessions.track,
    sessions.room AS sessions.room,
    sessions.capacity AS sessions.capacity,
    sessions.attendance_count AS sessions.attendance_count,
    sessions.avg_rating AS sessions.avg_rating,
    attendees.full_name AS attendees.full_name,
    attendees.specialty AS attendees.specialty,
    attendees.organization AS attendees.organization,
    attendees.engagement_tier AS attendees.engagement_tier,
    attendees.sessions_attended AS attendees.sessions_attended,
    attendees.booth_visits AS attendees.booth_visits,
    attendees.engagement_score AS attendees.engagement_score,
    sponsors.sponsor_name AS sponsors.sponsor_name,
    sponsors.tier AS sponsors.tier,
    sponsors.booth_number AS sponsors.booth_number,
    sponsors.investment_amount AS sponsors.investment_amount,
    sponsors.total_booth_visits AS sponsors.total_booth_visits,
    sponsors.unique_visitors AS sponsors.unique_visitors,
    sponsors.roi_score AS sponsors.roi_score
  )
  METRICS (
    sessions.total_sessions AS COUNT(sessions.session_id),
    sessions.avg_attendance AS AVG(sessions.attendance_count),
    sessions.avg_session_rating AS AVG(sessions.avg_rating),
    attendees.total_attendees AS COUNT(attendees.attendee_id),
    attendees.avg_engagement AS AVG(attendees.engagement_score),
    sponsors.total_sponsors AS COUNT(sponsors.sponsor_id),
    sponsors.total_sponsorship AS SUM(sponsors.investment_amount),
    sponsors.avg_roi AS AVG(sponsors.roi_score)
  )
  COMMENT = 'DEMO: Event Intelligence semantic view for Cortex Analyst | Author: SE Community | Expires: 2026-01-09';

DESCRIBE SEMANTIC VIEW SV_EVENT_ANALYTICS;
SHOW SEMANTIC VIEWS IN SCHEMA SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS;
