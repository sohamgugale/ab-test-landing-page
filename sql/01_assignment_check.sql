-- 01_assignment_check.sql
-- Checks that each group saw the page it was assigned to, and that `converted` is binary.
-- Result: 3,893 mismatched rows (1,928 control rows on new_page, 1,965 treatment rows on old_page).
--         converted: 259,241 zeros and 35,237 ones; no other values.

SELECT test_group, landing_page, COUNT(*) AS n_rows
FROM `ab_test.raw_ab_data`
GROUP BY test_group, landing_page
ORDER BY test_group, landing_page;

SELECT converted, COUNT(*) AS n_rows
FROM `ab_test.raw_ab_data`
GROUP BY converted;
