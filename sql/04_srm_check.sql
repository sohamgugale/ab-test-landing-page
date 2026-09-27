-- 04_srm_check.sql
-- Sample ratio mismatch (SRM) check against the intended 50/50 split,
-- plus a check that the country join covered every user.
-- The p-value is computed in the notebook (scipy.stats.chisquare); alarm threshold p < 0.001.
-- Result:
--   raw (rows)     147,202 / 147,276  control share 0.49987  chi2 = 0.0186
--   clean (users)  143,293 / 143,397  control share 0.49982  chi2 = 0.0377  (p = 0.846) -> pass
--   missing country after join: 0 of 286,690 users

WITH counts AS (
  SELECT 'raw (rows)' AS stage,
         COUNTIF(test_group = 'control')   AS n_control,
         COUNTIF(test_group = 'treatment') AS n_treatment
  FROM `ab_test.raw_ab_data`
  UNION ALL
  SELECT 'clean (users)',
         COUNTIF(test_group = 'control'),
         COUNTIF(test_group = 'treatment')
  FROM `ab_test.clean_ab_data`
)
SELECT
  stage,
  n_control,
  n_treatment,
  n_control + n_treatment                               AS n_total,
  ROUND(n_control / (n_control + n_treatment), 5)       AS control_share,
  POW(n_control   - (n_control + n_treatment) / 2, 2) / ((n_control + n_treatment) / 2)
+ POW(n_treatment - (n_control + n_treatment) / 2, 2) / ((n_control + n_treatment) / 2)
                                                        AS chi2_stat
FROM counts;

SELECT
  COUNT(*)                  AS n_users,
  COUNTIF(country IS NULL)  AS missing_country
FROM `ab_test.clean_ab_data`;
