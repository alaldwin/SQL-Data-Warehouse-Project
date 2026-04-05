/*
=============================================================================
DDL Scripts: Create Bronze Tables
=============================================================================
Scripts Purpose:
	This scripts creates tables in the 'bronze' schema, dropping existing tables
	if they already exists.
	Run this script to re-define the DDL struture of 'bronze' Tables
*/


DROP DATABASE IF EXISTS datamodeling;
CREATE DATABASE datamodeling;

DROP SCHEMA IF EXISTS bronze;

DROP TABLE IF EXISTS bronze.src_customer;
CREATE TABLE src_customer (
	customer_id VARCHAR(50) PRIMARY KEY,
	customer_code INT,
	customer_city VARCHAR(100),
	customer_state VARCHAR(50)
);

DROP TABLE IF EXISTS bronze.src_orderitems;
CREATE TABLE src_orderitems (
	order_id VARCHAR(50),
	product_id VARCHAR(50),
	seller_id VARCHAR(50),
	price DECIMAL(10,2),
	shipping_charges DECIMAL(10,2)
	PRIMARY KEY (order_id, product_id),
	FOREIGN KEY (order_id) REFERENCES src_orders(order_id),
	FOREIGN KEY (product_id) REFERENCES src_products(product_id)
);

DROP TABLE IF EXISTS bronze.src_orders;
CREATE TABLE src_orders (
	order_id VARCHAR(50) PRIMARY KEY,
	customer_id VARCHAR(50) REFERENCES src_customer(customer_id),
	order_purchase_timestamp TIMESTAMP,
	order_approved TIMESTAMP
);

DROP TABLE IF EXISTS bronze.src_payments;
CREATE TABLE src_payments (
	order_id VARCHAR(50),
	payment_sequential INT,
	payment_type VARCHAR(50),
	payment_installments INT,
	payment_value DECIMAL(10,2),
	PRIMARY KEY (order_id, payment_sequential),
	FOREIGN KEY (order_id) REFERENCES src_orders(order_id)
);

DROP TABLE IF EXISTS bronze.src_products;
CREATE TABLE src_products (
	product_id VARCHAR(50) PRIMARY KEY,
	product_category TEXT,
	product_weigth INT,
	product_length INT,
	product_heigth INT,
	product_width INT
);
