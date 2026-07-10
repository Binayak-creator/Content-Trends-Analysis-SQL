-- ==========================================================
-- CONTENT TRENDS ANALYSIS USING SQL
-- Author: Binayak Deb
-- Database: content_trends
-- Description:
-- Analyzing Netflix content trends using SQL to uncover
-- production patterns, content distribution, ratings,
-- release trends, and advanced analytical insights.
-- ==========================================================

USE content_trends;

-- ==========================================================
-- SECTION 1 : DATA EXPLORATION
-- ==========================================================

-- 1. Total number of records
SELECT COUNT(*) AS total_records
FROM netflix;

-- 2. Preview the dataset
SELECT *
FROM netflix
LIMIT 10;

-- 3. Display table structure
DESCRIBE netflix;

-- 4. Check for duplicate Show IDs
SELECT
    show_id,
    COUNT(*) AS duplicate_count
FROM netflix
GROUP BY show_id
HAVING COUNT(*) > 1;

-- 5. Check for NULL values
SELECT
    SUM(show_id IS NULL) AS show_id_nulls,
    SUM(type IS NULL) AS type_nulls,
    SUM(title IS NULL) AS title_nulls,
    SUM(director IS NULL) AS director_nulls,
    SUM(cast IS NULL) AS cast_nulls,
    SUM(country IS NULL) AS country_nulls,
    SUM(date_added IS NULL) AS date_added_nulls,
    SUM(release_year IS NULL) AS release_year_nulls,
    SUM(rating IS NULL) AS rating_nulls,
    SUM(duration IS NULL) AS duration_nulls,
    SUM(listed_in IS NULL) AS listed_in_nulls
FROM netflix;

-- ==========================================================
-- SECTION 2 : CONTENT OVERVIEW
-- ==========================================================

-- 6. Total content available
SELECT COUNT(*) AS total_titles
FROM netflix;

-- 7. Movies vs TV Shows
SELECT
    type,
    COUNT(*) AS total_titles
FROM netflix
GROUP BY type
ORDER BY total_titles DESC;

-- 8. Percentage share of Movies and TV Shows
SELECT
    type,
    COUNT(*) AS total_titles,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM netflix),
        2
    ) AS percentage
FROM netflix
GROUP BY type;

-- 9. Titles released each year
SELECT
    release_year,
    COUNT(*) AS total_titles
FROM netflix
GROUP BY release_year
ORDER BY release_year;

-- 10. Content added to Netflix each year
SELECT
    YEAR(STR_TO_DATE(date_added,'%M %d, %Y')) AS added_year,
    COUNT(*) AS total_titles
FROM netflix
WHERE date_added IS NOT NULL
GROUP BY added_year
ORDER BY added_year;

-- ==========================================================
-- SECTION 3 : CONTENT INSIGHTS
-- ==========================================================

-- 11. Top 10 countries producing Netflix content
SELECT
    country,
    COUNT(*) AS total_titles
FROM netflix
WHERE country IS NOT NULL
GROUP BY country
ORDER BY total_titles DESC
LIMIT 10;

-- 12. Country ranking using Window Function
SELECT
    country,
    COUNT(*) AS total_titles,
    DENSE_RANK() OVER
    (
        ORDER BY COUNT(*) DESC
    ) AS country_rank
FROM netflix
WHERE country IS NOT NULL
GROUP BY country;

-- 13. Top 10 directors
SELECT
    director,
    COUNT(*) AS total_titles
FROM netflix
WHERE director IS NOT NULL
GROUP BY director
ORDER BY total_titles DESC
LIMIT 10;

-- 14. Most productive director
SELECT
    director,
    COUNT(*) AS total_titles
FROM netflix
WHERE director IS NOT NULL
GROUP BY director
ORDER BY total_titles DESC
LIMIT 1;

-- 15. Most common content ratings
SELECT
    rating,
    COUNT(*) AS total_titles
FROM netflix
GROUP BY rating
ORDER BY total_titles DESC;

-- ==========================================================
-- SECTION 4 : TIME-BASED ANALYSIS
-- ==========================================================

-- 16. Age of every title
SELECT
    title,
    release_year,
    YEAR(CURDATE()) - release_year AS content_age
FROM netflix
ORDER BY content_age DESC;

-- 17. Decade-wise distribution
SELECT
    CONCAT(FLOOR(release_year/10)*10,'s') AS decade,
    COUNT(*) AS total_titles
FROM netflix
GROUP BY decade
ORDER BY decade;

-- 18. Categorize content into Classic, Modern and Recent
SELECT
    title,
    release_year,
    CASE
        WHEN release_year >= 2020 THEN 'Recent'
        WHEN release_year >= 2010 THEN 'Modern'
        ELSE 'Classic'
    END AS category
FROM netflix;

-- ==========================================================
-- SECTION 5 : DURATION ANALYSIS
-- ==========================================================

-- 19. Longest Movie
SELECT
    title,
    duration
FROM netflix
WHERE type='Movie'
ORDER BY CAST(REPLACE(duration,' min','') AS UNSIGNED) DESC
LIMIT 1;

-- 20. Shortest Movie
SELECT
    title,
    duration
FROM netflix
WHERE type='Movie'
ORDER BY CAST(REPLACE(duration,' min','') AS UNSIGNED)
LIMIT 1;

-- ==========================================================
-- SECTION 6 : ADVANCED SQL
-- ==========================================================

-- 21. Titles released after the average release year
SELECT
    title,
    release_year
FROM netflix
WHERE release_year >
(
    SELECT AVG(release_year)
    FROM netflix
);

-- 22. Years producing above-average content
WITH yearly AS
(
    SELECT
        release_year,
        COUNT(*) AS total_titles
    FROM netflix
    GROUP BY release_year
)

SELECT *
FROM yearly
WHERE total_titles >
(
    SELECT AVG(total_titles)
    FROM yearly
);

-- 23. Running total of releases
SELECT
    release_year,
    COUNT(*) AS yearly_total,
    SUM(COUNT(*))
    OVER
    (
        ORDER BY release_year
    ) AS cumulative_titles
FROM netflix
GROUP BY release_year;

-- 24. Rank release years by number of titles
WITH yearly AS
(
    SELECT
        release_year,
        COUNT(*) AS total_titles
    FROM netflix
    GROUP BY release_year
)

SELECT
    release_year,
    total_titles,
    RANK() OVER
    (
        ORDER BY total_titles DESC
    ) AS release_rank
FROM yearly;

-- 25. Year-over-Year comparison using LAG()
WITH yearly AS
(
    SELECT
        release_year,
        COUNT(*) AS total_titles
    FROM netflix
    GROUP BY release_year
)

SELECT
    release_year,
    total_titles,
    LAG(total_titles)
    OVER
    (
        ORDER BY release_year
    ) AS previous_year
FROM yearly;

-- 26. Most common rating within each content type
SELECT *
FROM
(
    SELECT
        type,
        rating,
        COUNT(*) AS total_titles,
        RANK() OVER
        (
            PARTITION BY type
            ORDER BY COUNT(*) DESC
        ) AS ranking
    FROM netflix
    GROUP BY type,rating
) ranked
WHERE ranking = 1;

-- ==========================================================
-- SECTION 7 : VIEWS
-- ==========================================================

-- 27. Create a reusable view for Movies
CREATE OR REPLACE VIEW movies_only AS
SELECT *
FROM netflix
WHERE type='Movie';

-- Preview Movies View
SELECT *
FROM movies_only
LIMIT 10;

-- 28. Executive summary view
CREATE OR REPLACE VIEW content_summary AS
SELECT
    type,
    rating,
    COUNT(*) AS total_titles
FROM netflix
GROUP BY type,rating;

-- Preview Summary View
SELECT *
FROM content_summary;

-- ==========================================================
-- END OF PROJECT
-- ==========================================================