-- Setup
CREATE TABLE movements (
    move_id    SERIAL PRIMARY KEY,
    account_id INT,
    amount     NUMERIC
);
INSERT INTO movements(account_id, amount) VALUES (1, 50);

BEGIN;
    -- first operation
    INSERT INTO movements(account_id, amount) VALUES (1, -20);
    -- mark a savepoint
    SAVEPOINT sp_before_update;
    -- second operation that might fail
    UPDATE accounts SET balance = balance - 20 WHERE id = 1;
    -- simulate error:
    SELECT 1/0;   -- division by zero
ROLLBACK TO SAVEPOINT sp_before_update;
COMMIT;
