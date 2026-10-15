-- Trigger: keep customers.balance in sync with new operations
DROP TRIGGER IF EXISTS update_balance;

CREATE TRIGGER update_balance
AFTER INSERT ON operations
FOR EACH ROW
BEGIN
    UPDATE customers
    SET balance = CASE
        WHEN NEW.operation_type = 'deposit'  THEN balance + NEW.amount
        WHEN NEW.operation_type = 'withdraw' THEN balance - NEW.amount
        ELSE balance
    END
    WHERE id = NEW.customer_id;
END;

-- View: per-customer activity summary
DROP VIEW IF EXISTS customer_summary;

CREATE VIEW customer_summary AS
SELECT
    c.id,
    c.job,
    c.age,
    c.balance,
    COUNT(o.id)                AS operation_count,
    COALESCE(SUM(o.amount), 0) AS total_amount
FROM customers c
LEFT JOIN operations o ON o.customer_id = c.id
GROUP BY c.id, c.job, c.age, c.balance;
