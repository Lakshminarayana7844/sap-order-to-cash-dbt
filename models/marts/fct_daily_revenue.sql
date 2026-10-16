with items as (
    select * from {{ ref('stg_vbap') }}
),

orders as (
    select * from {{ ref('stg_vbak') }}
)

select
    o.order_date,
    o.sales_org,
    count(distinct o.sales_order_id)                    as order_count,
    count(i.item_number)                                as item_count,
    sum(case when i.rejection_reason is null then i.net_value else 0 end) as net_revenue,
    sum(case when i.rejection_reason is not null then i.net_value else 0 end) as rejected_value
from orders o
join items i
    on o.sales_order_id = i.sales_order_id
group by o.order_date, o.sales_org
order by o.order_date
