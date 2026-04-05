/*
========================================================
DDL Script: Create Silver Tables
========================================================

Scripts Purpose:
	This scripts creates tables in the 'silver' schema, dropping existing tables
	if they already exist.
	Run this script to re-define the DDL structure of 'bronze' Tables.
*/



DROP TABLE IF EXISTS silver.src_customer CASCADE;
GO
  
CREATE TABLE silver.src_customer 
  (
	customer_id VARCHAR(50) PRIMARY KEY,
	customer_code BIGINT,
	customer_city VARCHAR(100),
	customer_state VARCHAR(50),
	dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
GO

DROP TABLE IF EXISTS silver.src_products CASCADE;
GO
  
CREATE TABLE silver.src_products 
  (
	product_id VARCHAR(50) PRIMARY KEY,
	product_category VARCHAR(255),
	product_weigth NUMERIC,
	product_length NUMERIC,
	product_heigth NUMERIC,
	product_width NUMERIC,
	dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
GO
  
DROP TABLE IF EXISTS silver.src_orders CASCADE;
GO
  
CREATE TABLE silver.src_orders 
  (
	order_id VARCHAR(50) PRIMARY KEY,
	customer_id VARCHAR(50) REFERENCES silver.src_customer(customer_id),
	order_purchase_timestamp TIMESTAMP,
	order_approved TIMESTAMP,
	dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
GO
  
DROP TABLE IF EXISTS silver.src_payments CASCADE;
GO
  
CREATE TABLE silver.src_payments 
  (
	order_id VARCHAR(50),
	payment_sequential INT,
	payment_type VARCHAR(50),
	payment_installments INT,
	payment_value NUMERIC(10,2),
	dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (order_id, payment_sequential),
	FOREIGN KEY (order_id) REFERENCES silver.src_orders(order_id)
);
GO
  
DROP TABLE IF EXISTS silver.src_orderitems CASCADE;
GO
  
CREATE TABLE silver.src_orderitems 
  (
	order_id VARCHAR(50),
	product_id VARCHAR(50),
	seller_id VARCHAR(50),
	price NUMERIC(10,2),
	shipping_charges NUMERIC(10,2),
	dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (order_id, product_id),
	FOREIGN KEY (order_id) REFERENCES silver.src_orders(order_id),
	FOREIGN KEY (product_id) REFERENCES silver.src_products(product_id)
);
GO
