with source as (
    select * from {{ ref('mara') }}
)

select
    matnr               as material_id,
    maktx               as material_name,
    matkl               as material_group,
    meins               as base_unit,
    cast(netpr as double) as standard_price
from source
