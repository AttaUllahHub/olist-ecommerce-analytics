WITH seller_rev AS (
    SELECT i.seller_id, SUM(i.price) AS revenue
    FROM order_items i
    JOIN delivered_orders d ON d.order_id = i.order_id
    GROUP BY 1
),
ranked AS (
    SELECT *, NTILE(10) OVER (ORDER BY revenue DESC) AS decile FROM seller_rev
)
SELECT
    decile,
    COUNT(*) AS sellers,
    ROUND(SUM(revenue), 0) AS revenue,
    ROUND(100.0 * SUM(revenue) / SUM(SUM(revenue)) OVER (), 2) AS revenue_share_pct,
    ROUND(100.0 * SUM(SUM(revenue)) OVER (ORDER BY decile) / SUM(SUM(revenue)) OVER (), 2) AS cumulative_share_pct
FROM ranked
GROUP BY decile
ORDER BY decile
