CREATE TABLE stan_ballots AS

SELECT
    stan_ballot,
    stan_show,
    year,
    round,
    stan_from_country,
    from_country,
    type,
    COUNT(*) AS n_alternatives,
    SUM(CASE WHEN points > 0 THEN 1 ELSE 0 END) AS n_ranked
FROM stan_points
GROUP BY
    stan_ballot,
    stan_show,
    year,
    round,
    stan_from_country,
    from_country,
    type
ORDER BY stan_ballot