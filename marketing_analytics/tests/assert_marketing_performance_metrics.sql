select *
from {{ ref('fct_marketing_performance') }}

where
    spend < 0

    or (impressions < 0)
    or (clicks < 0)

    or (missing_click_rows > 0 and clicks is not null)

    or (
        missing_impression_rows > 0
        and impressions is not null
    )

    or (
        clicks is not null
        and impressions > 0
        and abs(
            ctr - round(
                cast(clicks as double)
                / impressions * 100,
                4
            )
        ) > 0.0001
    )

    or (
        clicks > 0
        and abs(
            cpc - round(
                cast(spend as double) / clicks,
                4
            )
        ) > 0.0001
    )

    or (
        impressions > 0
        and abs(
            cpm - round(
                cast(spend as double)
                / impressions * 1000,
                4
            )
        ) > 0.0001
    )
