/*
 * ============================================================================
 * EVENT INTELLIGENCE PLATFORM - CORTEX AI AGENT
 * ============================================================================
 * Author: SE Community
 * Created: 2025-12-10
 * Expires: 2026-01-09
 * Purpose: Create Cortex Agent for natural language event analytics queries
 * 
 * Agent Name: event_intelligence_agent
 * Location: SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE
 * 
 * Capabilities:
 *   - Answer questions about session attendance and ratings
 *   - Provide sponsor ROI insights
 *   - Analyze attendee engagement patterns
 *   - Generate event analytics summaries
 * ============================================================================
 */

USE DATABASE SNOWFLAKE_EXAMPLE;
USE SCHEMA EVENT_INTELLIGENCE;

-- =============================================================================
-- CREATE CORTEX AGENT: event_intelligence_agent
-- =============================================================================
CREATE OR REPLACE AGENT event_intelligence_agent
  COMMENT = 'DEMO: Event Intelligence AI Agent for natural language analytics | Author: SE Community | Expires: 2026-01-09'
  PROFILE = '{"display_name": "Event Intelligence Assistant", "avatar": "conference-icon.png", "color": "blue"}'
  FROM SPECIFICATION
  $$
  models:
    orchestration: auto

  orchestration:
    budget:
      seconds: 60
      tokens: 32000

  instructions:
    system: |
      You are the Event Intelligence Assistant for the International Wound Care Symposium.
      
      Your role is to help event organizers, sponsors, and operations staff understand:
      - Session attendance and feedback patterns
      - Sponsor booth performance and ROI
      - Attendee engagement levels and demographics
      - Real-time event metrics and trends
      
      IMPORTANT GUIDELINES:
      - Always provide data-driven answers using the semantic view
      - When discussing ROI, explain the calculation methodology
      - For sponsor queries, be mindful that this data may be shared with sponsors
      - Round percentages to 1 decimal place, currency to 2 decimals
      - If asked about attendee PII (names, emails), remind users of privacy considerations
      - Proactively suggest related insights when answering questions
      
      CONTEXT:
      - Event: International Wound Care Symposium
      - Duration: December 15-17, 2025
      - Location: Convention Center
      - Attendees: ~500 healthcare professionals
      - Sessions: 25 educational sessions across multiple tracks
      - Sponsors: 15 exhibitors (Platinum, Gold, Silver, Bronze tiers)

    orchestration: |
      Use the Analyst tool (SV_EVENT_ANALYTICS semantic view) for all data queries.
      
      For session questions: Query session attendance, ratings, and capacity utilization.
      For sponsor questions: Query booth visits, unique visitors, and ROI scores.
      For attendee questions: Query engagement scores and participation patterns.
      
      Always verify the query results make sense before presenting them.
      If a query returns no results, explain possible reasons.

    response: |
      Format responses clearly with:
      - Markdown tables for multi-row data
      - Bold text for key metrics
      - Bullet points for lists
      - Brief explanations of what the data means
      
      Include relevant context, such as:
      - How a metric compares to averages
      - Trends or patterns you observe
      - Actionable recommendations when appropriate
      
      Keep responses concise but informative.

    sample_questions:
      - question: "What were the top 5 sessions by attendance?"
        answer: "I'll analyze session attendance data to identify the most popular sessions."
      - question: "Which sponsors had the most booth visits?"
        answer: "Let me check booth traffic data across all sponsor tiers."
      - question: "Show me average feedback ratings by track"
        answer: "I'll calculate average ratings grouped by conference track."
      - question: "What specialties are most represented among attendees?"
        answer: "I'll break down attendee demographics by medical specialty."
      - question: "How is sponsor ROI calculated and who has the best ROI?"
        answer: "I'll explain the ROI methodology and show the top performers."
      - question: "Which attendees are most engaged?"
        answer: "I'll identify highly engaged attendees based on their activity scores."

  tools:
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "Analyst"
        description: |
          Use this tool to answer questions about event performance data.
          
          The semantic view contains three main data domains:
          1. SESSIONS: Session attendance, capacity, ratings, speakers, tracks
          2. ATTENDEES: Attendee engagement, specialties, organizations
          3. SPONSORS: Booth visits, ROI scores, sponsorship tiers
          
          Example questions this tool can answer:
          - "What was the average attendance for Clinical Excellence track sessions?"
          - "Which Gold tier sponsors had the highest ROI?"
          - "How many Wound Care Specialists attended the conference?"
          - "What percentage of Platinum sponsor booths exceeded 100 visits?"

  tool_resources:
    Analyst:
      semantic_view: "SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS.SV_EVENT_ANALYTICS"
  $$;

-- =============================================================================
-- VERIFY AGENT CREATED
-- =============================================================================
SHOW AGENTS IN SCHEMA SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE;
DESCRIBE AGENT event_intelligence_agent;

-- =============================================================================
-- GRANT ACCESS TO AGENT (for demo users)
-- =============================================================================
-- Note: Uncomment and modify these grants based on your role structure
-- GRANT USAGE ON AGENT event_intelligence_agent TO ROLE PUBLIC;
-- GRANT USAGE ON SEMANTIC VIEW SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS.SV_EVENT_ANALYTICS TO ROLE PUBLIC;

SELECT 'Cortex Agent created successfully. Access via Snowsight AI Assistant or REST API.' AS status;

