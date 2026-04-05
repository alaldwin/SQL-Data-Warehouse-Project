# ETL Script Documentation

"""
Script Purpose:
This Python script extracts CSV files containing raw e-commerce data, 
performs basic transformations on the data, and loads it into a PostgreSQL database named datamodeling under the bronze schema.

Specifically, it:

1. Reads CSV files for customers, orders, order items, payments, and products.
2. Standardizes column names for consistency across datasets.
3. Renames certain columns to match the target PostgreSQL table structure.
4. Loads the transformed data into their corresponding tables in the bronze schema using SQLAlchemy.

This script forms the bronze layer of a data warehouse pipeline, 
serving as the raw ingestion layer before further transformation and aggregation in silver and gold layers.

Files Processed:
  df_Customers.csv → bronze.src_customer
  df_Orders.csv → bronze.src_orders
  df_OrderItems.csv → bronze.src_orderitems
  df_Payments.csv → bronze.src_payments
  df_Products.csv → bronze.src_products


Transformations Applied:

1. Convert all column names to lowercase and remove extra whitespace.
2. Rename columns for consistency with the database schema:
  customer_zip_code_prefix → customer_code
  order_approved_at → order_approved
  product_category_name → product_category
  product_weight_g → product_weight
  product_length_cm → product_length
  product_height_cm → product_height
  product_width_cm → product_width



Warnings:
  The script assumes that the target tables in the bronze schema already exist. Missing columns or mismatched schema will cause ProgrammingError during insertion.
  Ensure PostgreSQL is running and accessible at the specified host, port, and user credentials.
  This script does not drop or recreate tables; running it repeatedly may append duplicate records unless handled externally.
"""
import pandas as pd
from sqlalchemy import create_engine


def transform_files(df):
    # standardize column names
    df.columns = df.columns.str.lower().str.strip()

    df = df.rename(columns={
        "customer_zip_code_prefix": "customer_code",
        "order_approved_at": "order_approved",
        "product_category_name": "product_category",
        "product_weight_g": "product_weight",
        "product_length_cm": "product_length",
        "product_height_cm": "product_height",
        "product_width_cm": "product_width"
    })

    return df

def load_to_postgres(df, table_name, schema='bronze'):
# Database Loading: Connection to PostgreSQL is established via SQLAlchemy:
    engine = create_engine("postgresql://postgres:aldwino0012@localhost:5432/datamodeling")
# Data is loaded into each table using pandas.DataFrame.to_sql() with if_exists="append", allowing incremental loads without overwriting existing data.
    df.to_sql(
        name=table_name,
        con=engine,
        schema=schema,
        if_exists="append",   # important for pipelines
      # All data is inserted without the DataFrame index (index=False).
        index=False
    )

    print(f"Data loaded to {schema}.{table_name} successfully!")
"""
Execution Flow:
1. The main() function reads each CSV and applies transformations via transform_files().
2. Each transformed DataFrame is loaded into its corresponding table using load_to_postgres().
3. The script prints a success message for each table after loading.
"""

def main():

    df_customers = transform_files(pd.read_csv(r"C:\Users\aldwin\OneDrive\Desktop\files_learning_coding_in_python\DataWarehouse_project\df_Customers.csv"))
    df_orderitems = transform_files(pd.read_csv(r"C:\Users\aldwin\OneDrive\Desktop\files_learning_coding_in_python\DataWarehouse_project\df_OrderItems.csv"))
    df_orders = transform_files(pd.read_csv(r"C:\Users\aldwin\OneDrive\Desktop\files_learning_coding_in_python\DataWarehouse_project\df_Orders.csv"))
    df_payments = transform_files(pd.read_csv(r"C:\Users\aldwin\OneDrive\Desktop\files_learning_coding_in_python\DataWarehouse_project\df_Payments.csv"))
    df_products = transform_files(pd.read_csv(r"C:\Users\aldwin\OneDrive\Desktop\files_learning_coding_in_python\DataWarehouse_project\df_Products.csv"))

    # load raw (bronze)
    load_to_postgres(df_customers, "src_customer", schema="bronze")
    load_to_postgres(df_orders, "src_orders", schema="bronze")
    load_to_postgres(df_orderitems, "src_orderitems", schema="bronze")
    load_to_postgres(df_payments, "src_payments", schema="bronze")
    load_to_postgres(df_products, "src_products", schema="bronze")
    print("Successfully!!.")

if __name__=="__main__":
    main()

"""
Usage: 
bash:
  python load_bronze.py 

After execution, the raw data from CSVs will be available in the bronze layer of the datamodeling database for further processing into silver or gold layers.
  """
