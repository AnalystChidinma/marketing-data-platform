{{ config(materialized='table') }}

with facebook as (

    select
        cast(ad_date as date) as performance_date,
        cast(platform as string) as platform,
        cast(account_id as string) as account_id,
        cast(campaign_id as string) as campaign_id,
        campaign_name,
        currency_code,

        cast(spend as decimal(20, 6)) as spend,
        cast(impressions as bigint) as impressions,
        cast(clicks as bigint) as clicks

    from {{ ref('int_facebook_ads_performance') }}

),

snapchat as (

    select
        cast(ad_date as date) as performance_date,
        cast(platform as string) as platform,
        cast(account_id as string) as account_id,
        cast(campaign_id as string) as campaign_id,
        campaign_name,
        currency_code,

        cast(spend as decimal(20, 6)) as spend,
        cast(impressions as bigint) as impressions,
        cast(clicks as bigint) as clicks

    from {{ ref('int_snapchat_ads_performance') }}

),

unified as (

    select * from facebook

    union all

    select * from snapchat

),

aggregated as (

    select
        performance_date,
        platform,
        account_id,
        campaign_id,
        currency_code,

        max(campaign_name) as campaign_name,

        count(*) as source_record_count,

        count_if(clicks is null) as missing_click_rows,
        count_if(impressions is null) as missing_impression_rows,

        sum(spend) as spend,

        -- Complete impression total
        case
            when count_if(impressions is null) > 0
                then null
            else sum(impressions)
        end as impressions,

        -- Complete click total
        case
            when count_if(clicks is null) > 0
                then null
            else sum(clicks)
        end as clicks,

        -- Sum of available measurements
        sum(clicks) as known_clicks,
        sum(impressions) as known_impressions,

        -- Completeness indicators
        coalesce(
            count_if(clicks is null) = 0,
            false
        ) as clicks_complete,

        coalesce(
            count_if(impressions is null) = 0,
            false
        ) as impressions_complete

    from unified

    group by
        performance_date,
        platform,
        account_id,
        campaign_id,
        currency_code

),

final as (

    select
        *,

        -- Click-through rate (%)
        case
            when impressions > 0 and clicks is not null
                then round(
                    cast(clicks as double)
                    / impressions * 100,
                    4
                )
        end as ctr,

        -- Cost per click
        case
            when clicks > 0
                then round(
                    cast(spend as double) / clicks,
                    4
                )
        end as cpc,

        -- Cost per 1,000 impressions
        case
            when impressions > 0
                then round(
                    cast(spend as double)
                    / impressions * 1000,
                    4
                )
        end as cpm

    from aggregated

)

select *
from final
