-- Setup
CREATE TABLE inventory (
    product_id SERIAL PRIMARY KEY,
    name       TEXT,
    quantity   INT
);
INSERT INTO inventory(name, quantity) VALUES ('Widget', 100);

-- PGADMIN: SESSION 1
BEGIN;
    SELECT quantity
    FROM inventory
    WHERE product_id = 1
    FOR UPDATE;

-- PGADMIN: SESSION 2
BEGIN;
    UPDATE inventory
    SET quantity = quantity - 1
    WHERE product_id = 1;

-- PGADMIN: SESSION 1
COMMIT;