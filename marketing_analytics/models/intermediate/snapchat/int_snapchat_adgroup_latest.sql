{{ config(materialized='view') }}

with adgroup_history as (

    select
        source_surrogate_key,
        ad_group_id,
        campaign_id,
        ad_group_name,
        ad_group_updated_at

    from {{ ref('stg_snapchat_adgroup') }}

),

ranked as (

    select
        *,

        row_number() over (
            partition by ad_group_id
            order by
                ad_group_updated_at desc nulls last,
                source_surrogate_key desc
        ) as row_num

    from adgroup_history

),

latest as (

    select
        ad_group_id,
        campaign_id,
        ad_group_name,
        ad_group_updated_at

    from ranked
    where row_num = 1

)

select *
from latest
