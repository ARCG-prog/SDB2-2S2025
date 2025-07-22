-- Setup
CREATE TABLE accounts (
    id    SERIAL PRIMARY KEY,
    owner_acc TEXT,
    balance NUMERIC
);
INSERT INTO accounts(owner_acc, balance) VALUES ('Alice', 1000), ('Bob', 1000);


-- PGADMIN: SESSION 1
BEGIN;
    UPDATE accounts
    SET balance = balance - 10
    WHERE id = 1;
  
    SELECT pg_sleep(5);
  
    UPDATE accounts
    SET balance = balance - 10
    WHERE id = 2;
COMMIT;

-- PGADMIN: SESSION 2 - run immediately after A’s first UPDATE
BEGIN;
    UPDATE accounts
    SET balance = balance - 10
    WHERE id = 1;
  
    SELECT pg_sleep(5);

    UPDATE accounts
    SET balance = balance - 10
    WHERE id = 2;
COMMIT;
