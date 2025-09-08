-- V2__Add_sample_data.sql
-- Insert sample data for testing

-- Insert sample users
INSERT INTO users (username, email) VALUES 
    ('john_doe', 'john@example.com'),
    ('jane_smith', 'jane@example.com'),
    ('bob_wilson', 'bob@example.com');

-- Insert sample products
INSERT INTO products (name, description, price, stock_quantity) VALUES 
    ('Laptop', 'High-performance laptop with 16GB RAM', 1299.99, 10),
    ('Mouse', 'Wireless ergonomic mouse', 29.99, 50),
    ('Keyboard', 'Mechanical gaming keyboard', 89.99, 25),
    ('Monitor', '27-inch 4K display', 449.99, 15),
    ('Headphones', 'Noise-cancelling wireless headphones', 199.99, 30);

-- Insert sample orders
INSERT INTO orders (user_id, total_amount, status) VALUES 
    (1, 1329.98, 'COMPLETED'),
    (2, 119.98, 'COMPLETED'),
    (1, 649.98, 'PENDING');

-- Insert sample order items
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES 
    (1, 1, 1, 1299.99),
    (1, 2, 1, 29.99),
    (2, 3, 1, 89.99),
    (2, 2, 1, 29.99),
    (3, 4, 1, 449.99),
    (3, 5, 1, 199.99);