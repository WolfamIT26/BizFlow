-- =====================================================
-- 5. PROMOTION SERVICE - Copy Promotions
-- =====================================================
USE bizflow_promotion_db;

CREATE TABLE IF NOT EXISTS `promotions` LIKE bizflow_db.promotions;
CREATE TABLE IF NOT EXISTS `promotion_targets` LIKE bizflow_db.promotion_targets;
CREATE TABLE IF NOT EXISTS `bundle_items` LIKE bizflow_db.bundle_items;

INSERT IGNORE INTO promotions SELECT * FROM bizflow_db.promotions;
INSERT IGNORE INTO promotion_targets SELECT * FROM bizflow_db.promotion_targets;
INSERT IGNORE INTO bundle_items SELECT * FROM bizflow_db.bundle_items;

SELECT 'Promotion DB: Copied promotions, targets & bundles' AS status;
