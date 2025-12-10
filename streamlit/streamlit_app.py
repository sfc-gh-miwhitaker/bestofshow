"""
Event Intelligence Dashboard - Streamlit Application
=====================================================
Author: SE Community
Created: 2025-12-10
Expires: 2026-01-09
Purpose: Real-time operations dashboard for the International Wound Care Symposium

Features:
- Live event metrics (attendees, sessions, booth traffic)
- Session performance analytics
- Sponsor ROI tracking
- Attendee engagement insights
- AI-powered feedback sentiment analysis
"""

from snowflake.snowpark.context import get_active_session
import streamlit as st
import pandas as pd

# =============================================================================
# PAGE CONFIGURATION
# =============================================================================
st.set_page_config(
    page_title="Event Intelligence Dashboard",
    page_icon="🏥",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Get Snowflake session
session = get_active_session()

# =============================================================================
# CUSTOM STYLING
# =============================================================================
st.markdown("""
<style>
    .main-header {
        font-size: 2.5rem;
        font-weight: 700;
        color: #29B5E8;
        margin-bottom: 0;
    }
    .sub-header {
        font-size: 1.1rem;
        color: #666;
        margin-top: 0;
    }
    .metric-card {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        padding: 1rem;
        border-radius: 10px;
        color: white;
    }
    .stMetric {
        background-color: #f8f9fa;
        padding: 1rem;
        border-radius: 8px;
        border-left: 4px solid #29B5E8;
    }
</style>
""", unsafe_allow_html=True)

# =============================================================================
# HEADER
# =============================================================================
col1, col2 = st.columns([3, 1])
with col1:
    st.markdown('<p class="main-header">🏥 Event Intelligence Dashboard</p>', unsafe_allow_html=True)
    st.markdown('<p class="sub-header">International Wound Care Symposium | December 15-17, 2025</p>', unsafe_allow_html=True)
with col2:
    st.image("https://www.snowflake.com/wp-content/themes/flavor/flavor/library/img/logo.svg", width=150)

st.divider()

# =============================================================================
# SIDEBAR FILTERS
# =============================================================================
with st.sidebar:
    st.header("🔧 Filters")
    
    # Date filter
    date_options = ["All Days", "Day 1 (Dec 15)", "Day 2 (Dec 16)", "Day 3 (Dec 17)"]
    selected_date = st.selectbox("Select Date", date_options)
    
    # Track filter
    tracks_df = session.sql("""
        SELECT DISTINCT track FROM SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE.RAW_SESSIONS ORDER BY track
    """).to_pandas()
    tracks = ["All Tracks"] + tracks_df['TRACK'].tolist()
    selected_track = st.selectbox("Session Track", tracks)
    
    # Sponsor tier filter
    tiers = ["All Tiers", "Platinum", "Gold", "Silver", "Bronze"]
    selected_tier = st.selectbox("Sponsor Tier", tiers)
    
    st.divider()
    st.caption("💡 Dashboard auto-refreshes with Dynamic Tables")
    st.caption("📊 Powered by Snowflake Cortex AI")

# =============================================================================
# KEY METRICS ROW
# =============================================================================
st.subheader("📊 Live Event Metrics")

# Fetch live metrics
metrics_query = """
SELECT 
    (SELECT COUNT(*) FROM SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE.RAW_ATTENDEES) AS total_registered,
    (SELECT COUNT(DISTINCT attendee_id) FROM SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE.RAW_SESSION_CHECKINS) AS total_checked_in,
    (SELECT COUNT(DISTINCT attendee_id) FROM SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE.RAW_BOOTH_VISITS) AS booth_visitors,
    (SELECT ROUND(AVG(rating), 2) FROM SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE.RAW_FEEDBACK) AS avg_rating,
    (SELECT COUNT(*) FROM SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE.RAW_FEEDBACK) AS total_feedback
"""
metrics = session.sql(metrics_query).to_pandas().iloc[0]

col1, col2, col3, col4, col5 = st.columns(5)
with col1:
    st.metric("👥 Registered", f"{metrics['TOTAL_REGISTERED']:,}")
with col2:
    st.metric("✅ Checked In", f"{metrics['TOTAL_CHECKED_IN']:,}", 
              delta=f"{(metrics['TOTAL_CHECKED_IN']/metrics['TOTAL_REGISTERED']*100):.0f}%")
with col3:
    st.metric("🎪 Booth Visitors", f"{metrics['BOOTH_VISITORS']:,}")
with col4:
    st.metric("⭐ Avg Rating", f"{metrics['AVG_RATING']:.2f}/5.0")
with col5:
    st.metric("💬 Feedback", f"{metrics['TOTAL_FEEDBACK']:,}")

st.divider()

# =============================================================================
# SESSION PERFORMANCE
# =============================================================================
col1, col2 = st.columns(2)

with col1:
    st.subheader("🎤 Top Sessions by Attendance")
    
    track_filter = "" if selected_track == "All Tracks" else f"WHERE track = '{selected_track}'"
    
    sessions_query = f"""
    SELECT 
        session_name,
        speaker,
        track,
        attendance_count,
        capacity,
        ROUND(capacity_utilization_pct, 1) AS utilization_pct,
        ROUND(avg_rating, 2) AS avg_rating
    FROM SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE.DT_SESSION_ANALYTICS
    {track_filter}
    ORDER BY attendance_count DESC
    LIMIT 10
    """
    sessions_df = session.sql(sessions_query).to_pandas()
    
    # Display as bar chart
    st.bar_chart(
        sessions_df.set_index('SESSION_NAME')['ATTENDANCE_COUNT'],
        height=300
    )
    
    # Show data table
    with st.expander("View Session Details"):
        st.dataframe(sessions_df, use_container_width=True)

with col2:
    st.subheader("📈 Session Ratings Distribution")
    
    ratings_query = """
    SELECT 
        ROUND(avg_rating, 0) AS rating_bucket,
        COUNT(*) AS session_count
    FROM SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE.DT_SESSION_ANALYTICS
    WHERE avg_rating > 0
    GROUP BY rating_bucket
    ORDER BY rating_bucket
    """
    ratings_df = session.sql(ratings_query).to_pandas()
    
    st.bar_chart(
        ratings_df.set_index('RATING_BUCKET')['SESSION_COUNT'],
        height=300
    )

st.divider()

# =============================================================================
# SPONSOR PERFORMANCE
# =============================================================================
st.subheader("🎪 Sponsor Booth Performance")

tier_filter = "" if selected_tier == "All Tiers" else f"WHERE tier = '{selected_tier}'"

sponsors_query = f"""
SELECT 
    sponsor_name,
    tier,
    total_booth_visits,
    unique_visitors,
    ROUND(avg_visit_duration_sec, 0) AS avg_duration_sec,
    ROUND(roi_score, 2) AS roi_score,
    investment_amount
FROM SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE.DT_SPONSOR_PERFORMANCE
{tier_filter}
ORDER BY roi_score DESC
"""
sponsors_df = session.sql(sponsors_query).to_pandas()

col1, col2 = st.columns([2, 1])

with col1:
    st.dataframe(
        sponsors_df.style.background_gradient(subset=['ROI_SCORE'], cmap='Greens'),
        use_container_width=True,
        hide_index=True
    )

with col2:
    # Tier distribution pie chart
    tier_dist = sponsors_df.groupby('TIER')['TOTAL_BOOTH_VISITS'].sum()
    st.write("**Visits by Tier**")
    st.bar_chart(tier_dist)

st.divider()

# =============================================================================
# ATTENDEE ENGAGEMENT
# =============================================================================
st.subheader("👥 Attendee Engagement")

col1, col2, col3 = st.columns(3)

with col1:
    st.write("**Engagement Tier Distribution**")
    engagement_query = """
    SELECT 
        engagement_tier,
        COUNT(*) AS attendee_count
    FROM SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE.DT_ATTENDEE_ENGAGEMENT
    GROUP BY engagement_tier
    ORDER BY CASE engagement_tier 
        WHEN 'Highly Engaged' THEN 1 
        WHEN 'Engaged' THEN 2 
        WHEN 'Participating' THEN 3 
        ELSE 4 END
    """
    engagement_df = session.sql(engagement_query).to_pandas()
    st.bar_chart(engagement_df.set_index('ENGAGEMENT_TIER')['ATTENDEE_COUNT'])

with col2:
    st.write("**Top Specialties**")
    specialty_query = """
    SELECT 
        specialty,
        COUNT(*) AS count
    FROM SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE.RAW_ATTENDEES
    GROUP BY specialty
    ORDER BY count DESC
    LIMIT 8
    """
    specialty_df = session.sql(specialty_query).to_pandas()
    st.bar_chart(specialty_df.set_index('SPECIALTY')['COUNT'])

with col3:
    st.write("**Top Organizations**")
    org_query = """
    SELECT 
        organization,
        COUNT(*) AS count
    FROM SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE.RAW_ATTENDEES
    GROUP BY organization
    ORDER BY count DESC
    LIMIT 8
    """
    org_df = session.sql(org_query).to_pandas()
    st.bar_chart(org_df.set_index('ORGANIZATION')['COUNT'])

st.divider()

# =============================================================================
# FEEDBACK SENTIMENT (CORTEX AI)
# =============================================================================
st.subheader("🤖 AI-Powered Feedback Sentiment")

try:
    sentiment_query = """
    SELECT 
        sentiment_category,
        COUNT(*) AS count,
        ROUND(AVG(rating), 2) AS avg_rating
    FROM SNOWFLAKE_EXAMPLE.EVENT_INTELLIGENCE.FEEDBACK_WITH_SENTIMENT
    GROUP BY sentiment_category
    ORDER BY count DESC
    """
    sentiment_df = session.sql(sentiment_query).to_pandas()
    
    col1, col2 = st.columns(2)
    with col1:
        st.bar_chart(sentiment_df.set_index('SENTIMENT_CATEGORY')['COUNT'])
    with col2:
        st.dataframe(sentiment_df, use_container_width=True, hide_index=True)
        
except Exception as e:
    st.info("💡 Run the Cortex AI scripts (sql/04_cortex/) to enable sentiment analysis.")

st.divider()

# =============================================================================
# FOOTER
# =============================================================================
st.markdown("""
---
**Event Intelligence Platform** | Powered by Snowflake  
Data Sources: Real-time event tracking, Dynamic Tables, Cortex AI  
Author: SE Community | Expires: 2026-01-09

*This is a demonstration project. Data shown is synthetic.*
""")

