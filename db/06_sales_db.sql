-- =====================================================
-- 6. SALES SERVICE - Copy Orders & Payments
-- =====================================================
USE bizflow_sales_db;

CREATE TABLE IF NOT EXISTS `orders` LIKE bizflow_db.orders;
CREATE TABLE IF NOT EXISTS `order_items` LIKE bizflow_db.order_items;
CREATE TABLE IF NOT EXISTS `payments` LIKE bizflow_db.payments;

INSERT IGNORE INTO orders SELECT * FROM bizflow_db.orders;
INSERT IGNORE INTO order_items SELECT * FROM bizflow_db.order_items;
INSERT IGNORE INTO payments SELECT * FROM bizflow_db.payments;

SELECT 'Sales DB: Copied orders, order_items & payments' AS status;
