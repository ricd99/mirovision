CREATE TABLE stan_contestants AS
SELECT
    DENSE_RANK() OVER (
        ORDER BY
            year,
            COALESCE(semifinal_number, 2147483647),
            COALESCE(semifinal_running_order, 2147483647),
            COALESCE(final_running_order, 2147483647)
    ) AS stan_contestant,
    year,
    country,
    performer AS artist,
    song AS title,
    composers,
    lyricists,
    lyrics,
    youtube_url
FROM contestants
WHERE year >= 1975
and year != 2020
ORDER BY stan_contestant