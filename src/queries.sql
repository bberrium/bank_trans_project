-- 1. All customers (first 10)
SELECT id, age, job, marital, education, balance, term_deposit
FROM customers
LIMIT 10;

-- 2. Customers with a negative balance
SELECT id, age, job, balance
FROM customers
WHERE balance < 0
ORDER BY balance ASC;

-- 3. Operation count per customer
SELECT
    o.customer_id,
    c.job,
    COUNT(*) AS operation_count
FROM operations o
JOIN customers c ON c.id = o.customer_id
GROUP BY o.customer_id, c.job
ORDER BY operation_count DESC;

-- 4. Top balance
SELECT id, age, job, balance
FROM customers
ORDER BY balance DESC
LIMIT 1;

-- 5. Per-customer summary (view)
SELECT * FROM customer_summary ORDER BY total_amount DESC;

-- 6. Deposits vs withdrawals totals
SELECT operation_type, COUNT(*), SUM(amount)
FROM operations
GROUP BY operation_type;
