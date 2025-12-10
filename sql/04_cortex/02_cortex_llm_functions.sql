/*
 * ============================================================================
 * EVENT INTELLIGENCE PLATFORM - CORTEX LLM FUNCTIONS
 * ============================================================================
 * Author: SE Community
 * Created: 2025-12-10
 * Expires: 2026-01-09
 * Purpose: Apply Cortex AI functions for sentiment analysis and summarization
 * 
 * Functions Used:
 *   - SNOWFLAKE.CORTEX.SENTIMENT: Analyze feedback sentiment (-1 to +1)
 *   - SNOWFLAKE.CORTEX.SUMMARIZE: Generate feedback summaries
 *   - SNOWFLAKE.CORTEX.COMPLETE: Generate AI insights
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
-- FEEDBACK SENTIMENT ANALYSIS
-- =============================================================================
-- Add sentiment scores to feedback using Cortex SENTIMENT function
CREATE OR REPLACE TABLE FEEDBACK_WITH_SENTIMENT
  COMMENT = 'DEMO: Feedback with Cortex AI sentiment analysis | Author: SE Community | Expires: 2026-01-09'
AS
SELECT 
    f.*,
    SNOWFLAKE.CORTEX.SENTIMENT(f.feedback_text) AS sentiment_score,
    CASE 
        WHEN SNOWFLAKE.CORTEX.SENTIMENT(f.feedback_text) >= 0.3 THEN 'Positive'
        WHEN SNOWFLAKE.CORTEX.SENTIMENT(f.feedback_text) <= -0.3 THEN 'Negative'
        ELSE 'Neutral'
    END AS sentiment_category
FROM RAW_FEEDBACK f
WHERE f.feedback_text IS NOT NULL
  AND LENGTH(f.feedback_text) > 10;

-- =============================================================================
-- SESSION FEEDBACK SUMMARIES
-- =============================================================================
-- Generate AI summaries of feedback for each session
CREATE OR REPLACE TABLE SESSION_FEEDBACK_SUMMARIES
  COMMENT = 'DEMO: AI-generated session feedback summaries | Author: SE Community | Expires: 2026-01-09'
AS
WITH session_feedback_agg AS (
    SELECT 
        session_id,
        LISTAGG(feedback_text, '\n\n') WITHIN GROUP (ORDER BY submitted_at DESC) AS all_feedback,
        COUNT(*) AS feedback_count,
        AVG(rating) AS avg_rating,
        AVG(sentiment_score) AS avg_sentiment
    FROM FEEDBACK_WITH_SENTIMENT
    GROUP BY session_id
    HAVING COUNT(*) >= 3  -- Only summarize sessions with enough feedback
)
SELECT 
    s.session_id,
    s.session_name,
    s.speaker,
    sfa.feedback_count,
    ROUND(sfa.avg_rating, 2) AS avg_rating,
    ROUND(sfa.avg_sentiment, 3) AS avg_sentiment,
    SNOWFLAKE.CORTEX.SUMMARIZE(
        'Summarize the following attendee feedback for a medical education session. ' ||
        'Highlight key themes, common praise, and areas for improvement:\n\n' ||
        sfa.all_feedback
    ) AS ai_summary,
    CURRENT_TIMESTAMP() AS generated_at
FROM session_feedback_agg sfa
JOIN RAW_SESSIONS s ON sfa.session_id = s.session_id;

-- =============================================================================
-- SPONSOR ENGAGEMENT INSIGHTS
-- =============================================================================
-- Generate AI insights for sponsor performance
CREATE OR REPLACE TABLE SPONSOR_AI_INSIGHTS
  COMMENT = 'DEMO: AI-generated sponsor performance insights | Author: SE Community | Expires: 2026-01-09'
AS
WITH sponsor_metrics AS (
    SELECT 
        sp.sponsor_name,
        sp.tier,
        sp.investment_amount,
        sp.total_booth_visits,
        sp.unique_visitors,
        sp.avg_visit_duration_sec,
        sp.roi_score,
        ROW_NUMBER() OVER (ORDER BY sp.roi_score DESC) AS roi_rank
    FROM DT_SPONSOR_PERFORMANCE sp
)
SELECT 
    sm.*,
    SNOWFLAKE.CORTEX.COMPLETE(
        'llama3.1-8b',
        'You are an event analytics expert. Based on the following sponsor metrics, ' ||
        'provide a brief 2-3 sentence insight about their booth performance and recommendations:\n' ||
        'Sponsor: ' || sm.sponsor_name || '\n' ||
        'Tier: ' || sm.tier || '\n' ||
        'Investment: $' || sm.investment_amount::VARCHAR || '\n' ||
        'Total Visits: ' || sm.total_booth_visits::VARCHAR || '\n' ||
        'Unique Visitors: ' || sm.unique_visitors::VARCHAR || '\n' ||
        'Avg Visit Duration: ' || ROUND(sm.avg_visit_duration_sec)::VARCHAR || ' seconds\n' ||
        'ROI Score: ' || sm.roi_score::VARCHAR || '\n' ||
        'ROI Rank: #' || sm.roi_rank::VARCHAR || ' out of 15 sponsors'
    ) AS ai_insight,
    CURRENT_TIMESTAMP() AS generated_at
FROM sponsor_metrics sm;

-- =============================================================================
-- VIEW: V_FEEDBACK_SENTIMENT_ANALYSIS
-- =============================================================================
CREATE OR REPLACE VIEW V_FEEDBACK_SENTIMENT_ANALYSIS
  COMMENT = 'DEMO: Feedback with sentiment analysis | Author: SE Community | Expires: 2026-01-09'
AS
SELECT 
    fs.feedback_id,
    fs.attendee_id,
    fs.session_id,
    s.session_name,
    s.speaker,
    fs.rating,
    fs.feedback_text,
    fs.sentiment_score,
    fs.sentiment_category,
    fs.submitted_at,
    -- Sentiment alignment: does numeric rating match sentiment?
    CASE 
        WHEN fs.rating >= 4 AND fs.sentiment_category = 'Positive' THEN 'Aligned'
        WHEN fs.rating <= 2 AND fs.sentiment_category = 'Negative' THEN 'Aligned'
        WHEN fs.rating = 3 AND fs.sentiment_category = 'Neutral' THEN 'Aligned'
        ELSE 'Misaligned'
    END AS rating_sentiment_alignment
FROM FEEDBACK_WITH_SENTIMENT fs
JOIN RAW_SESSIONS s ON fs.session_id = s.session_id;

-- =============================================================================
-- VERIFY CORTEX AI ARTIFACTS
-- =============================================================================
SELECT 'FEEDBACK_WITH_SENTIMENT' AS table_name, COUNT(*) AS row_count FROM FEEDBACK_WITH_SENTIMENT
UNION ALL SELECT 'SESSION_FEEDBACK_SUMMARIES', COUNT(*) FROM SESSION_FEEDBACK_SUMMARIES
UNION ALL SELECT 'SPONSOR_AI_INSIGHTS', COUNT(*) FROM SPONSOR_AI_INSIGHTS;
