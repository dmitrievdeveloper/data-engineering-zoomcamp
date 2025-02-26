{{ config(materialized='table') }}  

WITH durations AS (
    SELECT 
        EXTRACT(YEAR FROM pickup_datetime) AS year,
        EXTRACT(MONTH FROM pickup_datetime) AS month,
        pickup_locationid,
        dropoff_locationid,
        pickup_zone,
        dropoff_zone,
        TIMESTAMP_DIFF(dropoff_datetime, pickup_datetime, SECOND) AS trip_duration
    FROM {{ ref('dim_fhv_trips') }}
),

p90 AS (
    SELECT 
        year,
        month,
        pickup_locationid,
        dropoff_locationid,
        pickup_zone,
        dropoff_zone,
        PERCENTILE_CONT(trip_duration, 0.90) OVER (PARTITION BY year, month, pickup_locationid, dropoff_locationid) AS duration_p90
    FROM durations
),

ranked_zones AS (
    SELECT 
    distinct
        year,
        month,
        pickup_locationid,
        dropoff_locationid,
        pickup_zone,
        dropoff_zone,
        duration_p90,
        ROW_NUMBER() OVER (PARTITION BY pickup_zone, year, month ORDER BY duration_p90 DESC) AS rn
    FROM p90
)

SELECT 
distinct
    year,
    month,
    pickup_locationid,
    dropoff_locationid,
    pickup_zone,
    dropoff_zone,
    duration_p90,
    rn
FROM ranked_zones
