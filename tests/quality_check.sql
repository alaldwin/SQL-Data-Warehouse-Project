/*
============================================================
DATA QUALITY / TESTING QUERIES
Purpose: Validate the integrity, uniqueness, and correctness 
of data in the bronze layer before moving to silver.
============================================================
*/


/*
1. Null Checks: Ensure critical columns are not empty.
   Expectation: 0 rows returned
*/
-- src_customer: customer_id should not be null
SELECT * 
FROM bronze.src_customer
WHERE customer_id IS NULL;


/*
2. Duplicate Checks: Verify no duplicate primary keys.
   Expectation: No duplicates
*/
-- src_customer: primary key duplicate check
SELECT 
	customer_id,
	COUNT(*) AS duplicate_count
FROM bronze.src_customer
GROUP BY customer_id
HAVING COUNT(*) > 1;


/*
3. Data Type / Format Validation: Ensure values are valid.
   Example: product weight should never be negative
*/
SELECT * 
FROM bronze.src_products
WHERE product_weigth < 0;



/*
4. Row Count Validation: Ensure data loaded correctly from bronze → silver
   Expectation: counts should match or differences explained
*/
-- src_customer
SELECT COUNT(*) AS bronze_count FROM bronze.src_customer;
SELECT COUNT(*) AS silver_count FROM silver.src_customer;
