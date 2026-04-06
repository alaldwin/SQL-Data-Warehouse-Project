
/*
Script Purpose:
This SQL script forms the silver layer of a data warehouse pipeline. 
It extracts data from the raw bronze tables, applies transformations, 
cleans, converts, and enriches columns, and loads them into corresponding silver tables.

Specifically, it:

1. Truncates silver tables to remove previous loads (CASCADE used to ensure referential integrity).
2. Extracts data from bronze tables and applies transformations such as:
   - Filtering (e.g., customer_code >= 5000)
   - Cleaning (e.g., removing underscores and formatting text)
   - Data type conversions (e.g., grams → kilograms, cm → meters, inches/feet)
   - Column renaming to match silver table schema
   - Adding new calculated columns (e.g., order approval_status, seller status)
3. Inserts the transformed data into silver tables with a timestamp column `dwh_create_date`.

Note:
- Running this script repeatedly will overwrite silver tables due to TRUNCATE.
- Assumes bronze tables exist and contain consistent data.
- Silver tables must exist with matching schema.
- CURRENT_TIMESTAMP is used to track ingestion time.
*/


-- ============================================================================
-- Load Silver Customer Table
-- ============================================================================
TRUNCATE TABLE silver.src_customer CASCADE;

INSERT INTO silver.src_customer (
	customer_id,
	customer_code,
	customer_city,
	customer_state,
	dwh_create_date
)
SELECT 
	customer_id,
	customer_code,
	customer_city,
	customer_state,
	CURRENT_TIMESTAMP
FROM (
	SELECT	
		customer_id,
		customer_code,
		customer_city,
		customer_state
	FROM bronze.src_customer
	WHERE customer_code >= 5000
	ORDER BY customer_code ASC
) AS t
ORDER BY customer_city DESC;


-- ============================================================================
-- Load Silver Products Table
-- Clean category names, convert units, and rename columns
-- ============================================================================
TRUNCATE TABLE silver.src_products CASCADE;

INSERT INTO silver.src_products (
    product_id,
    product_category,
    product_weight,
    product_length,
    product_height,
    product_width,
	dwh_create_date
)
SELECT 
	product_id,
	INITCAP(REPLACE(product_category, '_', ' ')) AS product_category,  -- clean category names
	ROUND(product_weigth / 1000.0, 2) AS product_weight,                -- grams → kilograms
	ROUND(product_length / 100.0, 1) AS product_length,                 -- cm → meters
	ROUND(product_heigth / 2.54) AS product_height,                     -- cm → inches/feet
	ROUND(product_width) AS product_width,
	CURRENT_TIMESTAMP
FROM bronze.src_products
ORDER BY product_category ASC;


-- ============================================================================
-- Load Silver Orders Table
-- Add approval_status column based on order_approved
-- ============================================================================
TRUNCATE TABLE silver.src_orders CASCADE;

INSERT INTO silver.src_orders (
	order_id,
	customer_id,
	order_purchase_timestamp,
	order_approved,
	approval_status,
	dwh_create_date
)
SELECT
	order_id,
	customer_id,
	order_purchase_timestamp,
	order_approved,
	CASE  
		WHEN order_approved IS NULL THEN 'Pending Approval'
		ELSE 'Approved'
	END AS approval_status,
	CURRENT_TIMESTAMP
FROM bronze.src_orders;


-- ============================================================================
-- Load Silver Order Items Table
-- Add status_of_seller column based on total orders per seller
-- ============================================================================
ALTER TABLE silver.src_orderitems
ADD COLUMN IF NOT EXISTS status_of_seller VARCHAR(50);

TRUNCATE TABLE silver.src_orderitems;

WITH seller_status AS (
	SELECT
		seller_id,
		CASE
			WHEN COUNT(*) > 1 THEN 'Repeat Seller'
			ELSE 'One-item seller'
		END AS status_of_seller
	FROM bronze.src_orderitems
	GROUP BY seller_id
)
INSERT INTO silver.src_orderitems (
	order_id,
	product_id,
	seller_id,
	status_of_seller,
	price,
	shipping_charges,
	dwh_create_date
)
SELECT
	o.order_id,
	o.product_id,
	o.seller_id,
	s.status_of_seller,
	o.price,
	o.shipping_charges,
	CURRENT_TIMESTAMP
FROM bronze.src_orderitems o
LEFT JOIN seller_status s
	ON o.seller_id = s.seller_id;


-- ============================================================================
-- Load Silver Payments Table
-- Clean payment_type column and ensure only payments for existing orders
-- ============================================================================
TRUNCATE TABLE silver.src_payments;

INSERT INTO silver.src_payments (
	order_id,
	payment_sequential,
	payment_type,
	payment_installments,
	payment_value,
	dwh_create_date
)
SELECT
	o.order_id,
	p.payment_sequential,
	REPLACE(p.payment_type, '_', ' ') AS payment_type,
	p.payment_installments,
	p.payment_value,
	CURRENT_TIMESTAMP AS dwh_create_date
FROM bronze.src_payments p
INNER JOIN silver.src_orders o
	ON p.order_id = o.order_id;
