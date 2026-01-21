-- Migration: Add product_costs and product_cost_histories tables
-- Date: 2026-01-15

USE `bizflow_db`;

-- Bảng lưu giá vốn hiện tại của sản phẩm
DROP TABLE IF EXISTS `product_costs`;
CREATE TABLE `product_costs` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `product_id` BIGINT NOT NULL,
    `cost_price` DECIMAL(15,2) NOT NULL COMMENT 'Giá vốn sản phẩm hiện tại',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT `fk_product_cost_product`
        FOREIGN KEY (`product_id`)
        REFERENCES `products`(`product_id`)
        ON DELETE CASCADE,
    
    UNIQUE KEY `uk_product_cost_product` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng lưu lịch sử thay đổi giá vốn khi nhập hàng
DROP TABLE IF EXISTS `product_cost_histories`;
CREATE TABLE `product_cost_histories` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `product_id` BIGINT NOT NULL,
    `cost_price` DECIMAL(15,2) NOT NULL COMMENT 'Giá vốn tại thời điểm nhập',
    `quantity` INT NOT NULL COMMENT 'Số lượng nhập',
    `note` VARCHAR(255) DEFAULT NULL,
    `created_by` BIGINT DEFAULT NULL COMMENT 'User ID người nhập',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT `fk_cost_history_product`
        FOREIGN KEY (`product_id`)
        REFERENCES `products`(`product_id`)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Thêm index để tìm kiếm nhanh
CREATE INDEX `idx_cost_history_product` ON `product_cost_histories`(`product_id`);
CREATE INDEX `idx_cost_history_created_at` ON `product_cost_histories`(`created_at`);

-- Insert dữ liệu giá vốn ban đầu từ bảng products (nếu có)
INSERT INTO `product_costs` (`product_id`, `cost_price`)
SELECT `product_id`, COALESCE(`cost_price`, 0) FROM `products` WHERE `cost_price` IS NOT NULL AND `cost_price` > 0;
