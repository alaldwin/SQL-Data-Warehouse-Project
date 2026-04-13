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

def extract_files():
    customers = pd.read_csv(r"C:\Users\aldwin\OneDrive\Desktop\files_learning_coding_in_python\DataWarehouse_project\df_Customers.csv")
    orderitems = pd.read_csv(r"C:\Users\aldwin\OneDrive\Desktop\coding_in_python\DataWarehouse_project\df_OrderItems.csv")
    orders = pd.read_csv(r"C:\Users\aldwin\OneDrive\Desktop\coding_in_python\DataWarehouse_project\df_Orders.csv")
    payments = pd.read_csv(r"C:\Users\aldwin\OneDrive\Desktop\coding_in_python\DataWarehouse_project\df_Payments.csv")
    products = pd.read_csv(r"C:\Users\aldwin\OneDrive\Desktop\coding_in_python\DataWarehouse_project\df_Products.csv")

    return (customers,orderitems,orders,payments,products)


    # standardize column names
def transform_generic(df):
    df.columns = df.columns.str.lower().str.strip()
    return df

def transform_products(df):
    df.columns = df.columns.str.lower().str.strip()
    return df.rename(columns={
        "product_category_name": "product_category",
        "product_weight_g": "product_weight",
        "product_length_cm": "product_length",
        "product_height_cm": "product_height",
        "product_width_cm": "product_width"
    })

def load_to_postgres(df, table_name, schema, key_column):
    engine = create_engine("postgresql://postgres:aldwino0012@localhost:5432/datamodeling")

 # remove duplicates
    df = df.drop_duplicates(subset=[key_column])

    try:
        existing_ids = pd.read_sql(
            f"SELECT {key_column} FROM {schema}.{table_name}",
            engine
        )
        df = df[~df[key_column].isin(existing_ids[key_column])]
    except Exception:
            # table might not exist yet
            print(f"Table {schema}.{table_name} not found. Creating new table.")

    # insert
    if not df.empty:
        df.to_sql(
            name=table_name,
            con=engine,
            schema=schema,
            if_exists="append",
            index=False
        )
        print(f"{len(df)} rows inserted into {schema}.{table_name}")
    else:
        print(f"No new data for {table_name}")


def main():
    customers, orderitems, orders, payments, products = extract_files()

    df_customers = transform_generic(customers)
    df_orders = transform_generic(orders)
    df_orderitems = transform_generic(orderitems)
    df_payments = transform_generic(payments)
    df_products = transform_products(products)

    load_to_postgres(df_customers, table_name="src_customer", schema="bronze", key_column="customer_id")
    load_to_postgres(df_orders, table_name="src_orders", schema="bronze", key_column="order_id")
    load_to_postgres(df_orderitems, table_name="src_orderitems", schema="bronze", key_column="order_id")
    load_to_postgres(df_payments, table_name="src_payments", schema="bronze", key_column="order_id")
    load_to_postgres(df_products, table_name="src_products", schema="bronze", key_column="product_id")

    print("Successfully!!.")

if __name__=="__main__":
    main()

"""
Usage: 
bash:
  python load_bronze.py 

After execution, the raw data from CSVs will be available in the bronze layer of the datamodeling database for further processing into silver or gold layers.
  """
