{{config(materialized='table')}}


SELECT 
    CATEGORY,
    SUM(TOTAL_SPENT) AS TOTAL_REVENUE_BY_CATEGORY
FROM {{ref('stg_retail_sales')}}
where CATEGORY IS NOT NULL
GROUP BY CATEGORY