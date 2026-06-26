library(cmdstanr)
library(tidyverse)
library(DBI)
library(RPostgres)

# ── Step 1: Load the fit ──────────────────────────────────────────────────────
contest_fit <- readRDS("stan/contest-fit.rds")

# ── Step 2: Load data from DB ────────────────────────────────────────────
con <- dbConnect(
  RPostgres::Postgres(),
  host="localhost",
  port=5433,
  dbname="postgres",
  user="postgres",
  password="testpass123"
)

stan_contestants = dbGetQuery(con, "SELECT * FROM stan_contestants")
stan_countries = dbGetQuery(con, "SELECT * FROM stan_countries")
dbDisconnect(con)

# Fix datatypes
stan_contestants <- stan_contestants |>
    mutate(stan_contestant = as.integer(stan_contestant))
stan_countries <- stan_countries |>
    mutate(stan_country = as.integer(stan_country))   

# ── Step 3: Extract and convert beta_contestant to cantobels ─────────────────
beta_summary <- contest_fit$summary("beta_contestant") |>
    mutate(
        stan_contestant = row_number(),
        cantobel_median = 10 * median / log(10),
        cantobel_mean = 10 * mean / log(10),
        cantobel_sd = 10 * sd / log(10),
        cantobel_q5 = 10 * q5 / log(10),
        cantobel_q95 = 10 * q95 / log(10)
    ) |>
    select(stan_contestant, starts_with("cantobel"), rhat, ess_bulk)


# ── Step 4: Join to song metadata ────────────────────────────────────────────
song_cantobels <- stan_contestants |>
    arrange(stan_contestant) |>
    left_join(beta_summary, by="stan_contestant")

# ── Step 5: Sanity checks ─────────────────────────────────────────────────────

best_songs <- song_cantobels |>
    arrange(desc(cantobel_median)) |>
    select(year, country, cantobel_median, cantobel_sd) |>
    head(20)

worst_songs <- song_cantobels|>
    arrange(cantobel_median) |>
    select(year, country, cantobel_median, cantobel_sd) |>
    head(20)

top_countries <- song_cantobels |>
    group_by(country) |>
    summarise(median_cantobel = median(cantobel_median)) |>
    arrange(desc(median_cantobel)) |>
    head(10)

sd_cantobels <- sd(song_cantobels$cantobel_median)

top_songs <- song_cantobels |>
    filter(year >= 2018) |>
    group_by(year) |>
    slice_max(cantobel_median, n = 3) |>
    arrange(year, desc(cantobel_median)) |>
    select(year, country, cantobel_median)

distribution_plot <- song_cantobels |>
  ggplot(aes(cantobel_median)) +
  geom_histogram(bins = 40, fill = "#39D7B8", colour = "white") +
  geom_vline(xintercept = 0, linetype = "dashed") +
  labs(x = "Cantobels", y = "Count",
       title = "Distribution of Eurovision Song Competitiveness")

saveRDS(song_cantobels, "data/song_cantobels.rds")
write_csv(song_cantobels, "data/song_cantobels.csv")