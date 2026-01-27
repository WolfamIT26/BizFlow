-- =====================================================
-- IMPORT LẠI DỮ LIỆU VỚI ENCODING ĐÚNG
-- Xóa và tạo lại database với charset UTF8MB4
-- =====================================================

SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;
SET character_set_client = utf8mb4;
SET character_set_connection = utf8mb4;
SET character_set_results = utf8mb4;
SET collation_connection = utf8mb4_unicode_ci;

-- =====================================================
-- Xóa và tạo lại DATABASE với charset đúng
-- =====================================================
DROP DATABASE IF EXISTS bizflow_db;
CREATE DATABASE bizflow_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE bizflow_db;

-- Xóa tất cả microservices databases
DROP DATABASE IF EXISTS bizflow_auth_db;
DROP DATABASE IF EXISTS bizflow_catalog_db;
DROP DATABASE IF EXISTS bizflow_customer_db;
DROP DATABASE IF EXISTS bizflow_inventory_db;
DROP DATABASE IF EXISTS bizflow_promotion_db;
DROP DATABASE IF EXISTS bizflow_sales_db;
DROP DATABASE IF EXISTS bizflow_report_db;

-- Tạo lại với charset đúng
CREATE DATABASE bizflow_auth_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE bizflow_catalog_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE bizflow_customer_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE bizflow_inventory_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE bizflow_promotion_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE bizflow_sales_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE bizflow_report_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

SELECT 'Databases recreated with UTF8MB4!' AS status;
