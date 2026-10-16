with items as (
    select * from {{ ref('stg_vbap') }}
),

orders as (
    select * from {{ ref('stg_vbak') }}
)

select
    o.sales_order_id,
    o.order_type,
    o.order_date,
    o.fiscal_year,
    o.sales_org,
    o.overall_status,
    case o.overall_status
        when 'A' then 'open'
        when 'B' then 'in_delivery'
        when 'C' then 'complete'
    end as status_label,
    o.customer_id,
    count(i.item_number)                          as item_count,
    sum(case when i.rejection_reason is null then i.net_value else 0 end) as open_net_value,
    sum(i.net_value)                              as gross_net_value,
    sum(case when i.rejection_reason is not null then 1 else 0 end) as rejected_items
from orders o
left join items i
    on o.sales_order_id = i.sales_order_id
group by
    o.sales_order_id, o.order_type, o.order_date, o.fiscal_year,
    o.sales_org, o.overall_status, o.customer_id
