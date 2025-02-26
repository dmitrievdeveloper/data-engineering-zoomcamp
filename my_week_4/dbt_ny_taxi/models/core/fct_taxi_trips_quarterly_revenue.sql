{{
    config(
        materialized='view'
    )
}}

WITH fact_trips_yrqrt AS (
    SELECT
        EXTRACT(YEAR FROM pickup_datetime) AS pickup_yr, 
        EXTRACT(QUARTER FROM pickup_datetime) AS pickup_qrt, 
        CONCAT(CAST(EXTRACT(YEAR FROM pickup_datetime) AS STRING), "-Q", 
               CAST(EXTRACT(QUARTER FROM pickup_datetime) AS STRING)) AS pickup_yr_qrt,
        service_type,
        total_amount
    FROM `dbt-project-451121.dbt_nytaxi.fact_trips` 
),

quarterly_rev AS (
    SELECT 
        pickup_yr,
        pickup_qrt,
        pickup_yr_qrt,
        service_type,
        SUM(total_amount) AS quarterly_revenue
    FROM fact_trips_yrqrt
    GROUP BY pickup_yr, pickup_qrt, pickup_yr_qrt, service_type
),

yoy_growth AS (
    SELECT 
        a.pickup_yr,
        a.pickup_qrt,
        a.pickup_yr_qrt,
        a.service_type,
        a.quarterly_revenue,
        b.quarterly_revenue AS last_year_revenue,
        SAFE_DIVIDE(a.quarterly_revenue - b.quarterly_revenue, b.quarterly_revenue) * 100 AS yoy_growth_percentage
    FROM quarterly_rev a
    LEFT JOIN quarterly_rev b 
        ON a.service_type = b.service_type
        AND a.pickup_qrt = b.pickup_qrt
        AND a.pickup_yr = b.pickup_yr + 1  -- Compare to previous year's same quarter
)
 
SELECT * FROM yoy_growth
ORDER BY pickup_yr DESC, pickup_qrt DESC
