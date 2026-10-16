with item_sum as (
    select
        o.order_date,
        sum(case when i.rejection_reason is null then i.net_value else 0 end) as expected
    from {{ ref('stg_vbak') }} o
    join {{ ref('stg_vbap') }} i
        on o.sales_order_id = i.sales_order_id
    group by o.order_date
),

mart as (
    select order_date, sum(net_revenue) as actual
    from {{ ref('fct_daily_revenue') }}
    group by order_date
)

select m.order_date, m.actual, s.expected
from mart m
join item_sum s using (order_date)
where abs(m.actual - s.expected) > 0.01
