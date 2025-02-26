{{
    config(
        materialized='table'
    )
}} 

with fhvtrips as (
    select *
    from {{ ref('stg_ext_fhv_taxi') }}
), 

dim_zones as (
    select * from {{ ref('dim_zones') }}
    where borough != 'Unknown'
)
select trips.tripid, 
    trips.pickup_locationid, 
    pickup_zone.borough as pickup_borough, 
    pickup_zone.zone as pickup_zone, 
    trips.dropoff_locationid,
    dropoff_zone.borough as dropoff_borough, 
    dropoff_zone.zone as dropoff_zone,  
    trips.pickup_datetime, 
    trips.dropoff_datetime, 
    trips.sr_flag, 
    trips.dispatching_base_num,
    trips.affiliated_base_number

from fhvtrips as trips
inner join dim_zones as pickup_zone
on trips.pickup_locationid = pickup_zone.locationid
inner join dim_zones as dropoff_zone
on trips.dropoff_locationid = dropoff_zone.locationid
