-- Insert categories
INSERT INTO categories (category_name) VALUES
('Electronics'),
('Clothing'),
('Food');

-- Insert products
INSERT INTO products (product_name, price, id_category, description) VALUES
('Laptop', 1200.00, 1, 'Laptop with 16GB RAM, 512GB SSD'),
('T-shirt', 20.00, 2, 'Cotton T-shirt, size M'),
('Apples', 3.50, 3, 'Fresh apples, 1 kg');

-- Insert clients
INSERT INTO clients (client_name, client_email, client_phone, client_address) VALUES
('John Doe', 'john.doe@example.com', '555-1234', '123 Fake St, City X'),
('Ana Smith', 'ana.smith@example.com', '555-5678', '456 Always St, City Y');

-- Insert orders
INSERT INTO orders (id_client, total) VALUES
(1, 1220.00),
(2, 23.50);

-- Insert order details
INSERT INTO order_details (id_order, id_product, quantity, subtotal) VALUES
(1, 1, 1, 1200.00),
(1, 2, 1, 20.00),
(2, 3, 1, 3.50);
