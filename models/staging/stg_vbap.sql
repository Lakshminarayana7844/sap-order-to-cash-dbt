with source as (
    select * from {{ ref('vbap') }}
)

select
    vbeln                          as sales_order_id,
    posnr                          as item_number,
    matnr                          as material_id,
    cast(kwmeng as double)         as order_quantity,
    cast(netpr as double)          as net_price,
    waers                          as currency,
    nullif(trim(cast(abgru as varchar)), '')        as rejection_reason,
    cast(kwmeng as double) * cast(netpr as double) as net_value
from source
