-- 08_dashboard_cumulative.sql
-- Saves the cumulative conversion series as a table for the Looker Studio dashboard.
-- The other dashboard table, ab_test.dash_results (test results and CIs by segment),
-- is written from the notebook so the dashboard shows exactly the notebook's numbers.

CREATE OR REPLACE TABLE `ab_test.dash_cumulative` AS
WITH daily AS (
  SELECT DATE(event_ts) AS day, test_group,
         COUNT(*) AS users, SUM(converted) AS conversions
  FROM `ab_test.clean_ab_data`
  GROUP BY day, test_group
),
cumulative AS (
  SELECT day, test_group,
         SUM(users)       OVER w AS cum_users,
         SUM(conversions) OVER w AS cum_conversions
  FROM daily
  WINDOW w AS (PARTITION BY test_group ORDER BY day
               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
)
SELECT
  day,
  MAX(IF(test_group = 'control',   cum_conversions / cum_users, NULL)) AS cum_cr_control,
  MAX(IF(test_group = 'treatment', cum_conversions / cum_users, NULL)) AS cum_cr_treatment,
  MAX(IF(test_group = 'treatment', cum_conversions / cum_users, NULL))
- MAX(IF(test_group = 'control',   cum_conversions / cum_users, NULL)) AS cum_diff
FROM cumulative
GROUP BY day;
