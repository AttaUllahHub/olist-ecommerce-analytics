SELECT
    p.payment_type,
    COUNT(DISTINCT p.order_id) AS orders,
    ROUND(SUM(p.payment_value), 0) AS payment_value,
    ROUND(100.0 * SUM(p.payment_value) / SUM(SUM(p.payment_value)) OVER (), 2) AS value_share_pct,
    ROUND(AVG(p.payment_value), 2) AS avg_payment,
    ROUND(AVG(p.payment_installments), 2) AS avg_installments
FROM order_payments p
JOIN delivered_orders d ON d.order_id = p.order_id
GROUP BY p.payment_type
ORDER BY payment_value DESC
