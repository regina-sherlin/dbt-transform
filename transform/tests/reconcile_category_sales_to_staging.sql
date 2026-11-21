WITH stg as (
    SELECT
        CATEGORY,
        SUM(TOTAL_SPENT) AS STG_CAT_REVENUE
    FROM {{ref('stg_retail_sales')}}
    WHERE CATEGORY IS NOT NULL
    GROUP BY CATEGORY
),
marts as (
    SELECT
        CATEGORY,
        TOTAL_REVENUE_BY_CATEGORY AS MART_CAT_REVENUE
    FROM {{ref('fct_category_sales')}}
)
SELECT
    stg.CATEGORY,
    stg.STG_CAT_REVENUE,
    marts.MART_CAT_REVENUE
FROM stg
full outer JOIN marts
    ON stg.CATEGORY = marts.CATEGORY
WHERE abs(STG_CAT_REVENUE - MART_CAT_REVENUE) > 0.01