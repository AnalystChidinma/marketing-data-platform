
{{ config(materialized='view') }}

with source as (

    select *
    from {{ source('snapchat_ads', 'snapchat_ads_stats') }}

),

renamed as (

    select
        cast(ad_detail_id as string) as ad_id,
        cast(ad_date as date) as ad_date,

        lower(nullif(trim(ad_country), '')) as country_code,
        upper(nullif(trim(ad_currency_code), '')) as currency_code,

        cast(ad_spend as double) as spend,
        cast(ad_impressions as bigint) as impressions,

        try_cast(
            nullif(lower(trim(ad_clicks)), 'null')
            as bigint
        ) as clicks,

        nullif(trim(data_src), '') as source_name

    from source

)

select *
from renamed
