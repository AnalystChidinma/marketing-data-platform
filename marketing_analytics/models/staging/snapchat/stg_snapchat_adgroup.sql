{{ config(materialized='view') }}

with source as (

    select *
    from {{ source(
        'snapchat_ads',
        'snapchat_ads_adgroup_history_new_ad_group_names'
    ) }}

),

renamed as (

    select
        cast(_surrogate_key as string) as source_surrogate_key,

        cast(ad_group_id as string) as ad_group_id,

        cast(campaign_id as string) as campaign_id,

        cast(ad_group_updated_at as timestamp)
            as ad_group_updated_at,

        nullif(trim(ad_group_name), '') as ad_group_name

    from source

)

select *
from renamed
