SELECT 'orders: duplicate order_id' AS check_name, COUNT(*) - COUNT(DISTINCT order_id) AS issues, (SELECT COUNT(*) FROM orders) AS rows_checked FROM orders
UNION ALL
SELECT 'orders: customer_id missing in customers', COUNT(*), (SELECT COUNT(*) FROM orders) FROM orders o WHERE NOT EXISTS (SELECT 1 FROM customers c WHERE c.customer_id = o.customer_id)
UNION ALL
SELECT 'order_items: order_id missing in orders', COUNT(*), (SELECT COUNT(*) FROM order_items) FROM order_items i WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.order_id = i.order_id)
UNION ALL
SELECT 'order_items: product_id missing in products', COUNT(*), (SELECT COUNT(*) FROM order_items) FROM order_items i WHERE NOT EXISTS (SELECT 1 FROM products p WHERE p.product_id = i.product_id)
UNION ALL
SELECT 'order_items: seller_id missing in sellers', COUNT(*), (SELECT COUNT(*) FROM order_items) FROM order_items i WHERE NOT EXISTS (SELECT 1 FROM sellers s WHERE s.seller_id = i.seller_id)
UNION ALL
SELECT 'orders: no items (any status)', COUNT(*), (SELECT COUNT(*) FROM orders) FROM orders o WHERE NOT EXISTS (SELECT 1 FROM order_items i WHERE i.order_id = o.order_id)
UNION ALL
SELECT 'orders: delivered but no delivery date', COUNT(*), (SELECT COUNT(*) FROM orders WHERE order_status = 'delivered') FROM orders WHERE order_status = 'delivered' AND delivered_customer_ts IS NULL
UNION ALL
SELECT 'orders: delivered before purchase', COUNT(*), (SELECT COUNT(*) FROM orders WHERE delivered_customer_ts IS NOT NULL) FROM orders WHERE delivered_customer_ts < purchase_ts
UNION ALL
SELECT 'order_reviews: orders with more than one review', COUNT(*), (SELECT COUNT(DISTINCT order_id) FROM order_reviews) FROM (SELECT order_id FROM order_reviews GROUP BY order_id HAVING COUNT(*) > 1)
UNION ALL
SELECT 'order_reviews: review_score outside 1-5', COUNT(*), (SELECT COUNT(*) FROM order_reviews) FROM order_reviews WHERE review_score NOT BETWEEN 1 AND 5
UNION ALL
SELECT 'order_items: non-positive price', COUNT(*), (SELECT COUNT(*) FROM order_items) FROM order_items WHERE price <= 0
UNION ALL
SELECT 'delivered_orders view: rows excluded for missing items', (SELECT COUNT(*) FROM orders WHERE order_status = 'delivered' AND delivered_customer_ts IS NOT NULL) - (SELECT COUNT(*) FROM delivered_orders), (SELECT COUNT(*) FROM orders WHERE order_status = 'delivered')
