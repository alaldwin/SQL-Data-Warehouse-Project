# ETL Script Documentation

"""
Script Purpose:
This Python script implements the **bronze layer ingestion pipeline** for an e-commerce data warehouse.

It extracts raw CSV datasets, applies basic standardization and transformation rules, and loads the cleaned data into a PostgreSQL database named `datamodeling` under the `bronze` schema.

The script is designed as the first stage of an ETL (Extract, Transform, Load) pipeline, where data is ingested in its raw but structured form before further transformation in silver and gold layers.

---

Core Responsibilities:

1. Extract raw CSV files for:
   - Customers
   - Orders
   - Order Items
   - Payments
   - Products

2. Transform data by:
   - Standardizing column names (lowercase, trimmed whitespace)
   - Renaming product-related fields to match warehouse schema
   - Removing duplicate records based on primary key columns

3. Load processed data into PostgreSQL tables using SQLAlchemy:
   - bronze.src_customer
   - bronze.src_orders
   - bronze.src_orderitems
   - bronze.src_payments
   - bronze.src_products

---

Files Processed:

- df_Customers.csv   → bronze.src_customer
- df_Orders.csv      → bronze.src_orders
- df_OrderItems.csv   → bronze.src_orderitems
- df_Payments.csv     → bronze.src_payments
- df_Products.csv     → bronze.src_products

---

Transformations Applied:

1. Column Standardization:
   - Convert all column names to lowercase
   - Remove leading and trailing whitespace

2. Column Renaming (Products Table Only):
   - product_category_name → product_category
   - product_weight_g → product_weight
   - product_length_cm → product_length
   - product_height_cm → product_height
   - product_width_cm → product_width

3. Data Cleaning:
   - Remove duplicate records based on the specified key column before loading
   - Exclude already existing records in PostgreSQL to avoid duplication

---

Architecture Context:

This script represents the **Bronze Layer** in a medallion architecture:
- Bronze → Raw ingestion (this script)
- Silver → Cleaned + normalized + joined datasets
- Gold → Business-ready analytics tables

---

Warnings / Important Notes:

- The script assumes that PostgreSQL is running and accessible using the provided credentials.
- Target tables inside the `bronze` schema must already exist or be created automatically by `pandas.to_sql`.
- Schema mismatches (missing columns, incorrect data types) may cause insertion errors.
- This pipeline does NOT enforce strict constraints or validation rules at the database level.
- Running the script multiple times may still result in duplicates if upstream deduplication logic is bypassed or changed.
- Engine connection is created inside runtime; ensure proper DB credentials before execution.

---

Future Improvements:

- Add data validation layer (e.g., Great Expectations)
- Move configuration to `.env` file
- Add logging to external file instead of console only
- Implement incremental loading with timestamps
- Add unit tests for load layer using mocked database engine
"""


import pandas as pd
from sqlalchemy import create_engine
import logging

logging.basicConfig(level=logging.INFO)

# -----------------------
# CONFIG
# -----------------------
DB_URL = "postgresql://postgres:aldwino0012@localhost:5432/datamodeling"

# -----------------------
# EXTRACT
# -----------------------
def extract_files(base_path):
    return (
        pd.read_csv(f"{base_path}/df_Customers.csv"),
        pd.read_csv(f"{base_path}/df_OrderItems.csv"),
        pd.read_csv(f"{base_path}/df_Orders.csv"),
        pd.read_csv(f"{base_path}/df_Payments.csv"),
        pd.read_csv(f"{base_path}/df_Products.csv"),
    )



    # standardize column names
# -----------------------
# TRANSFORM
# -----------------------
def transform_generic(df):
    df = df.copy()
    df.columns = df.columns.str.lower().str.strip()
    return df


def transform_products(df):
    df = transform_generic(df)
    return df.rename(columns={
        "product_category_name": "product_category",
        "product_weight_g": "product_weight",
        "product_length_cm": "product_length",
        "product_height_cm": "product_height",
        "product_width_cm": "product_width"
    })

# -----------------------
# LOAD
# -----------------------
def load_to_postgres(df, table_name, schema, key_column, engine):
    df = df.drop_duplicates(subset=[key_column])

    try:
        existing = pd.read_sql(
            f"SELECT {key_column} FROM {schema}.{table_name}",
            engine
        )
        df = df[~df[key_column].isin(existing[key_column])]
    except Exception:
        logging.info(f"Table {schema}.{table_name} not found. Creating new one.")

    if not df.empty:
        df.to_sql(
            name=table_name,
            con=engine,
            schema=schema,
            if_exists="append",
            index=False
        )
        logging.info(f"{len(df)} rows inserted into {schema}.{table_name}")
    else:
        logging.info(f"No new data for {table_name}")


# -----------------------
# MAIN
# -----------------------
def main(base_path):
    engine = create_engine(DB_URL)

    customers, orderitems, orders, payments, products = extract_files(base_path)

    df_customers = transform_generic(customers)
    df_orders = transform_generic(orders)
    df_orderitems = transform_generic(orderitems)
    df_payments = transform_generic(payments)
    df_products = transform_products(products)

    load_to_postgres(df_customers, "src_customer", "bronze", "customer_id", engine)
    load_to_postgres(df_orders, "src_orders", "bronze", "order_id", engine)
    load_to_postgres(df_orderitems, "src_orderitems", "bronze", "order_id", engine)
    load_to_postgres(df_payments, "src_payments", "bronze", "order_id", engine)
    load_to_postgres(df_products, "src_products", "bronze", "product_id", engine)

    print("ETL Completed Successfully!")


if __name__ == "__main__":
    main()
  
"""
Usage: 
bash:
  python load_bronze.py 

After execution, the raw data from CSVs will be available in the bronze layer of the datamodeling database for further processing into silver or gold layers.
  """
