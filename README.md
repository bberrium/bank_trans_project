# Bank Customer Analytics — SQL Project

> A relational SQLite database built from raw bank marketing + transaction
> data, featuring an auto-updating balance **trigger**, an aggregation
> **view**, and analytical queries — with a small Python ETL pipeline
> that loads the CSVs.

![Python](https://img.shields.io/badge/Python-3.9-3776AB?logo=python&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-003B57?logo=sqlite&logoColor=white)
![Pandas](https://img.shields.io/badge/pandas-150458?logo=pandas&logoColor=white)
![Academy](https://img.shields.io/badge/Picsart%20Academy-SQL%20Phase-blueviolet)
![Status](https://img.shields.io/badge/status-completed-success)

---

## Overview

This project was built during the **SQL phase at Picsart Academy**.
It takes two raw CSV files — a large customer dataset (42,639 rows) and a
small transaction ledger — and models them in a **SQLite** database.

The core of the project is the **database logic**, not the Python:

- A **trigger** (`update_balance`) that keeps `customers.balance` in sync
  automatically whenever a row is inserted into `operations`.
- A **view** (`customer_summary`) that aggregates each customer's
  operation count and total amount moved.
- A set of **analytical queries** for common banking questions
  (negative balances, top balances, per-customer activity).

---

## Objectives

- Design a small relational schema (`customers` ↔ `operations`)
- Load raw CSV data into SQLite via a reusable Python pipeline
- Enforce business rules at the database level with a **trigger**
- Provide a reusable reporting layer with a **view**
- Write readable, purpose-driven SQL queries

---

## Database Schema

```
┌────────────────────────┐          ┌────────────────────────┐
│      customers         │          │      operations        │
├────────────────────────┤          ├────────────────────────┤
│ id            INTEGER  │◄────┐    │ id            INTEGER  │
│ age           INTEGER  │     │    │ customer_id   INTEGER  │──┐
│ job           TEXT     │     └────│ amount        REAL     │  │
│ marital       TEXT     │          │ operation_type TEXT    │  │
│ education     TEXT     │          └────────────────────────┘  │
│ default       TEXT     │                  ▲                   │
│ balance       REAL     │                  │                   │
│ housing       TEXT     │          trigger: AFTER INSERT       │
│ loan          TEXT     │          updates customers.balance   │
│ contact       TEXT     │                                      │
│ day / month   ...      │◄─────────────────────────────────────┘
│ duration      INTEGER  │
│ campaign      INTEGER  │
│ pdays         INTEGER  │
│ previous      INTEGER  │
│ poutcome      TEXT     │
│ term_deposit  TEXT     │
└────────────────────────┘
```

### Tables

| Table | Rows | Description |
|---|---|---|
| `customers` | ~42,639 | Bank marketing contacts (age, job, education, balance, …) |
| `operations` | 32 | Ledger of deposits / withdrawals per customer |

### Objects

| Object | Type | Purpose |
|---|---|---|
| `update_balance` | Trigger | Adjusts `customers.balance` on every `operations` insert |
| `customer_summary` | View | Per-customer `operation_count` + `total_amount` |

---

## Tech Stack

- **Database:** SQLite 3 (file-based, zero-config)
- **Language:** Python 3.9
- **Libraries:** `pandas`, `sqlite3` (stdlib)
- **Notebook:** Jupyter (exploration & ad-hoc queries)
- **Concepts:** DDL, triggers, views, joins, aggregation, grouping

---

## Getting Started

### 1. Clone

```bash
git clone https://github.com/YOUR_USERNAME/bank-sql-project.git
cd bank-sql-project
```

### 2. Install dependencies

```bash
pip install pandas
```

### 3. Build the database

```bash
python src/create_db.py
```

This reads the two CSVs from `data/db/raw/` and writes `data/db/bank.db`.

### 4. Apply the trigger + view

```bash
sqlite3 data/db/bank.db < src/triggers_views.sql
```

### 5. Run queries

```bash
sqlite3 data/db/bank.db < src/queries.sql
```

---

## Project Structure

```
bank-sql-project/
├── data/
│   └── db/
│       ├── raw/
│       │   ├── BankCustomerData.csv
│       │   └── BankTransaction.csv
│       └── bank.db                # generated
├── src/
│   ├── config.py                  # path configuration
│   ├── create_db.py               # CSV → SQLite loader
│   ├── queries.sql                # analytical queries
│   └── triggers_views.sql         # trigger + view definitions
├── notebooks/
│   └── exploration.ipynb
└── README.md
```

---

## Sample Queries

### 1. Customers with a negative balance

```sql
SELECT * FROM customers WHERE balance < 0;
```

### 2. Operation count per customer

```sql
SELECT customer_id, COUNT(*) AS operation_count
FROM operations
GROUP BY customer_id
ORDER BY operation_count DESC;
```

### 3. Highest-balance customer

```sql
SELECT * FROM customers ORDER BY balance DESC LIMIT 1;
```

### 4. Per-customer summary (via the view)

```sql
SELECT * FROM customer_summary
ORDER BY total_amount DESC;
```

---

## The Trigger

`update_balance` runs **after every insert** on `operations` and mutates
`customers.balance` based on `operation_type`:

```sql
CREATE TRIGGER IF NOT EXISTS update_balance
AFTER INSERT ON operations
BEGIN
    UPDATE customers
    SET balance = CASE
        WHEN NEW.operation_type = 'deposit'    THEN balance + NEW.amount
        WHEN NEW.operation_type = 'withdrawal' THEN balance - NEW.amount
        ELSE balance
    END
    WHERE id = NEW.customer_id;
END;
```

This keeps the denormalized `balance` column consistent without any
application-side bookkeeping — the classic "trigger as business rule"
pattern.

---

## What I Learned

- How to design a small schema and load it from messy CSVs
- When to push logic into the **database layer** (triggers) vs. the app
- Building reusable reporting surfaces with **views**
- Writing SQL that reads like documentation (`CASE`, `GROUP BY`, aliases)
- Debugging real-world data problems — including a **malformed CSV row**
  that broke `pandas.read_csv`

---

## Known Issues / Future Work

- **CSV parsing bug:** `BankCustomerData.csv` contains a corrupted row
  (~line 80) where two records were concatenated, causing
  `pandas.read_csv` to throw `ParserError`. Fix by cleaning the source
  or loading with `on_bad_lines='skip'`.
- **Column mismatch:** `queries.sql` and the view reference `c.name`
  and `c.full_name`, but the `customers` table has no `name` column —
  only `id`, `age`, `job`, etc. Update the view/query to match the
  actual schema.
- **Trigger value mismatch:** the CSV uses `'withdraw'`, but the trigger
  checks for `'withdrawal'`. Withdrawals are currently no-ops. Align
  the string values.
- **Duplicate loader runs:** `create_db.py` calls `to_sql` without
  `if_exists='replace'`, so re-running appends duplicate rows. Add
  `if_exists='replace'` (or a uniqueness guard).
- Migrate from SQLite to **PostgreSQL** for production-style features
  (`EXPLAIN ANALYZE`, indexes, roles).
