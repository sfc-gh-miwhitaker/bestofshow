/*
 * ============================================================================
 * EVENT INTELLIGENCE PLATFORM - LOAD SAMPLE DATA
 * ============================================================================
 * Author: SE Community
 * Created: 2025-12-10
 * Expires: 2026-01-09
 * Purpose: Generate synthetic demo data for the International Wound Care Symposium
 * 
 * Data Generated:
 *   - 500 attendees (healthcare professionals)
 *   - 25 sessions (medical education tracks)
 *   - 15 sponsors (medical device/pharma companies)
 *   - ~2000 booth visits
 *   - ~1500 session check-ins
 *   - ~800 feedback entries
 * ============================================================================
 */

USE DATABASE SNOWFLAKE_EXAMPLE;
USE SCHEMA EVENT_INTELLIGENCE;

-- =============================================================================
-- GENERATE ATTENDEES
-- =============================================================================
INSERT INTO RAW_ATTENDEES (attendee_id, first_name, last_name, email, specialty, organization, registration_date)
SELECT 
    SEQ4() + 1 AS attendee_id,
    ARRAY_CONSTRUCT('Sarah', 'Michael', 'Emily', 'David', 'Jennifer', 'Robert', 'Lisa', 'James', 'Amanda', 'Christopher',
                    'Jessica', 'Matthew', 'Ashley', 'Daniel', 'Stephanie', 'Andrew', 'Nicole', 'Joshua', 'Elizabeth', 'Ryan')[UNIFORM(0, 19, RANDOM())] AS first_name,
    ARRAY_CONSTRUCT('Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez', 'Anderson',
                    'Taylor', 'Thomas', 'Hernandez', 'Moore', 'Martin', 'Jackson', 'Thompson', 'White', 'Lopez', 'Lee')[UNIFORM(0, 19, RANDOM())] AS last_name,
    LOWER(first_name) || '.' || LOWER(last_name) || UNIFORM(100, 999, RANDOM()) || '@' || 
        ARRAY_CONSTRUCT('hospital.org', 'medcenter.com', 'healthcare.net', 'clinic.org', 'university.edu')[UNIFORM(0, 4, RANDOM())] AS email,
    ARRAY_CONSTRUCT('Wound Care Specialist', 'Registered Nurse', 'Physician Assistant', 'Dermatologist', 'Plastic Surgeon',
                    'General Surgeon', 'Podiatrist', 'Physical Therapist', 'Clinical Researcher', 'Nurse Practitioner',
                    'Vascular Surgeon', 'Infectious Disease', 'Emergency Medicine', 'Family Medicine', 'Internal Medicine')[UNIFORM(0, 14, RANDOM())] AS specialty,
    ARRAY_CONSTRUCT('Memorial Hospital', 'City Medical Center', 'Regional Health System', 'University Hospital', 'Community Clinic',
                    'Veterans Medical Center', 'Childrens Hospital', 'Academic Medical Center', 'Rural Health Network', 'Specialty Care Center')[UNIFORM(0, 9, RANDOM())] AS organization,
    DATEADD('day', -UNIFORM(1, 90, RANDOM()), CURRENT_TIMESTAMP()) AS registration_date
FROM TABLE(GENERATOR(ROWCOUNT => 500));

-- =============================================================================
-- GENERATE SESSIONS
-- =============================================================================
INSERT INTO RAW_SESSIONS (session_id, session_name, speaker, start_time, end_time, room, capacity, track)
VALUES
    (1, 'Advances in Chronic Wound Management', 'Dr. Sarah Chen', '2025-12-15 09:00:00', '2025-12-15 10:30:00', 'Grand Ballroom A', 200, 'Clinical Excellence'),
    (2, 'Negative Pressure Wound Therapy: Best Practices', 'Dr. Michael Torres', '2025-12-15 09:00:00', '2025-12-15 10:30:00', 'Conference Room 101', 75, 'Advanced Techniques'),
    (3, 'Diabetic Foot Ulcer Prevention Strategies', 'Dr. Emily Watson', '2025-12-15 11:00:00', '2025-12-15 12:30:00', 'Grand Ballroom A', 200, 'Clinical Excellence'),
    (4, 'Biofilm Management in Wound Care', 'Dr. Robert Kim', '2025-12-15 11:00:00', '2025-12-15 12:30:00', 'Conference Room 102', 75, 'Research & Innovation'),
    (5, 'Surgical Wound Complications: Prevention and Treatment', 'Dr. Jennifer Adams', '2025-12-15 14:00:00', '2025-12-15 15:30:00', 'Grand Ballroom B', 150, 'Surgical Track'),
    (6, 'Nutrition and Wound Healing', 'Dr. Lisa Park', '2025-12-15 14:00:00', '2025-12-15 15:30:00', 'Conference Room 101', 75, 'Holistic Care'),
    (7, 'Pressure Injury Prevention in Acute Care', 'Dr. David Martinez', '2025-12-15 16:00:00', '2025-12-15 17:30:00', 'Grand Ballroom A', 200, 'Clinical Excellence'),
    (8, 'Advanced Wound Imaging Technologies', 'Dr. Amanda Lee', '2025-12-15 16:00:00', '2025-12-15 17:30:00', 'Conference Room 102', 75, 'Research & Innovation'),
    (9, 'Opening Keynote: The Future of Wound Care', 'Dr. James Wilson', '2025-12-16 08:30:00', '2025-12-16 09:30:00', 'Main Auditorium', 500, 'Keynote'),
    (10, 'Skin Substitutes and Biologics', 'Dr. Christopher Brown', '2025-12-16 10:00:00', '2025-12-16 11:30:00', 'Grand Ballroom A', 200, 'Advanced Techniques'),
    (11, 'Venous Leg Ulcer Management', 'Dr. Nicole Garcia', '2025-12-16 10:00:00', '2025-12-16 11:30:00', 'Conference Room 101', 75, 'Clinical Excellence'),
    (12, 'AI and Machine Learning in Wound Assessment', 'Dr. Matthew Johnson', '2025-12-16 13:00:00', '2025-12-16 14:30:00', 'Grand Ballroom B', 150, 'Research & Innovation'),
    (13, 'Pain Management in Wound Care', 'Dr. Stephanie White', '2025-12-16 13:00:00', '2025-12-16 14:30:00', 'Conference Room 102', 75, 'Holistic Care'),
    (14, 'Burn Wound Management Updates', 'Dr. Andrew Thompson', '2025-12-16 15:00:00', '2025-12-16 16:30:00', 'Grand Ballroom A', 200, 'Surgical Track'),
    (15, 'Antimicrobial Stewardship in Wound Care', 'Dr. Jessica Rodriguez', '2025-12-16 15:00:00', '2025-12-16 16:30:00', 'Conference Room 101', 75, 'Clinical Excellence'),
    (16, 'Hyperbaric Oxygen Therapy Indications', 'Dr. Ryan Davis', '2025-12-17 09:00:00', '2025-12-17 10:30:00', 'Grand Ballroom B', 150, 'Advanced Techniques'),
    (17, 'Wound Care in Pediatric Patients', 'Dr. Elizabeth Moore', '2025-12-17 09:00:00', '2025-12-17 10:30:00', 'Conference Room 102', 75, 'Special Populations'),
    (18, 'Telemedicine in Wound Care Delivery', 'Dr. Daniel Harris', '2025-12-17 11:00:00', '2025-12-17 12:30:00', 'Grand Ballroom A', 200, 'Research & Innovation'),
    (19, 'Quality Metrics and Outcome Measurement', 'Dr. Ashley Clark', '2025-12-17 11:00:00', '2025-12-17 12:30:00', 'Conference Room 101', 75, 'Clinical Excellence'),
    (20, 'Closing Keynote: Transforming Patient Outcomes', 'Dr. Sarah Chen', '2025-12-17 14:00:00', '2025-12-17 15:00:00', 'Main Auditorium', 500, 'Keynote'),
    (21, 'Hands-On Workshop: Advanced Debridement Techniques', 'Dr. Michael Torres', '2025-12-15 14:00:00', '2025-12-15 17:00:00', 'Workshop Room A', 30, 'Workshops'),
    (22, 'Hands-On Workshop: Compression Therapy Application', 'Dr. Nicole Garcia', '2025-12-16 14:00:00', '2025-12-16 17:00:00', 'Workshop Room B', 30, 'Workshops'),
    (23, 'Case Study Symposium: Complex Wound Cases', 'Panel Discussion', '2025-12-15 17:30:00', '2025-12-15 19:00:00', 'Grand Ballroom A', 200, 'Case Studies'),
    (24, 'Poster Presentations and Networking', 'Various Authors', '2025-12-16 17:00:00', '2025-12-16 19:00:00', 'Exhibition Hall', 300, 'Research & Innovation'),
    (25, 'Industry Symposium: Innovations in Wound Healing', 'Industry Partners', '2025-12-17 12:30:00', '2025-12-17 13:30:00', 'Grand Ballroom B', 150, 'Industry');

-- =============================================================================
-- GENERATE SPONSORS
-- =============================================================================
INSERT INTO RAW_SPONSORS (sponsor_id, sponsor_name, tier, booth_number, investment_amount, contact_email)
VALUES
    (1, 'WoundCare Technologies Inc', 'Platinum', 'A-101', 75000.00, 'events@woundcaretech.com'),
    (2, 'Advanced Biologics Corp', 'Platinum', 'A-102', 75000.00, 'sponsorship@advancedbio.com'),
    (3, 'HealFast Medical Devices', 'Gold', 'B-201', 50000.00, 'marketing@healfast.com'),
    (4, 'DermaSolutions Ltd', 'Gold', 'B-202', 50000.00, 'events@dermasolutions.com'),
    (5, 'Compression Therapy Systems', 'Gold', 'B-203', 50000.00, 'info@compressiontherapy.com'),
    (6, 'BioMatrix Wound Care', 'Silver', 'C-301', 25000.00, 'sales@biomatrix.com'),
    (7, 'NegPress Medical', 'Silver', 'C-302', 25000.00, 'marketing@negpress.com'),
    (8, 'Skin Substitute Innovations', 'Silver', 'C-303', 25000.00, 'events@skinsubstitute.com'),
    (9, 'Antimicrobial Dressings Co', 'Silver', 'C-304', 25000.00, 'info@antimicrobialdress.com'),
    (10, 'Oxygen Therapy Solutions', 'Bronze', 'D-401', 10000.00, 'sales@o2therapy.com'),
    (11, 'Wound Imaging Systems', 'Bronze', 'D-402', 10000.00, 'info@woundimaging.com'),
    (12, 'Nutrition for Healing', 'Bronze', 'D-403', 10000.00, 'marketing@nutritionhealing.com'),
    (13, 'Pain Management Pharma', 'Bronze', 'D-404', 10000.00, 'events@painmgmt.com'),
    (14, 'Surgical Supplies Direct', 'Bronze', 'D-405', 10000.00, 'sales@surgicalsupplies.com'),
    (15, 'Telemedicine Platforms Inc', 'Bronze', 'D-406', 10000.00, 'info@telemedplatforms.com');

-- =============================================================================
-- GENERATE BOOTH VISITS (with proper sponsor distribution from the start)
-- =============================================================================
INSERT INTO RAW_BOOTH_VISITS (visit_id, attendee_id, booth_id, sponsor_name, visit_timestamp, duration_seconds)
SELECT 
    ROW_NUMBER() OVER (ORDER BY seq) AS visit_id,
    UNIFORM(1, 500, RANDOM()) AS attendee_id,
    sponsor_id AS booth_id,
    sponsor_name,
    DATEADD('minute', UNIFORM(0, 2880, RANDOM()), '2025-12-15 08:00:00'::TIMESTAMP_NTZ) AS visit_timestamp,
    UNIFORM(30, 1200, RANDOM()) AS duration_seconds
FROM (
    -- Generate 2000 rows and join with sponsors to distribute evenly
    SELECT 
        SEQ4() AS seq,
        MOD(SEQ4(), 15) + 1 AS sponsor_idx
    FROM TABLE(GENERATOR(ROWCOUNT => 2000))
) gen
JOIN RAW_SPONSORS ON sponsor_id = sponsor_idx;

-- =============================================================================
-- GENERATE SESSION CHECKINS (with proper session distribution from the start)
-- =============================================================================
INSERT INTO RAW_SESSION_CHECKINS (checkin_id, attendee_id, session_id, checkin_timestamp, checkin_method)
SELECT 
    ROW_NUMBER() OVER (ORDER BY seq) AS checkin_id,
    UNIFORM(1, 500, RANDOM()) AS attendee_id,
    s.session_id,
    DATEADD('minute', UNIFORM(-5, 10, RANDOM()), s.start_time) AS checkin_timestamp,
    ARRAY_CONSTRUCT('BADGE_SCAN', 'MOBILE_APP', 'MANUAL')[UNIFORM(0, 2, RANDOM())] AS checkin_method
FROM (
    -- Generate 1500 rows and distribute across sessions
    SELECT 
        SEQ4() AS seq,
        MOD(SEQ4(), 25) + 1 AS session_idx
    FROM TABLE(GENERATOR(ROWCOUNT => 1500))
) gen
JOIN RAW_SESSIONS s ON s.session_id = session_idx;

-- =============================================================================
-- GENERATE FEEDBACK (with proper session distribution)
-- =============================================================================
INSERT INTO RAW_FEEDBACK (feedback_id, attendee_id, session_id, rating, feedback_text, submitted_at)
SELECT 
    ROW_NUMBER() OVER (ORDER BY seq) AS feedback_id,
    UNIFORM(1, 500, RANDOM()) AS attendee_id,
    session_idx AS session_id,
    UNIFORM(3, 5, RANDOM()) AS rating,
    CASE MOD(seq, 20)
        WHEN 0 THEN 'Excellent presentation! Very informative and practical for my daily practice.'
        WHEN 1 THEN 'Great content but the room was too crowded. Consider a larger venue next time.'
        WHEN 2 THEN 'The speaker was knowledgeable and engaging. Learned several new techniques.'
        WHEN 3 THEN 'Good overview but would have liked more hands-on demonstrations.'
        WHEN 4 THEN 'Outstanding session! The case studies were particularly helpful.'
        WHEN 5 THEN 'Valuable information on latest research. Will implement in my practice.'
        WHEN 6 THEN 'The Q&A session was too short. Would have appreciated more time for questions.'
        WHEN 7 THEN 'Excellent speaker! Clear explanations and great visual aids.'
        WHEN 8 THEN 'Content was somewhat basic for experienced practitioners.'
        WHEN 9 THEN 'Very practical session with actionable takeaways.'
        WHEN 10 THEN 'The networking opportunity was valuable. Met great colleagues.'
        WHEN 11 THEN 'Would recommend this session to colleagues. Well organized.'
        WHEN 12 THEN 'Appreciated the evidence-based approach to the topic.'
        WHEN 13 THEN 'Audio quality could be improved. Hard to hear at times.'
        WHEN 14 THEN 'Fantastic session! One of the best at this conference.'
        WHEN 15 THEN 'Good content but slides were too text-heavy.'
        WHEN 16 THEN 'Learned new approaches to managing complex wounds.'
        WHEN 17 THEN 'The handouts provided were very useful reference materials.'
        WHEN 18 THEN 'Session ran over time but the content was worth it.'
        ELSE 'Informative session with good balance of theory and practice.'
    END AS feedback_text,
    DATEADD('hour', UNIFORM(1, 48, RANDOM()), '2025-12-15 10:00:00'::TIMESTAMP_NTZ) AS submitted_at
FROM (
    SELECT 
        SEQ4() AS seq,
        MOD(SEQ4(), 25) + 1 AS session_idx
    FROM TABLE(GENERATOR(ROWCOUNT => 800))
) gen;

-- =============================================================================
-- VERIFY DATA LOAD
-- =============================================================================
SELECT 'RAW_ATTENDEES' AS table_name, COUNT(*) AS row_count FROM RAW_ATTENDEES
UNION ALL SELECT 'RAW_SESSIONS', COUNT(*) FROM RAW_SESSIONS
UNION ALL SELECT 'RAW_SPONSORS', COUNT(*) FROM RAW_SPONSORS
UNION ALL SELECT 'RAW_BOOTH_VISITS', COUNT(*) FROM RAW_BOOTH_VISITS
UNION ALL SELECT 'RAW_SESSION_CHECKINS', COUNT(*) FROM RAW_SESSION_CHECKINS
UNION ALL SELECT 'RAW_FEEDBACK', COUNT(*) FROM RAW_FEEDBACK;
