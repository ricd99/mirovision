CREATE TABLE stan_shows AS
SELECT
    DENSE_RANK() OVER (
        ORDER BY
            year,
            CASE round
                WHEN 'semi-final' THEN 1
                WHEN 'semi-final-1' THEN 2
                WHEN 'semi-final-2' THEN 3
                WHEN 'final' THEN 4
            END
    ) AS stan_show,
    year,
    round

FROM (
    SELECT DISTINCT year, round
    FROM votes
    WHERE year >= 1975
) AS distinct_shows
ORDER BY stan_show;