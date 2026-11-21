# Data

Eight tables from the Olist Brazilian E-Commerce Public Dataset are in `data/raw/`:

| File | Rows |
|---|---|
| olist_orders_dataset.csv | 99,441 |
| olist_customers_dataset.csv | 99,441 |
| olist_order_items_dataset.csv | 112,650 |
| olist_order_payments_dataset.csv | 103,886 |
| olist_order_reviews_dataset.csv | 99,224 |
| olist_products_dataset.csv | 32,951 |
| olist_sellers_dataset.csv | 3,095 |
| product_category_name_translation.csv | 71 |

The geolocation table (about 1M rows) is not used and not included.

## Provenance

The canonical source is Kaggle: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce. Kaggle needs a login, so this copy comes from a public GitHub mirror (`vikashGiri27/SQL-E-Commerce-Data-Analysis`). Before analysis, it was checked against the official dataset:

- Row counts match the official counts for all eight files.
- Order-status counts match (96,478 delivered, 1,107 shipped, 625 canceled, and so on).
- Review score distribution matches (11,424 / 3,151 / 8,179 / 19,142 / 57,328 for scores 1 to 5).
- Null counts in the order timestamp columns match.

Differences from the original Kaggle files, all handled in `sql/01_schema.sql`:

- Order and review timestamps are `dd-mm-yyyy hh:mm` instead of ISO format. The schema parses both.
- Product categories are already in English, and 13 products in two categories that Olist never translated are blank. The schema translates Portuguese names when it finds them and keeps English names as they are.
- The `Order_id` header in the orders file is capitalised. DuckDB column names are case-insensitive, so this has no effect.

To use the original Kaggle files, place them in `data/raw/` under the same names and run `python main.py`.

## Licence

Published by Olist under CC BY-NC-SA 4.0 (check the Kaggle page for the current terms). This repository is a non-commercial portfolio project. Credit for the data goes to Olist.
