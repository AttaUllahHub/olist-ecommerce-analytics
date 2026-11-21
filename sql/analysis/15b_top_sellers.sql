WITH seller_orders AS (
    SELECT
        i.seller_id,
        i.order_id,
        SUM(i.price) AS seller_revenue
    FROM order_items i
    JOIN delivered_orders d ON d.order_id = i.order_id
    GROUP BY 1, 2
)
SELECT
    s.seller_id,
    sl.state AS seller_state,
    COUNT(*) AS orders,
    ROUND(SUM(so.seller_revenue), 0) AS revenue,
    ROUND(AVG(d.review_score), 2) AS avg_review_score,
    ROUND(100.0 * AVG(CASE WHEN d.is_late THEN 1.0 ELSE 0.0 END), 1) AS late_pct
FROM seller_orders so
JOIN delivered_orders d ON d.order_id = so.order_id
JOIN sellers sl ON sl.seller_id = so.seller_id
JOIN (SELECT DISTINCT seller_id FROM seller_orders) s ON s.seller_id = so.seller_id
GROUP BY s.seller_id, sl.state
HAVING COUNT(*) >= 100
ORDER BY revenue DESC
LIMIT 15
