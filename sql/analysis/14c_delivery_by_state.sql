SELECT
    customer_state AS state,
    COUNT(*) AS orders,
    ROUND(AVG(delivery_days), 1) AS avg_delivery_days,
    ROUND(100.0 * AVG(CASE WHEN is_late THEN 1.0 ELSE 0.0 END), 1) AS late_pct,
    ROUND(AVG(review_score), 2) AS avg_review_score
FROM delivered_orders
GROUP BY customer_state
HAVING COUNT(*) >= 300
ORDER BY late_pct DESC
