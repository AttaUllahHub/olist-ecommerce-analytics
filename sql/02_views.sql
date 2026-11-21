CREATE OR REPLACE VIEW order_value AS
SELECT
    order_id,
    SUM(price) AS items_revenue,
    SUM(freight_value) AS freight,
    COUNT(*) AS n_items,
    COUNT(DISTINCT seller_id) AS n_sellers
FROM order_items
GROUP BY order_id;

CREATE OR REPLACE VIEW latest_review AS
SELECT order_id, review_id, review_score, review_comment_message
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY review_answer_ts DESC, review_id
        ) AS rn
    FROM order_reviews
)
WHERE rn = 1;

CREATE OR REPLACE VIEW delivered_orders AS
SELECT
    o.order_id,
    c.customer_unique_id,
    c.state AS customer_state,
    c.city AS customer_city,
    o.purchase_ts,
    o.delivered_customer_ts,
    o.estimated_delivery_ts,
    date_diff('hour', o.purchase_ts, o.delivered_customer_ts) / 24.0 AS delivery_days,
    date_diff('day', CAST(o.estimated_delivery_ts AS DATE), CAST(o.delivered_customer_ts AS DATE)) AS days_vs_estimate,
    CAST(o.delivered_customer_ts AS DATE) > CAST(o.estimated_delivery_ts AS DATE) AS is_late,
    v.items_revenue,
    v.freight,
    v.n_items,
    v.n_sellers,
    r.review_score
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
JOIN order_value v ON v.order_id = o.order_id
LEFT JOIN latest_review r ON r.order_id = o.order_id
WHERE o.order_status = 'delivered'
  AND o.delivered_customer_ts IS NOT NULL;
