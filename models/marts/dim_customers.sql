with customers as (
    select * from {{ ref('stg_kna1') }}
),

orders as (
    select * from {{ ref('fct_sales_orders') }}
),

agg as (
    select
        customer_id,
        count(*) as lifetime_orders,
        sum(gross_net_value) as lifetime_value,
        max(order_date) as last_order_date
    from orders
    group by customer_id
)

select
    c.customer_id,
    c.customer_name,
    c.country,
    c.city,
    c.industry,
    c.created_on,
    coalesce(a.lifetime_orders, 0) as lifetime_orders,
    coalesce(a.lifetime_value, 0)  as lifetime_value,
    a.last_order_date,
    case
        when coalesce(a.lifetime_value, 0) >= 100000 then 'gold'
        when coalesce(a.lifetime_value, 0) >= 30000  then 'silver'
        else 'bronze'
    end as value_segment
from customers c
left join agg a
    on c.customer_id = a.customer_id
