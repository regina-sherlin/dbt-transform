# Retail Store Sales Analytics Pipeline (dbt + Snowflake)

An end-to-end ELT data modeling and automated reconciliation pipeline built with **dbt** and **Snowflake**. This project transforms raw, denormalized retail transaction logs into a validated Star Schema (`fct_` and `dim_` models) ready for downstream BI reporting.

---

## Architecture & Data Lineage

![dbt Lineage Graph](docs/lineage_graph.png)


### Pipeline Layers
1. **Raw Ingestion (`RETAIL_DB.RAW`):** Untouched source transactions (`RETAIL_TB`) loaded from raw CSV files and registered via `sources.yml`.
2. **Staging Hygiene (`RETAIL_DB.RETAIL_STAGING`):** 1:1 cleaned transaction layer (`stg_retail_sales`) that standardizes strings via reusable Jinja macros, enforces strict data types, and mathematically reconstructs missing revenue totals.
3. **Version-Controlled Seeds (`RETAIL_DB.RETAIL`):** Static business lookup tables (`category_departments.csv`, `payment_method_mapping.csv`) maintained in Git and loaded via `dbt seed`.
4. **Analytics Marts (`RETAIL_DB.RETAIL_MARTS`):** Star Schema fact and dimension tables (`fct_daily_sales`, `fct_category_sales`, `dim_products`, `dim_categories`, `dim_payment_methods`) built for fast BI querying.

---

## Key Engineering Highlights

* **Reusable Jinja Macros (`macros/clean_string.sql`):** Standardized sentinel string scrubbing (`'UNKNOWN'`, `'ERROR'`, `'N/A'`, `'NULL'`, `'-'`, `''`) across columns using a DRY Jinja macro.
* **Dynamic SQL Generation with Jinja:** Used Jinja `{% for %}` loops in `fct_category_sales` to dynamically pivot payment methods (`Cash`, `Credit Card`, `Digital Wallet`, `Unknown`) into dedicated revenue columns.
* **Revenue Reconstruction (`COALESCE`):** Recovered missing `TOTAL_SPENT` figures where valid `QUANTITY` and `PRICE_PER_UNIT` values existed while retaining `RAW_TOTAL_SPENT` for auditability.
* **Star Schema Modeling:** Separated atomic and daily sales facts (`fct_daily_sales`, `fct_category_sales`) from descriptive dimensions (`dim_products`, `dim_categories`, `dim_payment_methods`) to prevent join fan-out and establish clear data grain.

---

## Data Quality & Automated Reconciliation

Every `dbt build` executes both schema-level generic tests and custom SQL reconciliation checks to guarantee zero data loss or metric drift across layers:

### Generic Schema Tests (`models/**/tests.yml`)
* **Primary Key Integrity:** Enforced `unique` and `not_null` constraints across all staging, fact, and dimension grains (`TRANSACTION_ID`, `TRANSACTION_DATE`, `ITEM`, `CATEGORY`, `PAYMENT_METHOD`).
* **Referential Integrity:** Validated `relationships` between mart dimensions and version-controlled seed tables (`category_departments`, `payment_method_mapping`).

### Custom Reconciliation Tests (`tests/`)
* **`reconcile_daily_sales_to_staging.sql`:** Asserts that total revenue in `fct_daily_sales` matches `stg_retail_sales` within `$0.01`.
* **`reconcile_category_sales_to_staging.sql`:** Verifies that category-level aggregated revenue reconciles back to staging totals.
* **`reconcile_products_to_staging.sql`:** Confirms distinct product counts in `dim_products` match unique non-null items in staging with zero join duplication.

---

## Project Structure

```text
transform/
├── dbt_project.yml
├── macros/
│   └── clean_string.sql
├── models/
│   ├── staging/
│   │   ├── sources.yml
│   │   ├── stg_retail_sales.sql
│   │   └── tests.yml
│   └── marts/
│       ├── dim_categories.sql
│       ├── dim_payment_methods.sql
│       ├── dim_products.sql
│       ├── fct_category_sales.sql
│       ├── fct_daily_sales.sql
│       └── tests.yml
├── seeds/
│   ├── category_departments.csv
│   └── payment_method_mapping.csv
└── tests/
    ├── reconcile_category_sales_to_staging.sql
    ├── reconcile_daily_sales_to_staging.sql
    └── reconcile_products_to_staging.sql
```

---

## How to Run Locally

1. **Install dependencies & verify Snowflake connection:**
   ```bash
   dbt debug
   ```
2. **Execute seeds, models, and all reconciliation tests in DAG order:**
   ```bash
   dbt build
   ```
3. **Generate and view interactive documentation:**
   ```bash
   dbt docs generate
   dbt docs serve
   ```
