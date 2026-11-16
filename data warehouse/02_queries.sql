-- 02 — SQL: verify the numbers and find where no-shows cluster
-- Part 2 (22 marks). Engine: MySQL 8 (MySQL Workbench).
-- SQLiteOnline: skip CREATE DATABASE / USE; everything else runs unchanged.

-- =====================================================================
-- Task 2.1 — Build and load the database
-- =====================================================================

-- 2.1.1 Create database & tables
CREATE DATABASE noshowguard;
USE noshowguard;

CREATE TABLE clinics (
  clinic_id VARCHAR(5) PRIMARY KEY, clinic_name VARCHAR(40) NOT NULL, city VARCHAR(20) NOT NULL,
  tier VARCHAR(10), latitude DECIMAL(8,4), longitude DECIMAL(8,4), temp_c DECIMAL(5,1));

CREATE TABLE appointments (
  appointment_id VARCHAR(8) PRIMARY KEY, patient_id VARCHAR(8) NOT NULL, clinic_id VARCHAR(5) NOT NULL,
  booked_on DATE, appt_date DATE, age INT, gender VARCHAR(1), distance_km DECIMAL(5,1), fee_inr INT,
  booking_channel VARCHAR(10), visit_type VARCHAR(12), reminder_sent VARCHAR(3), prior_no_shows INT,
  status VARCHAR(10), lead_days INT, no_show INT,
  FOREIGN KEY (clinic_id) REFERENCES clinics(clinic_id));

-- 2.1.2 Load: run `data warehouse/load_data.sql` now (8 clinics first, then 990 appointments), then verify
SELECT COUNT(*) AS clinics FROM clinics;                                     -- expect 8
SELECT COUNT(*) AS appointments, SUM(no_show) AS no_shows FROM appointments; -- expect 990 | 218

-- 2.1.3 Duplicate-key insert: a second row with appointment_id 'A0001' must be rejected by the PRIMARY KEY
INSERT INTO appointments VALUES ('A0001','P509','C05','2025-01-24','2025-01-25',60,'F',18.0,850,'Phone','Consultation','Yes',1,'No-Show',1,1);
-- Error (replace with the exact text from your run):
-- MySQL:  Error Code: 1062. Duplicate entry 'A0001' for key 'appointments.PRIMARY'
-- SQLite: UNIQUE constraint failed: appointments.appointment_id


-- =====================================================================
-- Task 2.2 — No-show rate by clinic
-- =====================================================================

-- 2.2.1 Clinics with >= 95 appointments
SELECT c.clinic_name,
       c.city,
       COUNT(*)                                     AS appointments,
       SUM(a.no_show)                               AS no_shows,
       ROUND(100.0 * SUM(a.no_show) / COUNT(*), 1)  AS no_show_pct
FROM appointments a
JOIN clinics c ON c.clinic_id = a.clinic_id
GROUP BY c.clinic_id, c.clinic_name, c.city
HAVING COUNT(*) >= 95              -- HAVING, not WHERE: the filter is on an aggregate
ORDER BY no_show_pct DESC;

-- 2.2.2 All 8 clinics (HAVING removed)
SELECT c.clinic_name,
       c.city,
       COUNT(*)                                     AS appointments,
       SUM(a.no_show)                               AS no_shows,
       ROUND(100.0 * SUM(a.no_show) / COUNT(*), 1)  AS no_show_pct
FROM appointments a
JOIN clinics c ON c.clinic_id = a.clinic_id
GROUP BY c.clinic_id, c.clinic_name, c.city
ORDER BY no_show_pct DESC;
-- Note: without HAVING, Gomti Nagar Care Point (Lucknow) has the highest rate, 33.3%,
-- but only 90 appointments, so it is less reliable than the clinics above the 95 cut-off.
-- Sitabuldi Health Point (Nagpur) also appears: 82 appointments, 15.9%.
-- Python cross-check (groupby on appointments_clean.csv): counts and no-shows match exactly
-- (see `data warehouse/02_pandas_crosscheck.ipynb`).


-- =====================================================================
-- Task 2.3 — Does booking far ahead matter?
-- =====================================================================
SELECT CASE
         WHEN lead_days <= 7  THEN '1-7'
         WHEN lead_days <= 14 THEN '8-14'
         WHEN lead_days <= 30 THEN '15-30'
         ELSE '31+'
       END                                          AS lead_band,
       COUNT(*)                                     AS appointments,
       SUM(no_show)                                 AS no_shows,
       ROUND(100.0 * SUM(no_show) / COUNT(*), 1)    AS no_show_pct
FROM appointments
GROUP BY lead_band
ORDER BY MIN(lead_days);           -- band order by real lead time; text sort would put '15-30' before '8-14'


-- =====================================================================
-- Task 2.4 — Month-by-month trend
-- =====================================================================
WITH monthly AS (
  SELECT SUBSTR(appt_date, 1, 7)                    AS month,
         COUNT(*)                                   AS appointments,
         ROUND(100.0 * SUM(no_show) / COUNT(*), 1)  AS no_show_pct
  FROM appointments
  GROUP BY month
)
SELECT month,
       appointments,
       no_show_pct,
       ROUND(no_show_pct - LAG(no_show_pct) OVER (ORDER BY month), 1) AS change_pp   -- this month minus last; NULL (blank) for January
FROM monthly
ORDER BY month;


-- =====================================================================
-- Task 2.5 — Rank clinics inside each city
-- =====================================================================
WITH clinic_rates AS (
  SELECT c.clinic_name,
         c.city,
         ROUND(100.0 * SUM(a.no_show) / COUNT(*), 1) AS no_show_pct
  FROM appointments a
  JOIN clinics c ON c.clinic_id = a.clinic_id
  GROUP BY c.clinic_id, c.clinic_name, c.city
)
SELECT clinic_name,
       city,
       no_show_pct,
       RANK() OVER (PARTITION BY city ORDER BY no_show_pct DESC) AS rank_in_city,
       CASE
         WHEN no_show_pct > (SELECT 100.0 * SUM(no_show) / COUNT(*) FROM appointments) THEN 'above'
         WHEN no_show_pct < (SELECT 100.0 * SUM(no_show) / COUNT(*) FROM appointments) THEN 'below'
         ELSE 'equal'
       END                                                       AS vs_overall
FROM clinic_rates
ORDER BY city, rank_in_city;
-- Overall rate (scalar subquery) = 22.02%.
