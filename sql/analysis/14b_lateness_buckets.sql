WITH bucketed AS (
    SELECT
        *,
        CASE
            WHEN days_vs_estimate <= -8 THEN '1. 8+ days early'
            WHEN days_vs_estimate BETWEEN -7 AND -1 THEN '2. 1-7 days early'
            WHEN days_vs_estimate = 0 THEN '3. On the estimated day'
            WHEN days_vs_estimate BETWEEN 1 AND 3 THEN '4. 1-3 days late'
            WHEN days_vs_estimate BETWEEN 4 AND 7 THEN '5. 4-7 days late'
            ELSE '6. 8+ days late'
        END AS bucket
    FROM delivered_orders
    WHERE review_score IS NOT NULL
)
SELECT
    bucket,
    COUNT(*) AS orders,
    ROUND(AVG(review_score), 2) AS avg_review_score,
    ROUND(100.0 * AVG(CASE WHEN review_score = 1 THEN 1.0 ELSE 0.0 END), 1) AS one_star_pct
FROM bucketed
GROUP BY bucket
ORDER BY bucket
