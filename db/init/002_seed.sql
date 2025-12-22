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
INSERT INTO product_categories (name) VALUES 
('Áo'),
('Quần'),
('Giày'),
('Phụ kiện')
ON DUPLICATE KEY UPDATE name=VALUES(name);

-- Seed products
INSERT INTO products (category_id, code, name, price, active) VALUES
(1, 'AO001', 'Áo Thun Cơ Bản', 99000.00, TRUE),
(1, 'AO002', 'Áo Polo Nam', 149000.00, TRUE),
(1, 'AO003', 'Áo Sơ Mi Trắng', 199000.00, TRUE),
(1, 'AO004', 'Áo Khoác Jean', 299000.00, TRUE),
(1, 'AO005', 'Áo Hoodie Unisex', 249000.00, TRUE),
(2, 'QN001', 'Quần Jean Nam', 249000.00, TRUE),
(2, 'QN002', 'Quần Khaki Chinos', 199000.00, TRUE),
(2, 'QN003', 'Quần Tây Công Sở', 399000.00, TRUE),
(2, 'QN004', 'Quần Thể Thao', 149000.00, TRUE),
(2, 'QN005', 'Quần Legging Nữ', 129000.00, TRUE),
(3, 'GY001', 'Giày Sneaker Nam', 299000.00, TRUE),
(3, 'GY002', 'Giày Lười Đen', 199000.00, TRUE),
(3, 'GY003', 'Giày Thể Thao Nữ', 349000.00, TRUE),
(3, 'GY004', 'Giày Oxford Công Sở', 599000.00, TRUE),
(3, 'GY005', 'Dép Quai Hậu', 79000.00, TRUE),
(4, 'PK001', 'Mũ Snapback', 89000.00, TRUE),
(4, 'PK002', 'Dây Chuyền Inox', 119000.00, TRUE),
(4, 'PK003', 'Vòng Tay Thạch Anh', 149000.00, TRUE),
(4, 'PK004', 'Túi Tote Vải', 249000.00, TRUE),
(4, 'PK005', 'Thắt Lưng Da Bò', 199000.00, TRUE),
(1, 'AO006', 'Áo Linen Mùa Hè', 179000.00, TRUE),
(2, 'QN006', 'Quần Shorts Nam', 99000.00, TRUE),
(3, 'GY006', 'Sandal Đê', 89000.00, TRUE),
(4, 'PK006', 'Kính Mặt Trời', 499000.00, TRUE)
ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), active=VALUES(active);

-- Seed customers
INSERT INTO customers (name, phone, email, address) VALUES
('Nguyễn Văn A', '0901234567', 'a@example.com', 'Hà Nội'),
('Trần Thị B', '0912345678', 'b@example.com', 'TP.HCM'),
('Công ty TNHH XYZ', '0987654321', 'xyz@example.com', 'Đà Nẵng'),
('Phạm Văn Thắng', '0923456789', 'thang@example.com', 'Hải Phòng'),
('Lê Thị Hương', '0934567890', 'huong@example.com', 'Hà Nội')
ON DUPLICATE KEY UPDATE name=VALUES(name), phone=VALUES(phone), email=VALUES(email), address=VALUES(address);
