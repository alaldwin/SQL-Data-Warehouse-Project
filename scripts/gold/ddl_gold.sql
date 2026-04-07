/*
Script Purpose:
This SQL script forms the gold layer of a data warehouse pipeline.
It transforms curated silver data into a dimensional model (star schema),
including dimension tables and a fact table for analytics and reporting.

Specifically, it:

1. Drops existing gold tables to ensure a clean rebuild of the data model.
2. Creates dimension tables (dim_customer, dim_product, dim_orders, dim_date):
   - Extracts relevant attributes from silver tables
   - Applies formatting (e.g., date_id generation using TO_CHAR)
   - Structures data for slicing and filtering in analytics
3. Creates a central fact table (fact_sales):
   - Joins multiple silver tables (customers, orders, products, payments, order items)
   - Captures transactional metrics (price, payment_value, shipping_charges)
   - Generates surrogate keys (customer_key using ROW_NUMBER)
   - Links to dimensions using natural keys and date identifiers
4. Standardizes date fields into integer-based keys (YYYYMMDD format) for consistency.

Dimension Tables:
- dim_customer: Customer location attributes
- dim_product: Product details and characteristics
- dim_orders: Order-level date references
- dim_date: Calendar breakdown for time-based analysis

Fact Table:
- fact_sales: Contains transactional sales data and measures

Note:
- Running this script will overwrite all gold tables (DROP TABLE IF EXISTS).
- Assumes silver tables are clean, consistent, and fully populated.
- Date keys are derived from timestamps and must align across fact and dimensions.
- Surrogate keys (e.g., customer_key) are generated dynamically and may change on reload.
- Be cautious with joins to avoid duplication (especially with order items and payments).
*/


-- ============================================================================
-- Create Customer Dimension Table
-- ============================================================================
DROP TABLE IF EXISTS gold.dim_customer;

CREATE TABLE gold.dim_customer AS 
SELECT 
	customer_id AS customer_id,
	customer_city AS customer_city,
	customer_state AS customer_state
FROM silver.src_customer;


-- ============================================================================
-- Create Product Dimension Table
-- ============================================================================
DROP TABLE IF EXISTS gold.dim_product;

CREATE TABLE gold.dim_product AS
SELECT
	product_id AS product_id,
	product_category AS product_category,
	product_weight AS product_weight
FROM silver.src_products;


-- ============================================================================
-- Create Orders Dimension Table
-- Contains date references for purchase and approval
-- ============================================================================
DROP TABLE IF EXISTS gold.dim_orders;

CREATE TABLE gold.dim_orders AS 
SELECT 
	order_id AS order_id,
	TO_CHAR(order_purchase_timestamp, 'YYYYMMDD')::INT AS date_id,
	TO_CHAR(order_approved, 'YYYYMMDD')::INT AS approved_id
FROM silver.src_orders;


-- ============================================================================
-- Create Date Dimension Table
-- Derived from order_purchase_timestamp
-- ============================================================================
DROP TABLE IF EXISTS gold.dim_date;

CREATE TABLE gold.dim_date AS 
SELECT
	TO_CHAR(order_purchase_timestamp, 'YYYYMMDD')::INT AS date_id,
	DATE(order_purchase_timestamp) AS full_date,
	EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
	EXTRACT(MONTH FROM order_purchase_timestamp) AS month,
	EXTRACT(DAY FROM order_purchase_timestamp) AS day
FROM silver.src_orders;


-- ============================================================================
-- Create Fact Sales Table
-- Combines transactional data across all entities
-- ============================================================================
DROP TABLE IF EXISTS gold.fact_sales;

CREATE TABLE gold.fact_sales AS
SELECT
	ROW_NUMBER() OVER (ORDER BY c.customer_id) AS customer_key, -- surrogate key
	o.order_id AS order_id, 
	p.product_id AS product_id,
	c.customer_id AS customer_id, 
	pm.payment_value AS payment_value,
	oi.price AS price,
	oi.shipping_charges AS shipping_charges,
	TO_CHAR(o.order_purchase_timestamp, 'YYYYMMDD')::INT AS date_id,
	TO_CHAR(o.order_approved, 'YYYYMMDD')::INT AS approved_id
FROM 
	silver.src_customer c
LEFT JOIN 
	silver.src_orders o
	ON c.customer_id = o.customer_id
LEFT JOIN 
	silver.src_orderitems oi
	ON o.order_id = oi.order_id
LEFT JOIN 
	silver.src_products p
	ON oi.product_id = p.product_id
LEFT JOIN
	silver.src_payments pm
	ON o.order_id = pm.order_id;
