-- Flight data analysis (PostgreSQL)
-- Tables: airports(airport_code, name, country, continent)
--         routes(route_id, airport_start, airport_destination, route_distance)
--         flights(year, month, route, carrier_type, nb_flights, nb_seats, total_nb_passengers)

-- 1. Shortest route starting at Hamburg (HAM)
SELECT route_id, airport_destination, route_distance
FROM routes
WHERE airport_start = 'HAM'
ORDER BY route_distance ASC
LIMIT 1;

-- 2. Destination of that shortest route
SELECT dest.name AS destination, r.route_distance
FROM routes r
JOIN airports dest ON dest.airport_code = r.airport_destination
WHERE r.airport_start = 'HAM'
ORDER BY r.route_distance ASC
LIMIT 1;

-- 3. Direct flights from Hamburg to Africa (found by airport name, not code).
--    Joining flights ensures the route was actually flown, not just listed.
SELECT DISTINCT
    dest.name AS destination,
    dest.country
FROM routes r
JOIN airports origin ON origin.airport_code = r.airport_start
JOIN airports dest   ON dest.airport_code   = r.airport_destination
JOIN flights f       ON f.route = r.route_id
WHERE origin.name = 'Hamburg'
  AND dest.continent = 'Afrika'
  AND f.nb_flights > 0
ORDER BY dest.country, dest.name;

-- 4. Passengers HAM -> BRU in 2024
SELECT SUM(f.total_nb_passengers) AS total_passengers
FROM flights f
JOIN routes r ON r.route_id = f.route
WHERE r.airport_start = 'HAM'
  AND r.airport_destination = 'BRU'
  AND f.year = 2024;

-- 5. Seats offered HAM -> BRU in 2024
--    nb_seats is seats per aircraft type, so multiply by number of flights.
SELECT SUM(f.nb_seats * f.nb_flights) AS seats_offered
FROM flights f
JOIN routes r ON r.route_id = f.route
WHERE r.airport_start = 'HAM'
  AND r.airport_destination = 'BRU'
  AND f.year = 2024;

-- 6. Load factor (% of seats occupied) HAM -> BRU in 2024
SELECT ROUND(
           SUM(f.total_nb_passengers) * 100.0 / SUM(f.nb_seats * f.nb_flights),
           1
       ) AS occupied_percent
FROM flights f
JOIN routes r ON r.route_id = f.route
WHERE r.airport_start = 'HAM'
  AND r.airport_destination = 'BRU'
  AND f.year = 2024;

-- 7. Shortest connection HAM -> Cape Town (CPT) with 2 or 3 flights.
--    Both variants are combined so the overall shortest is returned, and
--    airports are not visited twice (no loops such as HAM > CPT > Y > CPT).
WITH two_flights AS (
    SELECT
        r1.airport_start || ' > ' || r1.airport_destination || ' > ' || r2.airport_destination AS path,
        r1.route_distance + r2.route_distance AS total_distance
    FROM routes r1
    JOIN routes r2 ON r2.airport_start = r1.airport_destination
    WHERE r1.airport_start = 'HAM'
      AND r2.airport_destination = 'CPT'
),
three_flights AS (
    SELECT
        r1.airport_start || ' > ' || r1.airport_destination || ' > '
            || r2.airport_destination || ' > ' || r3.airport_destination AS path,
        r1.route_distance + r2.route_distance + r3.route_distance AS total_distance
    FROM routes r1
    JOIN routes r2 ON r2.airport_start = r1.airport_destination
    JOIN routes r3 ON r3.airport_start = r2.airport_destination
    WHERE r1.airport_start = 'HAM'
      AND r3.airport_destination = 'CPT'
      AND r1.airport_destination NOT IN ('HAM', 'CPT')
      AND r2.airport_destination NOT IN ('HAM', 'CPT')
      AND r1.airport_destination <> r2.airport_destination
)
SELECT path, total_distance
FROM (
    SELECT * FROM two_flights
    UNION ALL
    SELECT * FROM three_flights
) AS connections
ORDER BY total_distance ASC
LIMIT 1;