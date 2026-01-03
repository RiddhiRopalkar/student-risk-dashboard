CREATE DATABASE STUDENT_AI_PROJECT;
CREATE SCHEMA STUDENT_AI_PROJECT.DATA;
STUDENT_AI_PROJECTSTUDENT_AI_PROJECT.DATA
USE DATABASE STUDENT_AI_PROJECT;
USE SCHEMA DATA;

CREATE TABLE STUDENT_8WEEK_DATASET (
    student_id INT,
    student_name STRING,
    week INT,
    attendance INT,
    marks INT
);
DROP TABLE STUDENT_8WEEK_DATASET;
SELECT * FROM STUDENT_8WEEK_DATASET LIMIT 10;

CREATE OR REPLACE TEMP TABLE STEP1 AS
SELECT
    *,
    (classes_attended / total_classes) * 100 AS attendance_percent,
    (maths_score + physics_score + chemistry_score) / 3 AS avg_subject_score
FROM STUDENT_8WEEK_DATASET;

CREATE OR REPLACE TEMP TABLE STUDENT_AVG AS
SELECT
    student_id,
    AVG(attendance_percent) AS avg_attendance,
    AVG(avg_subject_score) AS avg_score
FROM STEP1
GROUP BY student_id;

CREATE OR REPLACE TEMP TABLE TREND_DF AS
SELECT
    student_id,
    REGR_SLOPE(attendance_percent, week_number) AS attendance_slope
FROM STEP1
GROUP BY student_id;

CREATE OR REPLACE TEMP TABLE TREND_LABELS AS
SELECT
    student_id,
    attendance_slope,
    CASE
        WHEN attendance_slope > 0.5 THEN 'INCREASING'
        WHEN attendance_slope < -0.5 THEN 'DECREASING'
        ELSE 'STABLE'
    END AS attendance_trend
FROM TREND_DF;

CREATE OR REPLACE TEMP TABLE ATTENDANCE_DROP AS
SELECT
    student_id,
    FIRST_VALUE(attendance_percent)
        OVER (PARTITION BY student_id ORDER BY week_number) -
    LAST_VALUE(attendance_percent)
        OVER (PARTITION BY student_id ORDER BY week_number
              ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
    AS attendance_drop
FROM STEP1;

CREATE OR REPLACE TABLE TRAINING_DATA AS
SELECT
    a.student_id,
    a.avg_attendance,
    a.avg_score,
    t.attendance_slope,
    t.attendance_trend,
    d.attendance_drop,

    CASE
        WHEN a.avg_attendance < 70 OR a.avg_score < 50 THEN 'HIGH'
        WHEN a.avg_attendance < 85 OR a.avg_score < 70 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS risk_label,

    CASE
        WHEN a.avg_attendance < 70 OR a.avg_score < 50 THEN 2
        WHEN a.avg_attendance < 85 OR a.avg_score < 70 THEN 1
        ELSE 0
    END AS risk_label_encoded

FROM STUDENT_AVG a
JOIN TREND_LABELS t USING (student_id)
JOIN ATTENDANCE_DROP d USING (student_id);

SELECT * FROM TRAINING_DATA;

CREATE OR REPLACE TEMP TABLE RISK_SCORING AS
SELECT
    *,
    LEAST(
        100,
        GREATEST(
            0,
            (100 - avg_attendance)
            + attendance_drop
            + (100 - avg_score)
        )
    ) AS risk_score
FROM TRAINING_DATA;

CREATE OR REPLACE TEMP TABLE EXPLANATIONS AS
SELECT
    *,
    RTRIM(
        CONCAT(
            CASE
                WHEN attendance_drop > 10
                THEN 'Attendance dropped by ' || ROUND(attendance_drop,1) || '%; '
                ELSE ''
            END,
            CASE
                WHEN avg_score < 70
                THEN 'Average score is low (' || ROUND(avg_score,1) || '); '
                ELSE ''
            END,
            CASE
                WHEN avg_attendance < 85
                THEN 'Average attendance is ' || ROUND(avg_attendance,1) || '%; '
                ELSE ''
            END
        ),
        '; '
    ) AS reason
FROM RISK_SCORING;

CREATE OR REPLACE TABLE PREDICTIONS_WITH_EXPLANATIONS AS
SELECT
    student_id,
    avg_attendance,
    avg_score,
    attendance_trend,
    attendance_drop,
    risk_label,
    risk_label_encoded,
    risk_score,

    CASE
        WHEN reason = '' OR reason IS NULL
        THEN 'No issues detected'
        ELSE reason
    END AS reason,

    CASE
        WHEN risk_label = 'HIGH' THEN 'Immediate follow-up'
        WHEN risk_label = 'MEDIUM' THEN 'Monitor weekly'
        ELSE 'No action needed'
    END AS action

FROM EXPLANATIONS;

SELECT * FROM PREDICTIONS_WITH_EXPLANATIONS;

-- Create a small warehouse
CREATE OR REPLACE WAREHOUSE MY_WAREHOUSE
WITH
    WAREHOUSE_SIZE = 'XSMALL'   -- small, cheap compute
    WAREHOUSE_TYPE = 'STANDARD'
    AUTO_SUSPEND = 300           -- suspend after 5 min idle
    AUTO_RESUME = TRUE;

-- Make sure warehouse is running
USE WAREHOUSE MY_WAREHOUSE;
ALTER WAREHOUSE MY_WAREHOUSE RESUME;

USE WAREHOUSE MY_WAREHOUSE;

SHOW WAREHOUSES LIKE 'MY_WAREHOUSE';

DESC TABLE predictions_with_explanations;




