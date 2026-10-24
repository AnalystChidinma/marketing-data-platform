{{ config(materialized='view') }}

with source as (

    select *
    from {{ source(
        'snapchat_ads',
        'snapchat_ads_campaign_history_new_campaign_names'
    ) }}

),

renamed as (

    select
        cast(campaign_id as string) as campaign_id,

        cast(account_id as string) as account_id,

        nullif(trim(campaign_name), '') as campaign_name

    from source

)

select *
from renamed
