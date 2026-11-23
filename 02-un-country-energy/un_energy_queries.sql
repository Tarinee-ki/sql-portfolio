-- UN country and energy data analysis (PostgreSQL)
-- Tables: country(area_name, series, year, value, ...)
--         energy(area_id, area_name, series, year, value, ...)
-- area_id = 1 is the world total in the energy table.

-- 1. Top 25 countries by population (2024)
--    Aggregate "Total" rows are excluded so only countries remain.
SELECT area_name, value AS population_in_millions
FROM country
WHERE series = 'Population mid-year estimates (millions)'
  AND year = 2024
  AND value IS NOT NULL
  AND area_name NOT LIKE 'Total%'
ORDER BY value DESC
LIMIT 25;

-- 2. Do all countries have a population value for 2024?
--    Lists countries that have no 2024 population value. Empty result = yes.
--    NOT EXISTS is used instead of NOT IN, because NOT IN returns nothing
--    as soon as the subquery contains a NULL.
SELECT DISTINCT c.area_name
FROM country c
WHERE c.area_name NOT LIKE 'Total%'
  AND NOT EXISTS (
      SELECT 1
      FROM country p
      WHERE p.area_name = c.area_name
        AND p.series = 'Population mid-year estimates (millions)'
        AND p.year = 2024
        AND p.value IS NOT NULL
  );

-- 3. Rank countries by population density (2024)
--    ROW_NUMBER: unique number, ties broken arbitrarily
--    RANK:       ties share a rank, the next rank is skipped (1, 1, 3)
--    DENSE_RANK: ties share a rank, no gap (1, 1, 2)
--    PostgreSQL sorts NULLs first in DESC order, so NULLs are filtered out.
SELECT
    area_name,
    value AS density,
    RANK()       OVER (ORDER BY value DESC) AS rank_val,
    DENSE_RANK() OVER (ORDER BY value DESC) AS dense_rank_val,
    ROW_NUMBER() OVER (ORDER BY value DESC) AS row_num_val
FROM country
WHERE series LIKE 'Population density%'
  AND year = 2024
  AND value IS NOT NULL
  AND area_name NOT LIKE 'Total%'
ORDER BY density DESC;

-- 4. Energy: do country values add up to the world value (area_id = 1)?
--    Per-capita and percentage series are excluded because averages
--    cannot be summed. Deviation up to 1 % counts as OK.
WITH country_sums AS (
    SELECT year, series, SUM(value) AS calculated_sum
    FROM energy
    WHERE area_id <> 1
      AND series NOT ILIKE '%per capita%'
      AND series NOT ILIKE '%percentage%'
    GROUP BY year, series
),
world AS (
    SELECT year, series, value AS reported_value
    FROM energy
    WHERE area_id = 1
),
compared AS (
    SELECT
        c.year,
        c.series,
        c.calculated_sum,
        w.reported_value,
        ABS(c.calculated_sum - w.reported_value) * 100.0
            / NULLIF(w.reported_value, 0) AS deviation_percent
    FROM country_sums c
    JOIN world w ON w.year = c.year AND w.series = c.series
)
SELECT
    year,
    series,
    calculated_sum,
    reported_value,
    ROUND(deviation_percent, 2) AS deviation_percent,
    CASE WHEN deviation_percent <= 1 THEN 'OK' ELSE 'CHECK' END AS status
FROM compared
ORDER BY deviation_percent DESC NULLS LAST;

-- 5. Missing data in the energy table
--    Build every combination of area x year x series and keep those
--    that have no row in the table.
--    5a. Summary: missing combinations per series
WITH missing AS (
    SELECT a.area_name, y.year, s.series
    FROM (SELECT DISTINCT area_id, area_name FROM energy) a
    CROSS JOIN (SELECT DISTINCT year FROM energy) y
    CROSS JOIN (SELECT DISTINCT series FROM energy) s
    WHERE NOT EXISTS (
        SELECT 1
        FROM energy e
        WHERE e.area_id = a.area_id
          AND e.year = y.year
          AND e.series = s.series
    )
)
SELECT series, COUNT(*) AS missing_combinations
FROM missing
GROUP BY series
ORDER BY missing_combinations DESC;

--    5b. Detail: the individual missing combinations
SELECT a.area_name, y.year, s.series
FROM (SELECT DISTINCT area_id, area_name FROM energy) a
CROSS JOIN (SELECT DISTINCT year FROM energy) y
CROSS JOIN (SELECT DISTINCT series FROM energy) s
WHERE NOT EXISTS (
    SELECT 1
    FROM energy e
    WHERE e.area_id = a.area_id
      AND e.year = y.year
      AND e.series = s.series
)
ORDER BY a.area_name, y.year, s.series;
