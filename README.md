# CareLoop Clinics — No-Show Guard

**Repository:** https://github.com/Akul-Kaushal/Capstone_Analytics

**Business question:** Which appointments are most likely to be missed, why do patients miss them, and what should CareLoop do first?

## Summary — one finding per Part

1. **Data (Part 1):** 1,020 raw bookings cleaned to **990** (20 duplicates, 6 unreadable dates and 4 blank statuses removed). **218** are no-shows, an overall rate of **22.0%**.
2. **SQL (Part 2):** no-shows climb with lead time, from **16.2%** for bookings made 1–7 days ahead to **60.5%** for bookings made 31+ days ahead. Hadapsar Care Centre has the highest rate among clinics with at least 95 appointments (**27.3%**).
3. **Model (Part 3):** logistic regression flags **49 of 198** test appointments at threshold 0.35 and catches **57%** of the real no-shows (recall 0.571, ROC-AUC **0.789**). Bookings with a reminder have about **69% lower odds** of a no-show in this model.
4. **GenAI (Part 4):** both notes classed `forgot_or_no_reminder` (N001, N007) are on appointments with **no reminder sent (2 of 2)**. Overall, 5 of the 10 notes are on appointments without a reminder.

## Recommendation

CareLoop should first **make sure every booking gets a reminder**, then **phone the patients the model flags** the evening before. In this data, 22.0% of the 990 appointments were missed. The risk climbs from 16.2% for bookings made within a week to 60.5% for bookings made more than 30 days ahead. In the model, holding the other features constant, a reminder goes with about 69% lower odds of a no-show. The two call-centre notes that blamed forgetting both came from appointments with no reminder (2 of 2). At a threshold of 0.35, the model asks the front desk to call 49 of 198 test-set patients and catches 57% of the real no-shows (28 of 49). Long-lead bookings and patients with earlier no-shows should be checked first. These are associations from observational data, so a small reminder trial would confirm the effect before CareLoop changes its policy.

## Model choice

**Logistic regression**, with scaling inside a `Pipeline`, at a **threshold of 0.35**.

- **Why this model:** it had the highest 5-fold cross-validated ROC-AUC on the training set (**0.774**). The others scored lower: tuned random forest 0.767 (`max_depth=3, n_estimators=200`), random forest 0.747, depth-3 tree 0.678. Logistic regression is also easy to explain to the front desk.
- **Why 0.35:** the threshold was chosen from out-of-fold training probabilities. F1 was **0.489** at 0.35 against 0.347 at 0.5, and recall nearly doubled (0.467 vs 0.249). Recall matters here because a missed warning costs an empty slot, while an extra call costs about a minute.
- **Test set:** used only once, for reporting: precision 0.571, recall 0.571, ROC-AUC **0.789**, 49 flagged.

## Limitations

1. **The 10 notes are only an illustration.** They cannot show the real reasons patients miss appointments across all clinics.
2. **The cleaning statistics were computed before the split.** The medians, quartiles and outlier fences in Part 1 came from all 990 rows, so the test rows had a small indirect influence on the cleaning. In a real system these would be calculated on the training rows only.
3. **The split is random, not past-to-future.** The same patient can also appear in both train and test, so the test score may be slightly optimistic for truly new bookings.
4. **The data are observational.** The reminder effect is an association, not proof that reminders cause fewer no-shows.

## Files

| Part | Files |
|---|---|
| Data | `data/appointments.csv`, `data/clinics.csv`, `data/followup_notes.csv` (originals, unedited) |
| 1 | `Working with init Data/01_ingest_clean.ipynb` → `rejected_rows.json`, `appointments_clean.csv`, `clinics_enriched.csv`, `data warehouse/load_data.sql` |
| 2 | `data warehouse/02_queries.sql` (with the duplicate-key error as a comment), `data warehouse/02_pandas_crosscheck.ipynb` |
| 3 | `date processing/03_model.ipynb` → `test_risk_scores.csv` |
| 4 | `llm/04_genai.ipynb` → `notes_analysed.csv` |

**Reproduce:** run the notebooks in order 01 → 04. Run `02_queries.sql` in MySQL 8: create the tables first, then run `load_data.sql`. Part 4 asks for a free Gemini API key at run time. The key is not stored anywhere in this repository.
