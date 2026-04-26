import pandas as pd
from etl import transform_generic, transform_products


def test_transform_generic_lowercase_columns():
    df = pd.DataFrame({
        "Customer_ID": [1],
        "Order Date": ["2026-01-01"]
    })

    result = transform_generic(df)

    assert "customer_id" in result.columns
    assert "order date" in result.columns


def test_transform_products_rename_columns():
    df = pd.DataFrame({
        "product_category_name": ["Electronics"],
        "product_weight_g": [100],
        "product_length_cm": [10],
        "product_height_cm": [5],
        "product_width_cm": [2]
    })

    result = transform_products(df)

    assert "product_category" in result.columns
    assert "product_weight" in result.columns
    assert "product_length" in result.columns
    assert "product_height" in result.columns
    assert "product_width" in result.columns
