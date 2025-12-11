-- ===================================================================
-- File: init.sql
-- Mô tả: Script khởi tạo database BizFlow
-- ===================================================================

-- Tạo database nếu chưa tồn tại
CREATE DATABASE IF NOT EXISTS bizflow_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE bizflow_db;

-- ===================================================================
-- Bảng: users
-- Mô tả: Lưu thông tin người dùng (admin, owner, employee)
-- ===================================================================
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    full_name VARCHAR(100),
    phone_number VARCHAR(20),
    role VARCHAR(20) NOT NULL,
    enabled BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    note TEXT,
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===================================================================
-- Bảng: customers
-- Mô tả: Lưu thông tin khách hàng
-- ===================================================================
CREATE TABLE IF NOT EXISTS customers (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20) UNIQUE,
    address VARCHAR(255),
    email VARCHAR(100),
    customer_type VARCHAR(20),
    tax_code VARCHAR(50),
    representative_name VARCHAR(100),
    representative_phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    notes TEXT,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    INDEX idx_phone (phone_number),
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===================================================================
-- Bảng: products
-- Mô tả: Lưu thông tin sản phẩm
-- ===================================================================
CREATE TABLE IF NOT EXISTS products (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(200) NOT NULL,
    category VARCHAR(100),
    unit VARCHAR(20),
    selling_price DECIMAL(15,2) NOT NULL,
    cost_price DECIMAL(15,2) NOT NULL,
    description TEXT,
    image_url VARCHAR(500),
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_code (code),
    INDEX idx_name (name),
    INDEX idx_category (category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===================================================================
-- Bảng: inventory
-- Mô tả: Lưu thông tin tồn kho
-- ===================================================================
CREATE TABLE IF NOT EXISTS inventory (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT NOT NULL UNIQUE,
    quantity INT NOT NULL DEFAULT 0,
    min_stock INT DEFAULT 0,
    max_stock INT,
    location VARCHAR(100),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    INDEX idx_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===================================================================
-- Bảng: orders
-- Mô tả: Lưu thông tin đơn hàng
-- ===================================================================
CREATE TABLE IF NOT EXISTS orders (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_code VARCHAR(50) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    customer_id BIGINT NOT NULL,
    employee_id BIGINT NOT NULL,
    total_amount DECIMAL(15,2) NOT NULL,
    discount_amount DECIMAL(15,2) DEFAULT 0,
    status VARCHAR(20) NOT NULL,
    notes TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (employee_id) REFERENCES users(id),
    INDEX idx_order_code (order_code),
    INDEX idx_customer (customer_id),
    INDEX idx_employee (employee_id),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===================================================================
-- Bảng: order_items
-- Mô tả: Lưu chi tiết sản phẩm trong đơn hàng
-- ===================================================================
CREATE TABLE IF NOT EXISTS order_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(15,2) NOT NULL,
    total_price DECIMAL(15,2) NOT NULL,
    discount_amount DECIMAL(15,2) DEFAULT 0,
    final_price DECIMAL(15,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id),
    INDEX idx_order (order_id),
    INDEX idx_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===================================================================
-- Bảng: debts
-- Mô tả: Lưu thông tin công nợ khách hàng
-- ===================================================================
CREATE TABLE IF NOT EXISTS debts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    order_id BIGINT,
    amount DECIMAL(15,2) NOT NULL,
    paid_amount DECIMAL(15,2) DEFAULT 0,
    remaining_amount DECIMAL(15,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    due_date TIMESTAMP,
    paid_at TIMESTAMP NULL,
    status VARCHAR(20) NOT NULL,
    notes TEXT,
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (order_id) REFERENCES orders(id),
    INDEX idx_customer (customer_id),
    INDEX idx_status (status),
    INDEX idx_due_date (due_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===================================================================
-- Dữ liệu mẫu ban đầu
-- ===================================================================

-- Thêm users mẫu (password đều là: 123456 - đã mã hóa BCrypt)
INSERT INTO users (username, password, email, full_name, phone_number, role, enabled) VALUES
('admin', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'admin@bizflow.com', 'Administrator', '0909111222', 'ADMIN', TRUE),
('test', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'test@bizflow.com', 'Test User', '0909333444', 'EMPLOYEE', TRUE);

-- Thêm khách hàng mẫu
INSERT INTO customers (name, phone_number, address, customer_type, active) VALUES
('Nguyễn Văn A', '0901234567', 'Hà Nội', 'CÁ NHÂN', TRUE),
('Công ty TNHH XYZ', '0987654321', 'TP.HCM', 'DOANH NGHIỆP', TRUE);

-- Thêm sản phẩm mẫu
INSERT INTO products (code, name, category, unit, selling_price, cost_price, active) VALUES
('SP001', 'Sản phẩm A', 'Danh mục 1', 'Cái', 100000, 80000, TRUE),
('SP002', 'Sản phẩm B', 'Danh mục 1', 'Hộp', 200000, 150000, TRUE),
('SP003', 'Sản phẩm C', 'Danh mục 2', 'Bộ', 500000, 400000, TRUE);

-- Thêm tồn kho mẫu
INSERT INTO inventory (product_id, quantity, min_stock, max_stock, location) VALUES
(1, 100, 10, 500, 'Kho A'),
(2, 50, 5, 200, 'Kho A'),
(3, 30, 3, 100, 'Kho B');

