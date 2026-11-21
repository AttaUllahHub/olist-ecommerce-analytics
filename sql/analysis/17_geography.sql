SELECT
    customer_state AS state,
    COUNT(*) AS orders,
    ROUND(SUM(items_revenue), 0) AS revenue,
    ROUND(100.0 * SUM(items_revenue) / SUM(SUM(items_revenue)) OVER (), 2) AS revenue_share_pct,
    ROUND(AVG(items_revenue), 2) AS avg_order_value,
    ROUND(100.0 * SUM(freight) / SUM(items_revenue), 1) AS freight_pct_of_revenue
FROM delivered_orders
GROUP BY customer_state
ORDER BY revenue DESC
