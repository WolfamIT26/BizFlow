mysqldump: [Warning] Using a password on the command line interface can be insecure.
-- MySQL dump 10.13  Distrib 8.0.44, for Linux (aarch64)
--
-- Host: localhost    Database: bizflow_db
-- ------------------------------------------------------
-- Server version	8.0.44

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `branches`
--

DROP TABLE IF EXISTS `branches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `branches` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `address` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `is_active` bit(1) NOT NULL,
  `name` varchar(255) NOT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `owner_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK_hw68nd07qk3jrjfg70qxq9vb7` (`name`),
  KEY `FK8lecw87wgj5h4k0x8klg4bnep` (`owner_id`),
  CONSTRAINT `FK8lecw87wgj5h4k0x8klg4bnep` FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `branches`
--

LOCK TABLES `branches` WRITE;
/*!40000 ALTER TABLE `branches` DISABLE KEYS */;
INSERT INTO `branches` VALUES (1,'TÂN CHÁNH HIỆP','gtvt@gmail.com',_binary '','GTVT','0981764731',NULL),(2,'123 Street','sadanhthue01@gmail.com',_binary '','Tân Bình','0981764731',2);
/*!40000 ALTER TABLE `branches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bundle_items`
--

DROP TABLE IF EXISTS `bundle_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bundle_items` (
  `bundle_id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Khóa chính, mã duy nhất của luật tặng/combo',
  `promotion_id` bigint NOT NULL COMMENT 'Khóa ngoại, liên kết với promotions',
  `main_product_id` int NOT NULL COMMENT 'Khóa ngoại, liên kết với products.product_id (Sản phẩm khách cần mua)',
  `main_quantity` int NOT NULL DEFAULT '1' COMMENT 'Số lượng sản phẩm chính cần mua',
  `gift_product_id` int NOT NULL COMMENT 'Khóa ngoại, liên kết với products.product_id (Sản phẩm được tặng/đi kèm)',
  `gift_quantity` int NOT NULL DEFAULT '1' COMMENT 'Số lượng quà tặng/sản phẩm đi kèm',
  `gift_discount_type` enum('FREE','PERCENT','FIXED_PRICE') NOT NULL DEFAULT 'FREE' COMMENT 'Loại giảm giá cho sản phẩm quà tặng/đi kèm',
  `gift_discount_value` decimal(15,2) DEFAULT '0.00' COMMENT 'Giá trị giảm/giá cố định cho sản phẩm quà tặng',
  `status` enum('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `product_id` bigint NOT NULL,
  `quantity` int NOT NULL,
  PRIMARY KEY (`bundle_id`),
  KEY `promotion_id` (`promotion_id`),
  KEY `main_product_id` (`main_product_id`),
  KEY `gift_product_id` (`gift_product_id`),
  KEY `idx_bundle_product` (`product_id`),
  CONSTRAINT `FKnovhg7gfyangkg1ftcjhmltw6` FOREIGN KEY (`promotion_id`) REFERENCES `promotions` (`promotion_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Bảng định nghĩa quy tắc Mua X tặng Y hoặc Combo sản phẩm';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bundle_items`
--

LOCK TABLES `bundle_items` WRITE;
/*!40000 ALTER TABLE `bundle_items` DISABLE KEYS */;
INSERT INTO `bundle_items` VALUES (1,3,21,3,11,1,'FREE',0.00,'ACTIVE','2026-01-03 17:38:52',0,0),(6,15,18,1,13,1,'FREE',0.00,'ACTIVE','2026-01-12 14:27:12',0,0),(7,16,14,3,19,1,'FREE',0.00,'ACTIVE','2026-01-12 14:36:25',0,0);
/*!40000 ALTER TABLE `bundle_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categories` (
  `category_id` bigint NOT NULL AUTO_INCREMENT,
  `category_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `parent_id` bigint DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`category_id`),
  KEY `parent_id` (`parent_id`),
  CONSTRAINT `categories_ibfk_1` FOREIGN KEY (`parent_id`) REFERENCES `categories` (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customers` (
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
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
INSERT INTO `customers` VALUES (1,'tân bình',NULL,'Pham viet','0866066042',NULL,NULL,44,NULL,44),(2,'tân bình',NULL,'Anh thái','0866066043',NULL,NULL,7518,NULL,7518),(5,'chung cư',NULL,'Anh Tứ','0866066044',NULL,NULL,0,NULL,0),(6,'tân bình',NULL,'Chị Vân','0866066045',NULL,NULL,243,'DONG',243),(7,'Test Address',NULL,'Test Customer','0962028826',NULL,NULL,0,'DONG',0),(8,'Test Address',NULL,'Test Customer 2','0928519177',NULL,NULL,10,'DONG',10),(10,'Test Address',NULL,'Test UI Flow','0996622189',NULL,NULL,0,'DONG',0),(11,'Tân Chánh Hiệp',NULL,'Anh Trung','0354970825',NULL,NULL,0,'DONG',0);
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_stocks`
--

DROP TABLE IF EXISTS `inventory_stocks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory_stocks` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `product_id` bigint NOT NULL,
  `stock` int NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `updated_by` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK_hii2068ogj2cdjykg0h9adjo0` (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=151 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_stocks`
--

LOCK TABLES `inventory_stocks` WRITE;
/*!40000 ALTER TABLE `inventory_stocks` DISABLE KEYS */;
INSERT INTO `inventory_stocks` VALUES (2,2,20,'2026-01-13 22:07:08.518145',NULL),(3,3,17,'2026-01-21 16:52:52.940189',4),(4,4,8,'2026-01-15 23:21:47.010253',4),(5,5,18,'2026-01-21 16:52:52.998250',4),(6,6,20,'2026-01-13 22:07:08.520953',NULL),(7,7,20,'2026-01-13 22:07:08.521410',NULL),(8,8,4,'2026-01-21 16:39:44.854536',4),(9,9,15,'2026-01-15 23:21:46.971048',4),(10,10,10,'2026-01-21 16:39:44.902047',4),(11,11,20,'2026-01-13 22:07:08.523134',NULL),(12,12,20,'2026-01-13 22:07:08.523593',NULL),(13,13,20,'2026-01-13 22:07:08.524031',NULL),(14,14,20,'2026-01-13 22:07:08.524436',NULL),(15,15,20,'2026-01-13 22:07:08.524811',NULL),(16,16,20,'2026-01-13 22:07:08.525221',NULL),(17,17,20,'2026-01-13 22:07:08.525678',NULL),(18,18,20,'2026-01-13 22:07:08.526184',NULL),(19,19,20,'2026-01-13 22:07:08.526577',NULL),(20,20,20,'2026-01-13 22:07:08.526975',NULL),(21,21,20,'2026-01-13 22:07:08.527433',NULL),(22,22,20,'2026-01-13 22:07:08.527886',NULL),(23,23,20,'2026-01-13 22:07:08.528338',NULL),(24,24,20,'2026-01-13 22:07:08.528703',NULL),(25,25,20,'2026-01-13 22:07:08.529092',NULL),(26,26,20,'2026-01-13 22:07:08.529502',NULL),(27,27,20,'2026-01-13 22:07:08.529895',NULL),(28,28,20,'2026-01-13 22:07:08.530740',NULL),(29,29,20,'2026-01-13 22:07:08.531151',NULL),(30,30,20,'2026-01-13 22:07:08.531574',NULL),(31,31,20,'2026-01-13 22:07:08.531960',NULL),(32,32,20,'2026-01-13 22:07:08.532376',NULL),(33,33,20,'2026-01-13 22:07:08.532741',NULL),(34,34,20,'2026-01-13 22:07:08.533125',NULL),(35,35,20,'2026-01-13 22:07:08.533514',NULL),(36,36,20,'2026-01-13 22:07:08.533910',NULL),(37,37,20,'2026-01-13 22:07:08.534286',NULL),(38,38,20,'2026-01-13 22:07:08.534641',NULL),(39,39,20,'2026-01-13 22:07:08.535020',NULL),(40,40,20,'2026-01-13 22:07:08.535408',NULL),(41,41,20,'2026-01-13 22:07:08.535802',NULL),(42,42,20,'2026-01-13 22:07:08.536259',NULL),(43,43,20,'2026-01-13 22:07:08.536662',NULL),(44,44,20,'2026-01-13 22:07:08.537046',NULL),(45,45,20,'2026-01-13 22:07:08.537471',NULL),(46,46,20,'2026-01-13 22:07:08.537863',NULL),(47,47,20,'2026-01-13 22:07:08.538397',NULL),(48,48,20,'2026-01-13 22:07:08.538762',NULL),(49,49,20,'2026-01-13 22:07:08.539137',NULL),(50,50,20,'2026-01-13 22:07:08.539546',NULL),(51,51,20,'2026-01-13 22:07:08.539911',NULL),(52,52,20,'2026-01-13 22:07:08.540299',NULL),(53,53,20,'2026-01-13 22:07:08.540667',NULL),(54,54,20,'2026-01-13 22:07:08.541037',NULL),(55,55,20,'2026-01-13 22:07:08.541437',NULL),(56,56,1,'2026-01-15 23:32:14.175640',4),(57,57,20,'2026-01-13 22:07:08.542559',NULL),(58,58,20,'2026-01-13 22:07:08.543511',NULL),(59,59,20,'2026-01-13 22:07:08.545163',NULL),(60,60,20,'2026-01-13 22:07:08.545596',NULL),(61,61,20,'2026-01-13 22:07:08.546052',NULL),(62,62,20,'2026-01-13 22:07:08.547222',NULL),(63,63,20,'2026-01-13 22:07:08.547692',NULL),(64,64,20,'2026-01-13 22:07:08.549431',NULL),(65,65,20,'2026-01-13 22:07:08.549927',NULL),(66,66,20,'2026-01-13 22:07:08.550596',NULL),(67,67,20,'2026-01-13 22:07:08.550978',NULL),(68,68,20,'2026-01-13 22:07:08.551456',NULL),(69,69,20,'2026-01-13 22:07:08.551822',NULL),(70,70,20,'2026-01-13 22:07:08.552165',NULL),(71,71,20,'2026-01-13 22:07:08.552529',NULL),(72,72,20,'2026-01-13 22:07:08.552869',NULL),(73,73,20,'2026-01-13 22:07:08.553294',NULL),(74,74,20,'2026-01-13 22:07:08.554052',NULL),(75,75,20,'2026-01-13 22:07:08.554392',NULL),(76,76,20,'2026-01-13 22:07:08.554730',NULL),(77,77,20,'2026-01-13 22:07:08.555106',NULL),(78,78,20,'2026-01-13 22:07:08.555436',NULL),(79,79,20,'2026-01-13 22:07:08.555757',NULL),(80,80,20,'2026-01-13 22:07:08.556092',NULL),(81,81,20,'2026-01-13 22:07:08.556443',NULL),(82,82,20,'2026-01-13 22:07:08.556784',NULL),(83,83,20,'2026-01-13 22:07:08.557179',NULL),(84,84,20,'2026-01-13 22:07:08.557607',NULL),(85,85,20,'2026-01-13 22:07:08.557990',NULL),(86,86,20,'2026-01-13 22:07:08.559043',NULL),(87,87,20,'2026-01-13 22:07:08.559678',NULL),(88,88,20,'2026-01-13 22:07:08.560101',NULL),(89,89,20,'2026-01-13 22:07:08.560449',NULL),(90,90,20,'2026-01-13 22:07:08.560834',NULL),(91,91,20,'2026-01-13 22:07:08.563471',NULL),(92,92,20,'2026-01-13 22:07:08.563906',NULL),(93,93,20,'2026-01-13 22:07:08.564324',NULL),(94,94,20,'2026-01-13 22:07:08.564732',NULL),(95,95,20,'2026-01-13 22:07:08.565105',NULL),(96,96,20,'2026-01-13 22:07:08.565452',NULL),(97,97,20,'2026-01-13 22:07:08.565780',NULL),(98,98,20,'2026-01-13 22:07:08.566265',NULL),(99,99,20,'2026-01-13 22:07:08.566712',NULL),(100,100,20,'2026-01-13 22:07:08.567111',NULL),(101,101,20,'2026-01-13 22:07:08.567499',NULL),(102,102,20,'2026-01-13 22:07:08.567843',NULL),(103,103,20,'2026-01-13 22:07:08.568211',NULL),(104,104,20,'2026-01-13 22:07:08.568558',NULL),(105,105,20,'2026-01-13 22:07:08.568889',NULL),(106,106,20,'2026-01-13 22:07:08.569286',NULL),(107,107,20,'2026-01-13 22:07:08.569626',NULL),(108,108,20,'2026-01-13 22:07:08.569940',NULL),(109,109,20,'2026-01-13 22:07:08.570306',NULL),(110,110,20,'2026-01-13 22:07:08.570657',NULL),(111,111,20,'2026-01-13 22:07:08.570989',NULL),(112,112,26,'2026-01-21 23:14:00.158117',4),(113,113,20,'2026-01-13 22:07:08.571683',NULL),(114,114,20,'2026-01-13 22:07:08.572000',NULL),(115,115,20,'2026-01-13 22:07:08.572382',NULL),(116,116,20,'2026-01-13 22:07:08.572752',NULL),(117,117,20,'2026-01-13 22:07:08.573082',NULL),(118,118,20,'2026-01-13 22:07:08.573394',NULL),(119,119,20,'2026-01-13 22:07:08.574168',NULL),(120,120,20,'2026-01-13 22:07:08.574533',NULL),(121,121,20,'2026-01-13 22:07:08.576212',NULL),(122,122,20,'2026-01-13 22:07:08.576667',NULL),(123,123,20,'2026-01-13 22:07:08.576995',NULL),(124,124,20,'2026-01-13 22:07:08.577340',NULL),(125,125,20,'2026-01-13 22:07:08.578108',NULL),(126,126,20,'2026-01-13 22:07:08.578635',NULL),(127,127,20,'2026-01-13 22:07:08.579180',NULL),(128,128,20,'2026-01-13 22:07:08.579855',NULL),(129,129,20,'2026-01-13 22:07:08.581091',NULL),(130,130,20,'2026-01-13 22:07:08.581823',NULL),(131,131,20,'2026-01-13 22:07:08.582201',NULL),(132,132,20,'2026-01-13 22:07:08.582525',NULL),(133,133,20,'2026-01-13 22:07:08.582870',NULL),(134,134,20,'2026-01-13 22:07:08.583203',NULL),(135,135,20,'2026-01-13 22:07:08.583662',NULL),(136,136,20,'2026-01-13 22:07:08.585177',NULL),(137,137,20,'2026-01-13 22:07:08.585574',NULL),(138,138,20,'2026-01-13 22:07:08.585880',NULL),(139,139,20,'2026-01-13 22:07:08.586290',NULL),(140,140,20,'2026-01-13 22:07:08.586594',NULL),(141,141,20,'2026-01-13 22:07:08.586907',NULL),(142,142,20,'2026-01-13 22:07:08.587264',NULL),(143,143,20,'2026-01-13 22:07:08.587688',NULL),(144,144,20,'2026-01-13 22:07:08.588264',NULL),(145,145,20,'2026-01-13 22:07:08.588643',NULL),(146,146,20,'2026-01-13 22:07:08.588949',NULL),(147,147,20,'2026-01-13 22:07:08.589256',NULL),(148,148,20,'2026-01-13 22:07:08.590242',NULL),(149,149,19,'2026-01-14 15:13:15.115093',4),(150,150,20,'2026-01-13 22:07:08.590847',NULL);
/*!40000 ALTER TABLE `inventory_stocks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_transactions`
--

DROP TABLE IF EXISTS `inventory_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory_transactions` (
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
  KEY `fk_it_created_by` (`created_by`),
  CONSTRAINT `fk_it_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_it_shelf` FOREIGN KEY (`shelf_id`) REFERENCES `shelves` (`shelf_id`) ON DELETE SET NULL,
  CONSTRAINT `fk_it_warehouse` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`warehouse_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=56 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_transactions`
--

LOCK TABLES `inventory_transactions` WRITE;
/*!40000 ALTER TABLE `inventory_transactions` DISABLE KEYS */;
INSERT INTO `inventory_transactions` VALUES (6,1,NULL,NULL,'SALE',1,10000.00,'ORDER',14,NULL,4,'2026-01-13 22:08:30'),(7,4,NULL,NULL,'SALE',1,15000.00,'ORDER',14,NULL,4,'2026-01-13 22:08:30'),(8,8,NULL,NULL,'SALE',1,20000.00,'ORDER',14,NULL,4,'2026-01-13 22:08:30'),(9,8,NULL,NULL,'SALE',1,20000.00,'ORDER',18,NULL,4,'2026-01-14 00:53:17'),(10,1,NULL,NULL,'SALE',1,10000.00,'ORDER',18,NULL,4,'2026-01-14 00:53:17'),(11,10,NULL,NULL,'SALE',1,15000.00,'ORDER',18,NULL,4,'2026-01-14 00:53:17'),(12,10,NULL,NULL,'SALE',1,15000.00,'ORDER',19,NULL,4,'2026-01-14 00:54:29'),(13,8,NULL,NULL,'SALE',1,20000.00,'ORDER',19,NULL,4,'2026-01-14 00:54:29'),(14,4,NULL,NULL,'SALE',1,15000.00,'ORDER',19,NULL,4,'2026-01-14 00:54:29'),(15,1,NULL,NULL,'SALE',1,10000.00,'ORDER',20,NULL,4,'2026-01-14 00:55:10'),(16,8,NULL,NULL,'SALE',1,20000.00,'ORDER',20,NULL,4,'2026-01-14 00:55:10'),(17,8,NULL,NULL,'SALE',1,20000.00,'ORDER',21,NULL,4,'2026-01-14 00:58:57'),(18,1,NULL,NULL,'SALE',1,10000.00,'ORDER',21,NULL,4,'2026-01-14 00:58:57'),(19,10,NULL,NULL,'SALE',1,15000.00,'ORDER',21,NULL,4,'2026-01-14 00:58:57'),(20,8,NULL,NULL,'SALE',1,20000.00,'ORDER',22,NULL,4,'2026-01-14 00:59:08'),(21,1,NULL,NULL,'SALE',1,10000.00,'ORDER',22,NULL,4,'2026-01-14 00:59:08'),(22,10,NULL,NULL,'SALE',1,15000.00,'ORDER',22,NULL,4,'2026-01-14 00:59:08'),(23,10,NULL,NULL,'SALE',1,15000.00,'ORDER',23,NULL,4,'2026-01-14 01:06:38'),(24,8,NULL,NULL,'SALE',1,20000.00,'ORDER',23,NULL,4,'2026-01-14 01:06:38'),(25,1,NULL,NULL,'SALE',1,10000.00,'ORDER',23,NULL,4,'2026-01-14 01:06:38'),(26,8,NULL,NULL,'SALE',2,20000.00,'ORDER',24,NULL,4,'2026-01-14 01:12:22'),(27,10,NULL,NULL,'SALE',1,15000.00,'ORDER',24,NULL,4,'2026-01-14 01:12:22'),(28,4,NULL,NULL,'SALE',1,15000.00,'ORDER',25,NULL,4,'2026-01-14 01:23:16'),(29,1,NULL,NULL,'SALE',1,10000.00,'ORDER',25,NULL,4,'2026-01-14 01:23:16'),(30,8,NULL,NULL,'SALE',1,20000.00,'ORDER',25,NULL,4,'2026-01-14 01:23:16'),(31,4,NULL,NULL,'SALE',1,15000.00,'ORDER',26,NULL,4,'2026-01-14 01:27:00'),(32,9,NULL,NULL,'SALE',1,18000.00,'ORDER',26,NULL,4,'2026-01-14 01:27:00'),(33,8,NULL,NULL,'SALE',1,20000.00,'ORDER',26,NULL,4,'2026-01-14 01:27:00'),(34,1,NULL,NULL,'SALE',1,10000.00,'ORDER',27,NULL,4,'2026-01-14 01:30:06'),(35,8,NULL,NULL,'SALE',1,20000.00,'ORDER',27,NULL,4,'2026-01-14 01:30:06'),(36,10,NULL,NULL,'SALE',1,15000.00,'ORDER',27,NULL,4,'2026-01-14 01:30:06'),(37,1,NULL,NULL,'SALE',1,10000.00,'ORDER',28,NULL,4,'2026-01-14 01:43:12'),(38,8,NULL,NULL,'SALE',1,20000.00,'ORDER',28,NULL,4,'2026-01-14 01:43:12'),(39,4,NULL,NULL,'SALE',1,15000.00,'ORDER',28,NULL,4,'2026-01-14 01:43:12'),(40,149,NULL,NULL,'SALE',1,70000.00,'ORDER',30,NULL,4,'2026-01-14 15:13:15'),(41,8,NULL,NULL,'SALE',1,18000.00,'ORDER',31,NULL,4,'2026-01-14 15:22:50'),(42,10,NULL,NULL,'SALE',1,13000.00,'ORDER',31,NULL,4,'2026-01-14 15:22:50'),(43,9,NULL,NULL,'SALE',4,16000.00,'ORDER',32,NULL,4,'2026-01-15 23:21:47'),(44,1,NULL,NULL,'SALE',1,9990.00,'ORDER',32,NULL,4,'2026-01-15 23:21:47'),(45,8,NULL,NULL,'SALE',1,18000.00,'ORDER',32,NULL,4,'2026-01-15 23:21:47'),(46,4,NULL,NULL,'SALE',7,14985.00,'ORDER',32,NULL,4,'2026-01-15 23:21:47'),(47,3,NULL,NULL,'SALE',1,4995.00,'ORDER',32,NULL,4,'2026-01-15 23:21:47'),(48,56,NULL,NULL,'SALE',5,319680.00,'ORDER',33,NULL,4,'2026-01-15 23:30:27'),(49,56,NULL,NULL,'SALE',14,319680.00,'ORDER',34,NULL,4,'2026-01-15 23:32:14'),(50,112,NULL,NULL,'SALE',14,400000.00,'ORDER',35,NULL,4,'2026-01-15 23:39:22'),(51,8,NULL,NULL,'SALE',1,18000.00,'ORDER',36,NULL,4,'2026-01-21 16:39:45'),(52,10,NULL,NULL,'SALE',2,13000.00,'ORDER',36,NULL,4,'2026-01-21 16:39:45'),(53,3,NULL,NULL,'SALE',2,4995.00,'ORDER',37,NULL,4,'2026-01-21 16:52:53'),(54,5,NULL,NULL,'SALE',2,9990.00,'ORDER',37,NULL,4,'2026-01-21 16:52:53'),(55,112,NULL,NULL,'IN',20,NULL,NULL,NULL,'',NULL,'2026-01-21 23:14:00');
/*!40000 ALTER TABLE `inventory_transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_items`
--

DROP TABLE IF EXISTS `order_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_items` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `price` decimal(15,2) NOT NULL,
  `quantity` int NOT NULL,
  `order_id` bigint NOT NULL,
  `product_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FKbioxgbv59vetrxe0ejfubep1w` (`order_id`),
  KEY `FKocimc7dtr037rh4ls4l95nlfi` (`product_id`),
  CONSTRAINT `FKbioxgbv59vetrxe0ejfubep1w` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  CONSTRAINT `FKocimc7dtr037rh4ls4l95nlfi` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=73 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_items`
--

LOCK TABLES `order_items` WRITE;
/*!40000 ALTER TABLE `order_items` DISABLE KEYS */;
INSERT INTO `order_items` VALUES (1,550000.00,1,1,120),(2,320000.00,1,2,56),(3,15000.00,150,3,4),(4,15000.00,100,4,4),(5,30000.00,1,5,12),(6,15000.00,1,5,10),(7,15000.00,150,6,4),(8,10000.00,1,7,1),(9,10000.00,1,8,1),(10,10000.00,1,9,1),(11,10000.00,1,10,1),(12,10000.00,2,11,1),(13,12000.00,1,11,2),(14,10000.00,1,12,1),(15,10000.00,-1,13,1),(16,12000.00,1,13,2),(17,10000.00,1,14,1),(18,15000.00,1,14,4),(19,20000.00,1,14,8),(20,10000.00,2,15,1),(21,15000.00,1,15,4),(22,20000.00,1,15,8),(23,20000.00,1,17,8),(24,10000.00,1,17,1),(25,15000.00,1,17,10),(26,20000.00,1,18,8),(27,10000.00,1,18,1),(28,15000.00,1,18,10),(29,15000.00,1,19,10),(30,20000.00,1,19,8),(31,15000.00,1,19,4),(32,10000.00,1,20,1),(33,20000.00,1,20,8),(34,20000.00,1,21,8),(35,10000.00,1,21,1),(36,15000.00,1,21,10),(37,20000.00,1,22,8),(38,10000.00,1,22,1),(39,15000.00,1,22,10),(40,15000.00,1,23,10),(41,20000.00,1,23,8),(42,10000.00,1,23,1),(43,20000.00,2,24,8),(44,15000.00,1,24,10),(45,15000.00,1,25,4),(46,10000.00,1,25,1),(47,20000.00,1,25,8),(48,15000.00,1,26,4),(49,18000.00,1,26,9),(50,20000.00,1,26,8),(51,10000.00,1,27,1),(52,20000.00,1,27,8),(53,15000.00,1,27,10),(54,10000.00,1,28,1),(55,20000.00,1,28,8),(56,15000.00,1,28,4),(57,70000.00,1,29,149),(58,70000.00,1,30,149),(59,18000.00,1,31,8),(60,13000.00,1,31,10),(61,16000.00,4,32,9),(62,9990.00,1,32,1),(63,18000.00,1,32,8),(64,14985.00,7,32,4),(65,4995.00,1,32,3),(66,319680.00,5,33,56),(67,319680.00,14,34,56),(68,400000.00,14,35,112),(69,18000.00,1,36,8),(70,13000.00,2,36,10),(71,4995.00,2,37,3),(72,9990.00,2,37,5);
/*!40000 ALTER TABLE `order_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
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
  KEY `FKakl1p7xiogdupq1376fttx2xc` (`parent_order_id`),
  CONSTRAINT `FK32ql8ubntj5uh44ph9659tiih` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `FKakl1p7xiogdupq1376fttx2xc` FOREIGN KEY (`parent_order_id`) REFERENCES `orders` (`id`),
  CONSTRAINT `FKpxtb8awmi0dk6smoh2vp1litg` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (1,'2026-01-02 09:16:42.670400',550000.00,NULL,4,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(2,'2026-01-02 09:19:05.594577',320000.00,NULL,4,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(3,'2026-01-02 14:55:51.508733',2250000.00,1,4,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(4,'2026-01-02 14:56:25.545823',1500000.00,1,4,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(5,'2026-01-07 15:19:34.479580',45000.00,1,4,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(6,'2026-01-08 22:39:05.199402',2250000.00,1,4,'TC-26010800001TH',_binary '','RETURNED','RETURN','TRANSFER','không liên lạc được cho khách ','không liên lạc được cho khách ',3,NULL),(7,'2026-01-11 22:12:48.265553',10000.00,7,3,'TC-260108001',_binary '\0','PAID',NULL,NULL,NULL,NULL,NULL,NULL),(8,'2026-01-11 22:12:48.371989',10000.00,7,3,'TC-260108002',_binary '\0','UNPAID',NULL,NULL,NULL,NULL,NULL,NULL),(9,'2026-01-11 22:29:34.634640',10000.00,8,3,'TC-260108003',_binary '\0','PAID',NULL,NULL,NULL,NULL,NULL,NULL),(10,'2026-01-11 22:29:34.702989',10000.00,8,3,'TC-260108004',_binary '\0','UNPAID',NULL,NULL,NULL,NULL,NULL,NULL),(11,'2026-01-11 23:07:46.008079',32000.00,10,3,'TC-260108005',_binary '\0','PAID',NULL,NULL,NULL,NULL,NULL,NULL),(12,'2026-01-11 23:07:46.317056',10000.00,10,3,'TC-260108006TH',_binary '','RETURNED','RETURN','CASH','Test return note','Test return',11,'Test return note'),(13,'2026-01-11 23:07:46.347180',2000.00,10,3,'TC-260108007ĐH',_binary '\0','PAID','EXCHANGE',NULL,NULL,NULL,11,NULL),(14,'2026-01-13 22:08:30.090476',45000.00,2,4,'SALE-20260113-0001',_binary '\0','PAID',NULL,NULL,NULL,NULL,NULL,NULL),(15,'2026-01-13 22:45:02.119240',55000.00,5,4,'TC-260100001',_binary '\0','UNPAID',NULL,NULL,NULL,NULL,NULL,NULL),(17,'2026-01-14 00:36:49.836673',45000.00,5,4,'TC-260100002',_binary '\0','UNPAID',NULL,NULL,NULL,NULL,NULL,NULL),(18,'2026-01-14 00:53:14.748040',45000.00,NULL,4,'TC-260100003',_binary '\0','PAID',NULL,NULL,NULL,NULL,NULL,NULL),(19,'2026-01-14 00:54:25.378622',50000.00,NULL,4,'TC-260100004',_binary '\0','PAID',NULL,NULL,NULL,NULL,NULL,NULL),(20,'2026-01-14 00:55:10.098462',30000.00,NULL,4,'TC-260100005',_binary '\0','PAID',NULL,NULL,NULL,NULL,NULL,NULL),(21,'2026-01-14 00:58:57.110283',45000.00,NULL,4,'TC-260100006',_binary '\0','PAID',NULL,NULL,NULL,NULL,NULL,NULL),(22,'2026-01-14 00:59:07.714321',45000.00,NULL,4,'TC-260100007',_binary '\0','PAID',NULL,NULL,NULL,NULL,NULL,NULL),(23,'2026-01-14 01:06:37.363011',45000.00,2,4,'TC-260100008',_binary '\0','PAID',NULL,NULL,NULL,NULL,NULL,NULL),(24,'2026-01-14 01:12:21.965280',55000.00,6,4,'TC-260100009',_binary '\0','PAID',NULL,NULL,NULL,NULL,NULL,NULL),(25,'2026-01-14 01:23:16.212815',45000.00,6,4,'TC-260100010',_binary '\0','PAID',NULL,NULL,NULL,NULL,NULL,NULL),(26,'2026-01-14 01:26:59.749152',53000.00,6,4,'TC-260100011',_binary '\0','PAID',NULL,NULL,NULL,NULL,NULL,NULL),(27,'2026-01-14 01:30:05.595484',45000.00,6,4,'TC-260100012',_binary '\0','PAID',NULL,NULL,NULL,NULL,NULL,NULL),(28,'2026-01-14 01:43:11.976187',45000.00,6,4,'TC-260100013',_binary '\0','PAID',NULL,NULL,NULL,NULL,NULL,NULL),(29,'2026-01-14 15:13:06.242928',70000.00,6,4,'TC-260100014',_binary '\0','UNPAID',NULL,NULL,NULL,NULL,NULL,NULL),(30,'2026-01-14 15:13:14.978350',70000.00,NULL,4,'TC-260100015',_binary '\0','PAID',NULL,NULL,NULL,NULL,NULL,NULL),(31,'2026-01-14 15:22:50.073880',31000.00,NULL,4,'TC-260100016',_binary '\0','PAID',NULL,NULL,NULL,NULL,NULL,NULL),(32,'2026-01-15 23:21:46.673560',201880.00,2,4,'TC-260100017',_binary '\0','PAID',NULL,NULL,NULL,NULL,NULL,NULL),(33,'2026-01-15 23:30:26.198147',1598400.00,2,4,'TC-260100018',_binary '\0','PAID',NULL,NULL,NULL,NULL,NULL,NULL),(34,'2026-01-15 23:32:14.067649',4475520.00,NULL,4,'TC-260100019',_binary '\0','PAID',NULL,NULL,NULL,NULL,NULL,NULL),(35,'2026-01-15 23:39:21.363061',5600000.00,2,4,'TC-260100020',_binary '\0','PAID',NULL,NULL,NULL,NULL,NULL,NULL),(36,'2026-01-21 16:39:44.602375',44000.00,1,4,'TC-260100021',_binary '\0','PAID',NULL,NULL,NULL,NULL,NULL,NULL),(37,'2026-01-21 16:52:32.348051',29970.00,2,4,'TC-260100022',_binary '\0','PAID',NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payments` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `amount` decimal(15,2) NOT NULL,
  `method` varchar(50) NOT NULL,
  `paid_at` datetime(6) DEFAULT NULL,
  `order_id` bigint NOT NULL,
  `status` varchar(20) DEFAULT NULL,
  `token` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK81gagumt0r8y3rmudcgpbk42l` (`order_id`),
  CONSTRAINT `FK81gagumt0r8y3rmudcgpbk42l` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
INSERT INTO `payments` VALUES (1,550000.00,'CASH','2026-01-02 09:16:42.739274',1,NULL,NULL),(2,320000.00,'CASH','2026-01-02 09:19:05.623705',2,NULL,NULL),(3,2250000.00,'TRANSFER','2026-01-02 14:55:51.725391',3,NULL,NULL),(4,1500000.00,'TRANSFER','2026-01-02 14:56:25.557417',4,NULL,NULL),(5,45000.00,'CASH','2026-01-07 15:19:34.559517',5,NULL,NULL),(6,2250000.00,'TRANSFER','2026-01-08 22:39:05.270491',6,'PAID',NULL),(7,10000.00,'CASH','2026-01-11 22:12:48.313454',7,'PAID',NULL),(9,10000.00,'CASH','2026-01-11 22:29:34.665095',9,'PAID',NULL),(10,10000.00,'CASH','2026-01-11 22:29:34.732654',10,'PAID',NULL),(11,32000.00,'CASH','2026-01-11 23:07:46.048339',11,'PAID',NULL),(12,10000.00,'CASH','2026-01-11 23:07:46.333425',12,'PAID',NULL),(13,2000.00,'CASH','2026-01-11 23:07:46.357445',13,'PAID',NULL),(14,45000.00,'CASH','2026-01-13 22:08:30.148978',14,'PAID',NULL),(15,45000.00,'TRANSFER','2026-01-14 00:53:17.377350',18,'PAID','SAMPLE-Z6Q2WK77 (mã tượng trưng)'),(16,50000.00,'TRANSFER','2026-01-14 00:54:29.125996',19,'PAID','SAMPLE-95QTC1KR (mã tượng trưng)'),(17,30000.00,'CARD','2026-01-14 00:55:10.178100',20,'PAID',NULL),(18,45000.00,'CASH','2026-01-14 00:58:57.308415',21,'PAID',NULL),(19,45000.00,'CASH','2026-01-14 00:59:07.821010',22,'PAID',NULL),(20,45000.00,'CASH','2026-01-14 01:06:37.524404',23,'PAID',NULL),(21,55000.00,'CASH','2026-01-14 01:12:22.095110',24,'PAID',NULL),(22,45000.00,'CASH','2026-01-14 01:23:16.411871',25,'PAID',NULL),(23,53000.00,'CASH','2026-01-14 01:26:59.931249',26,'PAID',NULL),(24,45000.00,'CASH','2026-01-14 01:30:05.750180',27,'PAID',NULL),(25,45000.00,'CASH','2026-01-14 01:43:12.145347',28,'PAID',NULL),(26,70000.00,'CASH','2026-01-14 15:13:15.109593',30,'PAID',NULL),(27,31000.00,'CASH','2026-01-14 15:22:50.248356',31,'PAID',NULL),(28,201880.00,'CASH','2026-01-15 23:21:47.016236',32,'PAID',NULL),(29,1598400.00,'TRANSFER','2026-01-15 23:30:27.433785',33,'PAID','SAMPLE-TTWG1H0S (mã tượng trưng)'),(30,4475520.00,'CASH','2026-01-15 23:32:14.174223',34,'PAID',NULL),(31,5600000.00,'CASH','2026-01-15 23:39:21.511886',35,'PAID',NULL),(32,44000.00,'CASH','2026-01-21 16:39:44.869910',36,'PAID',NULL),(33,29970.00,'TRANSFER','2026-01-21 16:52:52.961994',37,'PAID','SAMPLE-HLKHMF9F (mã tượng trưng)');
/*!40000 ALTER TABLE `payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `point_history`
--

DROP TABLE IF EXISTS `point_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `point_history` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) DEFAULT NULL,
  `points` int DEFAULT NULL,
  `reason` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `customer_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FKoykoexosmdcwsmph7ubqmq22` (`customer_id`),
  CONSTRAINT `FKoykoexosmdcwsmph7ubqmq22` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `point_history`
--

LOCK TABLES `point_history` WRITE;
/*!40000 ALTER TABLE `point_history` DISABLE KEYS */;
INSERT INTO `point_history` VALUES (2,'2026-01-11 22:29:34.759798',10,'ORDER_10',8);
/*!40000 ALTER TABLE `point_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_cost_histories`
--

DROP TABLE IF EXISTS `product_cost_histories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_cost_histories` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `product_id` bigint NOT NULL,
  `cost_price` decimal(15,2) NOT NULL,
  `quantity` int NOT NULL,
  `note` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_by` bigint DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FKagbnau0mqw831wgvk2h3v696m` (`product_id`),
  CONSTRAINT `FKagbnau0mqw831wgvk2h3v696m` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_cost_histories`
--

LOCK TABLES `product_cost_histories` WRITE;
/*!40000 ALTER TABLE `product_cost_histories` DISABLE KEYS */;
INSERT INTO `product_cost_histories` VALUES (1,112,300000.00,20,'',NULL,'2026-01-21 23:14:00.073194');
/*!40000 ALTER TABLE `product_cost_histories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_costs`
--

DROP TABLE IF EXISTS `product_costs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_costs` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `cost_price` decimal(15,2) NOT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `product_id` bigint NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK_emj5ou3kymldu462sbu36chhd` (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_costs`
--

LOCK TABLES `product_costs` WRITE;
/*!40000 ALTER TABLE `product_costs` DISABLE KEYS */;
INSERT INTO `product_costs` VALUES (1,300000.00,'2026-01-21 23:13:59.929129',112,'2026-01-21 23:13:59.929548');
/*!40000 ALTER TABLE `product_costs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
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
) ENGINE=InnoDB AUTO_INCREMENT=151 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES (1,'Coca-Cola lon 330ml','CC330','8934567000010',1,'lon',10000.00,7500.00,'active','Nước ngọt có ga','2025-12-29 17:04:24',NULL,NULL,'','',20),(2,'Trà Xanh Không Độ chai 500ml','TXKD500','8934567000027',1,'chai',12000.00,9000.00,'active','Trà giải khát không đường','2025-12-29 17:04:24',NULL,NULL,'','',20),(3,'Nước suối Aquafina 500ml','AQF500','8934567000034',1,'chai',5000.00,3500.00,'active','Nước tinh khiết','2025-12-29 17:04:24',NULL,NULL,'','',20),(4,'Bia Sài Gòn Lager 330ml','SGL330','8934567000041',1,'lon',15000.00,11000.00,'active','Bia Lager (có thể dùng chung ID 7 nếu không muốn tách)','2025-12-29 17:04:24',NULL,NULL,'','',20),(5,'Pepsi lon 330ml','PS330','8934567000058',1,'lon',10000.00,7500.00,'active','Nước ngọt có ga vị chanh','2025-12-29 17:04:24',NULL,NULL,'','',20),(6,'Snack Oishi vị Phô Mai 35g','OIS-PM35','8934567000065',2,'gói',8000.00,5500.00,'active','Bánh snack khoai tây','2025-12-29 17:04:24',NULL,NULL,'','',20),(7,'Khô Gà Lá Chanh 100g','KG-LC100','8934567000072',2,'túi',35000.00,25000.00,'active','Thực phẩm ăn liền','2025-12-29 17:04:24',NULL,NULL,'','',20),(8,'Hạt Hướng Dương Vị Muối 250g','HD-MS250','8934567000089',2,'gói',20000.00,14000.00,'active','Hạt rang ăn liền','2025-12-29 17:04:24',NULL,NULL,'','',20),(9,'Bánh Quy Cosy dừa 160g','CQ-DY160','8934567000096',2,'gói',18000.00,12500.00,'active','Bánh quy ngọt','2025-12-29 17:04:24',NULL,NULL,'','',20),(10,'Kẹo Alpenliebe vị caramen','ALP-CR','8934567000102',2,'gói',15000.00,10000.00,'active','Kẹo cứng (có thể dùng chung ID 6)','2025-12-29 17:04:24',NULL,NULL,'','',20),(11,'Dầu Gội Sunsilk Mềm Mượt 320g','DG-SM320','8934567000119',3,'chai',65000.00,45000.00,'active','Dầu gội đầu','2025-12-29 17:04:24',NULL,NULL,'','',20),(12,'Kem Đánh Răng P/S Bảo Vệ 120g','KDR-PSBV','8934567000126',3,'tuýp',30000.00,20000.00,'active','Kem đánh răng cơ bản','2025-12-29 17:04:24',NULL,NULL,'','',20),(13,'Xà Bông Lifebuoy diệt khuẩn 90g','XB-LB90','8934567000133',3,'bánh',15000.00,10000.00,'active','Xà bông tắm/rửa tay','2025-12-29 17:04:24',NULL,NULL,'','',20),(14,'Dao cạo râu Gillette 1 lưỡi','DCR-GL1','8934567000140',3,'cái',5000.00,3000.00,'active','Dụng cụ cá nhân','2025-12-29 17:04:24',NULL,NULL,'','',20),(15,'Khăn Giấy Gấu Trúc 180 tờ','KG-GT180','8934567000157',3,'gói',12000.00,8000.00,'active','Khăn giấy khô','2025-12-29 17:04:24',NULL,NULL,'','',20),(16,'Nước Mắm Chin-su 500ml','NM-CS500','8934567000164',4,'chai',45000.00,30000.00,'active','Nước mắm cá cơm','2025-12-29 17:04:24',NULL,NULL,'','',20),(17,'Dầu Ăn Tường An 1 Lít','DA-TA1L','8934567000171',4,'chai',60000.00,40000.00,'active','Dầu thực vật','2025-12-29 17:04:24',NULL,NULL,'','',20),(18,'Muối I-ốt Bạc Liêu 500g','M-BL500','8934567000188',4,'gói',5000.00,3000.00,'active','Muối ăn thông thường','2025-12-29 17:04:24',NULL,NULL,'','',20),(19,'Đường Trắng Biên Hòa 1kg','DT-BH1KG','8934567000195',4,'gói',25000.00,18000.00,'active','Đường tinh luyện','2025-12-29 17:04:24',NULL,NULL,'','',20),(20,'Bột Ngọt Ajinomoto 450g','BN-AJI450','8934567000201',4,'gói',35000.00,25000.00,'active','Chất điều vị','2025-12-29 17:04:24',NULL,NULL,'','',20),(21,'Nước Rửa Chén Mỹ Hảo 800g','NRC-MH800','8934567000218',5,'chai',25000.00,15000.00,'active','Nước rửa chén bát','2025-12-29 17:04:24',NULL,NULL,'','',20),(22,'Bột Giặt OMO Matic 800g','BG-OMO800','8934567000225',5,'túi',45000.00,30000.00,'active','Bột giặt máy giặt','2025-12-29 17:04:24',NULL,NULL,'','',20),(23,'Nước Lau Sàn Gift 1 Lít','NLS-GF1L','8934567000232',5,'chai',35000.00,22000.00,'active','Chất tẩy rửa sàn nhà','2025-12-29 17:04:24',NULL,NULL,'','',20),(24,'Thuốc diệt muỗi Mosfly chai','TDM-MOS','8934567000249',5,'chai',70000.00,50000.00,'active','Chất diệt côn trùng','2025-12-29 17:04:24',NULL,NULL,'','',20),(25,'Túi đựng rác tự phân hủy (3 cuộn)','TDR-3C','8934567000256',5,'gói',15000.00,10000.00,'active','Dụng cụ vệ sinh','2025-12-29 17:04:24',NULL,NULL,'','',20),(26,'Bánh Chocopie Hộp 12 cái','CP-12C','8934567000263',6,'hộp',40000.00,28000.00,'active','Bánh xốp phủ sô cô la','2025-12-29 17:04:24',NULL,NULL,'','',20),(27,'Kẹo Sugus Trái Cây 150g','K-SUG150','8934567000270',6,'túi',20000.00,13000.00,'active','Kẹo dẻo mềm','2025-12-29 17:04:24',NULL,NULL,'','',20),(28,'Bánh Mì Sữa Tươi Kinh Đô','BM-KDS','8934567000287',6,'gói',12000.00,8000.00,'active','Bánh mì ngọt ăn sáng','2025-12-29 17:04:24',NULL,NULL,'','',20),(29,'Thạch Rau Câu Long Hải 400g','TRC-LH400','8934567000294',6,'túi',15000.00,10000.00,'active','Tráng miệng lạnh','2025-12-29 17:04:24',NULL,NULL,'','',20),(30,'Kẹo Socola Kitkat thanh','SC-KKTH','8934567000300',6,'thanh',8000.00,5000.00,'active','Bánh xốp phủ socola','2025-12-29 17:04:24',NULL,NULL,'','',20),(31,'Bia Tiger lon 330ml','BT-330','8934567000317',7,'lon',17000.00,12500.00,'active','Bia Lager cao cấp','2025-12-29 17:04:24',NULL,NULL,'','',20),(32,'Bia Heineken lon 330ml','BH-330','8934567000324',7,'lon',20000.00,15000.00,'active','Bia nhập khẩu','2025-12-29 17:04:24',NULL,NULL,'','',20),(33,'Rượu Vodka Hà Nội 700ml','R-VDHN','8934567000331',7,'chai',150000.00,100000.00,'active','Rượu mạnh','2025-12-29 17:04:24',NULL,NULL,'','',20),(34,'Bia 333 lon 330ml','B3-330','8934567000348',7,'lon',14000.00,10000.00,'active','Bia truyền thống','2025-12-29 17:04:24',NULL,NULL,'','',20),(35,'Bia Larue lon 330ml','BL-330','8934567000355',7,'lon',13000.00,9000.00,'active','Bia phổ thông','2025-12-29 17:04:24',NULL,NULL,'','',20),(36,'Mì Hảo Hảo Tôm Chua Cay','MHHTC','8934567000362',8,'gói',6000.00,4000.00,'active','Mì ăn liền phổ thông','2025-12-29 17:04:24',NULL,NULL,'','',20),(37,'Phở Bò Gói Vifon','PB-VF','8934567000379',8,'gói',12000.00,8000.00,'active','Phở ăn liền','2025-12-29 17:04:24',NULL,NULL,'','',20),(38,'Mì Omachi Xốt Thịt Heo','M-OMXTH','8934567000386',8,'gói',10000.00,6500.00,'active','Mì không chiên','2025-12-29 17:04:24',NULL,NULL,'','',20),(39,'Cháo Thịt Bằm gói 50g','CB-50G','8934567000393',8,'gói',8000.00,5000.00,'active','Cháo ăn liền dinh dưỡng','2025-12-29 17:04:24',NULL,NULL,'','',20),(40,'Mì Kokomi Đại gói','MKD-GOI','8934567000409',8,'gói',5500.00,3500.00,'active','Mì gói lớn','2025-12-29 17:04:24',NULL,NULL,'','',20),(41,'Pate Cột Đèn Hải Phòng 100g','PCĐ-100','8934567000416',9,'hộp',25000.00,18000.00,'active','Thịt xay đóng hộp','2025-12-29 17:04:24',NULL,NULL,'','',20),(42,'Cá Hộp Sốt Cà Chua 3 Cô Gái','CH-3CG','8934567000423',9,'hộp',20000.00,14000.00,'active','Cá hộp ăn liền','2025-12-29 17:04:24',NULL,NULL,'','',20),(43,'Thịt Heo 2 Lát Đóng Hộp','TH2L-DH','8934567000430',9,'hộp',40000.00,28000.00,'active','Thịt heo chế biến sẵn','2025-12-29 17:04:24',NULL,NULL,'','',20),(44,'Sữa Đặc Ông Thọ Vàng 380g','SD-OTV','8934567000447',9,'lon',28000.00,20000.00,'active','Sữa đặc có đường','2025-12-29 17:04:24',NULL,NULL,'','',20),(45,'Dưa Chuột Muối chua 500g','DCM-500','8934567000454',9,'hũ',30000.00,21000.00,'active','Rau củ muối chua','2025-12-29 17:04:24',NULL,NULL,'','',20),(46,'Thuốc Lá Vinataba Gói','TL-VNTB','8934567000461',10,'gói',30000.00,22000.00,'active','Thuốc lá thông dụng','2025-12-29 17:04:24',NULL,NULL,'','',20),(47,'Thuốc Lá 555 Gói','TL-555','8934567000478',10,'gói',35000.00,26000.00,'active','Thuốc lá cao cấp hơn','2025-12-29 17:04:24',NULL,NULL,'','',20),(48,'Bật Lửa Gas BIC (màu xanh)','BL-BICX','8934567000485',10,'cái',8000.00,5000.00,'active','Bật lửa dùng 1 lần','2025-12-29 17:04:24',NULL,NULL,'','',20),(49,'Diêm Thống Nhất Hộp Nhỏ','D-TN','8934567000492',10,'hộp',2000.00,1000.00,'active','Diêm quẹt','2025-12-29 17:04:24',NULL,NULL,'','',20),(50,'Thuốc Lá Kent Gói','TL-KNT','8934567000508',10,'gói',40000.00,30000.00,'active','Thuốc lá nhập khẩu','2025-12-29 17:04:24',NULL,NULL,'','',20),(51,'Nước tăng lực Red Bull 250ml','NTL-RB','8934567000515',1,'lon',18000.00,13000.00,'active','Nước uống tăng lực Thái Lan','2025-12-29 17:08:00',NULL,NULL,'','',20),(52,'Sữa tươi Vinamilk không đường 1L','ST-VNM-KS','8934567000522',1,'hộp',35000.00,25000.00,'active','Sữa tươi tiệt trùng 100%','2025-12-29 17:08:00',NULL,NULL,'','',20),(53,'Nước ép cam Vfresh 1L','NE-VFC','8934567000539',1,'hộp',40000.00,28000.00,'active','Nước ép trái cây nguyên chất','2025-12-29 17:08:00',NULL,NULL,'','',20),(54,'Nước suối Lavie 1.5L','NUC-LV15','8934567000546',1,'chai',8000.00,5000.00,'active','Nước khoáng thiên nhiên','2025-12-29 17:08:00',NULL,NULL,'','',20),(55,'Nước yến ngân nhĩ 240ml','NY-NN240','8934567000553',1,'lon',25000.00,18000.00,'active','Nước giải khát bổ dưỡng','2025-12-29 17:08:00',NULL,NULL,'','',20),(56,'Bia 333 thùng 24 lon','B333-T24','8934567000560',1,'thùng',320000.00,250000.00,'active','Bia thùng 24 lon','2025-12-29 17:08:00',NULL,NULL,'','',20),(57,'Trà đào Cozy hộp 25 gói','TD-CZY25','8934567000577',1,'hộp',45000.00,32000.00,'active','Trà hòa tan vị đào','2025-12-29 17:08:00',NULL,NULL,'','',20),(58,'Sting dâu lon 330ml','NTL-STING','8934567000584',1,'lon',12000.00,8500.00,'active','Nước tăng lực vị dâu','2025-12-29 17:08:00',NULL,NULL,'','',20),(59,'Sữa chua uống Probi 65ml (lốc 5)','SCU-PB','8934567000591',1,'lốc',22000.00,16000.00,'active','Sữa chua uống lợi khuẩn','2025-12-29 17:08:00',NULL,NULL,'','',20),(60,'Nước ép dứa Dole 330ml','NED-DL330','8934567000607',1,'lon',15000.00,10000.00,'active','Nước ép dứa đóng lon','2025-12-29 17:08:00',NULL,NULL,'','',20),(61,'Bánh gạo One.One vị bò 100g','BG-OOVB','8934567000614',2,'gói',15000.00,10000.00,'active','Bánh gạo giòn tan','2025-12-29 17:08:00',NULL,NULL,'','',20),(62,'Snack Poca vị muối ớt 70g','SK-POCA','8934567000621',2,'gói',18000.00,12000.00,'active','Snack khoai tây lát muối ớt','2025-12-29 17:08:00',NULL,NULL,'','',20),(63,'Rong Biển Ăn Liền Taekyung 5g','RB-TK','8934567000638',2,'gói',7000.00,4500.00,'active','Rong biển sấy khô Hàn Quốc','2025-12-29 17:08:00',NULL,NULL,'','',20),(64,'Hạt điều rang muối 500g','HD-RM500','8934567000645',2,'hộp',150000.00,110000.00,'active','Hạt điều Bình Phước','2025-12-29 17:08:00',NULL,NULL,'','',20),(65,'Thịt bò khô miếng 50g','TBK-M50','8934567000652',2,'gói',45000.00,32000.00,'active','Thịt bò sấy khô xé sợi','2025-12-29 17:08:00',NULL,NULL,'','',20),(66,'Bánh phồng tôm Sa Giang 200g','BPT-SG200','8934567000669',2,'gói',30000.00,20000.00,'active','Bánh phồng tôm chưa chiên','2025-12-29 17:08:00',NULL,NULL,'','',20),(67,'Socola thanh Mars 50g','SC-MAR50','8934567000676',2,'thanh',18000.00,12000.00,'active','Socola nhân caramen','2025-12-29 17:08:00',NULL,NULL,'','',20),(68,'Bim Bim Lay\'s vị tự nhiên 50g','BB-LAYS','8934567000683',2,'gói',10000.00,6500.00,'active','Snack khoai tây lát mỏng','2025-12-29 17:08:00',NULL,NULL,'','',20),(69,'Kẹo dẻo Chuppa Chups 75g','KD-CC75','8934567000690',2,'gói',15000.00,10000.00,'active','Kẹo dẻo hình thù','2025-12-29 17:08:00',NULL,NULL,'','',20),(70,'Mứt gừng sấy dẻo 200g','MG-SD200','8934567000706',2,'hộp',50000.00,35000.00,'active','Mứt gừng đặc sản','2025-12-29 17:08:00',NULL,NULL,'','',20),(71,'Sữa tắm Enchanteur 450ml','ST-ECH','8934567000713',3,'chai',85000.00,60000.00,'active','Sữa tắm hương nước hoa','2025-12-29 17:08:00',NULL,NULL,'','',20),(72,'Dầu xả TRESemmé 340g','DX-TRE','8934567000720',3,'chai',70000.00,50000.00,'active','Dầu xả dưỡng tóc óng mượt','2025-12-29 17:08:00',NULL,NULL,'','',20),(73,'Kem chống nắng Bioré 50ml','KCN-BIO','8934567000737',3,'tuýp',90000.00,65000.00,'active','Bảo vệ da SPF50+','2025-12-29 17:08:00',NULL,NULL,'','',20),(74,'Son dưỡng môi Vaseline 10g','SDM-VAS','8934567000744',3,'hộp',35000.00,25000.00,'active','Dưỡng ẩm môi khô nẻ','2025-12-29 17:08:00',NULL,NULL,'','',20),(75,'Băng vệ sinh Diana Sensi 8 miếng','BVS-DS8','8934567000751',3,'gói',25000.00,18000.00,'active','Băng vệ sinh hàng ngày','2025-12-29 17:08:00',NULL,NULL,'','',20),(76,'Nước tẩy trang L’Oréal 400ml','NTT-LO400','8934567000768',3,'chai',130000.00,90000.00,'active','Làm sạch sâu da mặt','2025-12-29 17:08:00',NULL,NULL,'','',20),(77,'Mặt nạ giấy dưỡng ẩm (gói)','MN-GA','8934567000775',3,'gói',15000.00,10000.00,'active','Mặt nạ cấp ẩm','2025-12-29 17:08:00',NULL,NULL,'','',20),(78,'Sữa rửa mặt Cetaphil 125ml','SRM-CET','8934567000782',3,'chai',80000.00,55000.00,'active','Sữa rửa mặt dịu nhẹ','2025-12-29 17:08:00',NULL,NULL,'','',20),(79,'Khăn ướt Bobby không mùi (100 tờ)','KU-BBY','8934567000799',3,'gói',30000.00,20000.00,'active','Khăn ướt vệ sinh cá nhân','2025-12-29 17:08:00',NULL,NULL,'','',20),(80,'Kem dưỡng ẩm Nivea Soft 50ml','KDA-NS50','8934567000805',3,'hộp',45000.00,30000.00,'active','Kem dưỡng ẩm toàn thân','2025-12-29 17:08:00',NULL,NULL,'','',20),(81,'Tương ớt Chin-su chai 250g','TO-CS250','8934567000812',4,'chai',18000.00,12000.00,'active','Tương ớt cay nồng','2025-12-29 17:08:00',NULL,NULL,'','',20),(82,'Xì Dầu Maggi chai 200ml','XD-MAG200','8934567000829',4,'chai',22000.00,15000.00,'active','Nước tương đậu nành','2025-12-29 17:08:00',NULL,NULL,'','',20),(83,'Giấm gạo Ajinomoto 400ml','G-AJI400','8934567000836',4,'chai',15000.00,10000.00,'active','Giấm dùng nấu ăn','2025-12-29 17:08:00',NULL,NULL,'','',20),(84,'Hạt nêm Knorr 400g','HN-KNR400','8934567000843',4,'gói',30000.00,21000.00,'active','Gia vị nêm nếm thịt thăn','2025-12-29 17:08:00',NULL,NULL,'','',20),(85,'Tiêu xay Vifon 50g','TX-VF50','8934567000850',4,'hộp',25000.00,17000.00,'active','Bột tiêu xay nguyên chất','2025-12-29 17:08:00',NULL,NULL,'','',20),(86,'Dầu hào Maggi 350g','DH-MAG350','8934567000867',4,'chai',35000.00,24000.00,'active','Dầu hào nấm hương','2025-12-29 17:08:00',NULL,NULL,'','',20),(87,'Bột canh I-ốt 190g','BC-I-190','8934567000874',4,'gói',8000.00,5000.00,'active','Bột canh nêm nếm','2025-12-29 17:08:00',NULL,NULL,'','',20),(88,'Nước tương Phú Sĩ 500ml','NT-PS500','8934567000881',4,'chai',18000.00,12000.00,'active','Nước tương phổ thông','2025-12-29 17:08:00',NULL,NULL,'','',20),(89,'Dầu mè đen 200ml','DM-200','8934567000898',4,'chai',30000.00,21000.00,'active','Dầu mè thơm','2025-12-29 17:08:00',NULL,NULL,'','',20),(90,'Bột mì đa dụng 500g','BM-500','8934567000904',4,'gói',15000.00,10000.00,'active','Bột dùng làm bánh','2025-12-29 17:08:00',NULL,NULL,'','',20),(91,'Nước rửa tay Lifebuoy 450g','NRT-LB450','8934567000911',5,'chai',55000.00,38000.00,'active','Nước rửa tay diệt khuẩn','2025-12-29 17:08:00',NULL,NULL,'','',20),(92,'Nước xả vải Comfort 800ml','NXV-CF800','8934567000928',5,'túi',40000.00,28000.00,'active','Làm mềm và thơm quần áo','2025-12-29 17:08:00',NULL,NULL,'','',20),(93,'Giấy vệ sinh Sài Gòn 10 cuộn','GVS-SG10','8934567000935',5,'gói',50000.00,35000.00,'active','Giấy vệ sinh 3 lớp','2025-12-29 17:08:00',NULL,NULL,'','',20),(94,'Dầu hỏa thắp sáng 500ml','DH-500','8934567000942',5,'chai',15000.00,10000.00,'active','Chất đốt thắp sáng','2025-12-29 17:08:00',NULL,NULL,'','',20),(95,'Nến thơm Lavender','NT-LV','8934567000959',5,'cái',35000.00,24000.00,'active','Khử mùi, tạo hương thơm','2025-12-29 17:08:00',NULL,NULL,'','',20),(96,'Nước tẩy bồn cầu Vim 450ml','NTBC-VM','8934567000966',5,'chai',30000.00,20000.00,'active','Chất tẩy rửa nhà vệ sinh','2025-12-29 17:08:00',NULL,NULL,'','',20),(97,'Túi đựng rác 5kg (3 cuộn)','TDR-5KG','8934567000973',5,'gói',25000.00,17000.00,'active','Túi rác tự phân hủy','2025-12-29 17:08:00',NULL,NULL,'','',20),(98,'Bột thông cống 100g','BTC-100','8934567000980',5,'gói',15000.00,10000.00,'active','Hóa chất thông cống','2025-12-29 17:08:00',NULL,NULL,'','',20),(99,'Khăn lau đa năng 3M Scotch-Brite','KL-3MSB','8934567000997',5,'cái',40000.00,28000.00,'active','Khăn lau thấm nước','2025-12-29 17:08:00',NULL,NULL,'','',20),(100,'Nước lau kính Cif 500ml','NLK-CIF','8934567001000',5,'chai',35000.00,24000.00,'active','Làm sạch gương kính','2025-12-29 17:08:00',NULL,NULL,'','',20),(101,'Bánh quy bơ Danisa 454g','BQB-DAN','8934567001017',6,'hộp',90000.00,65000.00,'active','Bánh quy bơ hộp thiếc','2025-12-29 17:08:00',NULL,NULL,'','',20),(102,'Bánh Custas kem trứng hộp 6 cái','BC-KEM6','8934567001024',6,'hộp',35000.00,24000.00,'active','Bánh mềm nhân kem trứng','2025-12-29 17:08:00',NULL,NULL,'','',20),(103,'Kẹo cao su Doublemint','KCS-DM','8934567001031',6,'gói',10000.00,6000.00,'active','Kẹo cao su bạc hà','2025-12-29 17:08:00',NULL,NULL,'','',20),(104,'Bánh Goute mè giòn 144g','B-GME','8934567001048',6,'gói',25000.00,17000.00,'active','Bánh mặn giòn','2025-12-29 17:08:00',NULL,NULL,'','',20),(105,'Socola sữa Milo Cube','SC-MLC','8934567001055',6,'gói',50000.00,35000.00,'active','Socola viên ăn vặt','2025-12-29 17:08:00',NULL,NULL,'','',20),(106,'Bánh AFC lúa mì 200g','B-AFC','8934567001062',6,'gói',28000.00,20000.00,'active','Bánh quy ăn kiêng','2025-12-29 17:08:00',NULL,NULL,'','',20),(107,'Kẹo dẻo Haribo Gummy Bear','KD-HGB','8934567001079',6,'gói',30000.00,21000.00,'active','Kẹo dẻo hình gấu','2025-12-29 17:08:00',NULL,NULL,'','',20),(108,'Bánh mì sandwich lát (tươi)','BMS-LAT','8934567001086',6,'gói',18000.00,12000.00,'active','Bánh mì tươi ăn sáng','2025-12-29 17:08:00',NULL,NULL,'','',20),(109,'Thạch rau câu Zai Zai (hộp)','TRC-ZZ','8934567001093',6,'hộp',40000.00,28000.00,'active','Thạch rau câu nhiều vị','2025-12-29 17:08:00',NULL,NULL,'','',20),(110,'Bánh quy Oreo nhân kem 133g','BQ-OREO','8934567001109',6,'gói',15000.00,10000.00,'active','Bánh quy sô cô la','2025-12-29 17:08:00',NULL,NULL,'','',20),(111,'Rượu vang Đà Lạt Classic 750ml','RV-DL750','8934567001116',7,'chai',120000.00,85000.00,'active','Rượu vang đỏ phổ thông','2025-12-29 17:08:00',NULL,NULL,'','',20),(112,'Bia Tiger Crystal chai 330ml (thùng 24)','BTC-24','8934567001123',7,'thùng',400000.00,300000.00,'active','Bia Crystal nhẹ','2025-12-29 17:08:00',NULL,NULL,'','',40),(113,'Rượu Soju Chum Churum 360ml','RS-CC','8934567001130',7,'chai',65000.00,45000.00,'active','Rượu Soju Hàn Quốc','2025-12-29 17:08:00',NULL,NULL,'','',20),(114,'Bia Huda lon 330ml','B-HDA','8934567001147',7,'lon',13000.00,9500.00,'active','Bia địa phương miền Trung','2025-12-29 17:08:00',NULL,NULL,'','',20),(115,'Nước ngọt có gas 7Up lon 330ml','NG-7UP','8934567001154',7,'lon',10000.00,7500.00,'active','Nước ngọt chanh','2025-12-29 17:08:00',NULL,NULL,'','',20),(116,'Bia Larue chai 450ml','BL-450','8934567001161',7,'chai',18000.00,13000.00,'active','Chai bia truyền thống','2025-12-29 17:08:00',NULL,NULL,'','',20),(117,'Rượu Nếp Mới 500ml','RNM-500','8934567001178',7,'chai',50000.00,35000.00,'active','Rượu nếp truyền thống','2025-12-29 17:08:00',NULL,NULL,'','',20),(118,'Bia Strongbow Vị Dâu lon','BS-DV','8934567001185',7,'lon',20000.00,15000.00,'active','Cider trái cây','2025-12-29 17:08:00',NULL,NULL,'','',20),(119,'Bia Sapporo lon 330ml','BS-330','8934567001192',7,'lon',19000.00,14000.00,'active','Bia Nhật Bản','2025-12-29 17:08:00',NULL,NULL,'','',20),(120,'Rượu Whisky Johnnie Walker Red Label 750ml','RW-JWRL','8934567001208',7,'chai',550000.00,400000.00,'active','Rượu mạnh','2025-12-29 17:08:00',NULL,NULL,'','',20),(121,'Mì Tiến Vua Bò Hầm','M-TVBH','8934567001215',8,'gói',7000.00,4500.00,'active','Mì không chiên vị bò','2025-12-29 17:08:00',NULL,NULL,'','',20),(122,'Hủ tiếu Nam Vang Gói','HT-NVG','8934567001222',8,'gói',15000.00,10000.00,'active','Hủ tiếu ăn liền','2025-12-29 17:08:00',NULL,NULL,'','',20),(123,'Cháo Yến Mạch ăn liền 50g','CYM-50','8934567001239',8,'gói',9000.00,6000.00,'active','Cháo yến mạch ăn liền','2025-12-29 17:08:00',NULL,NULL,'','',20),(124,'Mì 3 Miền Tôm Chua Cay','M3M-TCC','8934567001246',8,'gói',5500.00,3500.00,'active','Mì phổ thông vị tôm chua cay','2025-12-29 17:08:00',NULL,NULL,'','',20),(125,'Miến Phú Hương Sườn Heo','MPH-SH','8934567001253',8,'gói',10000.00,7000.00,'active','Miến ăn liền vị sườn heo','2025-12-29 17:08:00',NULL,NULL,'','',20),(126,'Mì lẩu thái Gấu Đỏ','MLT-GD','8934567001260',8,'gói',6500.00,4000.00,'active','Mì gói vị lẩu thái','2025-12-29 17:08:00',NULL,NULL,'','',20),(127,'Bún riêu cua ăn liền','BRC-AL','8934567001277',8,'gói',13000.00,9000.00,'active','Bún ăn liền vị riêu cua','2025-12-29 17:08:00',NULL,NULL,'','',20),(128,'Cháo đậu xanh gói','CDX-GOI','8934567001284',8,'gói',7000.00,4500.00,'active','Cháo dinh dưỡng đậu xanh','2025-12-29 17:08:00',NULL,NULL,'','',20),(129,'Mì Reeva Lẩu nấm','M-RVLN','8934567001291',8,'gói',8000.00,5500.00,'active','Mì có sợi khoai tây','2025-12-29 17:08:00',NULL,NULL,'','',20),(130,'Phở khô Sông Hậu 400g','PK-SH400','8934567001307',8,'gói',20000.00,14000.00,'active','Phở khô làm bún','2025-12-29 17:08:00',NULL,NULL,'','',20),(131,'Thịt lợn hầm Tiên Yết 150g','TLH-TY','8934567001314',9,'hộp',35000.00,25000.00,'active','Thịt lợn hầm sẵn','2025-12-29 17:08:00',NULL,NULL,'','',20),(132,'Cá Ngừ Ngâm Dầu hộp 185g','CN-ND','8934567001321',9,'hộp',60000.00,42000.00,'active','Cá ngừ đóng hộp','2025-12-29 17:08:00',NULL,NULL,'','',20),(133,'Đậu cô ve muối chua 400g','DCVM-400','8934567001338',9,'hũ',25000.00,17000.00,'active','Rau củ ngâm chua','2025-12-29 17:08:00',NULL,NULL,'','',20),(134,'Sữa Đặc Ngôi Sao Phương Nam 380g','SD-NSPN','8934567001345',9,'lon',26000.00,19000.00,'active','Sữa đặc có đường','2025-12-29 17:08:00',NULL,NULL,'','',20),(135,'Lạp xưởng đóng gói 500g','LX-DG500','8934567001352',9,'gói',90000.00,65000.00,'active','Thực phẩm chế biến','2025-12-29 17:08:00',NULL,NULL,'','',20),(136,'Nước cốt gà Vifon 180g','NCG-VF','8934567001369',9,'hộp',45000.00,30000.00,'active','Nước cốt hầm xương','2025-12-29 17:08:00',NULL,NULL,'','',20),(137,'Thịt gà xé phay đóng hộp 150g','TGXP-150','8934567001376',9,'hộp',38000.00,26000.00,'active','Thịt gà đóng hộp ăn liền','2025-12-29 17:08:00',NULL,NULL,'','',20),(138,'Bò kho đóng hộp 300g','BK-DH300','8934567001383',9,'hộp',55000.00,40000.00,'active','Bò kho chế biến sẵn','2025-12-29 17:08:00',NULL,NULL,'','',20),(139,'Dứa (thơm) đóng hộp cắt lát 565g','DT-CLL','8934567001390',9,'lon',40000.00,28000.00,'active','Trái cây đóng hộp','2025-12-29 17:08:00',NULL,NULL,'','',20),(140,'Đậu phụ chiên đóng hộp 200g','DPC-DH','8934567001406',9,'hộp',20000.00,13000.00,'active','Đậu phụ chiên sẵn','2025-12-29 17:08:00',NULL,NULL,'','',20),(141,'Thuốc Lá Craven A Gói','TL-CA','8934567001413',10,'gói',32000.00,24000.00,'active','Thuốc lá','2025-12-29 17:08:00',NULL,NULL,'','',20),(142,'Thuốc Lá Marlboro Lights Gói','TL-MLT','8934567001420',10,'gói',45000.00,33000.00,'active','Thuốc lá nhẹ','2025-12-29 17:08:00',NULL,NULL,'','',20),(143,'Bật Lửa Đá Zippo (chưa đổ xăng)','BL-ZPO','8934567001437',10,'cái',350000.00,250000.00,'active','Bật lửa tái sử dụng','2025-12-29 17:08:00',NULL,NULL,'','',20),(144,'Xăng Bật Lửa Zippo 125ml','XBL-ZPO','8934567001444',10,'chai',50000.00,35000.00,'active','Nhiên liệu bật lửa','2025-12-29 17:08:00',NULL,NULL,'','',20),(145,'Giấy cuốn thuốc lá 100 tờ','GCT-100','8934567001451',10,'tệp',15000.00,10000.00,'active','Giấy cuốn thuốc','2025-12-29 17:08:00',NULL,NULL,'','',20),(146,'Tẩu hút thuốc lá nhỏ','THTL-N','8934567001468',10,'cái',80000.00,55000.00,'active','Dụng cụ hút thuốc','2025-12-29 17:08:00',NULL,NULL,'','',20),(147,'Thuốc Lá Thăng Long','TL-TL','8934567001475',10,'gói',25000.00,18000.00,'active','Thuốc lá phổ thông Việt Nam','2025-12-29 17:08:00',NULL,NULL,'','',20),(148,'Diêm hộp lớn 100 que','D-HL','8934567001482',10,'hộp',3000.00,1500.00,'active','Diêm dùng nhiều lần','2025-12-29 17:08:00',NULL,NULL,'','',20),(149,'Bật lửa điện sạc USB','BL-USB','8934567001499',10,'cái',120000.00,80000.00,'active','Bật lửa hiện đại','2025-12-29 17:08:00',NULL,NULL,'','',20),(150,'Giấy quấn thuốc lá Zig-Zag','GQTL-ZZ','8934567001505',10,'gói',20000.00,13000.00,'active','Giấy cuộn thuốc lá','2025-12-29 17:08:00',NULL,NULL,'','',20);
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `promotion_targets`
--

DROP TABLE IF EXISTS `promotion_targets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `promotion_targets` (
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
  KEY `idx_target_type_id` (`target_type`,`target_id`),
  CONSTRAINT `promotion_targets_ibfk_1` FOREIGN KEY (`promotion_id`) REFERENCES `promotions` (`promotion_id`)
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `promotion_targets`
--

LOCK TABLES `promotion_targets` WRITE;
/*!40000 ALTER TABLE `promotion_targets` DISABLE KEYS */;
INSERT INTO `promotion_targets` VALUES (9,1,NULL,1,0.00,50000.00,'2026-01-03 17:39:51',0,'BRANCH'),(10,2,NULL,3,0.00,20000.00,'2026-01-03 17:39:51',0,'BRANCH'),(11,3,21,NULL,0.00,NULL,'2026-01-03 17:39:51',0,'BRANCH'),(16,14,12,NULL,0.00,NULL,'2026-01-12 14:25:28',0,'BRANCH'),(32,2004,149,NULL,0.00,10000.00,'2026-01-12 17:28:06',149,'PRODUCT'),(33,2005,149,NULL,0.00,40000.00,'2026-01-12 17:30:13',149,'PRODUCT'),(34,2006,147,NULL,0.00,8000.00,'2026-01-12 17:30:46',147,'PRODUCT'),(35,2007,NULL,10,0.00,50000.00,'2026-01-12 17:31:37',10,'CATEGORY'),(36,2008,NULL,NULL,0.00,NULL,'2026-01-12 17:56:14',1,'CATEGORY'),(37,2009,NULL,NULL,0.00,NULL,'2026-01-12 17:56:14',2,'CATEGORY');
/*!40000 ALTER TABLE `promotion_targets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `promotions`
--

DROP TABLE IF EXISTS `promotions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `promotions` (
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
) ENGINE=InnoDB AUTO_INCREMENT=2010 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Bảng lưu trữ các chương trình khuyến mãi';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `promotions`
--

LOCK TABLES `promotions` WRITE;
/*!40000 ALTER TABLE `promotions` DISABLE KEYS */;
INSERT INTO `promotions` VALUES (1,'FLASH SALE Cuối Tuần Nước Giải Khát','Giảm giá 15% cho tất cả sản phẩm thuộc danh mục Nước Giải Khát.','PERCENT',0.15,'2026-01-05 08:00:00','2026-01-07 23:59:59','CATEGORIES','ACTIVE','2026-01-03 17:37:59','2026-01-03 17:37:59',_binary '\0','','BUNDLE'),(2,'Ưu đãi Hóa Mỹ Phẩm','Giảm trực tiếp 10.000 VNĐ cho mỗi sản phẩm Hóa Mỹ Phẩm.','FIXED_AMOUNT',10000,'2026-01-05 00:00:00','2026-01-15 23:59:59','CATEGORIES','ACTIVE','2026-01-03 17:37:59','2026-01-03 17:37:59',_binary '\0','','BUNDLE'),(3,'MUA 3 TẶNG 1: Snack và Nước Ngọt','Mua 3 gói Snack bất kỳ, tặng 1 lon nước ngọt Pepsi.','FREE_GIFT',0,'2026-01-05 00:00:00','2026-02-01 23:59:59','PRODUCTS','ACTIVE','2026-01-03 17:37:59','2026-01-03 17:37:59',_binary '\0','','BUNDLE'),(4,'Ưu đãi Đặc biệt Khách Hàng Thân Thiết','Giảm 5% cho đơn hàng của khách hàng có thẻ thành viên.','PERCENT',0.05,'2026-01-05 00:00:00','2026-12-31 23:59:59','CUSTOMERS','ACTIVE','2026-01-03 17:37:59','2026-01-03 17:37:59',_binary '\0','','BUNDLE'),(5,'Giảm 20K Đơn hàng Lớn','Giảm 20.000 VNĐ cho đơn hàng có giá trị từ 500.000 VNĐ.','FIXED_AMOUNT',20000,'2026-01-05 00:00:00','2026-01-31 23:59:59','ALL','ACTIVE','2026-01-03 17:37:59','2026-01-03 17:37:59',_binary '\0','','BUNDLE'),(14,'Giảm 5K cho Sữa Tươi Vinamilk','Giảm cố định 5,000 VND cho mỗi hộp Sữa Tươi Vinamilk 1 lít (Product ID 12).','FIXED_AMOUNT',5000,'2026-02-10 00:00:00','2026-02-20 23:59:59','PRODUCTS','ACTIVE','2026-01-12 14:24:59','2026-01-12 14:24:59',_binary '\0','','BUNDLE'),(15,'Combo Ăn Sáng: MUA Sandwich TẶNG Cà Phê','Mua 1 gói Bánh Mì Sandwich (Product 18) tặng 1 gói Cà Phê G7 (Product 13).','FREE_GIFT',0,'2026-02-15 00:00:00','2026-03-31 23:59:59','PRODUCTS','ACTIVE','2026-01-12 14:26:50','2026-01-12 14:26:50',_binary '\0','','BUNDLE'),(16,'Ưu đãi Tặng Quà: MUA 3 Sữa Chua TẶNG 1 Bánh Quy','Mua 3 hộp Sữa Chua Vinamilk (Product 14), tặng 1 gói Bánh Quy Cosy (Product 19).','FREE_GIFT',0,'2026-03-01 00:00:00','2026-03-15 23:59:59','PRODUCTS','ACTIVE','2026-01-12 14:36:06','2026-01-12 14:36:06',_binary '\0','','BUNDLE'),(17,'Giảm 5% cho Đơn hàng Lớn','Giảm 5% cho tổng giá trị đơn hàng từ 500,000 VND trở lên.','PERCENT',0.05,'2026-03-05 00:00:00','2026-03-31 23:59:59','ALL','ACTIVE','2026-01-12 14:36:43','2026-01-12 14:36:43',_binary '\0','','BUNDLE'),(2002,'Giảm 10K Bật Lửa Sạc USB (T1)','Giảm cố định 10,000 VND cho Bật Lửa Điện Sạc USB (Product ID 149).','FIXED_AMOUNT',10000,'2026-01-01 00:00:00','2026-01-31 23:59:59','PRODUCTS','ACTIVE',NULL,NULL,_binary '','JAN10KOFF','FIXED'),(2004,'Giảm 10K Bật Lửa Sạc USB (T1)','Giảm cố định 10,000 VND cho Bật Lửa Điện Sạc USB (Product ID 149).','FIXED_AMOUNT',10000,'2026-01-01 00:00:00','2026-01-31 23:59:59','PRODUCTS','ACTIVE',NULL,NULL,_binary '','JAN10KOFF','FIXED'),(2005,'GIẢM 40K Bật Lửa Sạc USB','Giảm cố định 40,000 VND cho Bật Lửa Điện Sạc USB (Product ID 149).','FIXED_AMOUNT',40000,'2026-01-01 00:00:00','2026-01-31 23:59:59','PRODUCTS','ACTIVE',NULL,NULL,_binary '','BL40KOFF','FIXED'),(2006,'GIẢM 8K Thuốc Lá TL','Giảm cố định 8,000 VND cho Thuốc Lá Thăng Long (Product ID 147).','FIXED_AMOUNT',8000,'2026-01-01 00:00:00','2026-01-31 23:59:59','PRODUCTS','ACTIVE',NULL,NULL,_binary '','TL8KOFF','FIXED'),(2007,'GIẢM 50K Phụ Kiện (DM 10)','Giảm cố định 50,000 VND cho đơn hàng có sản phẩm trong Danh mục ID 10.','FIXED_AMOUNT',50000,'2026-01-01 00:00:00','2026-01-31 23:59:59','CATEGORIES','ACTIVE',NULL,NULL,_binary '','CAT10_50K','FIXED'),(2008,'KM 10% nuoc giai khat','Giam 10% cho nhom nuoc','PERCENT',0.1,'2026-01-11 17:55:17','2026-02-11 17:55:17','CATEGORIES','ACTIVE','2026-01-12 17:55:17','2026-01-12 17:55:17',_binary '','KM-NUOC-10','PERCENT'),(2009,'KM giam 2K an vat','Giam 2000 cho nhom snack','FIXED_AMOUNT',2000,'2026-01-11 17:55:17','2026-02-11 17:55:17','CATEGORIES','ACTIVE','2026-01-12 17:55:17','2026-01-12 17:55:17',_binary '','KM-SNACK-2K','FIXED_AMOUNT');
/*!40000 ALTER TABLE `promotions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `shelves`
--

DROP TABLE IF EXISTS `shelves`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `shelves` (
  `shelf_id` bigint NOT NULL AUTO_INCREMENT,
  `warehouse_id` bigint NOT NULL,
  `shelf_code` varchar(50) NOT NULL,
  `shelf_name` varchar(100) DEFAULT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`shelf_id`),
  KEY `fk_shelf_warehouse` (`warehouse_id`),
  CONSTRAINT `fk_shelf_warehouse` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`warehouse_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shelves`
--

LOCK TABLES `shelves` WRITE;
/*!40000 ALTER TABLE `shelves` DISABLE KEYS */;
/*!40000 ALTER TABLE `shelves` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
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
  KEY `fk_user_branch` (`branch_id`),
  CONSTRAINT `FK9o70sp9ku40077y38fk4wieyk` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin','$2a$10$7gz3idM0iA0ikYyibDutqe31yrWDdVh2NIRa1gCj0QXVNw9723f0G','admin@bizflow.com','Administrator',NULL,'ADMIN',1,NULL,'2025-12-21 10:47:36','2025-12-21 10:47:36',NULL),(2,'owner','$2a$10$iDS5.CarVV4hxkD1P5oVYePzl/M8gs3jse7bGOAjhQBZ6iefSllWy','owner@bizflow.com','Store Owner',NULL,'OWNER',1,NULL,'2025-12-21 10:47:36','2025-12-21 10:47:36',NULL),(3,'test','$2a$10$iDS5.CarVV4hxkD1P5oVYePzl/M8gs3jse7bGOAjhQBZ6iefSllWy','test@bizflow.com','Test User',NULL,'EMPLOYEE',1,NULL,'2025-12-21 10:47:36','2025-12-21 10:47:36',NULL),(4,'vietphd','$2a$10$hTmAfVr7LjuSr5AxSKrpJeleoHtsiZn1RuVH9jub038t4C5SAIhiq','nhanvien1@gmail.com','Phạm Huy Đức Việt ','0902313141','EMPLOYEE',1,NULL,'2025-12-24 16:44:38','2026-01-02 14:08:05',NULL),(7,'Tutl','$2a$10$0P6niSx/VIjhEfnjFVv.cOWuRpb.WTEhAvCEdTzUO9BFyuDVwp2je','Tutl@gmail.com','Trần Long Tứ','0866066043','EMPLOYEE',1,NULL,'2026-01-03 21:57:14','2026-01-03 21:57:14',NULL),(8,'TanBinh','$2a$10$C2DybkhUAxwMFkLTSIVnteX834ZBW/Glnvg2OKPZxVzNZJvAYCIyW','tanbinh@gmail.com','Tân Bình','0866066042','OWNER',1,2,'2026-01-21 22:25:46','2026-01-21 22:25:46',NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `warehouses`
--

DROP TABLE IF EXISTS `warehouses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `warehouses` (
  `warehouse_id` bigint NOT NULL AUTO_INCREMENT,
  `warehouse_name` varchar(255) NOT NULL,
  `address` varchar(255) DEFAULT NULL,
  `manager_id` bigint DEFAULT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`warehouse_id`),
  KEY `fk_warehouse_manager` (`manager_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `warehouses`
--

LOCK TABLES `warehouses` WRITE;
/*!40000 ALTER TABLE `warehouses` DISABLE KEYS */;
/*!40000 ALTER TABLE `warehouses` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-01-21 16:52:46
