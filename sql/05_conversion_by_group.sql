-- 05_conversion_by_group.sql
-- Conversion rate by group on the clean table.
-- Result:
--   control    143,293 users  17,220 conversions  12.017%
--   treatment  143,397 users  17,025 conversions  11.873%

SELECT
  test_group,
  COUNT(*)                 AS users,
  SUM(converted)           AS conversions,
  ROUND(AVG(converted), 5) AS conversion_rate
FROM `ab_test.clean_ab_data`
GROUP BY test_group
ORDER BY test_group;
