-- =====================================================
-- SCRIPT PHÂN TÁN DỮ LIỆU VÀO CÁC DATABASE MICROSERVICES
-- Chuyển dữ liệu từ bizflow_db sang các database riêng
-- =====================================================

SET FOREIGN_KEY_CHECKS = 0;

-- =====================================================
-- 1. AUTHENTICATION SERVICE (bizflow_auth_db)
-- Tables: users, branches
-- =====================================================

-- Tạo database nếu chưa có
CREATE DATABASE IF NOT EXISTS bizflow_auth_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE bizflow_auth_db;

-- Tạo bảng users
CREATE TABLE IF NOT EXISTS `users` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(100) NOT NULL,
  `full_name` varchar(100) DEFAULT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `role` varchar(20) NOT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT '1',
  `branch_id` bigint DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `note` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  KEY `fk_user_branch` (`branch_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Tạo bảng branches
CREATE TABLE IF NOT EXISTS `branches` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `address` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `is_active` bit(1) NOT NULL,
  `name` varchar(255) NOT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `owner_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK_hw68nd07qk3jrjfg70qxq9vb7` (`name`),
  KEY `FK8lecw87wgj5h4k0x8klg4bnep` (`owner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Copy dữ liệu từ bizflow_db
INSERT IGNORE INTO users SELECT * FROM bizflow_db.users;
INSERT IGNORE INTO branches SELECT * FROM bizflow_db.branches;

-- =====================================================
-- 2. CATALOG SERVICE (bizflow_catalog_db)
-- Tables: products, categories, product_costs, product_cost_histories
-- =====================================================

CREATE DATABASE IF NOT EXISTS bizflow_catalog_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE bizflow_catalog_db;

-- Tạo bảng categories
CREATE TABLE IF NOT EXISTS `categories` (
  `category_id` int NOT NULL AUTO_INCREMENT,
  `category_name` varchar(255) NOT NULL,
  `parent_id` int DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`category_id`),
  KEY `fk_category_parent` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Tạo bảng products
CREATE TABLE IF NOT EXISTS `products` (
  `product_id` bigint NOT NULL AUTO_INCREMENT,
  `product_name` varchar(255) NOT NULL,
  `sku` varchar(100) NOT NULL,
  `barcode` varchar(100) DEFAULT NULL,
  `category_id` bigint DEFAULT NULL,
  `unit` varchar(50) NOT NULL,
  `price` decimal(15,2) NOT NULL,
  `cost_price` decimal(12,2) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `description` text,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  `active` bit(1) DEFAULT NULL,
  `code` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `stock` int DEFAULT NULL,
  PRIMARY KEY (`product_id`),
  UNIQUE KEY `sku` (`sku`),
  KEY `fk_product_category` (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Tạo bảng product_costs
CREATE TABLE IF NOT EXISTS `product_costs` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `cost_price` decimal(15,2) NOT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `product_id` bigint NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK_emj5ou3kymldu462sbu36chhd` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tạo bảng product_cost_histories
CREATE TABLE IF NOT EXISTS `product_cost_histories` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `product_id` bigint NOT NULL,
  `cost_price` decimal(15,2) NOT NULL,
  `quantity` int NOT NULL,
  `note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_by` bigint DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FKagbnau0mqw831wgvk2h3v696m` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copy dữ liệu
INSERT IGNORE INTO categories SELECT * FROM bizflow_db.categories;
INSERT IGNORE INTO products SELECT * FROM bizflow_db.products;
INSERT IGNORE INTO product_costs SELECT * FROM bizflow_db.product_costs;
INSERT IGNORE INTO product_cost_histories SELECT * FROM bizflow_db.product_cost_histories;

-- =====================================================
-- 3. CUSTOMER SERVICE (bizflow_customer_db)
-- Tables: customers, point_history
-- =====================================================

CREATE DATABASE IF NOT EXISTS bizflow_customer_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE bizflow_customer_db;

-- Tạo bảng customers
CREATE TABLE IF NOT EXISTS `customers` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `address` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `cccd` varchar(255) DEFAULT NULL,
  `dob` date DEFAULT NULL,
  `monthly_points` int NOT NULL,
  `tier` enum('BAC','BACH_KIM','DONG','KIM_CUONG','VANG') DEFAULT NULL,
  `total_points` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Tạo bảng point_history
CREATE TABLE IF NOT EXISTS `point_history` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) DEFAULT NULL,
  `points` int DEFAULT NULL,
  `reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `customer_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FKoykoexosmdcwsmph7ubqmq22` (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copy dữ liệu
INSERT IGNORE INTO customers SELECT * FROM bizflow_db.customers;
INSERT IGNORE INTO point_history SELECT * FROM bizflow_db.point_history;

-- =====================================================
-- 4. INVENTORY SERVICE (bizflow_inventory_db)
-- Tables: inventory_stocks, inventory_transactions, warehouses, shelves
-- =====================================================

CREATE DATABASE IF NOT EXISTS bizflow_inventory_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE bizflow_inventory_db;

-- Tạo bảng warehouses
CREATE TABLE IF NOT EXISTS `warehouses` (
  `warehouse_id` bigint NOT NULL AUTO_INCREMENT,
  `warehouse_name` varchar(255) NOT NULL,
  `address` varchar(255) DEFAULT NULL,
  `manager_id` bigint DEFAULT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`warehouse_id`),
  KEY `fk_warehouse_manager` (`manager_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Tạo bảng shelves
CREATE TABLE IF NOT EXISTS `shelves` (
  `shelf_id` bigint NOT NULL AUTO_INCREMENT,
  `warehouse_id` bigint NOT NULL,
  `shelf_code` varchar(50) NOT NULL,
  `shelf_name` varchar(100) DEFAULT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`shelf_id`),
  KEY `fk_shelf_warehouse` (`warehouse_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Tạo bảng inventory_stocks
CREATE TABLE IF NOT EXISTS `inventory_stocks` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `product_id` bigint NOT NULL,
  `stock` int NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `updated_by` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK_hii2068ogj2cdjykg0h9adjo0` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tạo bảng inventory_transactions
CREATE TABLE IF NOT EXISTS `inventory_transactions` (
  `transaction_id` bigint NOT NULL AUTO_INCREMENT,
  `product_id` bigint DEFAULT NULL,
  `warehouse_id` bigint DEFAULT NULL,
  `shelf_id` bigint DEFAULT NULL,
  `transaction_type` enum('IN','OUT','SALE','RETURN','ADJUST') NOT NULL,
  `quantity` int NOT NULL,
  `unit_price` decimal(12,2) DEFAULT NULL,
  `reference_type` varchar(50) DEFAULT NULL,
  `reference_id` bigint DEFAULT NULL,
  `note` text,
  `created_by` bigint DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`transaction_id`),
  KEY `fk_it_product` (`product_id`),
  KEY `fk_it_warehouse` (`warehouse_id`),
  KEY `fk_it_shelf` (`shelf_id`),
  KEY `fk_it_created_by` (`created_by`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Copy dữ liệu
INSERT IGNORE INTO warehouses SELECT * FROM bizflow_db.warehouses;
INSERT IGNORE INTO shelves SELECT * FROM bizflow_db.shelves;
INSERT IGNORE INTO inventory_stocks SELECT * FROM bizflow_db.inventory_stocks;
INSERT IGNORE INTO inventory_transactions SELECT * FROM bizflow_db.inventory_transactions;

-- =====================================================
-- 5. PROMOTION SERVICE (bizflow_promotion_db)
-- Tables: promotions, promotion_targets, bundle_items
-- =====================================================

CREATE DATABASE IF NOT EXISTS bizflow_promotion_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE bizflow_promotion_db;

-- Tạo bảng promotions
CREATE TABLE IF NOT EXISTS `promotions` (
  `promotion_id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Khóa chính, mã duy nhất của chương trình khuyến mãi',
  `name` varchar(255) NOT NULL COMMENT 'Tên chương trình (VD: Black Friday Sale, Khai trương)',
  `description` text COMMENT 'Mô tả chi tiết chương trình',
  `promotion_type` varchar(255) DEFAULT NULL,
  `discount_value` double DEFAULT NULL,
  `start_date` datetime NOT NULL COMMENT 'Thời gian bắt đầu áp dụng',
  `end_date` datetime NOT NULL COMMENT 'Thời gian kết thúc',
  `applies_to` enum('ALL','PRODUCTS','CATEGORIES','CUSTOMERS') NOT NULL DEFAULT 'ALL' COMMENT 'Áp dụng cho: Tất cả, Sản phẩm cụ thể, Danh mục cụ thể, Khách hàng cụ thể',
  `status` enum('ACTIVE','INACTIVE','EXPIRED','PENDING') NOT NULL DEFAULT 'PENDING' COMMENT 'Trạng thái của chương trình',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `active` bit(1) NOT NULL,
  `code` varchar(255) NOT NULL,
  `discount_type` enum('BUNDLE','FIXED','FIXED_AMOUNT','FREE_GIFT','PERCENT') NOT NULL,
  PRIMARY KEY (`promotion_id`),
  KEY `idx_start_end_date` (`start_date`,`end_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Bảng lưu trữ các chương trình khuyến mãi';

-- Tạo bảng promotion_targets
CREATE TABLE IF NOT EXISTS `promotion_targets` (
  `promo_target_id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Khóa chính',
  `promotion_id` bigint NOT NULL COMMENT 'Khóa ngoại, liên kết với bảng promotions',
  `product_id` int DEFAULT NULL COMMENT 'Khóa ngoại, liên kết với products.product_id (Sản phẩm được áp dụng)',
  `category_id` bigint DEFAULT NULL,
  `min_order_value` decimal(15,2) DEFAULT '0.00' COMMENT 'Giá trị đơn hàng tối thiểu để áp dụng (nếu cần)',
  `max_discount_amount` decimal(15,2) DEFAULT NULL COMMENT 'Số tiền giảm tối đa (nếu là giảm %)',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `target_id` bigint DEFAULT NULL,
  `target_type` enum('BRANCH','CATEGORY','CUSTOMER_GROUP','PRODUCT') NOT NULL,
  PRIMARY KEY (`promo_target_id`),
  KEY `promotion_id` (`promotion_id`),
  KEY `product_id` (`product_id`),
  KEY `category_id` (`category_id`),
  KEY `idx_target_type_id` (`target_type`,`target_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Tạo bảng bundle_items
CREATE TABLE IF NOT EXISTS `bundle_items` (
  `bundle_id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Khóa chính, mã duy nhất của luật tặng/combo',
  `promotion_id` bigint NOT NULL COMMENT 'Khóa ngoại, liên kết với promotions',
  `main_product_id` bigint NOT NULL,
  `main_quantity` int NOT NULL DEFAULT '1' COMMENT 'Số lượng sản phẩm chính cần mua',
  `gift_product_id` bigint NOT NULL,
  `gift_quantity` int NOT NULL DEFAULT '1' COMMENT 'Số lượng quà tặng/sản phẩm đi kèm',
  `gift_discount_type` varchar(255) NOT NULL,
  `gift_discount_value` double NOT NULL,
  `status` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `product_id` bigint NOT NULL,
  `quantity` int NOT NULL,
  PRIMARY KEY (`bundle_id`),
  KEY `promotion_id` (`promotion_id`),
  KEY `main_product_id` (`main_product_id`),
  KEY `gift_product_id` (`gift_product_id`),
  KEY `idx_bundle_product` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Bảng định nghĩa quy tắc Mua X tặng Y hoặc Combo sản phẩm';

-- Copy dữ liệu
INSERT IGNORE INTO promotions SELECT * FROM bizflow_db.promotions;
INSERT IGNORE INTO promotion_targets SELECT * FROM bizflow_db.promotion_targets;
INSERT IGNORE INTO bundle_items SELECT * FROM bizflow_db.bundle_items;

-- =====================================================
-- 6. SALES SERVICE (bizflow_sales_db)
-- Tables: orders, order_items, payments
-- =====================================================

CREATE DATABASE IF NOT EXISTS bizflow_sales_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE bizflow_sales_db;

-- Tạo bảng orders
CREATE TABLE IF NOT EXISTS `orders` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) DEFAULT NULL,
  `total_amount` decimal(15,2) NOT NULL,
  `customer_id` bigint DEFAULT NULL,
  `user_id` bigint DEFAULT NULL,
  `invoice_number` varchar(30) DEFAULT NULL,
  `is_return` bit(1) DEFAULT NULL,
  `status` varchar(30) DEFAULT NULL,
  `order_type` varchar(20) DEFAULT NULL,
  `refund_method` varchar(50) DEFAULT NULL,
  `return_note` varchar(255) DEFAULT NULL,
  `return_reason` varchar(255) DEFAULT NULL,
  `parent_order_id` bigint DEFAULT NULL,
  `note` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK_9euhgrj490gy02d8abquh7jvu` (`invoice_number`),
  KEY `FKpxtb8awmi0dk6smoh2vp1litg` (`customer_id`),
  KEY `FK32ql8ubntj5uh44ph9659tiih` (`user_id`),
  KEY `FKakl1p7xiogdupq1376fttx2xc` (`parent_order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Tạo bảng order_items
CREATE TABLE IF NOT EXISTS `order_items` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `price` decimal(15,2) NOT NULL,
  `quantity` int NOT NULL,
  `order_id` bigint NOT NULL,
  `product_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FKbioxgbv59vetrxe0ejfubep1w` (`order_id`),
  KEY `FKocimc7dtr037rh4ls4l95nlfi` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Tạo bảng payments
CREATE TABLE IF NOT EXISTS `payments` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `amount` decimal(15,2) NOT NULL,
  `method` varchar(50) NOT NULL,
  `paid_at` datetime(6) DEFAULT NULL,
  `order_id` bigint NOT NULL,
  `status` varchar(20) DEFAULT NULL,
  `token` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK81gagumt0r8y3rmudcgpbk42l` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Copy dữ liệu
INSERT IGNORE INTO orders SELECT * FROM bizflow_db.orders;
INSERT IGNORE INTO order_items SELECT * FROM bizflow_db.order_items;
INSERT IGNORE INTO payments SELECT * FROM bizflow_db.payments;

-- =====================================================
-- 7. REPORT SERVICE (bizflow_report_db)
-- Có thể để trống hoặc copy một số dữ liệu để báo cáo
-- =====================================================

CREATE DATABASE IF NOT EXISTS bizflow_report_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================
-- HOÀN THÀNH
-- =====================================================
SELECT '✅ Đã phân tán dữ liệu thành công vào các database microservices!' AS message;
SELECT 'bizflow_auth_db, bizflow_catalog_db, bizflow_customer_db, bizflow_inventory_db, bizflow_promotion_db, bizflow_sales_db, bizflow_report_db' AS databases_created;
