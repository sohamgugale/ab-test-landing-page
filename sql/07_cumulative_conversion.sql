-- 07_cumulative_conversion.sql
-- Running conversion rate per group by day, using window functions.
-- Used to check whether the effect stabilized over time. Not used for decision-making
-- (checking a p-value daily and stopping early inflates false positives).
-- Result: the gap is noisy early (-0.66 pp on Jan 2), briefly positive on Jan 10-12,
--   then stays between -0.09 and -0.15 pp from Jan 15 onward, ending at -0.145 pp.

WITH daily AS (
  SELECT DATE(event_ts) AS day, test_group,
         COUNT(*) AS users, SUM(converted) AS conversions
  FROM `ab_test.clean_ab_data`
  GROUP BY day, test_group
),
cumulative AS (
  SELECT
    day, test_group,
    SUM(users)       OVER w AS cum_users,
    SUM(conversions) OVER w AS cum_conversions
  FROM daily
  WINDOW w AS (PARTITION BY test_group ORDER BY day
               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
)
SELECT
  day,
  MAX(IF(test_group = 'control',   cum_users, NULL))                              AS cum_users_control,
  MAX(IF(test_group = 'treatment', cum_users, NULL))                              AS cum_users_treatment,
  ROUND(MAX(IF(test_group = 'control',   cum_conversions / cum_users, NULL)), 5)  AS cum_cr_control,
  ROUND(MAX(IF(test_group = 'treatment', cum_conversions / cum_users, NULL)), 5)  AS cum_cr_treatment,
  ROUND(MAX(IF(test_group = 'treatment', cum_conversions / cum_users, NULL))
      - MAX(IF(test_group = 'control',   cum_conversions / cum_users, NULL)), 5)  AS cum_diff
FROM cumulative
GROUP BY day
ORDER BY day;
