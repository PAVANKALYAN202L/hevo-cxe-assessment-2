# Hevo Data CXE Assessment

This repository contains the deliverables for the Hevo Data Customer Experience Engineer take-home assessment.

---

## Assessment I — PostgreSQL to Snowflake Pipeline

### Overview
Built a real-time data pipeline from a local PostgreSQL database (running in Docker) to Snowflake using Hevo Data with Logical Replication.

### Setup

**Prerequisites:**
- Docker Desktop
- ngrok (for tunneling local Postgres to Hevo cloud)
- Snowflake Trial Account
- Hevo Free Trial (via Snowflake Partner Connect)

**Source Database (Docker PostgreSQL):**
```bash
docker run --name hevo-postgres \
  -e POSTGRES_USER=$DB_USER \
  -e POSTGRES_PASSWORD=$DB_PASSWORD \
  -e POSTGRES_DB=$DB_NAME \
  -p 5432:5432 \
  -d postgres:15 \
  -c wal_level=logical \
  -c max_replication_slots=10 \
  -c max_wal_senders=10
```

**Expose via ngrok:**
```bash
ngrok tcp 5432
```

### Tables Created
- `customers` — customer details with JSON address field
- `orders` — order records with status
- `feedback` — order feedback with ratings

### Hevo Pipeline
- **Pipeline Name:** PostgreSQL-Assessment-1
- **Pipeline ID:** #1
- **Source:** PostgreSQL (Docker via ngrok)
- **Destination:** Snowflake Partner Connect
- **Ingestion Mode:** Logical Replication

### Transformations

**1. Username Extraction (Python Transformation)**
Extracts username from email field for the customers table.
See: `assessment-1/transformations/username_transform.py`

**2. Order Events (Hevo Model)**
Derives `event_type` from order `status` field.
See: `assessment-1/models/order_events.sql`

### Assumptions
- Used `VARCHAR(50)` for order status instead of PostgreSQL ENUM for simpler logical replication
- Used Docker postgres:15 as source for clean logical replication setup
- Used ngrok TCP tunnel to expose local Docker Postgres to Hevo cloud

---

## Assessment II — Snowflake Data Cleaning Challenge

### Overview
Cleaned and transformed messy raw e-commerce data ingested from PostgreSQL into Snowflake, producing a unified analytics-ready dataset.

### Raw Tables
- `customers_raw` — Raw customer data with duplicates, inconsistent formats
- `orders_raw` — Raw orders with nulls, negative amounts, duplicates
- `products_raw` — Raw products with inconsistent casing
- `country_dim` — Reference table for country code standardization

### Hevo Pipeline
- **Pipeline Name:** PostgreSQL-Assessment-1 (shared pipeline)
- **Pipeline ID:** #1
- Raw tables ingested via same Logical Replication pipeline

### Models (SQL Transformations)

| Model | Tasks | Description |
|-------|-------|-------------|
| `cleaned_customers` | 5, 6 | Deduplication, email lowercase, phone standardization, country normalization, NULL handling |
| `cleaned_orders` | 7 | Duplicate removal, negative amount fix, NULL amount fallback, currency uppercase, USD conversion |
| `cleaned_products` | 8 | Title case names/categories, inactive product marking |
| `final_analytics_dataset` | 9, 10 | Full JOIN with orphan/invalid customer handling |

### Data Cleaning Logic

**Customers (Tasks 5 & 6):**
- Kept most recent record per `customer_id` using `ROW_NUMBER()` with `QUALIFY`
- Standardized emails to lowercase
- Cleaned phone numbers to 10 digits using `REGEXP_REPLACE`, marked invalid as "Unknown"
- Standardized country codes: `usa/UnitedStates` → `US`, `IND/India` → `IN`, `SINGAPORE` → `SG`
- Replaced NULL `created_at` with `1900-01-01`

**Orders (Task 7):**
- Removed exact duplicates using `SELECT DISTINCT`
- Replaced negative amounts with `0` using `GREATEST()`
- Replaced NULL amounts with median of customer's transactions
- Standardized currency to uppercase using `UPPER()`
- Added `amount_usd` column with conversion rates: INR×0.012, SGD×0.74, EUR×1.08

**Products (Task 8):**
- Standardized product names and categories using `INITCAP()`
- Marked inactive products (`active_flag = 'N'`) as "Discontinued Product"

**Final Dataset (Tasks 9 & 10):**
- LEFT JOINed all cleaned tables to preserve all orders
- Marked missing customers as "Orphan Customer"
- Marked missing products as "Unknown Product"
- Marked completely NULL customer records as "Invalid Customer"

### Assumptions
- Currency conversion rates: INR=0.012, SGD=0.74, EUR=1.08 (approximate)
- Phone numbers are considered valid only if they contain exactly 10 digits after removing non-numeric characters
- NULL amount fallback uses median of that customer's other transactions; defaults to 0 if no other transactions exist

---

## Repository Structure

```
hevo-cxe-assessment/
├── README.md
├── .env.example
├── .gitignore
├── assessment-1/
│   ├── ddl/
│   │   ├── create_tables.sql
│   │   └── insert_data.sql
│   ├── transformations/
│   │   └── username_transform.py
│   ├── models/
│   │   └── order_events.sql
│   └── validation/
│       └── validation_queries.sql
└── assessment-2/
    ├── ddl/
    │   ├── create_raw_tables.sql
    │   └── insert_raw_data.sql
    ├── models/
    │   ├── cleaned_customers.sql
    │   ├── cleaned_orders.sql
    │   ├── cleaned_products.sql
    │   └── final_analytics_dataset.sql
    └── validation/
        └── verify_results.sql
```

---

## Important Notes
- No credentials or access keys are stored in this repository
- Use `.env.example` as a template — copy to `.env` and fill in values locally
- `.env` is listed in `.gitignore` and must never be committed
