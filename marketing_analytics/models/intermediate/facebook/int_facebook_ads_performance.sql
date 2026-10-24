
{{ config(materialized='view') }}

with ads_performance as (

    select
        ad_id,
        account_id,
        ad_date,
        spend,
        impressions,
        clicks
    from {{ ref('stg_facebook_ads_stats') }}

),

ads as (

    select
        ad_id,
        campaign_id,
        ad_group_id,
        account_id,
        ad_name,
        ad_status
    from {{ ref('stg_facebook_ads') }}

),

campaigns as (

    select
        campaign_id,
        campaign_name
    from {{ ref('stg_facebook_campaign') }}

),

accounts as (

    select
        account_id,
        account_name,
        currency_code
    from {{ ref('stg_facebook_account') }}

),

joined as (

    select
        p.ad_date,
        'facebook' as platform,

        p.account_id,
        acc.account_name,
        acc.currency_code,

        p.ad_id,
        a.ad_group_id,
        a.campaign_id,

        a.ad_name,
        a.ad_status,
        c.campaign_name,

        p.spend,
        p.impressions,
        p.clicks

    from ads_performance p

    left join ads a
        on p.ad_id = a.ad_id
        and p.account_id = a.account_id

    left join campaigns c
        on a.campaign_id = c.campaign_id

    left join accounts acc
        on p.account_id = acc.account_id

)

select *
from joined
