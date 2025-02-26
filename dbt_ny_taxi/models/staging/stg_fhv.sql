{{
    config(
        materialized='view'
    )
}} 

with tripdata as 
(
  select *
    --row_number() over(partition by vendorid, lpep_pickup_datetime) as rn
  from {{ source('staging','ext_fhv_taxi') }}
)

SELECT
    -- Identifiers
    {{ dbt_utils.generate_surrogate_key(['dispatching_base_num', 'pickup_datetime']) }} as tripid,
    {{ dbt.safe_cast("pulocationid", api.Column.translate_type("integer")) }} as pickup_locationid,
    {{ dbt.safe_cast("dolocationid", api.Column.translate_type("integer")) }} as dropoff_locationid,
    dispatching_base_num,


    -- timestamps
    cast(pickup_datetime as timestamp) as pickup_datetime,
    cast(dropoff_datetime as timestamp) as dropoff_datetime,

    -- Location Info
    --SAFE_CAST(pu_location_id AS INT64) AS pickup_locationid,
    --SAFE_CAST(do_location_id AS INT64) AS dropoff_locationid,

    -- Additional Fields
    SAFE_CAST(sr_flag AS INT64) AS sr_flag,
    affiliated_base_number

FROM tripdata
WHERE dispatching_base_num IS NOT NULL
