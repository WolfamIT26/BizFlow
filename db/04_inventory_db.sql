-- =====================================================
-- 4. INVENTORY SERVICE - Copy Inventory Data
-- =====================================================
USE bizflow_inventory_db;

CREATE TABLE IF NOT EXISTS `warehouses` LIKE bizflow_db.warehouses;
CREATE TABLE IF NOT EXISTS `shelves` LIKE bizflow_db.shelves;
CREATE TABLE IF NOT EXISTS `inventory_stocks` LIKE bizflow_db.inventory_stocks;
CREATE TABLE IF NOT EXISTS `inventory_transactions` LIKE bizflow_db.inventory_transactions;

INSERT IGNORE INTO warehouses SELECT * FROM bizflow_db.warehouses;
INSERT IGNORE INTO shelves SELECT * FROM bizflow_db.shelves;
INSERT IGNORE INTO inventory_stocks SELECT * FROM bizflow_db.inventory_stocks;
INSERT IGNORE INTO inventory_transactions SELECT * FROM bizflow_db.inventory_transactions;

SELECT 'Inventory DB: Copied inventory data' AS status;
