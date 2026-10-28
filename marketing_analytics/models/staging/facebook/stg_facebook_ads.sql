{{ config(materialized='view') }}

with source as (

    select *
    from {{ source('facebook_ads', 'new_ads_de_randomized') }}

),

renamed as (

    select
        cast(ad_id as bigint) as ad_id,
        cast(campaign_id as bigint) as campaign_id,
        cast(ad_group_id as bigint) as ad_group_id,
        cast(account_id as bigint) as account_id,

        nullif(trim(ad_name), '') as ad_name,

        upper(trim(ad_status)) as ad_status,

        try_cast(ad_updated_at as timestamp)
            as ad_updated_at

    from source

)

select *
from renamed
