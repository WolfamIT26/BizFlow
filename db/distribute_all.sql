-- =====================================================
-- SCRIPT PHÂN TÁN DỮ LIỆU HOÀN CHỈNH
-- Phân tán dữ liệu từ bizflow_db vào các DB microservices
-- =====================================================

SET FOREIGN_KEY_CHECKS = 0;
SET AUTOCOMMIT = 0;
START TRANSACTION;

-- =====================================================
-- 1. AUTHENTICATION DB (bizflow_auth_db)
-- =====================================================
USE bizflow_auth_db;
DROP TABLE IF EXISTS users, branches;
CREATE TABLE users LIKE bizflow_db.users;
CREATE TABLE branches LIKE bizflow_db.branches;
INSERT INTO users SELECT * FROM bizflow_db.users;
INSERT INTO branches SELECT * FROM bizflow_db.branches;

-- =====================================================
-- 2. CATALOG DB (bizflow_catalog_db)
-- =====================================================
USE bizflow_catalog_db;
DROP TABLE IF EXISTS product_cost_histories, product_costs, products, categories;
CREATE TABLE categories LIKE bizflow_db.categories;
CREATE TABLE products LIKE bizflow_db.products;
CREATE TABLE product_costs LIKE bizflow_db.product_costs;
CREATE TABLE product_cost_histories LIKE bizflow_db.product_cost_histories;
INSERT INTO categories SELECT * FROM bizflow_db.categories;
INSERT INTO products SELECT * FROM bizflow_db.products;
INSERT INTO product_costs SELECT * FROM bizflow_db.product_costs;
INSERT INTO product_cost_histories SELECT * FROM bizflow_db.product_cost_histories;

-- =====================================================
-- 3. CUSTOMER DB (bizflow_customer_db)
-- =====================================================
USE bizflow_customer_db;
DROP TABLE IF EXISTS point_history, customers;
CREATE TABLE customers LIKE bizflow_db.customers;
CREATE TABLE point_history LIKE bizflow_db.point_history;
INSERT INTO customers SELECT * FROM bizflow_db.customers;
INSERT INTO point_history SELECT * FROM bizflow_db.point_history;

-- =====================================================
-- 4. INVENTORY DB (bizflow_inventory_db)
-- =====================================================
USE bizflow_inventory_db;
DROP TABLE IF EXISTS inventory_transactions, inventory_stocks, shelves, warehouses;
CREATE TABLE warehouses LIKE bizflow_db.warehouses;
CREATE TABLE shelves LIKE bizflow_db.shelves;
CREATE TABLE inventory_stocks LIKE bizflow_db.inventory_stocks;
CREATE TABLE inventory_transactions LIKE bizflow_db.inventory_transactions;
INSERT INTO warehouses SELECT * FROM bizflow_db.warehouses;
INSERT INTO shelves SELECT * FROM bizflow_db.shelves;
INSERT INTO inventory_stocks SELECT * FROM bizflow_db.inventory_stocks;
INSERT INTO inventory_transactions SELECT * FROM bizflow_db.inventory_transactions;

-- =====================================================
-- 5. PROMOTION DB (bizflow_promotion_db)
-- =====================================================
USE bizflow_promotion_db;
DROP TABLE IF EXISTS bundle_items, promotion_targets, promotions;
CREATE TABLE promotions LIKE bizflow_db.promotions;
CREATE TABLE promotion_targets LIKE bizflow_db.promotion_targets;
CREATE TABLE bundle_items LIKE bizflow_db.bundle_items;
INSERT INTO promotions SELECT * FROM bizflow_db.promotions;
INSERT INTO promotion_targets SELECT * FROM bizflow_db.promotion_targets;
INSERT INTO bundle_items SELECT * FROM bizflow_db.bundle_items;

-- =====================================================
-- 6. SALES DB (bizflow_sales_db)
-- =====================================================
USE bizflow_sales_db;
DROP TABLE IF EXISTS payments, order_items, orders;
CREATE TABLE orders LIKE bizflow_db.orders;
CREATE TABLE order_items LIKE bizflow_db.order_items;
CREATE TABLE payments LIKE bizflow_db.payments;
INSERT INTO orders SELECT * FROM bizflow_db.orders;
INSERT INTO order_items SELECT * FROM bizflow_db.order_items;
INSERT INTO payments SELECT * FROM bizflow_db.payments;

COMMIT;
SET FOREIGN_KEY_CHECKS = 1;
SET AUTOCOMMIT = 1;

-- =====================================================
-- KIỂM TRA KẾT QUẢ
-- =====================================================
SELECT 'bizflow_auth_db' as database_name, 
       (SELECT COUNT(*) FROM bizflow_auth_db.users) as users,
       (SELECT COUNT(*) FROM bizflow_auth_db.branches) as branches;
       
SELECT 'bizflow_catalog_db' as database_name,
       (SELECT COUNT(*) FROM bizflow_catalog_db.categories) as categories,
       (SELECT COUNT(*) FROM bizflow_catalog_db.products) as products;
       
SELECT 'bizflow_customer_db' as database_name,
       (SELECT COUNT(*) FROM bizflow_customer_db.customers) as customers,
       (SELECT COUNT(*) FROM bizflow_customer_db.point_history) as point_history;
       
SELECT 'bizflow_inventory_db' as database_name,
       (SELECT COUNT(*) FROM bizflow_inventory_db.inventory_stocks) as stocks,
       (SELECT COUNT(*) FROM bizflow_inventory_db.inventory_transactions) as transactions;
       
SELECT 'bizflow_promotion_db' as database_name,
       (SELECT COUNT(*) FROM bizflow_promotion_db.promotions) as promotions,
       (SELECT COUNT(*) FROM bizflow_promotion_db.bundle_items) as bundle_items;
       
SELECT 'bizflow_sales_db' as database_name,
       (SELECT COUNT(*) FROM bizflow_sales_db.orders) as orders,
       (SELECT COUNT(*) FROM bizflow_sales_db.order_items) as order_items,
       (SELECT COUNT(*) FROM bizflow_sales_db.payments) as payments;

SELECT '✅ Phân tán dữ liệu thành công!' AS message;
