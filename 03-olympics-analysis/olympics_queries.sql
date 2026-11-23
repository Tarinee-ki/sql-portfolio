-- Olympic Games analysis (PostgreSQL)
-- Tables: sport_groups(sport_name, sport_group)
--         countries(country_code, country, area, landareakm, population_2022)
--         athletes(id, athlete_full_name, games_participations, first_game, athlete_year_birth)
--         olympic_games(game_id, game_location, game_name, game_season, game_year)
--         results(event_title, slug_game, athlete_id, discipline_title, participant_type,
--                 medal_type, rank_position, country_code)

-- 0. Which values does medal_type contain? (NULL, empty string, GOLD/SILVER/BRONZE?)
--    The filters below assume that real medals are neither NULL nor ''.
SELECT medal_type, COUNT(*) AS rows_count
FROM results
GROUP BY medal_type
ORDER BY rows_count DESC;

-- 1. Which athlete won the most medals?
--    Grouped by athlete id, because two athletes can share the same name.
--    WITH TIES keeps all athletes if several share the top count (PostgreSQL 13+).
SELECT a.id, a.athlete_full_name, COUNT(*) AS medal_count
FROM results r
JOIN athletes a ON a.id = r.athlete_id
WHERE r.medal_type IS NOT NULL
  AND r.medal_type <> ''
GROUP BY a.id, a.athlete_full_name
ORDER BY medal_count DESC
FETCH FIRST 1 ROWS WITH TIES;

-- 2. Which country won the most medals in each edition (2000-2022)?
--    A team medal is counted once per country: the results table has one row
--    per athlete, so DISTINCT collapses team members into one medal.
WITH medal_awards AS (
    SELECT DISTINCT slug_game, event_title, medal_type, country_code
    FROM results
    WHERE medal_type IS NOT NULL
      AND medal_type <> ''
),
country_medals AS (
    SELECT
        g.game_year,
        g.game_season,
        m.country_code,
        COUNT(*) AS medals
    FROM medal_awards m
    JOIN olympic_games g ON g.game_id = m.slug_game
    WHERE g.game_year BETWEEN 2000 AND 2022
    GROUP BY g.game_year, g.game_season, m.country_code
),
ranked AS (
    SELECT
        game_year,
        game_season,
        country_code,
        medals,
        RANK() OVER (PARTITION BY game_year, game_season ORDER BY medals DESC) AS rnk
    FROM country_medals
)
SELECT
    r.game_year,
    r.game_season,
    c.country,
    r.medals
FROM ranked r
LEFT JOIN countries c ON c.country_code = r.country_code
WHERE r.rnk = 1
ORDER BY r.game_year, r.game_season;

-- 3. Which disciplines produced the most medals overall (top 10)?
WITH medal_awards AS (
    SELECT DISTINCT slug_game, event_title, discipline_title, medal_type, country_code
    FROM results
    WHERE medal_type IS NOT NULL
      AND medal_type <> ''
)
SELECT discipline_title, COUNT(*) AS medals
FROM medal_awards
GROUP BY discipline_title
ORDER BY medals DESC
LIMIT 10;

-- 4. Data quality: medals awarded per edition.
--    Editions should be in a similar range; a very low or high count
--    points to incomplete or duplicated data.
WITH medal_awards AS (
    SELECT DISTINCT slug_game, event_title, medal_type, country_code
    FROM results
    WHERE medal_type IS NOT NULL
      AND medal_type <> ''
)
SELECT g.game_year, g.game_season, COUNT(*) AS medal_awards
FROM medal_awards m
JOIN olympic_games g ON g.game_id = m.slug_game
GROUP BY g.game_year, g.game_season
ORDER BY g.game_year, g.game_season;

-- 5a. Data quality: events that do not have exactly 3 medal types.
--     Expected exceptions: events with ties, and combat sports with two bronze
--     medals (these still show 3 types). Anything with 1, 2 or 4+ types
--     deserves a closer look.
SELECT
    g.game_year,
    r.event_title,
    COUNT(DISTINCT r.medal_type) AS medal_types
FROM results r
JOIN olympic_games g ON g.game_id = r.slug_game
WHERE r.medal_type IS NOT NULL
  AND r.medal_type <> ''
GROUP BY g.game_year, r.slug_game, r.event_title
HAVING COUNT(DISTINCT r.medal_type) <> 3
ORDER BY g.game_year, r.event_title;

-- 5b. Data quality: events that appear in results but have no medal at all.
--     (Empty if the table only contains medalists.)
SELECT g.game_year, r.event_title
FROM results r
JOIN olympic_games g ON g.game_id = r.slug_game
GROUP BY g.game_year, r.slug_game, r.event_title
HAVING COUNT(*) FILTER (WHERE r.medal_type IS NOT NULL AND r.medal_type <> '') = 0
ORDER BY g.game_year, r.event_title;

-- 6. Data quality: referential integrity of results.athlete_id.
--    LEFT JOIN is used instead of NOT IN, which breaks when NULLs are present.
SELECT 'athlete_id not found in athletes' AS check_name, COUNT(*) AS affected_rows
FROM results r
LEFT JOIN athletes a ON a.id = r.athlete_id
WHERE r.athlete_id IS NOT NULL
  AND a.id IS NULL
UNION ALL
SELECT 'athlete_id is NULL', COUNT(*)
FROM results
WHERE athlete_id IS NULL;
