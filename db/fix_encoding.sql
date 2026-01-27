-- Fix Vietnamese encoding for products
USE bizflow_db;

SET FOREIGN_KEY_CHECKS = 0;
SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

TRUNCATE TABLE products;

INSERT INTO products (product_id, product_name, name, code, sku, barcode, category_id, unit, price, cost_price, status, description, created_at, updated_at, active, stock) VALUES
(1, 'Coca-Cola lon 330ml', 'Coca-Cola lon 330ml', 'COCA330', 'SKU001', '8934567123456', 1, 'Lon', 15000.00, 10000.00, 'available', 'Nước ngọt có ga', '2024-01-15 10:00:00', '2024-01-15 10:00:00', 1, 100),
(2, 'Trà Xanh Không Độ chai 500ml', 'Trà Xanh Không Độ chai 500ml', 'TRA500', 'SKU002', '8934567123457', 1, 'Chai', 10000.00, 7000.00, 'available', 'Trà giải khát không đường', '2024-01-15 10:00:00', '2024-01-15 10:00:00', 1, 150),
(3, 'Nước suối Aquafina 500ml', 'Nước suối Aquafina 500ml', 'AQU500', 'SKU003', '8934567123458', 1, 'Chai', 5000.00, 3500.00, 'available', 'Nước tinh khiết', '2024-01-15 10:00:00', '2024-01-15 10:00:00', 1, 200),
(4, 'Bia Sài Gòn Lager 330ml', 'Bia Sài Gòn Lager 330ml', 'BIA330', 'SKU004', '8934567123459', 1, 'Lon', 12000.00, 8000.00, 'available', 'Bia Lager', '2024-01-15 10:00:00', '2024-01-15 10:00:00', 1, 80),
(5, 'Pepsi lon 330ml', 'Pepsi lon 330ml', 'PEP330', 'SKU005', '8934567123460', 1, 'Lon', 15000.00, 10000.00, 'available', 'Nước ngọt có ga vị chanh', '2024-01-15 10:00:00', '2024-01-15 10:00:00', 1, 90),
(6, 'Snack Oishi vị Phô Mai 35g', 'Snack Oishi vị Phô Mai 35g', 'OIS35', 'SKU006', '8934567123461', 2, 'Gói', 8000.00, 5500.00, 'available', 'Bánh snack khoai tây', '2024-01-15 10:00:00', '2024-01-15 10:00:00', 1, 120),
(7, 'Khô Gà Lá Chanh 100g', 'Khô Gà Lá Chanh 100g', 'KGA100', 'SKU007', '8934567123462', 2, 'Gói', 35000.00, 25000.00, 'available', 'Thực phẩm ăn liền', '2024-01-15 10:00:00', '2024-01-15 10:00:00', 1, 50),
(8, 'Hạt Hướng Dương Vị Muối 250g', 'Hạt Hướng Dương Vị Muối 250g', 'HHD250', 'SKU008', '8934567123463', 2, 'Gói', 45000.00, 32000.00, 'available', 'Hạt rang ăn liền', '2024-01-15 10:00:00', '2024-01-15 10:00:00', 1, 60),
(9, 'Bánh Quy Cosy dừa 160g', 'Bánh Quy Cosy dừa 160g', 'CSY160', 'SKU009', '8934567123464', 2, 'Hộp', 22000.00, 16000.00, 'available', 'Bánh quy ngọt', '2024-01-15 10:00:00', '2024-01-15 10:00:00', 1, 70),
(10, 'Kẹo Alpenliebe vị caramel', 'Kẹo Alpenliebe vị caramel', 'ALP001', 'SKU010', '8934567123465', 2, 'Viên', 2000.00, 1500.00, 'available', 'Kẹo cứng', '2024-01-15 10:00:00', '2024-01-15 10:00:00', 1, 200);

SET FOREIGN_KEY_CHECKS = 1;

-- Verify data
SELECT product_id, product_name, name, description FROM products ORDER BY product_id;
