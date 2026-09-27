-- 02_exclusion_breakdown.sql
-- Labels every user as clean, duplicate, mismatched, or both, split by assigned group.
-- Note: n_users counts a user once per group, so users logged in both groups appear in both rows.
-- Result:
--   clean                 control    143,293 rows / 143,293 users
--   clean                 treatment  143,397 rows / 143,397 users
--   duplicate + mismatch  control      3,909 rows /   2,902 users
--   duplicate + mismatch  treatment    3,877 rows /   2,886 users
--   duplicate only        treatment        2 rows /       1 user
-- No "mismatch only" users: every mismatched row belongs to a user with two rows.
-- Excluded rows are balanced across groups (3,909 control vs 3,879 treatment).

WITH per_user AS (
  SELECT
    user_id,
    COUNT(*) AS n_rows,
    COUNTIF((test_group = 'treatment') != (landing_page = 'new_page')) AS n_mismatch
  FROM `ab_test.raw_ab_data`
  GROUP BY user_id
),
labeled AS (
  SELECT
    r.test_group,
    r.user_id,
    CASE
      WHEN p.n_rows > 1 AND p.n_mismatch > 0 THEN 'duplicate + mismatch'
      WHEN p.n_rows > 1                      THEN 'duplicate only'
      WHEN p.n_mismatch > 0                  THEN 'mismatch only'
      ELSE 'clean'
    END AS status
  FROM `ab_test.raw_ab_data` r
  JOIN per_user p USING (user_id)
)
SELECT status, test_group,
       COUNT(*)                AS n_rows,
       COUNT(DISTINCT user_id) AS n_users
FROM labeled
GROUP BY status, test_group
ORDER BY status, test_group;
