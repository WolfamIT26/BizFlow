-- =====================================================
-- DỮ LIỆU SẢN PHẨM TIẾNG VIỆT CHUẨN
-- Encoding: UTF-8
-- =====================================================

SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

USE bizflow_db;

-- Xóa dữ liệu cũ
TRUNCATE TABLE products;

-- Insert lại với tiếng Việt đúng
INSERT INTO `products` (`product_id`, `product_name`, `sku`, `barcode`, `category_id`, `unit`, `price`, `cost_price`, `status`, `description`, `created_at`, `updated_at`, `active`, `code`, `name`, `stock`) VALUES
(1, 'Coca-Cola lon 330ml', 'CC330', '8934567000010', 1, 'lon', 10000.00, 7500.00, 'active', 'Nước ngọt có ga', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(2, 'Trà Xanh Không Độ chai 500ml', 'TXKD500', '8934567000027', 1, 'chai', 12000.00, 9000.00, 'active', 'Trà giải khát không đường', '2025-12-29 17:04:24', NULL, NULL, '', '', 120),
(3, 'Nước suối Aquafina 500ml', 'AQF500', '8934567000034', 1, 'chai', 5000.00, 3500.00, 'active', 'Nước tinh khiết', '2025-12-29 17:04:24', NULL, NULL, '', '', 120),
(4, 'Bia Sài Gòn Lager 330ml', 'SGL330', '8934567000041', 1, 'lon', 15000.00, 11000.00, 'active', 'Bia Lager', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(5, 'Pepsi lon 330ml', 'PS330', '8934567000058', 1, 'lon', 10000.00, 7500.00, 'active', 'Nước ngọt có ga vị chanh', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(6, 'Snack Oishi vị Phô Mai 35g', 'OIS-PM35', '8934567000065', 2, 'gói', 8000.00, 5500.00, 'active', 'Bánh snack khoai tây', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(7, 'Khô Gà Lá Chanh 100g', 'KG-LC100', '8934567000072', 2, 'túi', 35000.00, 25000.00, 'active', 'Thực phẩm ăn liền', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(8, 'Hạt Hướng Dương Vị Muối 250g', 'HD-MS250', '8934567000089', 2, 'gói', 20000.00, 14000.00, 'active', 'Hạt rang ăn liền', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(9, 'Bánh Quy Cosy dừa 160g', 'CQ-DY160', '8934567000096', 2, 'gói', 18000.00, 12500.00, 'active', 'Bánh quy ngọt', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(10, 'Kẹo Alpenliebe vị caramel', 'ALP-CR', '8934567000102', 2, 'gói', 15000.00, 10000.00, 'active', 'Kẹo cứng', '2025-12-29 17:04:24', NULL, NULL, '', '', 20);

SET FOREIGN_KEY_CHECKS = 1;

-- Kiểm tra kết quả
SELECT product_id, product_name, description FROM products LIMIT 10;
