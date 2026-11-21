WITH card_orders AS (
    SELECT p.order_id, MAX(p.payment_installments) AS installments, SUM(p.payment_value) AS paid
    FROM order_payments p
    JOIN delivered_orders d ON d.order_id = p.order_id
    WHERE p.payment_type = 'credit_card'
    GROUP BY 1
)
SELECT
    CASE
        WHEN installments = 1 THEN '1 (paid in full)'
        WHEN installments BETWEEN 2 AND 3 THEN '2-3'
        WHEN installments BETWEEN 4 AND 6 THEN '4-6'
        WHEN installments BETWEEN 7 AND 10 THEN '7-10'
        ELSE '11+'
    END AS installments,
    COUNT(*) AS orders,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS orders_pct,
    ROUND(AVG(paid), 2) AS avg_order_value
FROM card_orders
GROUP BY 1
ORDER BY MIN(installments)
