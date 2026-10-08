/*
====================================================================
PROJECT: Steam Market Analysis (Pricing, Reviews & Engagement)
DATABASE: PostgreSQL
DATASET: Steam Store Games (27,000+ titles)
AUTHOR: qrstxlx
====================================================================
*/

-- =================================================================
-- 1. TOP-RATED GAMES (FILTERING OUT NOISE & LOW REVIEW COUNTS)
-- Question: Which games are truly loved by the community?
-- Criteria: Minimum 10,000 total user reviews to filter out low-sample bias.
-- =================================================================

SELECT 
    name,
    price,
    positive_ratings,
    negative_ratings,
    (positive_ratings + negative_ratings) AS total_reviews,
    ROUND(
        (positive_ratings::numeric / (positive_ratings + negative_ratings)) * 100, 
        2
    ) AS approval_rate_pct
FROM steam_games
WHERE (positive_ratings + negative_ratings) >= 10000
ORDER BY approval_rate_pct DESC
LIMIT 10;


-- =================================================================
-- 2. PRICE TIER ANALYSIS (PLAYTIME & APPROVAL BY PRICE CATEGORY)
-- Question: Does price affect user engagement and satisfaction?
-- Tiers: Free-to-Play, Budget ($0.01-$10), Mid-range ($10.01-$30), AAA (>$30)
-- =================================================================

WITH categorized_games AS (
    SELECT 
        name,
        price,
        average_playtime,
        ROUND(
            (positive_ratings::numeric / NULLIF(positive_ratings + negative_ratings, 0)) * 100, 
            2
        ) AS approval_pct,
        CASE 
            WHEN price = 0 THEN 'Free-to-Play'
            WHEN price <= 10.00 THEN 'Budget ($0.01 - $10)'
            WHEN price <= 30.00 THEN 'Mid-range ($10.01 - $30)'
            ELSE 'Premium / AAA (>$30)'
        END AS price_tier
    FROM steam_games
    WHERE (positive_ratings + negative_ratings) > 0
)
SELECT 
    price_tier,
    COUNT(*) AS total_games,
    ROUND(AVG(average_playtime)::numeric, 1) AS avg_playtime_minutes,
    ROUND(AVG(approval_pct)::numeric, 2) AS avg_approval_pct
FROM categorized_games
GROUP BY price_tier
ORDER BY avg_playtime_minutes DESC;


-- =================================================================
-- 3. GENRE PLAYTIME LEADERS (TOP 3 TITLES PER GENRE)
-- Question: Which titles dominate each major genre by average playtime?
-- Technique: String unnesting & window ranking (DENSE_RANK)
-- =================================================================

WITH unnested_genres AS (
    -- Unnest semicolon-separated genre strings into individual rows
    SELECT 
        name,
        average_playtime,
        TRIM(genre) AS single_genre
    FROM steam_games,
    UNNEST(string_to_array(genres, ';')) AS genre
),
ranked_games AS (
    SELECT 
        single_genre,
        name,
        average_playtime,
        DENSE_RANK() OVER (
            PARTITION BY single_genre 
            ORDER BY average_playtime DESC
        ) AS rank_in_genre
    FROM unnested_genres
    WHERE single_genre IN ('Action', 'Indie', 'RPG', 'Simulation', 'Strategy')
      AND average_playtime > 0
)
SELECT 
    single_genre,
    rank_in_genre,
    name,
    average_playtime
FROM ranked_games
WHERE rank_in_genre <= 3
ORDER BY single_genre, rank_in_genre;