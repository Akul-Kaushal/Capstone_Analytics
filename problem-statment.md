# CareLoop Clinics — No-Show Guard
### [](https://assess.masaischool.com/test?token=tLShIMDUNojgkymFMWFzjejFGLaQVzkMJphKfWkkVfHBhwkhijjFkOcRYYhSRjgkKjcnQFsjgEKXJeHRIjFfjvWnLLFLMnAmzUQL#from-raw-bookings-to-a-risk-model-and-an-ai-assisted-follow-up-review)

### From raw bookings to a risk model and an AI-assisted follow-up review

CareLoop Clinics runs eight outpatient clinics in six Indian cities. Every missed appointment is an empty doctor slot that another patient could have used, and the front desk currently finds out about no-shows only after the day is over. Management wants three things: a cleaned, trustworthy booking table; evidence of _where_ and _when_ no-shows happen; and a model that flags risky bookings early. The call-centre team also writes a short note after phoning each patient who missed a visit. Nobody reads these notes at scale, so management would like them turned into structured reasons.

You are the analyst who builds all of it, end to end, from three files. This is one connected case, not four exercises: **Part 1's cleaned file is the input to Part 2 and Part 3, and Part 3's findings are read together with Part 4's AI-extracted reasons in your final recommendation.**

Every technique below was taught in the sessions. Where a library call goes beyond what was shown on screen, the brief gives it to you.

**Total marks:** 100 · **One deliverable:** one public GitHub repository link.

**Business question:** _Which appointments are most likely to be missed, why do patients miss them, and what should CareLoop do first?_

**Prediction point (used in Part 3):** the risk score is produced on the evening before the appointment, after that day's reminders have been sent or skipped. Everything in the model — including `reminder_sent` and `prior_no_shows` — is therefore known at that moment, and the front desk can still phone the riskiest patients.

## [](https://assess.masaischool.com/test?token=tLShIMDUNojgkymFMWFzjejFGLaQVzkMJphKfWkkVfHBhwkhijjFkOcRYYhSRjgkKjcnQFsjgEKXJeHRIjFfjvWnLLFLMnAmzUQL#submission-guidelines-read-first)

## Submission Guidelines (read first)

- **One submission only:** the link to one public GitHub repository. Everything for Parts 1–4 lives in that repository. Create it and upload your files through the GitHub website (Add file → Upload files). If the repository is private or contains your API key, it cannot be accepted.
- **Free tools only, no card, no subscription:**
    - **Python:** Google Colab (free Google account) with `csv`, `json`, `requests`, pandas, NumPy, scikit-learn, Pydantic.
    - **SQL:** MySQL Workbench with a local MySQL 8 server, as used in class. If installation fails, SQLiteOnline (free, in the browser) runs every query in this brief; skip the two `CREATE DATABASE` / `USE` lines there. Two differences to expect: the duplicate-key error is worded "UNIQUE constraint failed" instead of "Duplicate entry", and foreign keys are not enforced by default.
    - **GenAI:** a free Gemini API key from Google AI Studio (no card needed). The free tier is small (the instructor quoted about 5 requests a minute and 50 a day; check the current limits on your AI Studio page, because they change), so this brief is designed to need fewer than 25 calls in total. Use the model name shown in your Session 22.1 notebook; if it has been retired, pick the current Flash model listed in AI Studio. The _thinking_ setting differs between Gemini models: if the call in Task 4.1 fails with an error about `thinking_config`, remove that one line (or use the setting your model's page documents) and keep everything else — JSON mode, the schema and the Pydantic check — unchanged.
- **Never put your API key in a file you upload.** Never type or paste it into a code cell either: enter it at run time with `input()`, clear the cell output, and before downloading the notebook use _Edit → Find_ to search the whole notebook for the first characters of your key. A leaked key is a defect.
- **Time:** plan about 20–25 hours in total (roughly Part 1: 6 h, Part 2: 3–4 h, Part 3: 6 h, Part 4: 3–4 h, README and GitHub: 2 h). Installing MySQL and getting the Gemini key working can add time, so start those early.
- **Not asked for anywhere:** dashboards, web apps, slides, screenshots, videos. Everything is code, data and Markdown text in the repository.
- **Conventions that change numbers** (apply everywhere): the random seed is `random_state=42`; the train/test split is `test_size=0.2`; percentages are rounded to 1 decimal; `std` means NumPy's default (`np.std`, population) wherever Task 1.4 says so; quartiles use pandas/NumPy's default method.
- **Generative-AI rule:** you may use any assistant to explain an error. Any number it gives you must be reproduced by your own code before you use it.
- **Originality:** your code, queries and README must be your own work.

## [](https://assess.masaischool.com/test?token=tLShIMDUNojgkymFMWFzjejFGLaQVzkMJphKfWkkVfHBhwkhijjFkOcRYYhSRjgkKjcnQFsjgEKXJeHRIjFfjvWnLLFLMnAmzUQL#data-pack-data--do-not-edit-the-originals)

## Data Pack (`data/` — do not edit the originals)

| File                 | Rows  | What it is                                                                                               |
| -------------------- | ----- | -------------------------------------------------------------------------------------------------------- |
| `appointments.csv`   | 1,020 | Raw booking export, Jan–Jun 2025. Contains realistic errors.                                             |
| `clinics.csv`        | 8     | Clinic master: id, name, city, tier, latitude, longitude.                                                |
| `followup_notes.csv` | 30    | Call-centre notes about patients who missed an appointment. You will use the first 10 (free-tier limit). |

`appointments.csv` columns: `appointment_id`, `patient_id`, `clinic_id`, `booked_on`, `appt_date`, `age`, `gender`, `distance_km` (patient's home to clinic), `fee_inr`, `booking_channel` (App / Phone / Walk-in), `visit_type` (Consultation / Follow-up), `reminder_sent` (Yes / No), `prior_no_shows` (0–5, before this booking), `status` (Attended / No-Show). `followup_notes.csv` columns: `note_id`, `appointment_id`, `note_text`.

**Hand-off files you create:** `appointments_clean.csv` (Task 1.6) → used by Parts 2 and 3 · `clinics_enriched.csv` (Task 1.5) → used in Part 2 · `load_data.sql` (Task 1.6) → run in Part 2 · `test_risk_scores.csv` (Task 3.5) → cited in your README · `notes_analysed.csv` (Task 4.2) → used in Part 4.

#### [](https://assess.masaischool.com/test?token=tLShIMDUNojgkymFMWFzjejFGLaQVzkMJphKfWkkVfHBhwkhijjFkOcRYYhSRjgkKjcnQFsjgEKXJeHRIjFfjvWnLLFLMnAmzUQL#datasets)

#### Datasets:

**appointments.csv** - [appointments](https://coding-platform.s3.amazonaws.com/dev/lms/tickets/c1a9c6a2-5967-41fb-9133-cb6f78008699/qDCCmpyfss1kBJJB.csv)

**clinics.csv** - [clinics](https://coding-platform.s3.amazonaws.com/dev/lms/tickets/0fe7e34d-9470-47d8-b7b1-d54b77e009fe/jbFzPdd2gB2Ex2TY.csv)

**followup_notes.csv** - [followup_notes](https://coding-platform.s3.amazonaws.com/dev/lms/tickets/5e122459-7975-4534-957f-8397b0f9c03e/ecWvPsdV2FNmRZAa.csv)

---

## [](https://assess.masaischool.com/test?token=tLShIMDUNojgkymFMWFzjejFGLaQVzkMJphKfWkkVfHBhwkhijjFkOcRYYhSRjgkKjcnQFsjgEKXJeHRIjFfjvWnLLFLMnAmzUQL#part-1--python--data-foundations-ingest-validate-clean-enrich-26-marks)

## Part 1 — Python & Data Foundations: ingest, validate, clean, enrich (26 marks)

The export was typed by different front desks, so it has duplicates, inconsistent labels, impossible values and gaps. Everything downstream depends on getting this right, and every fix must be one you can name.

### [](https://assess.masaischool.com/test?token=tLShIMDUNojgkymFMWFzjejFGLaQVzkMJphKfWkkVfHBhwkhijjFkOcRYYhSRjgkKjcnQFsjgEKXJeHRIjFfjvWnLLFLMnAmzUQL#task-11--read-the-file-the-foundations-way-5-marks)

### Task 1.1 — Read the file the foundations way (5 marks)

Using only the `csv` module (not pandas): open `appointments.csv` with `with open(..., newline="")`, read it with `csv.DictReader`, and print the header and row count. Write a function `parse_row(row)` that converts `age`, `fee_inr` and `prior_no_shows` to `int` and `distance_km` to `float`, returning the converted dictionary. Loop over every row; use `try/except ValueError` to put rows that fail into a `rejected` list and the rest into an `accepted` list. Save `rejected` with `json.dump(..., indent=2)` as `rejected_rows.json`.

### [](https://assess.masaischool.com/test?token=tLShIMDUNojgkymFMWFzjejFGLaQVzkMJphKfWkkVfHBhwkhijjFkOcRYYhSRjgkKjcnQFsjgEKXJeHRIjFfjvWnLLFLMnAmzUQL#task-12--inspect-and-clean-pass-1-5-marks)

### Task 1.2 — Inspect and clean, pass 1 (5 marks)

Load the file with `pd.read_csv`. Print `shape`, `info()`, `isnull().sum()` and `duplicated().sum()`. Then, in this order: (a) drop exact duplicate rows; (b) clean `booking_channel` with `.str.strip().str.title()`; (c) convert `appt_date` with `pd.to_datetime(..., errors="coerce")` and `booked_on` with `pd.to_datetime`; (d) drop rows where `appt_date` is missing after conversion or `status` is missing. Print the row count after each step. **This task starts again from the original `appointments.csv`:** Task 1.1 is a separate exercise in reading with the `csv` module, so do not use its accepted/rejected lists here — the pandas cleaning in 1.2–1.3 is the one that feeds the rest of the project.

### [](https://assess.masaischool.com/test?token=tLShIMDUNojgkymFMWFzjejFGLaQVzkMJphKfWkkVfHBhwkhijjFkOcRYYhSRjgkKjcnQFsjgEKXJeHRIjFfjvWnLLFLMnAmzUQL#task-13--clean-pass-2-validity-gaps-and-outliers-5-marks)

### Task 1.3 — Clean, pass 2: validity, gaps and outliers (5 marks)

Work in this order, so that the quartiles and fences in (c) are computed **after** the gaps are filled. (a) Treat any `age` below 1 or above 100 as invalid and set it to missing. (b) Fill missing `age` with the median (then `.round().astype(int)`) and missing `distance_km` with its median. (c) For `distance_km` and `fee_inr`, compute Q1, Q3 and IQR with `.quantile`, and cap values at Q3 + 1.5×IQR and Q1 − 1.5×IQR with `np.clip`. (d) Round `distance_km` to 1 decimal and `fee_inr` to whole rupees (`.round().astype(int)`). Print how many values you capped in each column.

### [](https://assess.masaischool.com/test?token=tLShIMDUNojgkymFMWFzjejFGLaQVzkMJphKfWkkVfHBhwkhijjFkOcRYYhSRjgkKjcnQFsjgEKXJeHRIjFfjvWnLLFLMnAmzUQL#task-14--features-and-a-numpy-summary-4-marks)

### Task 1.4 — Features and a NumPy summary (4 marks)

Create `lead_days` = days between `booked_on` and `appt_date` (use `.dt.days`) and `no_show` = 1 if `status` is `"No-Show"` else 0. Then take `X = df[["age","distance_km","fee_inr","lead_days"]].to_numpy()` and, **without loops**, compute: (a) the mean of each column (`axis=0`); (b) the number and share of rows with `lead_days > 14` using a boolean mask (`mask.sum()` counts the `True` values and `mask.mean()` gives the share); (c) z-scores of the `distance_km` column using `(x - np.mean(x)) / np.std(x)` and the count of rows with `|z| > 2`.

### [](https://assess.masaischool.com/test?token=tLShIMDUNojgkymFMWFzjejFGLaQVzkMJphKfWkkVfHBhwkhijjFkOcRYYhSRjgkKjcnQFsjgEKXJeHRIjFfjvWnLLFLMnAmzUQL#task-15--enrich-the-clinics-from-a-live-api-3-marks)

### Task 1.5 — Enrich the clinics from a live API (3 marks)

For each of the 8 clinics call the free Open-Meteo API with `requests.get("https://api.open-meteo.com/v1/forecast", params={"latitude": ..., "longitude": ..., "hourly": "temperature_2m", "forecast_days": 1})`. Check `status_code == 200` before using the reply, read the JSON, take the **first** value of `["hourly"]["temperature_2m"]` (the midnight-UTC reading, a stand-in rather than the current weather) as `temp_c`, and save `clinics_enriched.csv` (the original columns plus `temp_c`; `df.to_csv("file.csv", index=False)` writes a DataFrame to CSV). No API key is needed. **If the API fails:** pass `timeout=10` to `requests.get`, wrap the call in `try/except requests.exceptions.RequestException`, retry that clinic once, and if it still fails (or the status is not 200, or `hourly` is missing) store `None` as `temp_c`, print the clinic's name and the reason, and carry on. Never type in a made-up temperature; in `load_data.sql` a missing value is written as `NULL` (unquoted).

### [](https://assess.masaischool.com/test?token=tLShIMDUNojgkymFMWFzjejFGLaQVzkMJphKfWkkVfHBhwkhijjFkOcRYYhSRjgkKjcnQFsjgEKXJeHRIjFfjvWnLLFLMnAmzUQL#task-16--export-the-clean-table-and-write-the-sql-load-script-4-marks)

### Task 1.6 — Export the clean table and write the SQL load script (4 marks)

Sort the cleaned data by `appointment_id`, format both date columns as `YYYY-MM-DD` text (`.dt.strftime("%Y-%m-%d")`), and save `appointments_clean.csv` with exactly these 16 columns, in this order: `appointment_id, patient_id, clinic_id, booked_on, appt_date, age, gender, distance_km, fee_inr, booking_channel, visit_type, reminder_sent, prior_no_shows, status, lead_days, no_show`. Then, with a `for` loop and f-strings, write `load_data.sql` containing one statement per row, in this pattern (text in single quotes, numbers unquoted): `INSERT INTO appointments VALUES ('A0001','P196','C05','2025-01-22',...,0);` — and likewise one `INSERT INTO clinics VALUES (...)` per clinic from `clinics_enriched.csv`. **Write all the `clinics` statements first**, because the appointments table points to them with a foreign key. Before exporting, check and print that `appointment_id` is unique and that none of the 16 columns has a missing value. (Building SQL text with f-strings is fine for this fixed, controlled dataset — none of its values contains an apostrophe. It is not a safe method for real applications, where parameterised queries are used instead.)

### [](https://assess.masaischool.com/test?token=tLShIMDUNojgkymFMWFzjejFGLaQVzkMJphKfWkkVfHBhwkhijjFkOcRYYhSRjgkKjcnQFsjgEKXJeHRIjFfjvWnLLFLMnAmzUQL#acceptance-criteria-part-1)

### Acceptance criteria (Part 1)

- 1.1: 1,020 rows read; **988 accepted, 32 rejected** (12 with a blank `age`, 20 with a blank `distance_km`). The 5 rows with impossible ages (such as 250) are _accepted_ — a type check is not a validity check.
- 1.2: raw shape **(1020, 14)**; nulls: `age` 12, `distance_km` 20, `status` 4, `appt_date` 1 (pandas reads the text `N/A` as missing); **20 duplicates**; `booking_channel` has **16** distinct raw spellings and **3** after cleaning (App, Phone, Walk-In). Row counts: 1,020 → **1,000** → **990** after step (d) (**6** unreadable dates; 4 blank statuses).
- 1.3: **5** invalid ages, so 17 missing ages in total; median age **48**; median distance **8.25**. Distance: Q1 4.625, Q3 13.0, upper fence 25.5625, **26** values capped (no low-side values). Fee: Q1 500, Q3 787.5, upper fence 1218.75, **3** values capped (the three ×10 keying errors); largest fee afterwards **1,219**.
- 1.4: `lead_days` runs from **1 to 45**; **218** no-shows out of 990 (**22.0%**). Column means ≈ **[48.17, 9.50, 635.71, 11.82]** (±0.01). **296** rows (**29.9%**) have `lead_days > 14`. **53** rows have |z| > 2 for `distance_km`.
- 1.5: 8 responses, normally all status 200; `clinics_enriched.csv` has 8 rows and a numeric `temp_c` between −10 and 50 (values change with the day). If a call failed twice, that clinic's `temp_c` is blank (and `NULL` in the SQL), the failure is printed, and no value is invented.
- 1.6: `appointment_id` has 990 distinct values and the 16 columns have **0** missing values; `appointments_clean.csv` has **990 rows and 16 columns**; `load_data.sql` has **8 + 990 = 998** INSERT statements.

---

## [](https://assess.masaischool.com/test?token=tLShIMDUNojgkymFMWFzjejFGLaQVzkMJphKfWkkVfHBhwkhijjFkOcRYYhSRjgkKjcnQFsjgEKXJeHRIjFfjvWnLLFLMnAmzUQL#part-2--sql-verify-the-numbers-and-find-where-no-shows-cluster-22-marks)

## Part 2 — SQL: verify the numbers and find where no-shows cluster (22 marks)

Numbers a manager acts on must be reproducible from the database, and they must agree with your Python numbers. Part 2 loads Part 1's output into MySQL and answers business questions with SQL.

### [](https://assess.masaischool.com/test?token=tLShIMDUNojgkymFMWFzjejFGLaQVzkMJphKfWkkVfHBhwkhijjFkOcRYYhSRjgkKjcnQFsjgEKXJeHRIjFfjvWnLLFLMnAmzUQL#task-21--build-and-load-the-database-4-marks)

### Task 2.1 — Build and load the database (4 marks)

In MySQL Workbench run `CREATE DATABASE noshowguard; USE noshowguard;` (skip in SQLiteOnline). Create the two tables below, then run your `load_data.sql`:

```sql
CREATE TABLE clinics (
  clinic_id VARCHAR(5) PRIMARY KEY, clinic_name VARCHAR(40) NOT NULL, city VARCHAR(20) NOT NULL,
  tier VARCHAR(10), latitude DECIMAL(8,4), longitude DECIMAL(8,4), temp_c DECIMAL(5,1));
CREATE TABLE appointments (
  appointment_id VARCHAR(8) PRIMARY KEY, patient_id VARCHAR(8) NOT NULL, clinic_id VARCHAR(5) NOT NULL,
  booked_on DATE, appt_date DATE, age INT, gender VARCHAR(1), distance_km DECIMAL(5,1), fee_inr INT,
  booking_channel VARCHAR(10), visit_type VARCHAR(12), reminder_sent VARCHAR(3), prior_no_shows INT,
  status VARCHAR(10), lead_days INT, no_show INT,
  FOREIGN KEY (clinic_id) REFERENCES clinics(clinic_id));
```

Check with `COUNT(*)` and `SUM(no_show)`. Then try to insert a second row whose `appointment_id` is `'A0001'` and record the error message.

### [](https://assess.masaischool.com/test?token=tLShIMDUNojgkymFMWFzjejFGLaQVzkMJphKfWkkVfHBhwkhijjFkOcRYYhSRjgkKjcnQFsjgEKXJeHRIjFfjvWnLLFLMnAmzUQL#task-22--no-show-rate-by-clinic-5-marks)

### Task 2.2 — No-show rate by clinic (5 marks)

`JOIN` `appointments` to `clinics`; for each clinic show `clinic_name`, `city`, `appointments`, `no_shows` and `no_show_pct`, where `no_show_pct` is `ROUND(100.0 * SUM(no_show) / COUNT(*), 1)`. Keep only clinics with **at least 95** appointments (`HAVING`) and sort by `no_show_pct` descending. Then remove the `HAVING` line, look at all 8 clinics, and note which clinic has the highest rate and how many appointments it has. In Python, reproduce the clinic counts and no-show counts with `groupby` and confirm they match the SQL.

### [](https://assess.masaischool.com/test?token=tLShIMDUNojgkymFMWFzjejFGLaQVzkMJphKfWkkVfHBhwkhijjFkOcRYYhSRjgkKjcnQFsjgEKXJeHRIjFfjvWnLLFLMnAmzUQL#task-23--does-booking-far-ahead-matter-4-marks)

### Task 2.3 — Does booking far ahead matter? (4 marks)

Using `CASE WHEN`, put `lead_days` into four bands (the labels must come out of the `CASE WHEN`, not be typed into the data) — `1-7`, `8-14`, `15-30`, `31+` (upper limits **inclusive**: 7, 14 and 30 belong to the lower band) — and show appointments, no-shows and `no_show_pct` per band in band order (hint: `ORDER BY MIN(lead_days)` sorts the bands by how short their lead times are, whereas sorting by the band text would put `15-30` before `8-14`).

### [](https://assess.masaischool.com/test?token=tLShIMDUNojgkymFMWFzjejFGLaQVzkMJphKfWkkVfHBhwkhijjFkOcRYYhSRjgkKjcnQFsjgEKXJeHRIjFfjvWnLLFLMnAmzUQL#task-24--month-by-month-trend-4-marks)

### Task 2.4 — Month-by-month trend (4 marks)

With a CTE named `monthly` (month = `SUBSTR(appt_date,1,7)`), compute appointments and `no_show_pct` per month, then use `LAG()` with `OVER (ORDER BY month)` to show the change in percentage points — this month's rate **minus** the previous month's rate (blank for January).

### [](https://assess.masaischool.com/test?token=tLShIMDUNojgkymFMWFzjejFGLaQVzkMJphKfWkkVfHBhwkhijjFkOcRYYhSRjgkKjcnQFsjgEKXJeHRIjFfjvWnLLFLMnAmzUQL#task-25--rank-clinics-inside-each-city-5-marks)

### Task 2.5 — Rank clinics inside each city (5 marks)

With a CTE `clinic_rates` (clinic, city, `no_show_pct`), select every clinic with `RANK() OVER (PARTITION BY city ORDER BY no_show_pct DESC)` as `rank_in_city`, plus a column `vs_overall` that says `'above'`, `'below'` or `'equal'` (no clinic is exactly equal here, but the query should handle it) by comparing the clinic's rate with the overall no-show rate computed in a scalar subquery. Order by city, then rank.

### [](https://assess.masaischool.com/test?token=tLShIMDUNojgkymFMWFzjejFGLaQVzkMJphKfWkkVfHBhwkhijjFkOcRYYhSRjgkKjcnQFsjgEKXJeHRIjFfjvWnLLFLMnAmzUQL#acceptance-criteria-part-2)

### Acceptance criteria (Part 2)

- 2.1: **8** clinics, **990** appointments, **218** no-shows (same as Task 1.4). The duplicate insert fails with a duplicate-key / unique-constraint error.
- 2.2 (≥ 95 appointments), in this order:

|clinic_name|city|appointments|no_shows|no_show_pct|
|---|---|---|---|---|
|Hadapsar Care Centre|Pune|143|39|27.3|
|Malviya Nagar Clinic|Jaipur|142|38|26.8|
|Kothrud Family Clinic|Pune|160|36|22.5|
|Vijay Nagar Clinic|Indore|101|21|20.8|
|Edappally Medical Centre|Kochi|142|23|16.2|
|Vaishali Nagar Clinic|Jaipur|130|18|13.8|

Without `HAVING`, two more clinics appear: **Gomti Nagar Care Point (Lucknow) has the highest rate, 33.3%, but only 90 appointments**; Sitabuldi Health Point (Nagpur) has 82 appointments at 15.9%. The pandas counts match the SQL counts exactly.

- 2.3: `1-7`: 390 / 63 / 16.2 · `8-14`: 304 / 53 / 17.4 · `15-30`: 253 / 76 / 30.0 · `31+`: 43 / 26 / 60.5 (appointments / no-shows / %).
- 2.4: 2025-01: 157 · 24.8 · blank; 2025-02: 151 · 20.5 · −4.3; 2025-03: 142 · 20.4 · −0.1; 2025-04: 177 · 20.9 · +0.5; 2025-05: 198 · 23.7 · +2.8; 2025-06: 165 · 21.2 · −2.5 (month · appointments · rate · change).
- 2.5: overall rate is 22.02%. Eight rows: Indore — Vijay Nagar 20.8, rank 1, below · Jaipur — Malviya Nagar 26.8, rank 1, above; Vaishali Nagar 13.8, rank 2, below · Kochi — Edappally 16.2, rank 1, below · Lucknow — Gomti Nagar 33.3, rank 1, above · Nagpur — Sitabuldi 15.9, rank 1, below · Pune — Hadapsar 27.3, rank 1, above; Kothrud 22.5, rank 2, above.

---

## [](https://assess.masaischool.com/test?token=tLShIMDUNojgkymFMWFzjejFGLaQVzkMJphKfWkkVfHBhwkhijjFkOcRYYhSRjgkKjcnQFsjgEKXJeHRIjFfjvWnLLFLMnAmzUQL#part-3--machine-learning-predict-no-shows-and-choose-the-model-honestly-30-marks)

## Part 3 — Machine Learning: predict no-shows and choose the model honestly (30 marks)

Load Part 1's `appointments_clean.csv`. The goal is a model whose risk score the front desk can use, the evening before, to decide whom to phone. Only about 1 booking in 5 is a no-show, so judge every model by **recall, precision and ROC-AUC as well as accuracy**. **Rule for the whole Part: the test set is for reporting only — never use it to choose a model, a setting or a threshold.** Two honest limits to remember (you will state them in Task 4.4): the medians, quartiles and outlier fences in Task 1.3 were calculated on all 990 rows before the split, so the test rows had a small indirect influence on the cleaning (in a real system they would be calculated on the training rows only); the same patient can appear in several bookings, so a random split can put one patient in both train and test; and the split is random, whereas a real system would be trained on the past and used on the future.

### [](https://assess.masaischool.com/test?token=tLShIMDUNojgkymFMWFzjejFGLaQVzkMJphKfWkkVfHBhwkhijjFkOcRYYhSRjgkKjcnQFsjgEKXJeHRIjFfjvWnLLFLMnAmzUQL#task-31--features-split-and-baseline-5-marks)

### Task 3.1 — Features, split and baseline (5 marks)

Build `X` from `age, distance_km, fee_inr, lead_days, prior_no_shows`, `reminder_sent` (convert Yes/No to 1/0 with `.map`), and the one-hot encoded `booking_channel` and `visit_type` (`pd.get_dummies(X, columns=["booking_channel","visit_type"])`). Do **not** use `patient_id`, `appointment_id`, dates, `clinic_id`, `gender` or `status` as features. Target `y = no_show`. Split with `train_test_split(X, y, test_size=0.2, random_state=42)`. Report the training and test sizes, the number of no-shows in the test set, and the **baseline accuracy** of always predicting "Attended". **Do not shuffle or re-sort the rows** after loading `appointments_clean.csv`: the exact test-set counts below depend on the row order of that file.

### [](https://assess.masaischool.com/test?token=tLShIMDUNojgkymFMWFzjejFGLaQVzkMJphKfWkkVfHBhwkhijjFkOcRYYhSRjgkKjcnQFsjgEKXJeHRIjFfjvWnLLFLMnAmzUQL#task-32--logistic-regression-6-marks)

### Task 3.2 — Logistic regression (6 marks)

Scale with `StandardScaler` (`scaler = StandardScaler()`, `X_train_s = scaler.fit_transform(X_train)`, `X_test_s = scaler.transform(X_test)` — **fit on the training set only**), fit `LogisticRegression(max_iter=1000)`, and report accuracy, the confusion matrix, precision, recall, F1 and ROC-AUC on the test set. Print the coefficients (`model.coef_[0]`, one per feature, in the column order of `X`) next to the feature names and report `np.exp(coefficient)` for `reminder_sent`. Remember that the model was fitted on _scaled_ features: to get the effect of a reminder going from No (0) to Yes (1), divide the coefficient by the feature's standard deviation (`scaler.scale_`) before applying `np.exp`. State both numbers and explain in one sentence why they differ. Word your conclusion as an _association_ ("in this model, holding the other features constant …"): the data are observational, so it does not prove that reminders cause fewer no-shows.

### [](https://assess.masaischool.com/test?token=tLShIMDUNojgkymFMWFzjejFGLaQVzkMJphKfWkkVfHBhwkhijjFkOcRYYhSRjgkKjcnQFsjgEKXJeHRIjFfjvWnLLFLMnAmzUQL#task-33--decision-tree-and-overfitting-5-marks)

### Task 3.3 — Decision tree and overfitting (5 marks)

Fit `DecisionTreeClassifier(random_state=42)` with no depth limit, and again with `max_depth=3`. For each, report training accuracy and test accuracy, and state in one sentence what the gap shows.

### [](https://assess.masaischool.com/test?token=tLShIMDUNojgkymFMWFzjejFGLaQVzkMJphKfWkkVfHBhwkhijjFkOcRYYhSRjgkKjcnQFsjgEKXJeHRIjFfjvWnLLFLMnAmzUQL#task-34--random-forest-and-a-comparison-table-6-marks)

### Task 3.4 — Random forest and a comparison table (6 marks)

Fit `RandomForestClassifier(n_estimators=100, random_state=42)`. Report accuracy, recall and ROC-AUC (use `predict_proba(X_test)[:, 1]` for AUC) and the top three `rf.feature_importances_` (the attribute name is given because the course mentioned the idea only briefly). Then build a table with one row each for logistic regression, the depth-3 tree and the random forest (accuracy, recall, ROC-AUC) and say which model looks best and why; this table is for reporting — the formal choice is made in Task 3.5.

### [](https://assess.masaischool.com/test?token=tLShIMDUNojgkymFMWFzjejFGLaQVzkMJphKfWkkVfHBhwkhijjFkOcRYYhSRjgkKjcnQFsjgEKXJeHRIjFfjvWnLLFLMnAmzUQL#task-35--tune-choose-the-model-and-the-threshold-then-test-once-8-marks)

### Task 3.5 — Tune, choose the model and the threshold, then test once (8 marks)

(a) Run `GridSearchCV(RandomForestClassifier(random_state=42), {"n_estimators": [100, 200], "max_depth": [3, 5, 8]}, cv=5, scoring="roc_auc")` on the **training** set; print `best_params_` and `best_score_` (a cross-validated ROC-AUC). (b) **Choose the final model without touching the test set:** compute the 5-fold cross-validated ROC-AUC on the training set for logistic regression, the depth-3 tree and the random forest — `cross_val_score(model, X_train, y_train, cv=5, scoring="roc_auc").mean()` — and compare them with the tuned forest's `best_score_`. For logistic regression, give `cross_val_score` the **unscaled** `X_train` together with the supplied pipeline below, so that the scaler is re-fitted on each fold's own training part (scaling the whole training set first would let each validation fold influence the scaler). The highest wins. (c) **Choose the threshold without touching the test set:** get out-of-fold training probabilities for the winner with `cross_val_predict(model, X_train, y_train, cv=5, method="predict_proba")[:, 1]` (for logistic regression use the pipeline and the unscaled `X_train`) and compare thresholds 0.5 and 0.35 on precision, recall, F1 and number flagged; pick the threshold with the higher F1 and say why recall matters here (a missed warning costs an empty slot, an extra call costs a minute). (d) Fit the winner on the training set (the pipeline fits its own scaler) and evaluate it **once** on the test set at your chosen threshold: precision, recall, number flagged and ROC-AUC. (e) Save `test_risk_scores.csv` with columns `appointment_id`, `no_show`, `risk_prob`, `flag` (1 if `risk_prob` ≥ your threshold) for every test row. (To get `appointment_id`, keep it aside before building `X`, or use `X_test.index` to look it up in the loaded DataFrame.) In one sentence, say how a clinic would really choose the threshold: by how many follow-up calls the front desk can make in an evening, against the cost of an empty slot.

Supplied pipeline for logistic regression (a pipeline chains the same `fit`/`transform` steps you used in 3.2 and repeats them inside every fold; the idea is the one from 20.2, the code is given because it was not shown in class):

```python
from sklearn.pipeline import Pipeline
lr_pipe = Pipeline([("scaler", StandardScaler()), ("model", LogisticRegression(max_iter=1000))])
cv_auc = cross_val_score(lr_pipe, X_train, y_train, cv=5, scoring="roc_auc").mean()
oof = cross_val_predict(lr_pipe, X_train, y_train, cv=5, method="predict_proba")[:, 1]
lr_pipe.fit(X_train, y_train)
probs = lr_pipe.predict_proba(X_test)[:, 1]
```

### [](https://assess.masaischool.com/test?token=tLShIMDUNojgkymFMWFzjejFGLaQVzkMJphKfWkkVfHBhwkhijjFkOcRYYhSRjgkKjcnQFsjgEKXJeHRIjFfjvWnLLFLMnAmzUQL#acceptance-criteria-part-3)

### Acceptance criteria (Part 3)

Metrics from scikit-learn can differ slightly across versions, so ML numbers carry a tolerance; counts and baselines are exact. Reference run: scikit-learn 1.5.0, pandas 2.3, NumPy 1.26.

- 3.1: `X` has **11** columns; train **792** rows, test **198** rows; **49** no-shows in the test set (**22.0%** of the data overall); baseline accuracy **0.7525** (149 of 198).
- 3.2: accuracy ≈ **0.788** (±0.03); precision ≈ 0.63, recall ≈ **0.35** (±0.06), F1 ≈ 0.45, **ROC-AUC ≈ 0.789 (±0.04)**; confusion matrix ≈ [[139, 10], [32, 17]]. `reminder_sent` has the **most negative** coefficient (≈ −0.58); `lead_days` and `prior_no_shows` are both clearly positive (≈ +0.6). `np.exp` of the `reminder_sent` coefficient ≈ **0.56** (odds × 0.56 per one standard deviation of the scaled feature, SD ≈ 0.49). For the real No→Yes change, `np.exp(coef / scale)` ≈ **0.31**, i.e. in this fitted model the odds of a no-show are about **69% lower** for appointments with a reminder, holding the other features constant — an association, not proof of cause — and do not report 44% as the effect of sending a reminder.
- 3.3: full-depth tree: training accuracy **1.00**, test ≈ **0.67** (depth ≈ 15) — _below the 0.7525 baseline_, so it memorised noise. Depth-3 tree: training ≈ 0.82, test ≈ 0.78.
- 3.4: random forest: training accuracy 1.00, test accuracy ≈ **0.75** (±0.03), recall ≈ 0.31, ROC-AUC ≈ **0.71** (±0.04); `lead_days` is among the top three importances (reference: `lead_days` 0.22, `age` 0.20, `distance_km` 0.19; the order can vary). Logistic regression has the highest test ROC-AUC of the three models (shown for information; the model is _chosen_ in Task 3.5 from training data only).
- 3.5: reference run (all ±0.03 unless stated). `best_score_` (cross-validated **ROC-AUC**, not accuracy) ≈ **0.77**; the winning `best_params_` may differ (any grid value is acceptable). Cross-validated training ROC-AUC: logistic regression ≈ **0.77**, depth-3 tree ≈ 0.68, random forest ≈ 0.75, tuned forest ≈ 0.77; **logistic regression is the highest** (it is also highest in every other random split tried), and the tuned forest scores ≈ 0.74 on the test set (for information only). Out-of-fold training probabilities, threshold 0.5: precision ≈ 0.58, recall ≈ **0.25**, F1 ≈ 0.35, ≈ 73 flagged; threshold 0.35: precision ≈ 0.51, recall ≈ **0.47**, F1 ≈ **0.49**, ≈ 154 flagged (±8) — so **0.35 is chosen** (higher F1 and much higher recall). One test-set evaluation of logistic regression at 0.35: precision ≈ 0.57, recall ≈ **0.57** (±0.05), about **49** flagged (±2), ROC-AUC ≈ 0.79. (A few test rows sit within 0.002 of 0.35, so the flagged count can move by one or two between scikit-learn versions or solvers.) `test_risk_scores.csv` has **198** rows, and the number of rows with `flag = 1` equals the number you reported.

---

## [](https://assess.masaischool.com/test?token=tLShIMDUNojgkymFMWFzjejFGLaQVzkMJphKfWkkVfHBhwkhijjFkOcRYYhSRjgkKjcnQFsjgEKXJeHRIjFfjvWnLLFLMnAmzUQL#part-4--genai-turn-call-centre-notes-into-structured-reasons-then-recommend-22-marks)

## Part 4 — GenAI: turn call-centre notes into structured reasons, then recommend (22 marks)

The model says _who_ is at risk; the notes say _why_ patients actually missed. You will use the Gemini API to read the first 10 notes, force the answers into a fixed format, validate them with Pydantic, test the weak spots, and then combine everything into a recommendation.

**Allowed `root_cause` values:** `forgot_or_no_reminder`, `distance_or_transport`, `cost_or_fee`, `illness_or_emergency`, `work_or_schedule`, `other`.

### [](https://assess.masaischool.com/test?token=tLShIMDUNojgkymFMWFzjejFGLaQVzkMJphKfWkkVfHBhwkhijjFkOcRYYhSRjgkKjcnQFsjgEKXJeHRIjFfjvWnLLFLMnAmzUQL#task-41--one-validated-call-5-marks)

### Task 4.1 — One validated call (5 marks)

Get a free key in Google AI Studio and install the library in Colab. Write a function `analyse_note(note_text)` that sends one note to the Gemini Flash model used in class, with a system instruction, a prompt built with the CRAFT parts (Context, Role, Action, Tone, Format), `temperature=0`, `response_mime_type` set to JSON, and a JSON response schema with four fields: `root_cause` (a plain string — do **not** make it an enum; the allowed values go in your prompt and are enforced afterwards by the check in Task 4.2), `confidence` (0–1), `summary` (at most 25 words), `recommended_action`. Set the thinking level to minimal as shown in Session 22.1, and give `max_output_tokens` plenty of room (1000 or more): on some models hidden reasoning tokens count against the limit and can cut the JSON off, which makes `json.loads` fail. Run it on note **N001** and print the parsed dictionary. Shape of the call (follow your Session 22.1 notebook if any detail differs; the key is typed at run time):

```python
!pip install -q google-genai pydantic
from google import genai
from google.genai import types
SCHEMA = {   # same idea as the name / age / city example in class: properties, their types, and required
    "type": "object",
    "properties": {"root_cause": {"type": "string"}, "confidence": {"type": "number"},
                   "summary": {"type": "string"}, "recommended_action": {"type": "string"}},
    "required": ["root_cause", "confidence", "summary", "recommended_action"]}
API_KEY = input("Paste your key: ")
client = genai.Client(api_key=API_KEY)
response = client.models.generate_content(
    model=MODEL_NAME,                      # the Flash model from Session 22.1
    contents=prompt,
    config=types.GenerateContentConfig(system_instruction=SYSTEM_TEXT, temperature=0,
        max_output_tokens=1000, response_mime_type="application/json", response_schema=SCHEMA,
        thinking_config=types.ThinkingConfig(thinking_level="minimal")))   # as in Session 22.1; if your model rejects it, delete this line
data = json.loads(response.text)
```

### [](https://assess.masaischool.com/test?token=tLShIMDUNojgkymFMWFzjejFGLaQVzkMJphKfWkkVfHBhwkhijjFkOcRYYhSRjgkKjcnQFsjgEKXJeHRIjFfjvWnLLFLMnAmzUQL#task-42--validate-and-process-the-10-notes-7-marks)

### Task 4.2 — Validate and process the 10 notes (7 marks)

(a) Define a Pydantic model `FollowupInsight(BaseModel)` with `root_cause: str = Field(min_length=3)`, `confidence: float = Field(ge=0, le=1)`, `summary: str = Field(min_length=5)`, `recommended_action: str = Field(min_length=5)`, and write a check that `root_cause` is in the allowed list. (b) Read `followup_notes.csv` with pandas and loop over the first 10 rows. **Input validation:** pandas reads a blank note as `NaN` (a float, which has no `.strip()`), so test `pd.isna(note_text)` _first_, then `str(note_text).strip() == ""`. If the note is missing, empty or only spaces, do **not** call the API — record `root_cause="other"`, `confidence=0.0`, `summary="No note recorded"`, `recommended_action="Re-call patient"` and `validation_status="skipped_blank"`. Otherwise call `analyse_note`, validate the result with the Pydantic model (as in class: pass the dictionary into the class, `FollowupInsight(**data)`) and the allowed-list check, and set `validation_status` to `"valid"` or `"invalid"` (never let one bad reply stop the loop: use `try/except`). (c) Pause between calls (`import time` then `time.sleep(13)`) to respect the free-tier rate limit. (d) Save `notes_analysed.csv` with columns `note_id, appointment_id, root_cause, confidence, summary, recommended_action, validation_status, raw_response`. **Keep every reply, including invalid ones, and never repair it:** put the model's reply exactly as returned (the JSON text) in `raw_response`, copy whichever fields it did contain, and leave a field empty if the reply lacked it (for a skipped blank note, `raw_response` is empty).

### [](https://assess.masaischool.com/test?token=tLShIMDUNojgkymFMWFzjejFGLaQVzkMJphKfWkkVfHBhwkhijjFkOcRYYhSRjgkKjcnQFsjgEKXJeHRIjFfjvWnLLFLMnAmzUQL#task-43--break-it-on-purpose-5-marks)

### Task 4.3 — Break it on purpose (5 marks)

(a) Feed the Pydantic model two deliberately bad replies and catch each with `try/except ValidationError` (`from pydantic import ValidationError`): one with `confidence = 1.7`, one missing `recommended_action`; print what each error says. (b) For notes **N007** (Hinglish) and **N009** (ambiguous), compare two prompts at `temperature=0`: V1 = just "Classify this note", V2 = your CRAFT prompt with the allowed values and the instruction to answer `other` rather than guess. Use the **same** schema and settings for both (root_cause as a plain string, JSON mode, `temperature=0`), so that the only difference is the prompt; then check each reply against the allowed list. Show the four results in a small table and say which prompt you would deploy. (c) Count and print the total number of API calls you used across Tasks 4.1–4.3 (about 14 on a first pass: 1 in 4.1, 9 in 4.2, 4 here; 12 if you reuse your 4.2 results for the V2 prompt).

### [](https://assess.masaischool.com/test?token=tLShIMDUNojgkymFMWFzjejFGLaQVzkMJphKfWkkVfHBhwkhijjFkOcRYYhSRjgkKjcnQFsjgEKXJeHRIjFfjvWnLLFLMnAmzUQL#task-44--recommendation-and-github-5-marks)

### Task 4.4 — Recommendation and GitHub (5 marks)

(a) _(3 marks)_ Merge `notes_analysed.csv` with `appointments_clean.csv` on `appointment_id` and cross-tabulate `root_cause` against `reminder_sent` (`pd.crosstab`). Write `README.md` with: a 4-line summary (one finding per Part, each with its number); a one-paragraph recommendation that answers the business question using **at least four numbers** from Parts 1–4; the model you chose and why (include AUC and the threshold); and **three limitations** (choose from: the 10 notes are an illustration and cannot show the real reasons clinic-wide; the cleaning statistics came from all rows before the split; the same patient can sit in both train and test; the split is random, not past-to-future; one train/test split; a threshold that really depends on call capacity; clinic-level sample sizes; the data are observational, so associations are not causes). (b) _(2 marks)_ Create the public GitHub repository, upload every file listed under _Submission_, confirm the key is nowhere in it, and paste the link at the top of the README.

### [](https://assess.masaischool.com/test?token=tLShIMDUNojgkymFMWFzjejFGLaQVzkMJphKfWkkVfHBhwkhijjFkOcRYYhSRjgkKjcnQFsjgEKXJeHRIjFfjvWnLLFLMnAmzUQL#acceptance-criteria-part-4)

### Acceptance criteria (Part 4)

GenAI output can vary run to run, so Part 4 is checked on structure and agreement, not on exact wording.

- 4.1: `analyse_note` returns a dictionary with exactly the four fields; for **N001** `root_cause` is `forgot_or_no_reminder`.
- 4.2: `notes_analysed.csv` has **10 rows** and 8 columns (the 7 listed plus `raw_response`); **N004 is blank** and appears with `validation_status = skipped_blank` and **no API call** (so 9 calls); every other row is `valid` or `invalid` (invalid rows are kept as they came back, not dropped or repaired); `confidence` is within 0–1 on every `valid` and `skipped_blank` row; an invalid row keeps the reply in `raw_response` and has empty cells for any field the reply lacked. Expected root causes (agreement on **at least 7 of the 9** non-blank notes is required):

|note|N001|N002|N003|N004|N005|N006|N007|N008|N009|N010|
|---|---|---|---|---|---|---|---|---|---|---|
|expected|forgot_or_no_reminder|distance_or_transport|cost_or_fee|other (blank)|illness_or_emergency|work_or_schedule|forgot_or_no_reminder|distance_or_transport|other|work_or_schedule|

- 4.3: the `confidence = 1.7` reply fails on the upper limit (reported as "less than or equal to 1" in Pydantic v2); the missing-field reply fails with a "missing"/"field required" error; both are caught without crashing. The V2 prompt returns an allowed `root_cause` for both N007 and N009. Your reported call count matches what your code actually did (expected 12–14) and is **below 25**.
- 4.4: the merged table has 10 rows. If your model matched the key above, **both** notes classed `forgot_or_no_reminder` (N001, N007) belong to appointments with `reminder_sent = No` (2 of 2); **5 of the 10** notes belong to appointments with `reminder_sent = No`. The README names at least four numbers that you can find in your own outputs and states three limitations. The repository is public.

---

## [](https://assess.masaischool.com/test?token=tLShIMDUNojgkymFMWFzjejFGLaQVzkMJphKfWkkVfHBhwkhijjFkOcRYYhSRjgkKjcnQFsjgEKXJeHRIjFfjvWnLLFLMnAmzUQL#submission)

## Submission

Submit **one link**: your public GitHub repository, containing at least: `01_ingest_clean.ipynb` (Tasks 1.1–1.6), `rejected_rows.json`, `appointments_clean.csv`, `clinics_enriched.csv`, `load_data.sql`, `02_queries.sql` (all Part 2 queries and the duplicate-key error text as a comment), `03_model.ipynb`, `test_risk_scores.csv`, `04_genai.ipynb` (with your key removed), `notes_analysed.csv`, `README.md`, and a `data/` folder holding the three original files. One link for the whole project — no separate links, and no screenshots, slides or videos.