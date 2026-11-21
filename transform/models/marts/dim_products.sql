{{config(materialized='table')}}

with products as (
    SELECT DISTINCT 
        ITEM,
        CATEGORY
    FROM {{ref('stg_retail_sales')}}
    WHERE ITEM IS NOT NULL
)
SELECT *
FROM products 