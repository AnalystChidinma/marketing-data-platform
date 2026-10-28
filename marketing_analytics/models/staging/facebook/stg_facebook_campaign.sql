{{ config(materialized='view') }}

with source as (

    select *
    from {{ source('facebook_ads', 'new_campaign_de_randomized') }}

),

renamed as (

    select
        cast(campaign_id as bigint) as campaign_id,

        nullif(trim(campaign_name), '') as campaign_name,

        try_cast(campaign_updated_at as timestamp)
            as campaign_updated_at

    from source

)

select *
from renamed
