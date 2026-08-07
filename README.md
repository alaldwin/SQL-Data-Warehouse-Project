# SQL Data Warehouse Project

An end-to-end **Data Warehouse project built using SQL**, designed to simulate real-world data engineering workflows—from raw data ingestion to analytics-ready datasets.

---

## Project Goal

The goal of this project is to build a **modern data warehouse** that:

- Consolidates raw data from multiple sources  
- Cleans and transforms data into usable formats  
- Structures data into an **analytics-ready model (Star Schema)**  
- Enables fast, reliable, and scalable reporting  

---

## Architecture Overview

This project follows the **Medallion Architecture**, a widely used pattern in modern data engineering:

- 🥉 **Bronze Layer (Raw Data)**  
  - Stores raw CSV using python data exactly as ingested  
  - No transformations applied  

- 🥈 **Silver Layer (Cleaned Data)**  
  - Handles missing values  
  - Standardizes formats  
  - Removes duplicates  
  - Applies data validation rules  

- 🥇 **Gold Layer (Business Layer)**  
  - Data is modeled into **fact and dimension tables**  
  - Optimized for analytics and reporting  
  - Implements a **Star Schema**  

---

## Repository Structure
```
SQL-Data-Warehouse-Project/
│
├── datasets/
│
├── docs/
│ ├── data_architecture.drawio
│ ├── data_flow.drawio
│ ├── data_models.drawio
│ ├── data_catalog.md
│ └── naming-conventions.md
│
├── scripts/
│ ├── bronze/
│ ├── silver/
│ └── gold/
│
├── tests/ # Data quality checks and validation scripts
│
├── LICENSE
└── README.md
```

---

## Skills Demonstrated

This project showcases key **Data Engineering skills**:

- Advanced SQL (joins, aggregations, transformations)
- ETL pipeline development
- Data warehouse design
- Medallion architecture implementation
- Star schema modeling
- Data cleaning and validation
- Documentation and data cataloging

---

## Tools & Technologies

- SQL
- SQL Server / PostgreSQL
- Draw.io (for architecture diagrams)
- Git & GitHub

---


## How to Run This Project

## 1. Clone the repository
```bash
git clone https://github.com/alaldwin/SQL-Data-Warehouse-Project.git
```
## 2. Prepare datasets

- Place CSV files inside the ```datasets/``` folder
- Ensure file paths match the SQL scripts

## 3. Run SQL scripts in order
```
SQL

-- Step 1: Bronze layer
scripts/bronze/

-- Step 2: Silver layer
scripts/silver/

-- Step 3: Gold layer
scripts/gold/
```

### 4. Run data quality tests

```
tests/
```

---

## Example Use Cases

- Sales performance analysis
- Customer segmentation
- Product insights
- Business intelligence reporting

---

## Why This Project Matters

 Without a proper data warehouse:

 -  Data is inconsistent and scattered
 -  Reporting is slow and unreliable
 -  Manual processes introduce errors

 With this solution:

 -  Centralized and structured data
 -  Faster analytics and reporting
 -  Reliable decision-making

 ---

 ## Future Improvements
 
- Add dashboard visualization (Power BI / Tableau)
- Automate pipelines using Airflow or Prefect
- Deploy to cloud platforms (GCP BigQuery / AWS Redshift)
- Implement incremental loading (CDC)
