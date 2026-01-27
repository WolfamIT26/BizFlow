-- =====================================================
-- 2. CATALOG SERVICE - Copy Products & Categories
-- =====================================================
USE bizflow_catalog_db;

CREATE TABLE IF NOT EXISTS `categories` LIKE bizflow_db.categories;
CREATE TABLE IF NOT EXISTS `products` LIKE bizflow_db.products;
CREATE TABLE IF NOT EXISTS `product_costs` LIKE bizflow_db.product_costs;
CREATE TABLE IF NOT EXISTS `product_cost_histories` LIKE bizflow_db.product_cost_histories;

INSERT IGNORE INTO categories SELECT * FROM bizflow_db.categories;
INSERT IGNORE INTO products SELECT * FROM bizflow_db.products;
INSERT IGNORE INTO product_costs SELECT * FROM bizflow_db.product_costs;
INSERT IGNORE INTO product_cost_histories SELECT * FROM bizflow_db.product_cost_histories;

SELECT 'Catalog DB: Copied categories, products, and costs' AS status;
