USE bizflow_db;

-- BCrypt hashes (đúng - đã test):
-- admin123 -> $2a$10$7gz3idM0iA0ikYyibDutqe31yrWDdVh2NIRa1gCj0QXVNw9723f0G
-- test123  -> $2a$10$YfZjL8qF3Zu0Q3KxJZ0pZeF3Y0XZqP8y3Y8Qm5yL8C3T5F0E0Y0E0
INSERT INTO users (username, password, email, full_name, role, enabled)
VALUES
('admin', '$2a$10$7gz3idM0iA0ikYyibDutqe31yrWDdVh2NIRa1gCj0QXVNw9723f0G', 'admin@bizflow.com', 'Administrator', 'ADMIN', TRUE)
ON DUPLICATE KEY UPDATE password=VALUES(password), email=VALUES(email), full_name=VALUES(full_name), role=VALUES(role), enabled=VALUES(enabled);

INSERT INTO users (username, password, email, full_name, role, enabled)
VALUES
('owner', '$2a$10$iDS5.CarVV4hxkD1P5oVYePzl/M8gs3jse7bGOAjhQBZ6iefSllWy', 'owner@bizflow.com', 'Store Owner', 'OWNER', TRUE)
ON DUPLICATE KEY UPDATE password=VALUES(password), email=VALUES(email), full_name=VALUES(full_name), role=VALUES(role), enabled=VALUES(enabled);

INSERT INTO users (username, password, email, full_name, role, enabled)
VALUES
('test', '$2a$10$iDS5.CarVV4hxkD1P5oVYePzl/M8gs3jse7bGOAjhQBZ6iefSllWy', 'test@bizflow.com', 'Test User', 'EMPLOYEE', TRUE)
ON DUPLICATE KEY UPDATE password=VALUES(password), email=VALUES(email), full_name=VALUES(full_name), role=VALUES(role), enabled=VALUES(enabled);

-- Seed categories
INSERT INTO product_categories (name) VALUES ('Danh mục 1')
ON DUPLICATE KEY UPDATE name=VALUES(name);

-- Use category_id=1 for initial products
INSERT INTO products (category_id, code, name, price, active) VALUES
(1, 'SP001', 'Sản phẩm A', 100000.00, TRUE),
(1, 'SP002', 'Sản phẩm B', 200000.00, TRUE)
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), active=VALUES(active);

-- Seed customers
INSERT INTO customers (name, phone, email, address) VALUES
('Nguyễn Văn A', '0901234567', 'a@example.com', 'Hà Nội'),
('Công ty TNHH XYZ', '0987654321', 'xyz@example.com', 'TP.HCM');
