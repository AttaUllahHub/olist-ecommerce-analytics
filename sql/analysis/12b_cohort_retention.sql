WITH first_purchase AS (
    SELECT customer_unique_id, MIN(date_trunc('month', purchase_ts)) AS cohort_month
    FROM delivered_orders
    GROUP BY 1
),
activity AS (
    SELECT DISTINCT
        d.customer_unique_id,
        f.cohort_month,
        date_diff('month', f.cohort_month, date_trunc('month', d.purchase_ts)) AS month_index
    FROM delivered_orders d
    JOIN first_purchase f USING (customer_unique_id)
),
cohort_size AS (
    SELECT cohort_month, COUNT(*) AS cohort_customers
    FROM first_purchase
    GROUP BY 1
)
SELECT
    strftime(a.cohort_month, '%Y-%m') AS cohort_month,
    a.month_index,
    s.cohort_customers,
    COUNT(*) AS active_customers,
    ROUND(100.0 * COUNT(*) / s.cohort_customers, 2) AS retention_pct
FROM activity a
JOIN cohort_size s USING (cohort_month)
WHERE a.month_index BETWEEN 0 AND 6
  AND a.cohort_month BETWEEN TIMESTAMP '2017-01-01' AND TIMESTAMP '2018-02-01'
GROUP BY a.cohort_month, a.month_index, s.cohort_customers
ORDER BY a.cohort_month, a.month_index
