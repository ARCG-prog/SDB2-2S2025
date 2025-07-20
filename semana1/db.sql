CREATE TABLE categories (
    id_category SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL
);

CREATE TABLE products (
    id_product SERIAL PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    id_category INT REFERENCES categories(id_category),
    description TEXT
);

CREATE TABLE clients (
    id_client SERIAL PRIMARY KEY,
    client_name VARCHAR(100) NOT NULL,
    client_email VARCHAR(100) UNIQUE NOT NULL,
    client_phone VARCHAR(15),
    client_address TEXT
);

CREATE TABLE orders (
    id_order SERIAL PRIMARY KEY,
    id_client INT REFERENCES clients(id_client),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(10, 2) NOT NULL
);

CREATE TABLE order_details (
    id_detail SERIAL PRIMARY KEY,
    id_order INT REFERENCES orders(id_order),
    id_product INT REFERENCES products(id_product),
    quantity INT NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL
);