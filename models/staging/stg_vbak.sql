with source as (
    select * from {{ ref('vbak') }}
)

select
    vbeln                 as sales_order_id,
    auart                 as order_type,
    cast(erdat as date)   as order_date,
    kunnr                 as customer_id,
    vkorg                 as sales_org,
    cast(gjahr as integer) as fiscal_year,
    gbstk                 as overall_status
from source
