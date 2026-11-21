WITH category_sales AS (
    SELECT
        COALESCE(p.category, 'uncategorised') AS category,
        COUNT(DISTINCT i.order_id) AS orders,
        COUNT(*) AS items_sold,
        SUM(i.price) AS revenue,
        AVG(i.price) AS avg_item_price,
        AVG(d.review_score) AS avg_review_score
    FROM order_items i
    JOIN delivered_orders d ON d.order_id = i.order_id
    JOIN products p ON p.product_id = i.product_id
    GROUP BY 1
)
SELECT
    RANK() OVER (ORDER BY revenue DESC) AS revenue_rank,
    category,
    orders,
    items_sold,
    ROUND(revenue, 0) AS revenue,
    ROUND(100.0 * revenue / SUM(revenue) OVER (), 2) AS revenue_share_pct,
    ROUND(100.0 * SUM(revenue) OVER (ORDER BY revenue DESC) / SUM(revenue) OVER (), 2) AS cumulative_share_pct,
    ROUND(avg_item_price, 2) AS avg_item_price,
    ROUND(avg_review_score, 2) AS avg_review_score
FROM category_sales
ORDER BY revenue_rank
