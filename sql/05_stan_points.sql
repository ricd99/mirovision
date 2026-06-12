CREATE TABLE stan_points AS
WITH
-- step 1: filter and pivot votes into long format
votes_long AS (

    -- total points
    SELECT
        year, round, from_country, to_country,
        'total' AS type,
        total_points AS points
    from votes
    WHERE year >= 1975
    AND jury_points IS NULL -- use televoting + jury, not total, once they were published separately (2016 onwards)
    AND total_points IS NOT NULL

    UNION ALL

    -- televoting points (when available separately)
    SELECT
        year, round, from_country, to_country,
        'televoting' AS type,
        televoting_points AS points
    FROM votes
    WHERE year >= 1975
    AND jury_points IS NOT NULL
    AND televoting_points IS NOT NULL

    UNION ALL

    -- jury points (when available separately)
    SELECT 
        year, round, from_country, to_country,
        'jury' AS type,
        jury_points AS points
    FROM votes
    WHERE year >= 1975
    AND jury_points IS NOT NULL
),

-- step 2: add round ordering
votes_ordered AS (
    SELECT
        *,
        CASE round
            WHEN 'semi-final' THEN 1
            WHEN 'semi-final-1' THEN 2
            WHEN 'semi-final-2' THEN 3
            WHEN 'final' THEN 4
        END AS round_order
    FROM votes_long
)

-- step 3: join all stan tablse and create IDs
SELECT
    DENSE_RANK() OVER (
        ORDER BY
            v.year,
            v.round_order,
            v.type,
            sc_from.stan_country
    ) AS stan_ballot,
    ss.stan_show,
    v.year,
    v.round,
    sc_from.stan_country AS stan_from_country,
    v.from_country,
    v.type,
    scon.stan_contestant,
    sc_to.stan_country AS stan_to_country,
    v.to_country,
    v.points
FROM votes_ordered v
INNER JOIN stan_countries sc_from ON v.from_country = sc_from.country
INNER JOIN stan_countries sc_to ON v.to_country = sc_to.country
INNER JOIN stan_shows ss ON v.year = ss.year AND v.round = ss.round
INNER JOIN stan_contestants scon
    ON v.year = scon.year
    AND v.to_country = scon.country
ORDER BY stan_ballot, points DESC;