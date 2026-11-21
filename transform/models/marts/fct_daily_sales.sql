{{config(materialized='table')}}

SELECT 
    TRANSACTION_DATE, 
    count(distinct TRANSACTION_ID) as total_orders,
    sum(QUANTITY) as total_items_sold,
    sum(TOTAL_SPENT) as daily_revenue,
    round(avg(TOTAL_SPENT),2) as avg_order_value
FROM {{ ref('stg_retail_sales')}}
where TRANSACTION_DATE is not NULL
group by TRANSACTION_DATE
order by TRANSACTION_DATE