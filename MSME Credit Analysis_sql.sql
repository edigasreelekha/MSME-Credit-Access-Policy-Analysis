-- ============================================================================
-- PROJECT: MSME Credit Access & Regional Formalization Analysis (36 States/UTs)
-- AUTHOR: Ediga Sreelekha
-- TOOLS: MySQL 8.0 Workbench, Power BI, Microsoft Excel
-- DATA SOURCES: Ministry of MSME Udyam Dashboard & RBI PSL Credit Data
-- ============================================================================

-- 1. Create and select the project database
CREATE DATABASE IF NOT EXISTS msme_policy_project;
USE msme_policy_project;

-- 2. Create the master table structure matching your cleaned Excel file
DROP TABLE IF EXISTS master_data;

CREATE TABLE master_data (
    S_No INT PRIMARY KEY,
    State_UT_Name VARCHAR(100) NOT NULL,
    Micro BIGINT,
    Small INT,
    Medium INT,
    Total_Udyam BIGINT,
    IMEL_UAP BIGINT,
    Total_MSMEs BIGINT,
    Region VARCHAR(50),
    MSME_Bank_Credit_Cr DECIMAL(12, 2),
    Women_Owned_Udyam_Pct DECIMAL(5, 2),
    Avg_Credit_per_MSME_Lakhs DECIMAL(6, 2),
    Scaling_Rate_Pct DECIMAL(5, 2)
);


-- ============================================================================
-- 3. ANALYTICAL SQL QUERIES FOR YOUR PORTFOLIO & INTERVIEWS
-- ============================================================================
select * from master_data;

-- Query A: National KPI Summary Check (Matches Power BI Top KPI Cards)

SELECT 
    COUNT(*) AS total_states_uts,
    SUM(Total_MSMEs) AS national_total_msmes,
    ROUND(SUM(MSME_Bank_Credit_Cr) / 100000, 2) AS total_bank_credit_lakh_cr,
    ROUND(AVG(Avg_Credit_per_MSME_Lakhs), 2) AS state_avg_credit_lakhs,
    ROUND(AVG(Women_Owned_Udyam_Pct), 2) AS state_avg_women_ownership_pct
FROM master_data;

 -- Query B: Regional Credit Concentration vs. Enterprise share

SELECT 
    Region,
    COUNT(State_UT_Name) AS states_count,
    SUM(Total_MSMEs) AS regional_msmes,
    ROUND((SUM(Total_MSMEs) * 100.0) / (SELECT SUM(Total_MSMEs) FROM master_data), 2) AS pct_share_of_msmes,
    SUM(MSME_Bank_Credit_Cr) AS regional_credit_cr,
    ROUND((SUM(MSME_Bank_Credit_Cr) * 100.0) / (SELECT SUM(MSME_Bank_Credit_Cr) FROM master_data), 2) AS pct_share_of_credit,
    ROUND(AVG(Avg_Credit_per_MSME_Lakhs), 2) AS avg_credit_per_msme_lakhs
FROM master_data
GROUP BY Region
ORDER BY regional_credit_cr DESC;

-- Query C: Policy Segmentation — Identifying "High-Registration, Credit-Gap" States
SELECT 
    State_UT_Name,
    Region,
    Total_MSMEs,
    MSME_Bank_Credit_Cr,
    Avg_Credit_per_MSME_Lakhs,
    Scaling_Rate_Pct,
    CASE 
        WHEN Total_MSMEs >= 5000000 AND Avg_Credit_per_MSME_Lakhs >= 3.50 THEN 'Tier 1: High-Scale Credit Leader'
        WHEN Total_MSMEs >= 5000000 AND Avg_Credit_per_MSME_Lakhs < 3.50 THEN 'Tier 2: High-Registration Credit Gap'
        ELSE 'Tier 3: Developing / Niche Ecosystem'
    END AS policy_tier
FROM master_data
ORDER BY Total_MSMEs DESC;


 Query D: Top 10 States by Average Credit Ticket Size & Scaling Graduation Rate

SELECT 
    State_UT_Name,
    Region,
    Avg_Credit_per_MSME_Lakhs,
    Scaling_Rate_Pct,
    Women_Owned_Udyam_Pct
FROM master_data
ORDER BY Avg_Credit_per_MSME_Lakhs DESC
LIMIT 10;

Query E: Top 10 States Leading in Women-Owned MSME Formalization


SELECT 
    State_UT_Name,
    Region,
    Women_Owned_Udyam_Pct,
    Total_Udyam,
    Avg_Credit_per_MSME_Lakhs
FROM master_data
ORDER BY Women_Owned_Udyam_Pct DESC
LIMIT 10;