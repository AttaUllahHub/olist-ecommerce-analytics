WITH ref AS (
    SELECT CAST(MAX(purchase_ts) AS DATE) + 1 AS ref_date FROM delivered_orders
),
rfm AS (
    SELECT
        d.customer_unique_id,
        date_diff('day', CAST(MAX(d.purchase_ts) AS DATE), (SELECT ref_date FROM ref)) AS recency_days,
        COUNT(DISTINCT d.order_id) AS frequency,
        SUM(d.items_revenue) AS monetary
    FROM delivered_orders d
    GROUP BY 1
),
scored AS (
    SELECT
        *,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
    FROM rfm
),
segmented AS (
    SELECT
        *,
        CASE
            WHEN frequency >= 2 AND r_score >= 4 THEN 'Active repeat buyers'
            WHEN frequency >= 2 THEN 'Lapsed repeat buyers'
            WHEN m_score = 5 AND r_score >= 4 THEN 'Recent big spenders'
            WHEN m_score = 5 THEN 'Lapsed big spenders'
            WHEN r_score >= 4 THEN 'Recent one-time buyers'
            ELSE 'Dormant one-time buyers'
        END AS segment
    FROM scored
)
SELECT
    segment,
    COUNT(*) AS customers,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS customers_pct,
    ROUND(SUM(monetary), 0) AS revenue,
    ROUND(100.0 * SUM(monetary) / SUM(SUM(monetary)) OVER (), 2) AS revenue_pct,
    ROUND(AVG(monetary), 2) AS avg_spend,
    ROUND(AVG(recency_days), 0) AS avg_recency_days
FROM segmented
GROUP BY segment
ORDER BY revenue DESC
