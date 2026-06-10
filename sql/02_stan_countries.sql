CREATE TABLE stan_countries AS
-- giving each contestant a unique id
WITH contestant_ranked AS (
    SELECT
        country,
        DENSE_RANK() OVER ( -- DENSE_RANK means no ranking gaps: two rows tie at 2, next rank is 3
            ORDER BY
            year, 
            COALESCE(semifinal_number, 2147483647), -- NULLS get this large number (max 32 bit integer)
            COALESCE(semifinal_running_order, 2147483647),
            COALESCE(final_running_order, 2147483647)
        ) AS contestant
    FROM contestants
),
-- giving each country a unique id (by the first time they showed up in eurovision)
first_appearance AS (
    SELECT
        country,
        MIN(contestant) AS first_contestant
    FROM contestant_ranked
    GROUP BY country
)
SELECT
    DENSE_RANK() OVER (ORDER BY f.first_contestant) AS stan_country,
    f.country,
    co.country_name,
    co.region
FROM first_appearance f
INNER JOIN countries co ON f.country = co.country
ORDER BY stan_country;
