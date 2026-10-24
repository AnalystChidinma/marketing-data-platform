{{ config(materialized='view') }}

with ads_performance as (

    select
        ad_id,
        ad_date,
        country_code,
        currency_code,
        spend,
        impressions,
        clicks,
        source_name

    from {{ ref('stg_snapchat_ads_stats') }}

),

ads as (

    select
        ad_id,
        ad_group_id,
        ad_name,
        ad_updated_at

    from {{ ref('stg_snapchat_ads') }}

),

adgroups as (

    select
        ad_group_id,
        campaign_id,
        ad_group_name

    from {{ ref('int_snapchat_adgroup_latest') }}

),

campaigns as (

    select
        campaign_id,
        account_id,
        campaign_name

    from {{ ref('stg_snapchat_campaign') }}

),

joined as (

    select
        p.ad_date,
        'snapchat' as platform,

        p.country_code,
        p.currency_code,
        p.source_name,

        c.account_id,
        p.ad_id,

        a.ad_group_id,
        g.campaign_id,

        a.ad_name,
        g.ad_group_name,
        c.campaign_name,

        p.spend,
        p.impressions,
        p.clicks

    from ads_performance p

    left join ads a
        on p.ad_id = a.ad_id

    left join adgroups g
        on a.ad_group_id = g.ad_group_id

    left join campaigns c
        on g.campaign_id = c.campaign_id

)

select *
from joined
