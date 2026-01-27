-- Fix Vietnamese encoding for all tables
SET FOREIGN_KEY_CHECKS = 0;
SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

-- ======================
-- Fix CATEGORIES table
-- ======================
USE bizflow_db;
TRUNCATE TABLE categories;

INSERT INTO categories (category_id, category_name, parent_id, status, created_at, description, updated_at) VALUES
(1, 'Nước Giải Khát', NULL, 'active', NULL, NULL, NULL),
(2, 'Đồ Ăn Vặt', NULL, 'active', NULL, NULL, NULL),
(3, 'Hóa Mỹ Phẩm', NULL, 'active', NULL, NULL, NULL),
(4, 'Gia Vị & Nước Chấm', NULL, 'active', NULL, NULL, NULL),
(5, 'Sản Phẩm Chăm Sóc Nhà Cửa', NULL, 'active', NULL, NULL, NULL),
(6, 'Bánh Kẹo', NULL, 'active', NULL, NULL, NULL),
(7, 'Bia & Rượu', NULL, 'active', NULL, NULL, NULL),
(8, 'Mì, Phở, Cháo Gói', NULL, 'active', NULL, NULL, NULL),
(9, 'Đồ Hộp & Thực Phẩm Đóng Hộp', NULL, 'active', NULL, NULL, NULL),
(10, 'Thuốc Lá & Diêm', NULL, 'active', NULL, NULL, NULL);

-- ======================
-- Fix USERS table
-- ======================
UPDATE users SET full_name = 'Phạm Huy Đức Việt' WHERE id = 4;
UPDATE users SET full_name = 'Trần Long Tú' WHERE id = 7;
UPDATE users SET full_name = 'Tấn Bình' WHERE id = 8;

-- ======================
-- Fix CUSTOMERS table
-- ======================
UPDATE customers SET address = 'tân bình' WHERE id = 1;
UPDATE customers SET address = 'tân bình' WHERE id = 2;
UPDATE customers SET name = 'Anh Thới' WHERE id = 2;
UPDATE customers SET address = 'chung cư' WHERE id = 5;
UPDATE customers SET name = 'Anh Tú' WHERE id = 5;
UPDATE customers SET name = 'Chị Vân' WHERE id = 6;
UPDATE customers SET address = 'tân bình' WHERE id = 6;
UPDATE customers SET address = 'Tân Chánh Hiệp' WHERE id = 11;

-- ======================
-- Fix PROMOTIONS table
-- ======================
UPDATE promotions SET name = 'Nước giải khát' WHERE promotion_id = 2034;
UPDATE promotions SET description = 'toàn bộ nước giải khát' WHERE promotion_id = 2034;
UPDATE promotions SET name = 'Dale hội cuối năm' WHERE promotion_id = 2035;
UPDATE promotions SET name = 'giảm tiền sản phẩm' WHERE promotion_id = 2038;
UPDATE promotions SET name = 'compo nước' WHERE promotion_id = 2039;
UPDATE promotions SET name = 'compo nước giải khát' WHERE promotion_id = 2041;
UPDATE promotions SET name = 'giảm giá poca' WHERE promotion_id = 2042;
UPDATE promotions SET name = 'Thời đại' WHERE promotion_id = 2043;
UPDATE promotions SET name = 'giảm tiền sản phẩm' WHERE promotion_id = 2044;

-- ======================
-- Fix BRANCHES table
-- ======================
UPDATE branches SET address = 'TÂN CHÁNH HIỆP' WHERE id = 1;

SET FOREIGN_KEY_CHECKS = 1;

-- Verify results
SELECT 'Categories:' as table_name;
SELECT category_id, category_name FROM categories;

SELECT 'Users:' as table_name;
SELECT id, username, full_name FROM users WHERE id IN (4, 7, 8);

SELECT 'Customers:' as table_name;
SELECT id, name, address FROM customers LIMIT 8;

SELECT 'Promotions:' as table_name;
SELECT promotion_id, name, description FROM promotions LIMIT 10;

SELECT 'Branches:' as table_name;
SELECT id, name, address FROM branches;
