# CBA dbt Analytics Layer

A production-style analytics engineering project built on top of Australian banking transaction data. Implements a full 3-layer dbt architecture — staging, intermediate, and marts — transforming raw transaction data into business-ready analytics including customer segmentation and spending trend analysis.

## Architecture

```
raw.transactions (PostgreSQL)
raw.accounts (PostgreSQL)
        │
        ▼
Staging Layer (views)
   ├── stg_transactions   — cleaned, typed, standardised transactions
   └── stg_accounts       — cleaned account master data
        │
        ▼
Intermediate Layer (views)
   └── int_customer_monthly_spend   — monthly spend per customer per category
        │
        ▼
Marts Layer (tables)
   ├── mart_customer_segments     — customer segmentation (Premium / High Value / Regular / Low Activity)
   ├── mart_category_trends       — monthly spend trends by merchant category
   └── mart_monthly_summary       — portfolio-level monthly summary
```

## Tech Stack

| Layer | Tool |
|---|---|
| Transformation | dbt-postgres 1.10 |
| Storage | PostgreSQL 15 |
| Data source | cba-banking-pipeline (95k transactions, 500 accounts) |

## Quick Start

### Prerequisites
- Python 3.10+
- PostgreSQL running with cba_pipeline database populated
- See [cba-banking-pipeline](https://github.com/vivianasoyoung/cba-banking-pipeline) to set up the source data

### 1. Install dbt

```bash
pip install dbt-postgres
```

### 2. Configure connection

```bash
mkdir -p ~/.dbt
cat > ~/.dbt/profiles.yml << 'EOF'
cba_dbt_analytics:
  target: dev
  outputs:
    dev:
      type: postgres
      host: 127.0.0.1
      port: 5432
      dbname: cba_pipeline
      user: airflow
      password: airflow
      schema: staging
      threads: 4
EOF
```

### 3. Run the models

```bash
cd cba_dbt_analytics
dbt run
```

### 4. Run tests

```bash
dbt test
```

### 5. Generate and serve docs

```bash
dbt docs generate
dbt docs serve --port 8081
```

Open http://localhost:8081 to see the full lineage graph.

## Models

### Staging
| Model | Materialisation | Description |
|---|---|---|
| stg_transactions | view | Cleaned transactions — standardised columns, filtered declined |
| stg_accounts | view | Cleaned account master data |

### Intermediate
| Model | Materialisation | Description |
|---|---|---|
| int_customer_monthly_spend | view | Monthly spend aggregated per account per merchant category |

### Marts
| Model | Materialisation | Description |
|---|---|---|
| mart_customer_segments | table | 500 accounts segmented by average monthly spend |
| mart_category_trends | table | 84 rows of monthly spend trends by merchant category |
| mart_monthly_summary | table | 7 months of portfolio-level transaction summaries |

## Customer Segments

| Segment | Criteria |
|---|---|
| Premium | Average monthly spend ≥ $5,000 |
| High Value | Average monthly spend ≥ $2,000 |
| Regular | Average monthly spend ≥ $500 |
| Low Activity | Average monthly spend < $500 |

## Data Tests

| Test | Column | Model |
|---|---|---|
| unique | transaction_id | raw.transactions |
| not_null | transaction_id | raw.transactions |
| not_null | amount | raw.transactions |
| not_null | transaction_type | raw.transactions |
| unique | account_id | raw.accounts |
| not_null | account_id | raw.accounts |

## Project Structure

```
cba-dbt-analytics/
└── cba_dbt_analytics/
    ├── models/
    │   ├── staging/
    │   │   ├── sources.yml
    │   │   ├── stg_transactions.sql
    │   │   └── stg_accounts.sql
    │   ├── intermediate/
    │   │   └── int_customer_monthly_spend.sql
    │   └── marts/
    │       ├── mart_customer_segments.sql
    │       ├── mart_category_trends.sql
    │       └── mart_monthly_summary.sql
    └── dbt_project.yml
```
