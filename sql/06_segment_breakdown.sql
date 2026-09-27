-- 06_segment_breakdown.sql
-- Conversion by group for every segment (country, weekday, UTC hour, day) in one long table.
-- treatment_share is a within-segment randomization check; share_of_users uses a window function.
-- Result: treatment_share stays between 0.49 and 0.51 in all 57 segments.
--   Country mix: US 70.07%, UK 24.94%, CA 4.99%.
--   Monday and Tuesday have more users because the window (Mon Jan 2 - Tue Jan 24, 2017)
--   contains four of each and three of every other weekday.
-- Notes: hours are UTC, not users' local time. Jan 2 and Jan 24 are partial days.

WITH base AS (
  SELECT
    test_group,
    converted,
    country,
    FORMAT_DATE('%Y-%m-%d', DATE(event_ts))     AS day,
    FORMAT_TIMESTAMP('%u-%a', event_ts)         AS weekday,   -- 1-Mon ... 7-Sun
    FORMAT('%02d', EXTRACT(HOUR FROM event_ts)) AS hour_utc
  FROM `ab_test.clean_ab_data`
),
long_format AS (
  SELECT 'country'  AS seg_type, country  AS seg_value, test_group, converted FROM base
  UNION ALL
  SELECT 'weekday',  weekday,  test_group, converted FROM base
  UNION ALL
  SELECT 'hour_utc', hour_utc, test_group, converted FROM base
  UNION ALL
  SELECT 'day',      day,      test_group, converted FROM base
),
wide AS (
  SELECT
    seg_type,
    seg_value,
    COUNTIF(test_group = 'control')                 AS n_control,
    COUNTIF(test_group = 'treatment')               AS n_treatment,
    SUM(IF(test_group = 'control',   converted, 0)) AS conv_control,
    SUM(IF(test_group = 'treatment', converted, 0)) AS conv_treatment
  FROM long_format
  GROUP BY seg_type, seg_value
)
SELECT
  seg_type,
  seg_value,
  n_control,
  n_treatment,
  ROUND(SAFE_DIVIDE(n_control + n_treatment,
        SUM(n_control + n_treatment) OVER (PARTITION BY seg_type)), 4) AS share_of_users,
  ROUND(SAFE_DIVIDE(n_treatment, n_control + n_treatment), 4)          AS treatment_share,
  ROUND(SAFE_DIVIDE(conv_control,   n_control),   5)                   AS cr_control,
  ROUND(SAFE_DIVIDE(conv_treatment, n_treatment), 5)                   AS cr_treatment,
  ROUND(SAFE_DIVIDE(conv_treatment, n_treatment)
      - SAFE_DIVIDE(conv_control,   n_control), 5)                     AS abs_diff
FROM wide
ORDER BY seg_type, seg_value;
