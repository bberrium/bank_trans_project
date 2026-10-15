-- ============================================================
-- schema.sql
-- Table definitions for the Bank Customer Analytics project.
-- Run BEFORE loading data (create_db.py applies this first).
-- ============================================================

PRAGMA foreign_keys = ON;

-- Drop in reverse dependency order so re-runs are clean
DROP TABLE IF EXISTS operations;
DROP TABLE IF EXISTS customers;

-- ------------------------------------------------------------
-- customers: one row per bank customer (from BankCustomerData.csv)
-- ------------------------------------------------------------
CREATE TABLE customers (
    id           INTEGER PRIMARY KEY,      -- original CSV id
    age          INTEGER,
    job          TEXT,
    marital      TEXT,
    education    TEXT,
    "default"    TEXT,                     -- quoted: reserved word
    balance      REAL DEFAULT 0,           -- kept in sync by trigger
    housing      TEXT,
    loan         TEXT,
    contact      TEXT,
    day          INTEGER,
    month        TEXT,
    duration     INTEGER,
    campaign     INTEGER,
    pdays        INTEGER,
    previous     INTEGER,
    poutcome     TEXT,
    term_deposit TEXT
);

-- ------------------------------------------------------------
-- operations: ledger of deposits / withdrawals
-- (from BankTransaction.csv)
-- ------------------------------------------------------------
CREATE TABLE operations (
    id             INTEGER PRIMARY KEY,
    customer_id    INTEGER NOT NULL,
    amount         REAL    NOT NULL CHECK (amount >= 0),
    operation_type TEXT    NOT NULL CHECK (operation_type IN ('deposit', 'withdraw')),
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- Indexes to speed up the common joins / filters
-- ------------------------------------------------------------
CREATE INDEX idx_operations_customer ON operations(customer_id);
CREATE INDEX idx_customers_balance   ON customers(balance);