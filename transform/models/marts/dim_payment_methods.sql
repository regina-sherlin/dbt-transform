{{config(materialized='table')}}

with sales as (
    SELECT DISTINCT 
        PAYMENT_METHOD
    FROM {{ref('stg_retail_sales')}}
    where PAYMENT_METHOD is not NULL
),
payment_methods as (
    SELECT 
        PAYMENT_METHOD,
        PAYMENT_CATEGORY,
        IS_DIGITAL,
        HAS_PROCESSING_FEE
    FROM {{ref('payment_method_mapping')}} 
)
SELECT 
    s.PAYMENT_METHOD,
    COALESCE(p.PAYMENT_CATEGORY,'Other') AS PAYMENT_CATEGORY,
    COALESCE(p.IS_DIGITAL, false) AS IS_DIGITAL,
    COALESCE(p.HAS_PROCESSING_FEE, false) AS HAS_PROCESSING_FEE
FROM sales s 
LEFT JOIN payment_methods p 
    ON s.PAYMENT_METHOD = p.PAYMENT_METHOD