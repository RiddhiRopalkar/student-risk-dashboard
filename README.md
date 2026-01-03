🎓 Student Risk Dashboard – AI-Powered Early Warning System

An AI-driven student performance monitoring and early-warning system built using Snowflake SQL and Streamlit to identify at-risk students, explain the causes, and support timely academic intervention.


🚩 Problem Statement

Educational institutions often struggle with:

Identifying struggling students early
Understanding why performance is declining
Monitoring attendance and academic trends over time
Taking timely corrective action
Traditional reports are reactive, fragmented, and lack clear explanations.
This leads to delayed interventions, poor academic outcomes, and increased dropout risk


💡 Solution Overview

This project provides a data-driven early warning platform that continuously analyzes student attendance and academic performance using Snowflake SQL and presents actionable insights through an interactive Streamlit dashboard.

The system:
Processes multi-week student performance data
Computes attendance trends and performance metrics
Predicts student risk levels (HIGH / MEDIUM / LOW)
Calculates an overall risk score (0–100)
Generates human-readable explanations for each student
Provides recommended actions for educators

The solution is scalable, explainable, and ready for real-world academic environments.


🧠 Key Features

🎯 Risk Prediction Engine
Classifies students into HIGH, MEDIUM, and LOW risk categories

📉 Trend Analysis
Computes attendance slope and detects declining patterns

🧮 Risk Scoring System
Generates a 0–100 risk score combining attendance, scores, and trends

🧾 Explainable AI Output
Automatically generates clear explanations for every risk decision

📊 Interactive Dashboard
Streamlit dashboard with filters, KPIs, tables, and visualizations

🧑‍🏫 Action Recommendations
Provides suggested interventions based on student risk level

🏗️ System Architecture

Data Layer :
   8-week student performance dataset
   Attendance, scores, and weekly metrics

Analytics Layer (Snowflake SQL) :
   Feature engineering and aggregation
   Trend detection using regression
   Risk labeling and scoring
Explanation generation

Visualization Layer :
   Snowflake-connected Streamlit application
   Real-time filters, KPIs, and charts

🛠️ Technology Stack

Snowflake SQL

Snowflake Warehouse

Python

Streamlit

Pandas

Matplotlib
   
