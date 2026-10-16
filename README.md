# sap-order-to-cash-dbt

A dbt project that models SAP-style order-to-cash data (SD module extracts plus customer and material master) into clean analytics marts, running entirely on DuckDB. Built to show how raw ECC table extracts (VBAK, VBAP, KNA1, MARA) turn into tested, documented data models a BW/4HANA or analytics engineer would ship.

## What it does

- Loads synthetic SAP-style extracts as dbt seeds: sales order headers (`vbak`), items (`vbap`), customers (`kna1`), materials (`mara`). 180 orders, 462 items, 30 customers, 20 materials.
- Staging views rename cryptic SAP field names to readable ones (`vbeln` -> `sales_order_id`, `kwmeng` -> `order_quantity`) and cast types.
- Marts:
  - `fct_sales_orders`: one row per order with item counts, gross and open net value, rejected items, status labels.
  - `dim_customers`: customer master enriched with lifetime orders, lifetime value, last order date and a gold/silver/bronze value segment.
  - `fct_daily_revenue`: daily net revenue per sales org, excluding rejected items.
- 23 tests: uniqueness, not-null, referential integrity (items -> orders, orders -> customers), accepted values, non-negative amounts, and a custom reconciliation test that proves `fct_daily_revenue` sums back to item level.

## Run it

```bash
pip install -r requirements.txt
dbt deps
dbt build      # seeds + models + tests, all in one embedded DuckDB file
dbt docs generate && dbt docs serve   # lineage graph and column docs
```

Or with Docker:

```bash
docker build -t sap-o2c-dbt .
docker run --rm sap-o2c-dbt          # runs dbt deps + dbt build
```

No warehouse account needed. DuckDB is embedded; the whole build runs in about a second.

## Project layout

```
seeds/            SAP-style CSV extracts (generated, no real data)
models/staging/   typed, renamed views over the raw extracts
models/marts/     business-facing fact and dimension tables
tests/            custom singular tests (negative values, revenue reconciliation)
```

## Design notes

- Rejected items (`abgru` set) are kept but excluded from open/net revenue, matching how SAP SD reports treat rejected lines.
- Customer segmentation thresholds (100k / 30k EUR lifetime value) are deliberately simple and documented in `dim_customers.sql`.
- SAP field names are kept in seeds and sources on purpose: the staging layer is where translation happens, same pattern as a BW datasource to ADSO flow.

## Limits

- Synthetic data with a fixed random seed; volumes are small so CI stays fast.
- One sales org, one currency (EUR), one order type. A real project would parameterize these.
- No incremental models: DuckDB rebuilds are cheap at this size, so everything is a full refresh.

## CI

GitHub Actions runs `dbt deps && dbt build` on every push and pull request (`.github/workflows/ci.yml`). Green means seeds, all models and all 23 tests pass.
