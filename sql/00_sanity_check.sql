-- 00_sanity_check.sql
-- First look at the raw tables after loading them into BigQuery.
-- Result (raw_ab_data): 294,478 rows, 290,584 unique users, 0 rows with nulls,
--   147,202 control rows / 147,276 treatment rows,
--   first event 2017-01-02 13:42:05 UTC, last event 2017-01-24 13:41:54 UTC.
-- Result (raw_countries): 290,584 rows, 290,584 unique users (one row per user).

SELECT
  COUNT(*)                                   AS total_rows,
  COUNT(DISTINCT user_id)                    AS unique_users,
  MIN(event_ts)                              AS first_ts,
  MAX(event_ts)                              AS last_ts,
  COUNTIF(test_group = 'control')            AS control_rows,
  COUNTIF(test_group = 'treatment')          AS treatment_rows,
  COUNTIF(user_id IS NULL OR event_ts IS NULL
          OR test_group IS NULL OR landing_page IS NULL
          OR converted IS NULL)              AS rows_with_nulls
FROM `ab_test.raw_ab_data`;

SELECT
  COUNT(*)                AS total_rows,
  COUNT(DISTINCT user_id) AS unique_users
FROM `ab_test.raw_countries`;
