WITH monthly AS (
    SELECT
        date_trunc('month', purchase_ts) AS month,
        COUNT(*) AS orders,
        SUM(items_revenue) AS revenue,
        SUM(freight) AS freight,
        SUM(items_revenue) / COUNT(*) AS avg_order_value
    FROM delivered_orders
    WHERE purchase_ts >= TIMESTAMP '2017-01-01' AND purchase_ts < TIMESTAMP '2018-09-01'
    GROUP BY 1
)
SELECT
    strftime(month, '%Y-%m') AS month,
    orders,
    ROUND(revenue, 0) AS revenue,
    ROUND(freight, 0) AS freight,
    ROUND(avg_order_value, 2) AS avg_order_value,
    ROUND(100.0 * (revenue / LAG(revenue) OVER (ORDER BY month) - 1), 1) AS revenue_mom_pct,
    ROUND(AVG(revenue) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 0) AS revenue_3m_avg
FROM monthly
ORDER BY month
