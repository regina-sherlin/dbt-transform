
with stg as (
    select sum(TOTAL_SPENT) as stg_total 
    from {{ref('stg_retail_sales')}}
    where TRANSACTION_DATE is not null
),
mart as (
    select sum(DAILY_REVENUE) as mart_total 
    from {{ref('fct_daily_sales')}}
)
SELECT 
    stg_total,
    mart_total  
FROM stg 
CROSS JOIN mart
where abs(stg_total - mart_total) > 0.01