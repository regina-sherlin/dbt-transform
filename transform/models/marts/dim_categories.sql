{{config(materialized='table')}}

with categories as (
    SELECT DISTINCT 
        CATEGORY
    FROM {{ref('stg_retail_sales')}}
    WHERE CATEGORY IS NOT NULL
),
departments as (
    SELECT
        *
    FROM {{ref('category_departments')}}
)
SELECT 
    c.CATEGORY,
    COALESCE(d.DEPARTMENT, 'Other') AS DEPARTMENT,
    COALESCE(d.IS_ESSENTIAL_GOODS, false) AS IS_ESSENTIAL_GOODS
FROM categories c 
LEFT JOIN departments d 
    ON c.CATEGORY = d.CATEGORY