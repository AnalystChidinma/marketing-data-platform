{{ config(materialized='view') }}

with source as (

    select *
    from {{ source('facebook_ads', 'ads_stats') }}

),

renamed as (

    select
        cast(ad_id as bigint) as ad_id,
        cast(account_id as bigint) as account_id,
        cast(ad_date as date) as ad_date,

        try_cast(
            ad_spend as decimal(18, 2)
        ) as spend,

        try_cast(
            nullif(lower(trim(ad_impressions)), 'null')
            as bigint
        ) as impressions,

        try_cast(
            nullif(lower(trim(ad_clicks)), 'null')
            as bigint
        ) as clicks

    from source

)

select *
from renamed
