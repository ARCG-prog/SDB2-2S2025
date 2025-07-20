-- Select all products
SELECT * FROM products;

-- View all orders for a client
SELECT o.id_order, o.order_date, o.total
FROM orders o
JOIN clients c ON ( o.id_client = c.id_client )
WHERE c.client_name = 'John Doe';

-- Calculate total sales for a product
SELECT p.product_name, SUM(od.subtotal) AS total_sales
FROM order_details od
JOIN products p ON ( od.id_product = p.id_product )
GROUP BY p.product_name;

-- Count the number of orders placed by a client
SELECT c.client_name, COUNT(o.id_order) AS order_count
FROM clients c
JOIN orders o ON ( c.id_client = o.id_client )
GROUP BY c.client_name;

-- Get the most sold products
SELECT p.product_name, SUM(od.quantity) AS total_sold
FROM order_details od
JOIN products p ON ( od.id_product = p.id_product )
GROUP BY p.product_name
ORDER BY total_sold DESC
LIMIT 5;

-- Get the total purchases by each client
SELECT c.client_name, SUM(o.total) AS total_purchases
FROM clients c
JOIN orders o ON ( c.id_client = o.id_client )
GROUP BY c.client_name;

-- Stored Procedures

-- Add a New Product
CREATE OR REPLACE FUNCTION add_product(product_name VARCHAR, price DECIMAL, category_id INT, product_description TEXT)
RETURNS VOID AS $$
BEGIN
    INSERT INTO products (product_name, price, id_category, description)
    VALUES (product_name, price, category_id, product_description);
END;
$$ LANGUAGE plpgsql;

SELECT add_product('Smartphone', 500.00, 1, 'Smartphone with 128GB storage');

-- Update Product Price
CREATE OR REPLACE FUNCTION update_product_price(product_id INT, new_price DECIMAL)
RETURNS VOID AS $$
BEGIN
    UPDATE products
    SET price = new_price
    WHERE id_product = product_id;
END;
$$ LANGUAGE plpgsql;

SELECT update_product_price(1, 520.00);

