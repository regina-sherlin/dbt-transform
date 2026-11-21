with stg as (
    SELECT
     count(DISTINCT ITEM) as stg_total_item_count
    FROM {{ref('stg_retail_sales')}}
),
mart as (
    SELECT 
        count(DISTINCT ITEM) as mart_total_item_count
    FROM {{ref('dim_products')}}
)
select 
    stg_total_item_count,
    mart_total_item_count
FROM stg 
CROSS JOIN mart
where abs(stg_total_item_count - mart_total_item_count) > 0.01
