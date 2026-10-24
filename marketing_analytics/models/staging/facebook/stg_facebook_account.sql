
{{ config(materialized='view') }}

with source as (

    select *
    from {{ source('facebook_ads', 'new_account_de_randomized') }}

),

renamed as (

    select
        cast(account_id as bigint) as account_id,

        nullif(trim(account_name), '') as account_name,

        upper(
            nullif(trim(ad_currency_code), '')
        ) as currency_code,

        cast(account_created_at as timestamp)
            as account_created_at,

        cast(account_updated_at as timestamp)
            as account_updated_at

    from source

)

select *
from renamed
