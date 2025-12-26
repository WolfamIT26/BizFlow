USE bizflow_db;

-- Roles
INSERT INTO roles (name) VALUES
('ADMIN'),
('OWNER'),
('MANAGER'),
('EMPLOYEE')
ON DUPLICATE KEY UPDATE name=VALUES(name);

-- Branches
INSERT INTO branches (name, address, phone, email, owner_id, is_active) VALUES
('Truong Chinh', '123 Main St', '0281234567', 'branch@bizflow.com', NULL, TRUE)
ON DUPLICATE KEY UPDATE address=VALUES(address), phone=VALUES(phone), email=VALUES(email), is_active=VALUES(is_active);

-- Users (BCrypt hashes)
INSERT INTO users (username, password, email, full_name, phone_number, role, branch_id, enabled) VALUES
('admin', '$2a$10$7gz3idM0iA0ikYyibDutqe31yrWDdVh2NIRa1gCj0QXVNw9723f0G', 'admin@bizflow.com', 'Admin', '0900000000', 'ADMIN', 1, TRUE),
('employee', '$2a$10$iDS5.CarVV4hxkD1P5oVYePzl/M8gs3jse7bGOAjhQBZ6iefSllWy', 'employee@bizflow.com', 'Employee', '0902222222', 'EMPLOYEE', 1, TRUE),
('vietphd', '$2a$10$AwqQCrhiMkiGj.88g6ji/uqQvk6txMGyMApmq8vBJB0.RMBcpGiHC', 'nhanvien1@gmail.com', 'Viet PhD', '0902313141', 'EMPLOYEE', 1, TRUE)
ON DUPLICATE KEY UPDATE email=VALUES(email), full_name=VALUES(full_name), phone_number=VALUES(phone_number), role=VALUES(role), branch_id=VALUES(branch_id), enabled=VALUES(enabled);

-- Shops
INSERT INTO shops (name, address, phone, is_active) VALUES
('Main Shop', '123 Main St', '0281234567', TRUE)
ON DUPLICATE KEY UPDATE address=VALUES(address), phone=VALUES(phone), is_active=VALUES(is_active);

-- Categories
INSERT INTO categories (name) VALUES
('Ao'),
('Quan'),
('Giay'),
('Phu kien')
ON DUPLICATE KEY UPDATE name=VALUES(name);

-- Products
INSERT INTO products (shop_id, category_id, code, name, price, active) VALUES
(1, 1, 'P001', 'Ao thun', 99000, 1),
(1, 1, 'P002', 'Ao so mi', 159000, 1),
(1, 2, 'P003', 'Quan jean', 249000, 1),
(1, 3, 'P004', 'Giay sneaker', 399000, 1),
(1, 4, 'P005', 'Phu kien', 79000, 1)
ON DUPLICATE KEY UPDATE price=VALUES(price), active=VALUES(active), name=VALUES(name);

-- Inventory
INSERT INTO inventory (product_id, shop_id, quantity) VALUES
(1, 1, 50),
(2, 1, 40),
(3, 1, 30),
(4, 1, 20),
(5, 1, 60)
ON DUPLICATE KEY UPDATE quantity=VALUES(quantity);

-- Suppliers
INSERT INTO suppliers (name, phone, address) VALUES
('Supplier A', '0281111111', 'Warehouse A'),
('Supplier B', '0282222222', 'Warehouse B')
ON DUPLICATE KEY UPDATE phone=VALUES(phone), address=VALUES(address);

-- Stock imports
INSERT INTO stock_imports (shop_id, user_id, supplier_id, import_date, total_amount) VALUES
(1, 1, 1, '2024-12-01', 5000000),
(1, 1, 2, '2024-12-10', 3000000)
ON DUPLICATE KEY UPDATE total_amount=VALUES(total_amount);

INSERT INTO stock_import_items (stock_import_id, product_id, quantity, import_price) VALUES
(1, 1, 20, 70000),
(1, 3, 15, 180000),
(2, 4, 10, 300000),
(2, 5, 25, 50000)
ON DUPLICATE KEY UPDATE quantity=VALUES(quantity), import_price=VALUES(import_price);

-- Customers
INSERT INTO customers (shop_id, name, phone, email, address) VALUES
(1, 'Nguyen Van A', '0903333333', 'a@example.com', 'HCM'),
(1, 'Tran Thi B', '0904444444', 'b@example.com', 'HCM')
ON DUPLICATE KEY UPDATE name=VALUES(name), address=VALUES(address);

-- Orders
INSERT INTO orders (shop_id, user_id, customer_id, total_amount, created_at) VALUES
(1, 2, 1, 500000, '2024-12-20 10:00:00'),
(1, 2, 2, 350000, '2024-12-21 15:30:00')
ON DUPLICATE KEY UPDATE total_amount=VALUES(total_amount);

INSERT INTO order_items (order_id, product_id, quantity, price) VALUES
(1, 1, 2, 99000),
(1, 3, 1, 249000),
(2, 2, 1, 159000),
(2, 5, 2, 79000)
ON DUPLICATE KEY UPDATE quantity=VALUES(quantity), price=VALUES(price);

INSERT INTO payments (order_id, method, amount, paid_at) VALUES
(1, 'CASH', 500000, '2024-12-20 10:05:00'),
(2, 'BANK_TRANSFER', 350000, '2024-12-21 15:35:00')
ON DUPLICATE KEY UPDATE amount=VALUES(amount), method=VALUES(method);
