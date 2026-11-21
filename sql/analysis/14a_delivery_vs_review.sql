SELECT
    CASE WHEN is_late THEN 'Late' ELSE 'On time or early' END AS delivery_outcome,
    COUNT(*) AS orders,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS orders_pct,
    ROUND(AVG(delivery_days), 1) AS avg_delivery_days,
    ROUND(AVG(review_score), 2) AS avg_review_score,
    ROUND(100.0 * AVG(CASE WHEN review_score = 1 THEN 1.0 ELSE 0.0 END), 1) AS one_star_pct,
    ROUND(100.0 * AVG(CASE WHEN review_score = 5 THEN 1.0 ELSE 0.0 END), 1) AS five_star_pct
FROM delivered_orders
WHERE review_score IS NOT NULL
GROUP BY is_late
ORDER BY is_late
