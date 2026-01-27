-- =====================================================
-- 1. AUTHENTICATION SERVICE - Copy Users & Branches
-- =====================================================
USE bizflow_auth_db;

CREATE TABLE IF NOT EXISTS `users` LIKE bizflow_db.users;
CREATE TABLE IF NOT EXISTS `branches` LIKE bizflow_db.branches;

INSERT IGNORE INTO users SELECT * FROM bizflow_db.users;
INSERT IGNORE INTO branches SELECT * FROM bizflow_db.branches;

SELECT 'Auth DB: Copied users & branches' AS status;
