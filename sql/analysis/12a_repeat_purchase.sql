WITH per_customer AS (
    SELECT customer_unique_id, COUNT(DISTINCT order_id) AS n_orders, SUM(items_revenue) AS revenue
    FROM delivered_orders
    GROUP BY 1
)
SELECT
    CASE WHEN n_orders >= 3 THEN '3+' ELSE CAST(n_orders AS VARCHAR) END AS orders_placed,
    COUNT(*) AS customers,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS customers_pct,
    ROUND(SUM(revenue), 0) AS revenue,
    ROUND(100.0 * SUM(revenue) / SUM(SUM(revenue)) OVER (), 2) AS revenue_pct
FROM per_customer
GROUP BY 1
ORDER BY 1
