-- 03_build_clean_table.sql
-- Builds the analysis table. Drops every row of any user who has more than one row
-- or any row where group and page disagree (per-protocol cleaning), and joins country.
-- Raw tables are left untouched.
-- Result: 286,690 rows, one per user (294,478 raw rows - 7,788 removed rows).

CREATE OR REPLACE TABLE `ab_test.clean_ab_data` AS
WITH per_user AS (
  SELECT
    user_id,
    COUNT(*) AS n_rows,
    COUNTIF((test_group = 'treatment') != (landing_page = 'new_page')) AS n_mismatch
  FROM `ab_test.raw_ab_data`
  GROUP BY user_id
)
SELECT
  r.user_id,
  r.event_ts,
  r.test_group,
  r.landing_page,
  r.converted,
  c.country
FROM `ab_test.raw_ab_data` r
JOIN per_user p USING (user_id)
LEFT JOIN `ab_test.raw_countries` c USING (user_id)
WHERE p.n_rows = 1
  AND p.n_mismatch = 0;
