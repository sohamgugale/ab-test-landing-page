-- 02b_verify_dirty_users.sql
-- Confirms how many rows each repeated user has and whether they were logged in both groups.
-- Result: every repeated user has exactly 2 rows.
--   1,895 users logged in both control and treatment
--   1,999 users with 2 rows in a single group
--   3,894 repeated users in total

WITH per_user AS (
  SELECT user_id,
         COUNT(*)                   AS n_rows,
         COUNT(DISTINCT test_group) AS n_groups
  FROM `ab_test.raw_ab_data`
  GROUP BY user_id
)
SELECT n_rows, n_groups, COUNT(*) AS n_users
FROM per_user
WHERE n_rows > 1
GROUP BY n_rows, n_groups
ORDER BY n_rows, n_groups;
