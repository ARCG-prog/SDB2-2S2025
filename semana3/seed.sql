-- Seed clients
INSERT INTO clients (full_name, email, phone)
VALUES 
('Anna Lopez', 'anna@example.com', '+50212345678'),
('Michael Smith', 'michael.smith@example.com', '+50298765432'),
('Laura Reyes', 'laura.reyes@example.com', '+50224681357');

-- Seed services
INSERT INTO services (name, description, price, duration_minutes)
VALUES 
('Haircut', 'Standard haircut with consultation', 20.00, 30),
('Keratin Treatment', 'Hair smoothing with keratin formula', 120.00, 90),
('Facial', 'Deep cleansing and exfoliating facial', 45.00, 60),
('Manicure', 'Nail trimming, shaping, and polish', 25.00, 40);

-- Seed employees
INSERT INTO employees (name, role, email)
VALUES
('Lucía Pérez', 'Stylist', 'lucia@spa.com'),
('Carlos Gómez', 'Esthetician', 'carlos@spa.com'),
('Sandra Ruiz', 'Nail Technician', 'sandra@spa.com');

-- Seed appointments
INSERT INTO appointments (client_id, employee_id, service_id, appointment_time, status, notes)
VALUES
(1, 1, 1, '2025-07-22 10:00:00', 'Completed', 'Client requested layered style'),
(2, 2, 3, '2025-07-22 13:00:00', 'Scheduled', NULL),
(3, 3, 4, '2025-07-23 09:00:00', 'Scheduled', 'First visit');

-- Seed payments
INSERT INTO payments (appointment_id, amount_paid, payment_method)
VALUES 
(1, 20.00, 'Cash');