
{{config(materialized='table')}}

with source as (
    SELECT *
    FROM {{ source('src', 'RETAIL_TB') }}
),
cleaned as (
    SELECT
        TRANSACTION_ID,
        CUSTOMER_ID,
        CATEGORY,
        {{clean_string('ITEM')}} as ITEM,
        cast(PRICE_PER_UNIT as decimal(10,2)) as PRICE_PER_UNIT,
        cast(QUANTITY as integer) as QUANTITY,
        TOTAL_SPENT AS RAW_TOTAL_SPENT,
        COALESCE(cast(TOTAL_SPENT as decimal(10,2)), 
            QUANTITY * (cast(PRICE_PER_UNIT AS decimal(10,2)))
        ) AS TOTAL_SPENT,
        COALESCE({{clean_string('PAYMENT_METHOD')}}, 'Unknown') as PAYMENT_METHOD,
        COALESCE({{clean_string('LOCATION')}}, 'Unknown') as LOCATION,
        TRANSACTION_DATE,
        DISCOUNT_APPLIED
    FROM {{ source('src', 'RETAIL_TB') }}
    WHERE TRANSACTION_ID IS NOT NULL
)
select * from cleaned