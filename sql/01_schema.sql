CREATE OR REPLACE MACRO parse_ts(x) AS COALESCE(try_strptime(x, '%d-%m-%Y %H:%M'), try_strptime(x, '%Y-%m-%d %H:%M:%S'));

CREATE OR REPLACE TABLE customers AS
SELECT
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix AS zip_prefix,
    customer_city AS city,
    customer_state AS state
FROM read_csv('data/raw/olist_customers_dataset.csv', header = true, all_varchar = true);

CREATE OR REPLACE TABLE orders AS
SELECT
    Order_id AS order_id,
    customer_id,
    order_status,
    parse_ts(order_purchase_timestamp) AS purchase_ts,
    parse_ts(order_approved_at) AS approved_ts,
    parse_ts(order_delivered_carrier_date) AS carrier_ts,
    parse_ts(order_delivered_customer_date) AS delivered_customer_ts,
    parse_ts(order_estimated_delivery_date) AS estimated_delivery_ts
FROM read_csv('data/raw/olist_orders_dataset.csv', header = true, all_varchar = true);

CREATE OR REPLACE TABLE order_items AS
SELECT
    order_id,
    CAST(order_item_id AS INTEGER) AS order_item_id,
    product_id,
    seller_id,
    CAST(shipping_limit_date AS TIMESTAMP) AS shipping_limit_ts,
    CAST(price AS DOUBLE) AS price,
    CAST(freight_value AS DOUBLE) AS freight_value
FROM read_csv('data/raw/olist_order_items_dataset.csv', header = true, all_varchar = true);

CREATE OR REPLACE TABLE order_payments AS
SELECT
    order_id,
    CAST(payment_sequential AS INTEGER) AS payment_sequential,
    payment_type,
    CAST(payment_installments AS INTEGER) AS payment_installments,
    CAST(payment_value AS DOUBLE) AS payment_value
FROM read_csv('data/raw/olist_order_payments_dataset.csv', header = true, all_varchar = true);

CREATE OR REPLACE TABLE order_reviews AS
SELECT
    review_id,
    order_id,
    CAST(review_score AS INTEGER) AS review_score,
    review_comment_title,
    review_comment_message,
    parse_ts(review_creation_date) AS review_creation_ts,
    parse_ts(review_answer_timestamp) AS review_answer_ts
FROM read_csv('data/raw/olist_order_reviews_dataset.csv', header = true, all_varchar = true,
              quote = '"', escape = '"', parallel = false);

CREATE OR REPLACE TABLE sellers AS
SELECT
    seller_id,
    seller_zip_code_prefix AS zip_prefix,
    seller_city AS city,
    seller_state AS state
FROM read_csv('data/raw/olist_sellers_dataset.csv', header = true, all_varchar = true);

CREATE OR REPLACE TABLE category_translation AS
SELECT
    product_category_name AS category_pt,
    product_category_name_english AS category_en
FROM read_csv('data/raw/product_category_name_translation.csv', header = true, all_varchar = true);

CREATE OR REPLACE TABLE products AS
SELECT
    p.product_id,
    COALESCE(t.category_en, NULLIF(p.product_category_name, '')) AS category,
    TRY_CAST(p.product_name_lenght AS INTEGER) AS name_length,
    TRY_CAST(p.product_description_lenght AS INTEGER) AS description_length,
    TRY_CAST(p.product_photos_qty AS INTEGER) AS photos_qty,
    TRY_CAST(p.product_weight_g AS DOUBLE) AS weight_g
FROM read_csv('data/raw/olist_products_dataset.csv', header = true, all_varchar = true) p
LEFT JOIN category_translation t ON t.category_pt = p.product_category_name;
