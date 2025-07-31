-- Create clients table
CREATE TABLE clients (
    client_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create services table
CREATE TABLE services (
    service_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price NUMERIC(10,2) NOT NULL,
    duration_minutes INT CHECK (duration_minutes > 0)
);

-- Create employees table
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    role VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    is_active BOOLEAN DEFAULT TRUE
);

-- Create appointments table
CREATE TABLE appointments (
    appointment_id SERIAL PRIMARY KEY,
    client_id INT REFERENCES clients(client_id) ON DELETE CASCADE,
    employee_id INT REFERENCES employees(employee_id) ON DELETE SET NULL,
    service_id INT REFERENCES services(service_id),
    appointment_time TIMESTAMP NOT NULL,
    status VARCHAR(20) DEFAULT 'Scheduled' CHECK (status IN ('Scheduled', 'Completed', 'Cancelled')),
    notes TEXT
);

-- Create payments table
CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    appointment_id INT REFERENCES appointments(appointment_id) ON DELETE CASCADE,
    amount_paid NUMERIC(10,2) NOT NULL,
    payment_method VARCHAR(30) CHECK (payment_method IN ('Cash', 'Card', 'Transfer')),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
