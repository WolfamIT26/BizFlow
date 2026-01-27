-- Fix Vietnamese encoding for promotions table
SET FOREIGN_KEY_CHECKS = 0;
SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

USE bizflow_db;

-- Fix promotions with correct Vietnamese text
UPDATE promotions SET name = 'Nước giải khác' WHERE promotion_id = 2034;
UPDATE promotions SET description = 'toàn bộ nước giải khác' WHERE promotion_id = 2034;

UPDATE promotions SET name = 'Dale hời cuối năm' WHERE promotion_id = 2035;

UPDATE promotions SET name = 'Thái dúi' WHERE promotion_id = 2043;

UPDATE promotions SET name = 'Combo Siêu Tiết Kiệm - Tháng 1 2026' WHERE promotion_id = 2045;
UPDATE promotions SET description = 'Mua combo sản phẩm với giá ưu đãi đặc biệt. Nhanh tay đặt hàng ngay hôm nay!' WHERE promotion_id = 2045;

UPDATE promotions SET name = 'Flash Sale 15% - Tháng 1 2026' WHERE promotion_id = 2046;
UPDATE promotions SET description = 'Giảm giá 15% cho sản phẩm được chọn. Nhanh tay đặt hàng ngay hôm nay!' WHERE promotion_id = 2046;

UPDATE promotions SET name = 'Flash Sale 25% - Tháng 1 2026' WHERE promotion_id = 2047;
UPDATE promotions SET description = 'Giảm giá 25% cho sản phẩm được chọn. Nhanh tay đặt hàng ngay hôm nay!' WHERE promotion_id = 2047;

UPDATE promotions SET name = 'Flash Sale 40% - Tháng 1 2026' WHERE promotion_id = 2048;
UPDATE promotions SET description = 'Giảm giá 40% cho sản phẩm được chọn. Nhanh tay đặt hàng ngay hôm nay!' WHERE promotion_id = 2048;

UPDATE promotions SET name = 'Flash Sale 20% - Tháng 1 2026' WHERE promotion_id = 2049;
UPDATE promotions SET description = 'Giảm giá 20% cho sản phẩm được chọn. Nhanh tay đặt hàng ngay hôm nay!' WHERE promotion_id = 2049;

UPDATE promotions SET name = 'Flash Sale 10% - Tháng 1 2026' WHERE promotion_id = 2050;
UPDATE promotions SET description = 'Giảm giá 10% cho sản phẩm được chọn. Nhanh tay đặt hàng ngay hôm nay!' WHERE promotion_id = 2050;

UPDATE promotions SET name = 'Giảm Ngay 3.000đ - Tháng 1 2026' WHERE promotion_id = 2051;
UPDATE promotions SET description = 'Giảm ngay 3.000đ khi mua sản phẩm được chọn. Nhanh tay đặt hàng ngay hôm nay!' WHERE promotion_id = 2051;

UPDATE promotions SET name = 'Flash Sale 5% - Tháng 1 2026' WHERE promotion_id = 2052;
UPDATE promotions SET description = 'Giảm giá 5% cho sản phẩm được chọn. Nhanh tay đặt hàng ngay hôm nay!' WHERE promotion_id = 2052;

SET FOREIGN_KEY_CHECKS = 1;

-- Verify results
SELECT promotion_id, name, description FROM promotions WHERE promotion_id >= 2034 ORDER BY promotion_id;
