-- =====================================================
-- 3. CUSTOMER SERVICE - Copy Customers & Points
-- =====================================================
USE bizflow_customer_db;

CREATE TABLE IF NOT EXISTS `customers` LIKE bizflow_db.customers;
CREATE TABLE IF NOT EXISTS `point_history` LIKE bizflow_db.point_history;

INSERT IGNORE INTO customers SELECT * FROM bizflow_db.customers;
INSERT IGNORE INTO point_history SELECT * FROM bizflow_db.point_history;

SELECT 'Customer DB: Copied customers & point_history' AS status;
