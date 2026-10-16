select sales_order_id, item_number, net_value
from {{ ref('stg_vbap') }}
where net_value < 0
