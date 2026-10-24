{{ config(materialized='view') }}

with source as (

    select *
    from {{ source(
        'snapchat_ads',
        'snapchat_ads_ad_history_new_ad_names'
    ) }}

),

renamed as (

    select
        cast(ad_id as string) as ad_id,
        cast(ad_group_id as string) as ad_group_id,

        cast(ad_detail_updated_at as timestamp)
            as ad_updated_at,

        nullif(trim(ad_name), '') as ad_name

    from source

)

select *
from renamed
