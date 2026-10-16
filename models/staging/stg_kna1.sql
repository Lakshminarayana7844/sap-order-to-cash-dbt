with source as (
    select * from {{ ref('kna1') }}
)

select
    kunnr                as customer_id,
    name1                as customer_name,
    land1                as country,
    ort01                as city,
    branche              as industry,
    cast(erdat as date)  as created_on
from source
