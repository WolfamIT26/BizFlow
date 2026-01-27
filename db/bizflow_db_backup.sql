-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: mysql:3306
-- Generation Time: Jan 26, 2026 at 03:18 PM
-- Server version: 8.0.45
-- PHP Version: 8.3.26

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `bizflow_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `branches`
--

CREATE TABLE `branches` (
  `id` bigint NOT NULL,
  `address` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `is_active` bit(1) NOT NULL,
  `name` varchar(255) NOT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `owner_id` bigint DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `branches`
--

INSERT INTO `branches` (`id`, `address`, `email`, `is_active`, `name`, `phone`, `owner_id`) VALUES
(1, 'TÂN CHÁNH HIỆP', 'gtvt@gmail.com', b'1', 'GTVT', '0981764731', NULL),
(2, '123 Street', 'sadanhthue01@gmail.com', b'1', 'Tân Bình', '0981764731', 2);

-- --------------------------------------------------------

--
-- Table structure for table `bundle_items`
--

CREATE TABLE `bundle_items` (
  `bundle_id` bigint NOT NULL COMMENT 'Khóa chính, mã duy nhất của luật tặng/combo',
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
  `quantity` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Bảng định nghĩa quy tắc Mua X tặng Y hoặc Combo sản phẩm';

--
-- Dumping data for table `bundle_items`
--

INSERT INTO `bundle_items` (`bundle_id`, `promotion_id`, `main_product_id`, `main_quantity`, `gift_product_id`, `gift_quantity`, `gift_discount_type`, `gift_discount_value`, `status`, `created_at`, `product_id`, `quantity`) VALUES
(36, 2036, 153, 1, 153, 1, 'FREE', 0, 'ACTIVE', '2026-01-25 07:11:26', 153, 1),
(37, 2039, 3, 3, 3, 1, 'FREE', 0, 'ACTIVE', '2026-01-25 07:37:36', 3, 3),
(38, 2041, 5, 3, 5, 1, 'FREE', 0, 'ACTIVE', '2026-01-25 07:40:41', 5, 3),
(39, 2043, 23, 3, 23, 1, 'FREE', 0, 'ACTIVE', '2026-01-25 08:30:39', 23, 3),
(40, 2045, 19, 3, 18, 1, 'FREE', 0, 'ACTIVE', '2026-01-25 10:16:18', 19, 3),
(41, 2055, 2001, 2, 2002, 1, 'PERCENT', 100, 'active', '2026-01-26 06:27:54', 2001, 2),
(42, 2055, 2001, 2, 2003, 1, 'FIXED', 0, 'active', '2026-01-26 06:27:54', 2003, 1);

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `category_id` int NOT NULL,
  `category_name` varchar(255) NOT NULL,
  `parent_id` int DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`category_id`, `category_name`, `parent_id`, `status`, `created_at`, `description`, `updated_at`) VALUES
(1, 'Nước Giải Khát', NULL, 'active', NULL, NULL, NULL),
(2, 'Đồ Ăn Vặt', NULL, 'active', NULL, NULL, NULL),
(3, 'Hóa Mỹ Phẩm', NULL, 'active', NULL, NULL, NULL),
(4, 'Gia Vị & Nước Chấm', NULL, 'active', NULL, NULL, NULL),
(5, 'Sản Phẩm Chăm Sóc Nhà Cửa', NULL, 'active', NULL, NULL, NULL),
(6, 'Bánh Kẹo', NULL, 'active', NULL, NULL, NULL),
(7, 'Bia & Rượu', NULL, 'active', NULL, NULL, NULL),
(8, 'Mì, Phở, Cháo Gói', NULL, 'active', NULL, NULL, NULL),
(9, 'Đồ Hộp & Thực Phẩm Đóng Hộp', NULL, 'active', NULL, NULL, NULL),
(10, 'Thuốc Lá & Diêm', NULL, 'active', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `customers`
--

CREATE TABLE `customers` (
  `id` bigint NOT NULL,
  `address` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `cccd` varchar(255) DEFAULT NULL,
  `dob` date DEFAULT NULL,
  `monthly_points` int NOT NULL,
  `tier` enum('BAC','BACH_KIM','DONG','KIM_CUONG','VANG') DEFAULT NULL,
  `total_points` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `customers`
--

INSERT INTO `customers` (`id`, `address`, `email`, `name`, `phone`, `cccd`, `dob`, `monthly_points`, `tier`, `total_points`) VALUES
(1, 'tân bình', NULL, 'Pham viet', '0866066042', NULL, NULL, 44, NULL, 44),
(2, 'tân bình', NULL, 'Anh thái', '0866066043', NULL, NULL, 7518, NULL, 7518),
(5, 'chung cư', NULL, 'Anh Tứ', '0866066044', NULL, NULL, 870, NULL, 870),
(6, 'tân bình', NULL, 'Chị Vân', '0866066045', NULL, NULL, 243, 'DONG', 243),
(7, 'Test Address', NULL, 'Test Customer', '0962028826', NULL, NULL, 0, 'DONG', 0),
(8, 'Test Address', NULL, 'Test Customer 2', '0928519177', NULL, NULL, 10, 'DONG', 10),
(10, 'Test Address', NULL, 'Test UI Flow', '0996622189', NULL, NULL, 0, 'DONG', 0),
(11, 'Tân Chánh Hiệp', NULL, 'Anh Trung', '0354970825', NULL, NULL, 0, 'DONG', 0);

-- --------------------------------------------------------

--
-- Table structure for table `inventory_stocks`
--

CREATE TABLE `inventory_stocks` (
  `id` bigint NOT NULL,
  `product_id` bigint NOT NULL,
  `stock` int NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `updated_by` bigint DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `inventory_stocks`
--

INSERT INTO `inventory_stocks` (`id`, `product_id`, `stock`, `updated_at`, `updated_by`) VALUES
(2, 2, 120, '2026-01-23 14:47:28.313850', NULL),
(3, 3, 93, '2026-01-25 23:10:15.506570', 3),
(4, 4, 5, '2026-01-25 23:10:15.520821', 3),
(5, 5, 2, '2026-01-25 23:10:15.499273', 3),
(6, 6, 20, '2026-01-13 22:07:08.520953', NULL),
(7, 7, 13, '2026-01-25 01:42:09.530992', 3),
(8, 8, 3, '2026-01-25 01:40:19.774231', 3),
(9, 9, 15, '2026-01-15 23:21:46.971048', 4),
(10, 10, 9, '2026-01-25 01:40:19.825940', 3),
(11, 11, 20, '2026-01-13 22:07:08.523134', NULL),
(12, 12, 20, '2026-01-13 22:07:08.523593', NULL),
(13, 13, 20, '2026-01-13 22:07:08.524031', NULL),
(14, 14, 20, '2026-01-13 22:07:08.524436', NULL),
(15, 15, 20, '2026-01-13 22:07:08.524811', NULL),
(16, 16, 20, '2026-01-13 22:07:08.525221', NULL),
(17, 17, 20, '2026-01-13 22:07:08.525678', NULL),
(18, 18, 20, '2026-01-13 22:07:08.526184', NULL),
(19, 19, 20, '2026-01-13 22:07:08.526577', NULL),
(20, 20, 19, '2026-01-25 21:40:32.620127', 3),
(21, 21, 20, '2026-01-13 22:07:08.527433', NULL),
(22, 22, 20, '2026-01-13 22:07:08.527886', NULL),
(23, 23, 16, '2026-01-25 21:40:32.608140', 3),
(24, 24, 20, '2026-01-13 22:07:08.528703', NULL),
(25, 25, 20, '2026-01-13 22:07:08.529092', NULL),
(26, 26, 20, '2026-01-13 22:07:08.529502', NULL),
(27, 27, 20, '2026-01-13 22:07:08.529895', NULL),
(28, 28, 20, '2026-01-13 22:07:08.530740', NULL),
(29, 29, 20, '2026-01-13 22:07:08.531151', NULL),
(30, 30, 20, '2026-01-13 22:07:08.531574', NULL),
(31, 31, 20, '2026-01-13 22:07:08.531960', NULL),
(32, 32, 20, '2026-01-13 22:07:08.532376', NULL),
(33, 33, 19, '2026-01-25 01:42:09.545019', 3),
(34, 34, 20, '2026-01-13 22:07:08.533125', NULL),
(35, 35, 20, '2026-01-13 22:07:08.533514', NULL),
(36, 36, 20, '2026-01-13 22:07:08.533910', NULL),
(37, 37, 20, '2026-01-13 22:07:08.534286', NULL),
(38, 38, 20, '2026-01-13 22:07:08.534641', NULL),
(39, 39, 20, '2026-01-13 22:07:08.535020', NULL),
(40, 40, 20, '2026-01-13 22:07:08.535408', NULL),
(41, 41, 20, '2026-01-13 22:07:08.535802', NULL),
(42, 42, 20, '2026-01-13 22:07:08.536259', NULL),
(43, 43, 20, '2026-01-13 22:07:08.536662', NULL),
(44, 44, 20, '2026-01-13 22:07:08.537046', NULL),
(45, 45, 20, '2026-01-13 22:07:08.537471', NULL),
(46, 46, 20, '2026-01-13 22:07:08.537863', NULL),
(47, 47, 20, '2026-01-13 22:07:08.538397', NULL),
(48, 48, 20, '2026-01-13 22:07:08.538762', NULL),
(49, 49, 20, '2026-01-13 22:07:08.539137', NULL),
(50, 50, 20, '2026-01-13 22:07:08.539546', NULL),
(51, 51, 20, '2026-01-13 22:07:08.539911', NULL),
(52, 52, 20, '2026-01-13 22:07:08.540299', NULL),
(53, 53, 20, '2026-01-13 22:07:08.540667', NULL),
(54, 54, 20, '2026-01-13 22:07:08.541037', NULL),
(55, 55, 20, '2026-01-13 22:07:08.541437', NULL),
(56, 56, 1, '2026-01-15 23:32:14.175640', 4),
(57, 57, 20, '2026-01-13 22:07:08.542559', NULL),
(58, 58, 20, '2026-01-13 22:07:08.543511', NULL),
(59, 59, 20, '2026-01-13 22:07:08.545163', NULL),
(60, 60, 20, '2026-01-13 22:07:08.545596', NULL),
(61, 61, 20, '2026-01-13 22:07:08.546052', NULL),
(62, 62, 20, '2026-01-13 22:07:08.547222', NULL),
(63, 63, 20, '2026-01-13 22:07:08.547692', NULL),
(64, 64, 20, '2026-01-13 22:07:08.549431', NULL),
(65, 65, 20, '2026-01-13 22:07:08.549927', NULL),
(66, 66, 20, '2026-01-13 22:07:08.550596', NULL),
(67, 67, 20, '2026-01-13 22:07:08.550978', NULL),
(68, 68, 20, '2026-01-13 22:07:08.551456', NULL),
(69, 69, 20, '2026-01-13 22:07:08.551822', NULL),
(70, 70, 20, '2026-01-13 22:07:08.552165', NULL),
(71, 71, 20, '2026-01-13 22:07:08.552529', NULL),
(72, 72, 20, '2026-01-13 22:07:08.552869', NULL),
(73, 73, 20, '2026-01-13 22:07:08.553294', NULL),
(74, 74, 20, '2026-01-13 22:07:08.554052', NULL),
(75, 75, 20, '2026-01-13 22:07:08.554392', NULL),
(76, 76, 20, '2026-01-13 22:07:08.554730', NULL),
(77, 77, 20, '2026-01-13 22:07:08.555106', NULL),
(78, 78, 20, '2026-01-13 22:07:08.555436', NULL),
(79, 79, 20, '2026-01-13 22:07:08.555757', NULL),
(80, 80, 20, '2026-01-13 22:07:08.556092', NULL),
(81, 81, 20, '2026-01-13 22:07:08.556443', NULL),
(82, 82, 20, '2026-01-13 22:07:08.556784', NULL),
(83, 83, 20, '2026-01-13 22:07:08.557179', NULL),
(84, 84, 20, '2026-01-13 22:07:08.557607', NULL),
(85, 85, 20, '2026-01-13 22:07:08.557990', NULL),
(86, 86, 20, '2026-01-13 22:07:08.559043', NULL),
(87, 87, 20, '2026-01-13 22:07:08.559678', NULL),
(88, 88, 20, '2026-01-13 22:07:08.560101', NULL),
(89, 89, 20, '2026-01-13 22:07:08.560449', NULL),
(90, 90, 20, '2026-01-13 22:07:08.560834', NULL),
(91, 91, 20, '2026-01-13 22:07:08.563471', NULL),
(92, 92, 20, '2026-01-13 22:07:08.563906', NULL),
(93, 93, 20, '2026-01-13 22:07:08.564324', NULL),
(94, 94, 20, '2026-01-13 22:07:08.564732', NULL),
(95, 95, 20, '2026-01-13 22:07:08.565105', NULL),
(96, 96, 20, '2026-01-13 22:07:08.565452', NULL),
(97, 97, 20, '2026-01-13 22:07:08.565780', NULL),
(98, 98, 20, '2026-01-13 22:07:08.566265', NULL),
(99, 99, 20, '2026-01-13 22:07:08.566712', NULL),
(100, 100, 20, '2026-01-13 22:07:08.567111', NULL),
(101, 101, 20, '2026-01-13 22:07:08.567499', NULL),
(102, 102, 20, '2026-01-13 22:07:08.567843', NULL),
(103, 103, 20, '2026-01-13 22:07:08.568211', NULL),
(104, 104, 20, '2026-01-13 22:07:08.568558', NULL),
(105, 105, 20, '2026-01-13 22:07:08.568889', NULL),
(106, 106, 20, '2026-01-13 22:07:08.569286', NULL),
(107, 107, 20, '2026-01-13 22:07:08.569626', NULL),
(108, 108, 20, '2026-01-13 22:07:08.569940', NULL),
(109, 109, 20, '2026-01-13 22:07:08.570306', NULL),
(110, 110, 20, '2026-01-13 22:07:08.570657', NULL),
(111, 111, 20, '2026-01-13 22:07:08.570989', NULL),
(112, 112, 5, '2026-01-25 01:42:09.536330', 3),
(113, 113, 20, '2026-01-13 22:07:08.571683', NULL),
(114, 114, 20, '2026-01-13 22:07:08.572000', NULL),
(115, 115, 20, '2026-01-13 22:07:08.572382', NULL),
(116, 116, 20, '2026-01-13 22:07:08.572752', NULL),
(117, 117, 20, '2026-01-13 22:07:08.573082', NULL),
(118, 118, 20, '2026-01-13 22:07:08.573394', NULL),
(119, 119, 20, '2026-01-13 22:07:08.574168', NULL),
(120, 120, 20, '2026-01-13 22:07:08.574533', NULL),
(121, 121, 20, '2026-01-13 22:07:08.576212', NULL),
(122, 122, 20, '2026-01-13 22:07:08.576667', NULL),
(123, 123, 20, '2026-01-13 22:07:08.576995', NULL),
(124, 124, 20, '2026-01-13 22:07:08.577340', NULL),
(125, 125, 20, '2026-01-13 22:07:08.578108', NULL),
(126, 126, 20, '2026-01-13 22:07:08.578635', NULL),
(127, 127, 20, '2026-01-13 22:07:08.579180', NULL),
(128, 128, 20, '2026-01-13 22:07:08.579855', NULL),
(129, 129, 20, '2026-01-13 22:07:08.581091', NULL),
(130, 130, 20, '2026-01-13 22:07:08.581823', NULL),
(131, 131, 20, '2026-01-13 22:07:08.582201', NULL),
(132, 132, 20, '2026-01-13 22:07:08.582525', NULL),
(133, 133, 20, '2026-01-13 22:07:08.582870', NULL),
(134, 134, 20, '2026-01-13 22:07:08.583203', NULL),
(135, 135, 20, '2026-01-13 22:07:08.583662', NULL),
(136, 136, 20, '2026-01-13 22:07:08.585177', NULL),
(137, 137, 20, '2026-01-13 22:07:08.585574', NULL),
(138, 138, 20, '2026-01-13 22:07:08.585880', NULL),
(139, 139, 20, '2026-01-13 22:07:08.586290', NULL),
(140, 140, 20, '2026-01-13 22:07:08.586594', NULL),
(141, 141, 20, '2026-01-13 22:07:08.586907', NULL),
(142, 142, 20, '2026-01-13 22:07:08.587264', NULL),
(143, 143, 20, '2026-01-13 22:07:08.587688', NULL),
(144, 144, 20, '2026-01-13 22:07:08.588264', NULL),
(145, 145, 20, '2026-01-13 22:07:08.588643', NULL),
(146, 146, 20, '2026-01-13 22:07:08.588949', NULL),
(147, 147, 20, '2026-01-13 22:07:08.589256', NULL),
(148, 148, 20, '2026-01-13 22:07:08.590242', NULL),
(149, 149, 19, '2026-01-14 15:13:15.115093', 4),
(150, 150, 20, '2026-01-13 22:07:08.590847', NULL),
(151, 1, 96, '2026-01-25 23:10:15.528909', 3),
(152, 151, 10, '2026-01-22 23:07:32.500754', NULL),
(153, 152, 10, '2026-01-22 23:16:12.283910', NULL),
(154, 153, 10, '2026-01-22 23:34:52.363132', NULL),
(155, 154, 101, '2026-01-24 19:07:10.335347', 3),
(156, 155, 150, '2026-01-25 23:04:58.688905', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `inventory_transactions`
--

CREATE TABLE `inventory_transactions` (
  `transaction_id` bigint NOT NULL,
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
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `inventory_transactions`
--

INSERT INTO `inventory_transactions` (`transaction_id`, `product_id`, `warehouse_id`, `shelf_id`, `transaction_type`, `quantity`, `unit_price`, `reference_type`, `reference_id`, `note`, `created_by`, `created_at`) VALUES
(6, 1, NULL, NULL, 'SALE', 1, 10000.00, 'ORDER', 14, NULL, 4, '2026-01-13 22:08:30'),
(7, 4, NULL, NULL, 'SALE', 1, 15000.00, 'ORDER', 14, NULL, 4, '2026-01-13 22:08:30'),
(8, 8, NULL, NULL, 'SALE', 1, 20000.00, 'ORDER', 14, NULL, 4, '2026-01-13 22:08:30'),
(9, 8, NULL, NULL, 'SALE', 1, 20000.00, 'ORDER', 18, NULL, 4, '2026-01-14 00:53:17'),
(10, 1, NULL, NULL, 'SALE', 1, 10000.00, 'ORDER', 18, NULL, 4, '2026-01-14 00:53:17'),
(11, 10, NULL, NULL, 'SALE', 1, 15000.00, 'ORDER', 18, NULL, 4, '2026-01-14 00:53:17'),
(12, 10, NULL, NULL, 'SALE', 1, 15000.00, 'ORDER', 19, NULL, 4, '2026-01-14 00:54:29'),
(13, 8, NULL, NULL, 'SALE', 1, 20000.00, 'ORDER', 19, NULL, 4, '2026-01-14 00:54:29'),
(14, 4, NULL, NULL, 'SALE', 1, 15000.00, 'ORDER', 19, NULL, 4, '2026-01-14 00:54:29'),
(15, 1, NULL, NULL, 'SALE', 1, 10000.00, 'ORDER', 20, NULL, 4, '2026-01-14 00:55:10'),
(16, 8, NULL, NULL, 'SALE', 1, 20000.00, 'ORDER', 20, NULL, 4, '2026-01-14 00:55:10'),
(17, 8, NULL, NULL, 'SALE', 1, 20000.00, 'ORDER', 21, NULL, 4, '2026-01-14 00:58:57'),
(18, 1, NULL, NULL, 'SALE', 1, 10000.00, 'ORDER', 21, NULL, 4, '2026-01-14 00:58:57'),
(19, 10, NULL, NULL, 'SALE', 1, 15000.00, 'ORDER', 21, NULL, 4, '2026-01-14 00:58:57'),
(20, 8, NULL, NULL, 'SALE', 1, 20000.00, 'ORDER', 22, NULL, 4, '2026-01-14 00:59:08'),
(21, 1, NULL, NULL, 'SALE', 1, 10000.00, 'ORDER', 22, NULL, 4, '2026-01-14 00:59:08'),
(22, 10, NULL, NULL, 'SALE', 1, 15000.00, 'ORDER', 22, NULL, 4, '2026-01-14 00:59:08'),
(23, 10, NULL, NULL, 'SALE', 1, 15000.00, 'ORDER', 23, NULL, 4, '2026-01-14 01:06:38'),
(24, 8, NULL, NULL, 'SALE', 1, 20000.00, 'ORDER', 23, NULL, 4, '2026-01-14 01:06:38'),
(25, 1, NULL, NULL, 'SALE', 1, 10000.00, 'ORDER', 23, NULL, 4, '2026-01-14 01:06:38'),
(26, 8, NULL, NULL, 'SALE', 2, 20000.00, 'ORDER', 24, NULL, 4, '2026-01-14 01:12:22'),
(27, 10, NULL, NULL, 'SALE', 1, 15000.00, 'ORDER', 24, NULL, 4, '2026-01-14 01:12:22'),
(28, 4, NULL, NULL, 'SALE', 1, 15000.00, 'ORDER', 25, NULL, 4, '2026-01-14 01:23:16'),
(29, 1, NULL, NULL, 'SALE', 1, 10000.00, 'ORDER', 25, NULL, 4, '2026-01-14 01:23:16'),
(30, 8, NULL, NULL, 'SALE', 1, 20000.00, 'ORDER', 25, NULL, 4, '2026-01-14 01:23:16'),
(31, 4, NULL, NULL, 'SALE', 1, 15000.00, 'ORDER', 26, NULL, 4, '2026-01-14 01:27:00'),
(32, 9, NULL, NULL, 'SALE', 1, 18000.00, 'ORDER', 26, NULL, 4, '2026-01-14 01:27:00'),
(33, 8, NULL, NULL, 'SALE', 1, 20000.00, 'ORDER', 26, NULL, 4, '2026-01-14 01:27:00'),
(34, 1, NULL, NULL, 'SALE', 1, 10000.00, 'ORDER', 27, NULL, 4, '2026-01-14 01:30:06'),
(35, 8, NULL, NULL, 'SALE', 1, 20000.00, 'ORDER', 27, NULL, 4, '2026-01-14 01:30:06'),
(36, 10, NULL, NULL, 'SALE', 1, 15000.00, 'ORDER', 27, NULL, 4, '2026-01-14 01:30:06'),
(37, 1, NULL, NULL, 'SALE', 1, 10000.00, 'ORDER', 28, NULL, 4, '2026-01-14 01:43:12'),
(38, 8, NULL, NULL, 'SALE', 1, 20000.00, 'ORDER', 28, NULL, 4, '2026-01-14 01:43:12'),
(39, 4, NULL, NULL, 'SALE', 1, 15000.00, 'ORDER', 28, NULL, 4, '2026-01-14 01:43:12'),
(40, 149, NULL, NULL, 'SALE', 1, 70000.00, 'ORDER', 30, NULL, 4, '2026-01-14 15:13:15'),
(41, 8, NULL, NULL, 'SALE', 1, 18000.00, 'ORDER', 31, NULL, 4, '2026-01-14 15:22:50'),
(42, 10, NULL, NULL, 'SALE', 1, 13000.00, 'ORDER', 31, NULL, 4, '2026-01-14 15:22:50'),
(43, 9, NULL, NULL, 'SALE', 4, 16000.00, 'ORDER', 32, NULL, 4, '2026-01-15 23:21:47'),
(44, 1, NULL, NULL, 'SALE', 1, 9990.00, 'ORDER', 32, NULL, 4, '2026-01-15 23:21:47'),
(45, 8, NULL, NULL, 'SALE', 1, 18000.00, 'ORDER', 32, NULL, 4, '2026-01-15 23:21:47'),
(46, 4, NULL, NULL, 'SALE', 7, 14985.00, 'ORDER', 32, NULL, 4, '2026-01-15 23:21:47'),
(47, 3, NULL, NULL, 'SALE', 1, 4995.00, 'ORDER', 32, NULL, 4, '2026-01-15 23:21:47'),
(48, 56, NULL, NULL, 'SALE', 5, 319680.00, 'ORDER', 33, NULL, 4, '2026-01-15 23:30:27'),
(49, 56, NULL, NULL, 'SALE', 14, 319680.00, 'ORDER', 34, NULL, 4, '2026-01-15 23:32:14'),
(50, 112, NULL, NULL, 'SALE', 14, 400000.00, 'ORDER', 35, NULL, 4, '2026-01-15 23:39:22'),
(51, 8, NULL, NULL, 'SALE', 1, 18000.00, 'ORDER', 36, NULL, 4, '2026-01-21 16:39:45'),
(52, 10, NULL, NULL, 'SALE', 2, 13000.00, 'ORDER', 36, NULL, 4, '2026-01-21 16:39:45'),
(53, 3, NULL, NULL, 'SALE', 2, 4995.00, 'ORDER', 37, NULL, 4, '2026-01-21 16:52:53'),
(54, 5, NULL, NULL, 'SALE', 2, 9990.00, 'ORDER', 37, NULL, 4, '2026-01-21 16:52:53'),
(55, 1, NULL, NULL, 'ADJUST', 100, NULL, 'OTHER', NULL, 'Điều chỉnh kho: Tăng 100 (Cũ: 0 → Mới: 100)', 1, '2026-01-22 21:47:03'),
(56, 151, NULL, NULL, 'IN', 10, NULL, NULL, NULL, 'Nhập hàng - Giá vốn: 25000', NULL, '2026-01-22 23:07:32'),
(57, 152, NULL, NULL, 'IN', 10, NULL, NULL, NULL, 'Nhập hàng - Giá vốn: 80000', NULL, '2026-01-22 23:16:12'),
(58, 153, NULL, NULL, 'IN', 10, NULL, NULL, NULL, 'Nhập hàng - Giá vốn: 1500', NULL, '2026-01-22 23:34:52'),
(59, 154, NULL, NULL, 'IN', 1, NULL, NULL, NULL, 'Nhập hàng - Giá vốn: 50000', NULL, '2026-01-23 02:47:31'),
(60, 2, NULL, NULL, 'IN', 100, NULL, NULL, NULL, ' nhập ngày 23/01/2026\n', NULL, '2026-01-23 14:47:28'),
(61, 154, NULL, NULL, 'IN', 100, NULL, 'RECEIPT', NULL, NULL, 3, '2026-01-24 19:07:10'),
(62, 1, NULL, NULL, 'SALE', 1, 10000.00, 'ORDER', 38, NULL, 3, '2026-01-25 01:40:20'),
(63, 8, NULL, NULL, 'SALE', 1, 20000.00, 'ORDER', 38, NULL, 3, '2026-01-25 01:40:20'),
(64, 4, NULL, NULL, 'SALE', 2, 15000.00, 'ORDER', 38, NULL, 3, '2026-01-25 01:40:20'),
(65, 10, NULL, NULL, 'SALE', 1, 15000.00, 'ORDER', 38, NULL, 3, '2026-01-25 01:40:20'),
(66, 7, NULL, NULL, 'SALE', 7, 35000.00, 'ORDER', 39, NULL, 3, '2026-01-25 01:42:10'),
(67, 112, NULL, NULL, 'SALE', 1, 400000.00, 'ORDER', 39, NULL, 3, '2026-01-25 01:42:10'),
(68, 33, NULL, NULL, 'SALE', 1, 150000.00, 'ORDER', 39, NULL, 3, '2026-01-25 01:42:10'),
(69, 3, NULL, NULL, 'SALE', 3, 4000.00, 'ORDER', 40, NULL, 3, '2026-01-25 21:17:22'),
(70, 3, NULL, NULL, 'SALE', 1, 4000.00, 'ORDER', 40, NULL, 3, '2026-01-25 21:17:22'),
(71, 5, NULL, NULL, 'SALE', 3, 8000.00, 'ORDER', 40, NULL, 3, '2026-01-25 21:17:22'),
(72, 5, NULL, NULL, 'SALE', 1, 8000.00, 'ORDER', 40, NULL, 3, '2026-01-25 21:17:22'),
(73, 3, NULL, NULL, 'SALE', 3, 4000.00, 'ORDER', 41, NULL, 3, '2026-01-25 21:34:39'),
(74, 3, NULL, NULL, 'SALE', 1, 4000.00, 'ORDER', 41, NULL, 3, '2026-01-25 21:34:39'),
(75, 1, NULL, NULL, 'SALE', 2, 8000.00, 'ORDER', 41, NULL, 3, '2026-01-25 21:34:39'),
(76, 3, NULL, NULL, 'SALE', 3, 0.00, 'ORDER', 42, NULL, 3, '2026-01-25 21:40:33'),
(77, 3, NULL, NULL, 'SALE', 1, 0.00, 'ORDER', 42, NULL, 3, '2026-01-25 21:40:33'),
(78, 23, NULL, NULL, 'SALE', 3, 35000.00, 'ORDER', 42, NULL, 3, '2026-01-25 21:40:33'),
(79, 23, NULL, NULL, 'SALE', 1, 35000.00, 'ORDER', 42, NULL, 3, '2026-01-25 21:40:33'),
(80, 20, NULL, NULL, 'SALE', 1, 35000.00, 'ORDER', 42, NULL, 3, '2026-01-25 21:40:33'),
(81, 155, NULL, NULL, 'IN', 150, NULL, NULL, NULL, 'Nhập hàng - Giá vốn: 390000', NULL, '2026-01-25 23:04:59'),
(82, 5, NULL, NULL, 'SALE', 3, 0.00, 'ORDER', 43, NULL, 3, '2026-01-25 23:08:13'),
(83, 5, NULL, NULL, 'SALE', 1, 0.00, 'ORDER', 43, NULL, 3, '2026-01-25 23:08:13'),
(84, 3, NULL, NULL, 'SALE', 3, 0.00, 'ORDER', 43, NULL, 3, '2026-01-25 23:08:13'),
(85, 3, NULL, NULL, 'SALE', 1, 0.00, 'ORDER', 43, NULL, 3, '2026-01-25 23:08:13'),
(86, 3, NULL, NULL, 'IN', 100, NULL, NULL, NULL, '', NULL, '2026-01-25 23:09:47'),
(87, 3, NULL, NULL, 'SALE', 3, 0.00, 'ORDER', 45, NULL, 3, '2026-01-25 23:09:54'),
(88, 3, NULL, NULL, 'SALE', 1, 0.00, 'ORDER', 45, NULL, 3, '2026-01-25 23:09:54'),
(89, 5, NULL, NULL, 'SALE', 3, 0.00, 'ORDER', 45, NULL, 3, '2026-01-25 23:09:54'),
(90, 5, NULL, NULL, 'SALE', 1, 0.00, 'ORDER', 45, NULL, 3, '2026-01-25 23:09:54'),
(91, 5, NULL, NULL, 'SALE', 3, 0.00, 'ORDER', 46, NULL, 3, '2026-01-25 23:10:15'),
(92, 5, NULL, NULL, 'SALE', 1, 0.00, 'ORDER', 46, NULL, 3, '2026-01-25 23:10:15'),
(93, 3, NULL, NULL, 'SALE', 3, 0.00, 'ORDER', 46, NULL, 3, '2026-01-25 23:10:16'),
(94, 3, NULL, NULL, 'SALE', 1, 0.00, 'ORDER', 46, NULL, 3, '2026-01-25 23:10:16'),
(95, 4, NULL, NULL, 'SALE', 1, 12000.00, 'ORDER', 46, NULL, 3, '2026-01-25 23:10:16'),
(96, 1, NULL, NULL, 'SALE', 1, 8000.00, 'ORDER', 46, NULL, 3, '2026-01-25 23:10:16');

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `id` bigint NOT NULL,
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
  `note` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`id`, `created_at`, `total_amount`, `customer_id`, `user_id`, `invoice_number`, `is_return`, `status`, `order_type`, `refund_method`, `return_note`, `return_reason`, `parent_order_id`, `note`) VALUES
(1, '2026-01-02 09:16:42.670400', 550000.00, NULL, 4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(2, '2026-01-02 09:19:05.594577', 320000.00, NULL, 4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(3, '2026-01-02 14:55:51.508733', 2250000.00, 1, 4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(4, '2026-01-02 14:56:25.545823', 1500000.00, 1, 4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(5, '2026-01-07 15:19:34.479580', 45000.00, 1, 4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(6, '2026-01-08 22:39:05.199402', 2250000.00, 1, 4, 'TC-26010800001TH', b'1', 'RETURNED', 'RETURN', 'TRANSFER', 'không liên lạc được cho khách ', 'không liên lạc được cho khách ', 3, NULL),
(7, '2026-01-11 22:12:48.265553', 10000.00, 7, 3, 'TC-260108001', b'0', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL),
(8, '2026-01-11 22:12:48.371989', 10000.00, 7, 3, 'TC-260108002', b'0', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL),
(9, '2026-01-11 22:29:34.634640', 10000.00, 8, 3, 'TC-260108003', b'0', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL),
(10, '2026-01-11 22:29:34.702989', 10000.00, 8, 3, 'TC-260108004', b'0', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL),
(11, '2026-01-11 23:07:46.008079', 32000.00, 10, 3, 'TC-260108005', b'0', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL),
(12, '2026-01-11 23:07:46.317056', 10000.00, 10, 3, 'TC-260108006TH', b'1', 'RETURNED', 'RETURN', 'CASH', 'Test return note', 'Test return', 11, 'Test return note'),
(13, '2026-01-11 23:07:46.347180', 2000.00, 10, 3, 'TC-260108007ĐH', b'0', 'PAID', 'EXCHANGE', NULL, NULL, NULL, 11, NULL),
(14, '2026-01-13 22:08:30.090476', 45000.00, 2, 4, 'SALE-20260113-0001', b'0', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL),
(15, '2026-01-13 22:45:02.119240', 55000.00, 5, 4, 'TC-260100001', b'0', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL),
(17, '2026-01-14 00:36:49.836673', 45000.00, 5, 4, 'TC-260100002', b'0', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL),
(18, '2026-01-14 00:53:14.748040', 45000.00, NULL, 4, 'TC-260100003', b'0', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL),
(19, '2026-01-14 00:54:25.378622', 50000.00, NULL, 4, 'TC-260100004', b'0', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL),
(20, '2026-01-14 00:55:10.098462', 30000.00, NULL, 4, 'TC-260100005', b'0', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL),
(21, '2026-01-14 00:58:57.110283', 45000.00, NULL, 4, 'TC-260100006', b'0', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL),
(22, '2026-01-14 00:59:07.714321', 45000.00, NULL, 4, 'TC-260100007', b'0', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL),
(23, '2026-01-14 01:06:37.363011', 45000.00, 2, 4, 'TC-260100008', b'0', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL),
(24, '2026-01-14 01:12:21.965280', 55000.00, 6, 4, 'TC-260100009', b'0', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL),
(25, '2026-01-14 01:23:16.212815', 45000.00, 6, 4, 'TC-260100010', b'0', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL),
(26, '2026-01-14 01:26:59.749152', 53000.00, 6, 4, 'TC-260100011', b'0', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL),
(27, '2026-01-14 01:30:05.595484', 45000.00, 6, 4, 'TC-260100012', b'0', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL),
(28, '2026-01-14 01:43:11.976187', 45000.00, 6, 4, 'TC-260100013', b'0', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL),
(29, '2026-01-14 15:13:06.242928', 70000.00, 6, 4, 'TC-260100014', b'0', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL),
(30, '2026-01-14 15:13:14.978350', 70000.00, NULL, 4, 'TC-260100015', b'0', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL),
(31, '2026-01-14 15:22:50.073880', 31000.00, NULL, 4, 'TC-260100016', b'0', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL),
(32, '2026-01-15 23:21:46.673560', 201880.00, 2, 4, 'TC-260100017', b'0', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL),
(33, '2026-01-15 23:30:26.198147', 1598400.00, 2, 4, 'TC-260100018', b'0', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL),
(34, '2026-01-15 23:32:14.067649', 4475520.00, NULL, 4, 'TC-260100019', b'0', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL),
(35, '2026-01-15 23:39:21.363061', 5600000.00, 2, 4, 'TC-260100020', b'0', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL),
(36, '2026-01-21 16:39:44.602375', 44000.00, 1, 4, 'TC-260100021', b'0', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL),
(37, '2026-01-21 16:52:32.348051', 29970.00, 2, 4, 'TC-260100022', b'0', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL),
(38, '2026-01-25 01:40:19.604697', 75000.00, 5, 3, 'TC-260100023', b'0', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL),
(39, '2026-01-25 01:42:09.425632', 795000.00, 5, 3, 'TC-260100024', b'0', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL),
(40, '2026-01-25 21:17:21.171313', 48000.00, NULL, 3, 'TC-260100025', b'0', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL),
(41, '2026-01-25 21:34:39.340421', 32000.00, NULL, 3, 'TC-260100026', b'0', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL),
(42, '2026-01-25 21:40:32.389743', 175000.00, NULL, 3, 'TC-260100027', b'0', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL),
(43, '2026-01-25 23:08:12.913010', 0.00, NULL, 3, 'TC-260100028', b'0', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL),
(45, '2026-01-25 23:09:53.819633', 0.00, NULL, 3, 'TC-260100029', b'0', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL),
(46, '2026-01-25 23:10:15.404137', 20000.00, NULL, 3, 'TC-260100030', b'0', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `order_items`
--

CREATE TABLE `order_items` (
  `id` bigint NOT NULL,
  `price` decimal(15,2) NOT NULL,
  `quantity` int NOT NULL,
  `order_id` bigint NOT NULL,
  `product_id` bigint NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `order_items`
--

INSERT INTO `order_items` (`id`, `price`, `quantity`, `order_id`, `product_id`) VALUES
(1, 550000.00, 1, 1, 120),
(2, 320000.00, 1, 2, 56),
(3, 15000.00, 150, 3, 4),
(4, 15000.00, 100, 4, 4),
(5, 30000.00, 1, 5, 12),
(6, 15000.00, 1, 5, 10),
(7, 15000.00, 150, 6, 4),
(8, 10000.00, 1, 7, 1),
(9, 10000.00, 1, 8, 1),
(10, 10000.00, 1, 9, 1),
(11, 10000.00, 1, 10, 1),
(12, 10000.00, 2, 11, 1),
(13, 12000.00, 1, 11, 2),
(14, 10000.00, 1, 12, 1),
(15, 10000.00, -1, 13, 1),
(16, 12000.00, 1, 13, 2),
(17, 10000.00, 1, 14, 1),
(18, 15000.00, 1, 14, 4),
(19, 20000.00, 1, 14, 8),
(20, 10000.00, 2, 15, 1),
(21, 15000.00, 1, 15, 4),
(22, 20000.00, 1, 15, 8),
(23, 20000.00, 1, 17, 8),
(24, 10000.00, 1, 17, 1),
(25, 15000.00, 1, 17, 10),
(26, 20000.00, 1, 18, 8),
(27, 10000.00, 1, 18, 1),
(28, 15000.00, 1, 18, 10),
(29, 15000.00, 1, 19, 10),
(30, 20000.00, 1, 19, 8),
(31, 15000.00, 1, 19, 4),
(32, 10000.00, 1, 20, 1),
(33, 20000.00, 1, 20, 8),
(34, 20000.00, 1, 21, 8),
(35, 10000.00, 1, 21, 1),
(36, 15000.00, 1, 21, 10),
(37, 20000.00, 1, 22, 8),
(38, 10000.00, 1, 22, 1),
(39, 15000.00, 1, 22, 10),
(40, 15000.00, 1, 23, 10),
(41, 20000.00, 1, 23, 8),
(42, 10000.00, 1, 23, 1),
(43, 20000.00, 2, 24, 8),
(44, 15000.00, 1, 24, 10),
(45, 15000.00, 1, 25, 4),
(46, 10000.00, 1, 25, 1),
(47, 20000.00, 1, 25, 8),
(48, 15000.00, 1, 26, 4),
(49, 18000.00, 1, 26, 9),
(50, 20000.00, 1, 26, 8),
(51, 10000.00, 1, 27, 1),
(52, 20000.00, 1, 27, 8),
(53, 15000.00, 1, 27, 10),
(54, 10000.00, 1, 28, 1),
(55, 20000.00, 1, 28, 8),
(56, 15000.00, 1, 28, 4),
(57, 70000.00, 1, 29, 149),
(58, 70000.00, 1, 30, 149),
(59, 18000.00, 1, 31, 8),
(60, 13000.00, 1, 31, 10),
(61, 16000.00, 4, 32, 9),
(62, 9990.00, 1, 32, 1),
(63, 18000.00, 1, 32, 8),
(64, 14985.00, 7, 32, 4),
(65, 4995.00, 1, 32, 3),
(66, 319680.00, 5, 33, 56),
(67, 319680.00, 14, 34, 56),
(68, 400000.00, 14, 35, 112),
(69, 18000.00, 1, 36, 8),
(70, 13000.00, 2, 36, 10),
(71, 4995.00, 2, 37, 3),
(72, 9990.00, 2, 37, 5),
(73, 10000.00, 1, 38, 1),
(74, 20000.00, 1, 38, 8),
(75, 15000.00, 2, 38, 4),
(76, 15000.00, 1, 38, 10),
(77, 35000.00, 7, 39, 7),
(78, 400000.00, 1, 39, 112),
(79, 150000.00, 1, 39, 33),
(80, 4000.00, 3, 40, 3),
(81, 4000.00, 1, 40, 3),
(82, 8000.00, 3, 40, 5),
(83, 8000.00, 1, 40, 5),
(84, 4000.00, 3, 41, 3),
(85, 4000.00, 1, 41, 3),
(86, 8000.00, 2, 41, 1),
(87, 0.00, 3, 42, 3),
(88, 0.00, 1, 42, 3),
(89, 35000.00, 3, 42, 23),
(90, 35000.00, 1, 42, 23),
(91, 35000.00, 1, 42, 20),
(92, 0.00, 3, 43, 5),
(93, 0.00, 1, 43, 5),
(94, 0.00, 3, 43, 3),
(95, 0.00, 1, 43, 3),
(96, 0.00, 3, 45, 3),
(97, 0.00, 1, 45, 3),
(98, 0.00, 3, 45, 5),
(99, 0.00, 1, 45, 5),
(100, 0.00, 3, 46, 5),
(101, 0.00, 1, 46, 5),
(102, 0.00, 3, 46, 3),
(103, 0.00, 1, 46, 3),
(104, 12000.00, 1, 46, 4),
(105, 8000.00, 1, 46, 1);

-- --------------------------------------------------------

--
-- Table structure for table `payments`
--

CREATE TABLE `payments` (
  `id` bigint NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `method` varchar(50) NOT NULL,
  `paid_at` datetime(6) DEFAULT NULL,
  `order_id` bigint NOT NULL,
  `status` varchar(20) DEFAULT NULL,
  `token` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `payments`
--

INSERT INTO `payments` (`id`, `amount`, `method`, `paid_at`, `order_id`, `status`, `token`) VALUES
(1, 550000.00, 'CASH', '2026-01-02 09:16:42.739274', 1, NULL, NULL),
(2, 320000.00, 'CASH', '2026-01-02 09:19:05.623705', 2, NULL, NULL),
(3, 2250000.00, 'TRANSFER', '2026-01-02 14:55:51.725391', 3, NULL, NULL),
(4, 1500000.00, 'TRANSFER', '2026-01-02 14:56:25.557417', 4, NULL, NULL),
(5, 45000.00, 'CASH', '2026-01-07 15:19:34.559517', 5, NULL, NULL),
(6, 2250000.00, 'TRANSFER', '2026-01-08 22:39:05.270491', 6, 'PAID', NULL),
(7, 10000.00, 'CASH', '2026-01-11 22:12:48.313454', 7, 'PAID', NULL),
(9, 10000.00, 'CASH', '2026-01-11 22:29:34.665095', 9, 'PAID', NULL),
(10, 10000.00, 'CASH', '2026-01-11 22:29:34.732654', 10, 'PAID', NULL),
(11, 32000.00, 'CASH', '2026-01-11 23:07:46.048339', 11, 'PAID', NULL),
(12, 10000.00, 'CASH', '2026-01-11 23:07:46.333425', 12, 'PAID', NULL),
(13, 2000.00, 'CASH', '2026-01-11 23:07:46.357445', 13, 'PAID', NULL),
(14, 45000.00, 'CASH', '2026-01-13 22:08:30.148978', 14, 'PAID', NULL),
(15, 45000.00, 'TRANSFER', '2026-01-14 00:53:17.377350', 18, 'PAID', 'SAMPLE-Z6Q2WK77 (mã tượng trưng)'),
(16, 50000.00, 'TRANSFER', '2026-01-14 00:54:29.125996', 19, 'PAID', 'SAMPLE-95QTC1KR (mã tượng trưng)'),
(17, 30000.00, 'CARD', '2026-01-14 00:55:10.178100', 20, 'PAID', NULL),
(18, 45000.00, 'CASH', '2026-01-14 00:58:57.308415', 21, 'PAID', NULL),
(19, 45000.00, 'CASH', '2026-01-14 00:59:07.821010', 22, 'PAID', NULL),
(20, 45000.00, 'CASH', '2026-01-14 01:06:37.524404', 23, 'PAID', NULL),
(21, 55000.00, 'CASH', '2026-01-14 01:12:22.095110', 24, 'PAID', NULL),
(22, 45000.00, 'CASH', '2026-01-14 01:23:16.411871', 25, 'PAID', NULL),
(23, 53000.00, 'CASH', '2026-01-14 01:26:59.931249', 26, 'PAID', NULL),
(24, 45000.00, 'CASH', '2026-01-14 01:30:05.750180', 27, 'PAID', NULL),
(25, 45000.00, 'CASH', '2026-01-14 01:43:12.145347', 28, 'PAID', NULL),
(26, 70000.00, 'CASH', '2026-01-14 15:13:15.109593', 30, 'PAID', NULL),
(27, 31000.00, 'CASH', '2026-01-14 15:22:50.248356', 31, 'PAID', NULL),
(28, 201880.00, 'CASH', '2026-01-15 23:21:47.016236', 32, 'PAID', NULL),
(29, 1598400.00, 'TRANSFER', '2026-01-15 23:30:27.433785', 33, 'PAID', 'SAMPLE-TTWG1H0S (mã tượng trưng)'),
(30, 4475520.00, 'CASH', '2026-01-15 23:32:14.174223', 34, 'PAID', NULL),
(31, 5600000.00, 'CASH', '2026-01-15 23:39:21.511886', 35, 'PAID', NULL),
(32, 44000.00, 'CASH', '2026-01-21 16:39:44.869910', 36, 'PAID', NULL),
(33, 29970.00, 'TRANSFER', '2026-01-21 16:52:52.961994', 37, 'PAID', 'SAMPLE-HLKHMF9F (mã tượng trưng)'),
(34, 75000.00, 'CASH', '2026-01-25 01:40:19.782717', 38, 'PAID', NULL),
(35, 795000.00, 'CASH', '2026-01-25 01:42:09.539972', 39, 'PAID', NULL),
(36, 48000.00, 'CASH', '2026-01-25 21:17:21.619775', 40, 'PAID', NULL),
(37, 32000.00, 'CASH', '2026-01-25 21:34:39.466296', 41, 'PAID', NULL),
(38, 175000.00, 'CASH', '2026-01-25 21:40:32.612196', 42, 'PAID', NULL),
(39, 0.00, 'CASH', '2026-01-25 23:08:13.171431', 43, 'PAID', NULL),
(40, 0.00, 'CASH', '2026-01-25 23:09:53.946665', 45, 'PAID', NULL),
(41, 20000.00, 'CASH', '2026-01-25 23:10:15.525879', 46, 'PAID', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `point_history`
--

CREATE TABLE `point_history` (
  `id` bigint NOT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `points` int DEFAULT NULL,
  `reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `customer_id` bigint DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `point_history`
--

INSERT INTO `point_history` (`id`, `created_at`, `points`, `reason`, `customer_id`) VALUES
(2, '2026-01-11 22:29:34.759798', 10, 'ORDER_10', 8);

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `product_id` bigint NOT NULL,
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
  `stock` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`product_id`, `product_name`, `sku`, `barcode`, `category_id`, `unit`, `price`, `cost_price`, `status`, `description`, `created_at`, `updated_at`, `active`, `code`, `name`, `stock`) VALUES
(1, 'Coca-Cola lon 330ml', 'CC330', '8934567000010', 1, 'lon', 10000.00, 7500.00, 'active', 'Nước ngọt có ga', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(2, 'Trà Xanh Không Độ chai 500ml', 'TXKD500', '8934567000027', 1, 'chai', 12000.00, 9000.00, 'active', 'Trà giải khát không đường', '2025-12-29 17:04:24', NULL, NULL, '', '', 120),
(3, 'Nước suối Aquafina 500ml', 'AQF500', '8934567000034', 1, 'chai', 5000.00, 3500.00, 'active', 'Nước tinh khiết', '2025-12-29 17:04:24', NULL, NULL, '', '', 120),
(4, 'Bia Sài Gòn Lager 330ml', 'SGL330', '8934567000041', 1, 'lon', 15000.00, 11000.00, 'active', 'Bia Lager (có thể dùng chung ID 7 nếu không muốn tách)', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(5, 'Pepsi lon 330ml', 'PS330', '8934567000058', 1, 'lon', 10000.00, 7500.00, 'active', 'Nước ngọt có ga vị chanh', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(6, 'Snack Oishi vị Phô Mai 35g', 'OIS-PM35', '8934567000065', 2, 'gói', 8000.00, 5500.00, 'active', 'Bánh snack khoai tây', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(7, 'Khô Gà Lá Chanh 100g', 'KG-LC100', '8934567000072', 2, 'túi', 35000.00, 25000.00, 'active', 'Thực phẩm ăn liền', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(8, 'Hạt Hướng Dương Vị Muối 250g', 'HD-MS250', '8934567000089', 2, 'gói', 20000.00, 14000.00, 'active', 'Hạt rang ăn liền', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(9, 'Bánh Quy Cosy dừa 160g', 'CQ-DY160', '8934567000096', 2, 'gói', 18000.00, 12500.00, 'active', 'Bánh quy ngọt', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(10, 'Kẹo Alpenliebe vị caramen', 'ALP-CR', '8934567000102', 2, 'gói', 15000.00, 10000.00, 'active', 'Kẹo cứng (có thể dùng chung ID 6)', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(11, 'Dầu Gội Sunsilk Mềm Mượt 320g', 'DG-SM320', '8934567000119', 3, 'chai', 65000.00, 45000.00, 'active', 'Dầu gội đầu', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(12, 'Kem Đánh Răng P/S Bảo Vệ 120g', 'KDR-PSBV', '8934567000126', 3, 'tuýp', 30000.00, 20000.00, 'active', 'Kem đánh răng cơ bản', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(13, 'Xà Bông Lifebuoy diệt khuẩn 90g', 'XB-LB90', '8934567000133', 3, 'bánh', 15000.00, 10000.00, 'active', 'Xà bông tắm/rửa tay', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(14, 'Dao cạo râu Gillette 1 lưỡi', 'DCR-GL1', '8934567000140', 3, 'cái', 5000.00, 3000.00, 'active', 'Dụng cụ cá nhân', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(15, 'Khăn Giấy Gấu Trúc 180 tờ', 'KG-GT180', '8934567000157', 3, 'gói', 12000.00, 8000.00, 'active', 'Khăn giấy khô', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(16, 'Nước Mắm Chin-su 500ml', 'NM-CS500', '8934567000164', 4, 'chai', 45000.00, 30000.00, 'active', 'Nước mắm cá cơm', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(17, 'Dầu Ăn Tường An 1 Lít', 'DA-TA1L', '8934567000171', 4, 'chai', 60000.00, 40000.00, 'active', 'Dầu thực vật', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(18, 'Muối I-ốt Bạc Liêu 500g', 'M-BL500', '8934567000188', 4, 'gói', 5000.00, 3000.00, 'active', 'Muối ăn thông thường', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(19, 'Đường Trắng Biên Hòa 1kg', 'DT-BH1KG', '8934567000195', 4, 'gói', 25000.00, 18000.00, 'active', 'Đường tinh luyện', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(20, 'Bột Ngọt Ajinomoto 450g', 'BN-AJI450', '8934567000201', 4, 'gói', 35000.00, 25000.00, 'active', 'Chất điều vị', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(21, 'Nước Rửa Chén Mỹ Hảo 800g', 'NRC-MH800', '8934567000218', 5, 'chai', 25000.00, 15000.00, 'active', 'Nước rửa chén bát', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(22, 'Bột Giặt OMO Matic 800g', 'BG-OMO800', '8934567000225', 5, 'túi', 45000.00, 30000.00, 'active', 'Bột giặt máy giặt', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(23, 'Nước Lau Sàn Gift 1 Lít', 'NLS-GF1L', '8934567000232', 5, 'chai', 35000.00, 22000.00, 'active', 'Chất tẩy rửa sàn nhà', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(24, 'Thuốc diệt muỗi Mosfly chai', 'TDM-MOS', '8934567000249', 5, 'chai', 70000.00, 50000.00, 'active', 'Chất diệt côn trùng', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(25, 'Túi đựng rác tự phân hủy (3 cuộn)', 'TDR-3C', '8934567000256', 5, 'gói', 15000.00, 10000.00, 'active', 'Dụng cụ vệ sinh', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(26, 'Bánh Chocopie Hộp 12 cái', 'CP-12C', '8934567000263', 6, 'hộp', 40000.00, 28000.00, 'active', 'Bánh xốp phủ sô cô la', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(27, 'Kẹo Sugus Trái Cây 150g', 'K-SUG150', '8934567000270', 6, 'túi', 20000.00, 13000.00, 'active', 'Kẹo dẻo mềm', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(28, 'Bánh Mì Sữa Tươi Kinh Đô', 'BM-KDS', '8934567000287', 6, 'gói', 12000.00, 8000.00, 'active', 'Bánh mì ngọt ăn sáng', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(29, 'Thạch Rau Câu Long Hải 400g', 'TRC-LH400', '8934567000294', 6, 'túi', 15000.00, 10000.00, 'active', 'Tráng miệng lạnh', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(30, 'Kẹo Socola Kitkat thanh', 'SC-KKTH', '8934567000300', 6, 'thanh', 8000.00, 5000.00, 'active', 'Bánh xốp phủ socola', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(31, 'Bia Tiger lon 330ml', 'BT-330', '8934567000317', 7, 'lon', 17000.00, 12500.00, 'active', 'Bia Lager cao cấp', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(32, 'Bia Heineken lon 330ml', 'BH-330', '8934567000324', 7, 'lon', 20000.00, 15000.00, 'active', 'Bia nhập khẩu', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(33, 'Rượu Vodka Hà Nội 700ml', 'R-VDHN', '8934567000331', 7, 'chai', 150000.00, 100000.00, 'active', 'Rượu mạnh', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(34, 'Bia 333 lon 330ml', 'B3-330', '8934567000348', 7, 'lon', 14000.00, 10000.00, 'active', 'Bia truyền thống', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(35, 'Bia Larue lon 330ml', 'BL-330', '8934567000355', 7, 'lon', 13000.00, 9000.00, 'active', 'Bia phổ thông', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(36, 'Mì Hảo Hảo Tôm Chua Cay', 'MHHTC', '8934567000362', 8, 'gói', 6000.00, 4000.00, 'active', 'Mì ăn liền phổ thông', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(37, 'Phở Bò Gói Vifon', 'PB-VF', '8934567000379', 8, 'gói', 12000.00, 8000.00, 'active', 'Phở ăn liền', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(38, 'Mì Omachi Xốt Thịt Heo', 'M-OMXTH', '8934567000386', 8, 'gói', 10000.00, 6500.00, 'active', 'Mì không chiên', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(39, 'Cháo Thịt Bằm gói 50g', 'CB-50G', '8934567000393', 8, 'gói', 8000.00, 5000.00, 'active', 'Cháo ăn liền dinh dưỡng', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(40, 'Mì Kokomi Đại gói', 'MKD-GOI', '8934567000409', 8, 'gói', 5500.00, 3500.00, 'active', 'Mì gói lớn', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(41, 'Pate Cột Đèn Hải Phòng 100g', 'PCĐ-100', '8934567000416', 9, 'hộp', 25000.00, 18000.00, 'active', 'Thịt xay đóng hộp', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(42, 'Cá Hộp Sốt Cà Chua 3 Cô Gái', 'CH-3CG', '8934567000423', 9, 'hộp', 20000.00, 14000.00, 'active', 'Cá hộp ăn liền', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(43, 'Thịt Heo 2 Lát Đóng Hộp', 'TH2L-DH', '8934567000430', 9, 'hộp', 40000.00, 28000.00, 'active', 'Thịt heo chế biến sẵn', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(44, 'Sữa Đặc Ông Thọ Vàng 380g', 'SD-OTV', '8934567000447', 9, 'lon', 28000.00, 20000.00, 'active', 'Sữa đặc có đường', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(45, 'Dưa Chuột Muối chua 500g', 'DCM-500', '8934567000454', 9, 'hũ', 30000.00, 21000.00, 'active', 'Rau củ muối chua', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(46, 'Thuốc Lá Vinataba Gói', 'TL-VNTB', '8934567000461', 10, 'gói', 30000.00, 22000.00, 'active', 'Thuốc lá thông dụng', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(47, 'Thuốc Lá 555 Gói', 'TL-555', '8934567000478', 10, 'gói', 35000.00, 26000.00, 'active', 'Thuốc lá cao cấp hơn', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(48, 'Bật Lửa Gas BIC (màu xanh)', 'BL-BICX', '8934567000485', 10, 'cái', 8000.00, 5000.00, 'active', 'Bật lửa dùng 1 lần', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(49, 'Diêm Thống Nhất Hộp Nhỏ', 'D-TN', '8934567000492', 10, 'hộp', 2000.00, 1000.00, 'active', 'Diêm quẹt', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(50, 'Thuốc Lá Kent Gói', 'TL-KNT', '8934567000508', 10, 'gói', 40000.00, 30000.00, 'active', 'Thuốc lá nhập khẩu', '2025-12-29 17:04:24', NULL, NULL, '', '', 20),
(51, 'Nước tăng lực Red Bull 250ml', 'NTL-RB', '8934567000515', 1, 'lon', 18000.00, 13000.00, 'active', 'Nước uống tăng lực Thái Lan', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(52, 'Sữa tươi Vinamilk không đường 1L', 'ST-VNM-KS', '8934567000522', 1, 'hộp', 35000.00, 25000.00, 'active', 'Sữa tươi tiệt trùng 100%', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(53, 'Nước ép cam Vfresh 1L', 'NE-VFC', '8934567000539', 1, 'hộp', 40000.00, 28000.00, 'active', 'Nước ép trái cây nguyên chất', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(54, 'Nước suối Lavie 1.5L', 'NUC-LV15', '8934567000546', 1, 'chai', 8000.00, 5000.00, 'active', 'Nước khoáng thiên nhiên', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(55, 'Nước yến ngân nhĩ 240ml', 'NY-NN240', '8934567000553', 1, 'lon', 25000.00, 18000.00, 'active', 'Nước giải khát bổ dưỡng', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(56, 'Bia 333 thùng 24 lon', 'B333-T24', '8934567000560', 1, 'thùng', 320000.00, 250000.00, 'active', 'Bia thùng 24 lon', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(57, 'Trà đào Cozy hộp 25 gói', 'TD-CZY25', '8934567000577', 1, 'hộp', 45000.00, 32000.00, 'active', 'Trà hòa tan vị đào', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(58, 'Sting dâu lon 330ml', 'NTL-STING', '8934567000584', 1, 'lon', 12000.00, 8500.00, 'active', 'Nước tăng lực vị dâu', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(59, 'Sữa chua uống Probi 65ml (lốc 5)', 'SCU-PB', '8934567000591', 1, 'lốc', 22000.00, 16000.00, 'active', 'Sữa chua uống lợi khuẩn', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(60, 'Nước ép dứa Dole 330ml', 'NED-DL330', '8934567000607', 1, 'lon', 15000.00, 10000.00, 'active', 'Nước ép dứa đóng lon', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(61, 'Bánh gạo One.One vị bò 100g', 'BG-OOVB', '8934567000614', 2, 'gói', 15000.00, 10000.00, 'active', 'Bánh gạo giòn tan', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(62, 'Snack Poca vị muối ớt 70g', 'SK-POCA', '8934567000621', 2, 'gói', 18000.00, 12000.00, 'active', 'Snack khoai tây lát muối ớt', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(63, 'Rong Biển Ăn Liền Taekyung 5g', 'RB-TK', '8934567000638', 2, 'gói', 7000.00, 4500.00, 'active', 'Rong biển sấy khô Hàn Quốc', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(64, 'Hạt điều rang muối 500g', 'HD-RM500', '8934567000645', 2, 'hộp', 150000.00, 110000.00, 'active', 'Hạt điều Bình Phước', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(65, 'Thịt bò khô miếng 50g', 'TBK-M50', '8934567000652', 2, 'gói', 45000.00, 32000.00, 'active', 'Thịt bò sấy khô xé sợi', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(66, 'Bánh phồng tôm Sa Giang 200g', 'BPT-SG200', '8934567000669', 2, 'gói', 30000.00, 20000.00, 'active', 'Bánh phồng tôm chưa chiên', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(67, 'Socola thanh Mars 50g', 'SC-MAR50', '8934567000676', 2, 'thanh', 18000.00, 12000.00, 'active', 'Socola nhân caramen', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(68, 'Bim Bim Lay\'s vị tự nhiên 50g', 'BB-LAYS', '8934567000683', 2, 'gói', 10000.00, 6500.00, 'active', 'Snack khoai tây lát mỏng', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(69, 'Kẹo dẻo Chuppa Chups 75g', 'KD-CC75', '8934567000690', 2, 'gói', 15000.00, 10000.00, 'active', 'Kẹo dẻo hình thù', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(70, 'Mứt gừng sấy dẻo 200g', 'MG-SD200', '8934567000706', 2, 'hộp', 50000.00, 35000.00, 'active', 'Mứt gừng đặc sản', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(71, 'Sữa tắm Enchanteur 450ml', 'ST-ECH', '8934567000713', 3, 'chai', 85000.00, 60000.00, 'active', 'Sữa tắm hương nước hoa', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(72, 'Dầu xả TRESemmé 340g', 'DX-TRE', '8934567000720', 3, 'chai', 70000.00, 50000.00, 'active', 'Dầu xả dưỡng tóc óng mượt', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(73, 'Kem chống nắng Bioré 50ml', 'KCN-BIO', '8934567000737', 3, 'tuýp', 90000.00, 65000.00, 'active', 'Bảo vệ da SPF50+', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(74, 'Son dưỡng môi Vaseline 10g', 'SDM-VAS', '8934567000744', 3, 'hộp', 35000.00, 25000.00, 'active', 'Dưỡng ẩm môi khô nẻ', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(75, 'Băng vệ sinh Diana Sensi 8 miếng', 'BVS-DS8', '8934567000751', 3, 'gói', 25000.00, 18000.00, 'active', 'Băng vệ sinh hàng ngày', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(76, 'Nước tẩy trang L’Oréal 400ml', 'NTT-LO400', '8934567000768', 3, 'chai', 130000.00, 90000.00, 'active', 'Làm sạch sâu da mặt', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(77, 'Mặt nạ giấy dưỡng ẩm (gói)', 'MN-GA', '8934567000775', 3, 'gói', 15000.00, 10000.00, 'active', 'Mặt nạ cấp ẩm', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(78, 'Sữa rửa mặt Cetaphil 125ml', 'SRM-CET', '8934567000782', 3, 'chai', 80000.00, 55000.00, 'active', 'Sữa rửa mặt dịu nhẹ', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(79, 'Khăn ướt Bobby không mùi (100 tờ)', 'KU-BBY', '8934567000799', 3, 'gói', 30000.00, 20000.00, 'active', 'Khăn ướt vệ sinh cá nhân', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(80, 'Kem dưỡng ẩm Nivea Soft 50ml', 'KDA-NS50', '8934567000805', 3, 'hộp', 45000.00, 30000.00, 'active', 'Kem dưỡng ẩm toàn thân', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(81, 'Tương ớt Chin-su chai 250g', 'TO-CS250', '8934567000812', 4, 'chai', 18000.00, 12000.00, 'active', 'Tương ớt cay nồng', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(82, 'Xì Dầu Maggi chai 200ml', 'XD-MAG200', '8934567000829', 4, 'chai', 22000.00, 15000.00, 'active', 'Nước tương đậu nành', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(83, 'Giấm gạo Ajinomoto 400ml', 'G-AJI400', '8934567000836', 4, 'chai', 15000.00, 10000.00, 'active', 'Giấm dùng nấu ăn', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(84, 'Hạt nêm Knorr 400g', 'HN-KNR400', '8934567000843', 4, 'gói', 30000.00, 21000.00, 'active', 'Gia vị nêm nếm thịt thăn', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(85, 'Tiêu xay Vifon 50g', 'TX-VF50', '8934567000850', 4, 'hộp', 25000.00, 17000.00, 'active', 'Bột tiêu xay nguyên chất', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(86, 'Dầu hào Maggi 350g', 'DH-MAG350', '8934567000867', 4, 'chai', 35000.00, 24000.00, 'active', 'Dầu hào nấm hương', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(87, 'Bột canh I-ốt 190g', 'BC-I-190', '8934567000874', 4, 'gói', 8000.00, 5000.00, 'active', 'Bột canh nêm nếm', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(88, 'Nước tương Phú Sĩ 500ml', 'NT-PS500', '8934567000881', 4, 'chai', 18000.00, 12000.00, 'active', 'Nước tương phổ thông', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(89, 'Dầu mè đen 200ml', 'DM-200', '8934567000898', 4, 'chai', 30000.00, 21000.00, 'active', 'Dầu mè thơm', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(90, 'Bột mì đa dụng 500g', 'BM-500', '8934567000904', 4, 'gói', 15000.00, 10000.00, 'active', 'Bột dùng làm bánh', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(91, 'Nước rửa tay Lifebuoy 450g', 'NRT-LB450', '8934567000911', 5, 'chai', 55000.00, 38000.00, 'active', 'Nước rửa tay diệt khuẩn', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(92, 'Nước xả vải Comfort 800ml', 'NXV-CF800', '8934567000928', 5, 'túi', 40000.00, 28000.00, 'active', 'Làm mềm và thơm quần áo', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(93, 'Giấy vệ sinh Sài Gòn 10 cuộn', 'GVS-SG10', '8934567000935', 5, 'gói', 50000.00, 35000.00, 'active', 'Giấy vệ sinh 3 lớp', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(94, 'Dầu hỏa thắp sáng 500ml', 'DH-500', '8934567000942', 5, 'chai', 15000.00, 10000.00, 'active', 'Chất đốt thắp sáng', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(95, 'Nến thơm Lavender', 'NT-LV', '8934567000959', 5, 'cái', 35000.00, 24000.00, 'active', 'Khử mùi, tạo hương thơm', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(96, 'Nước tẩy bồn cầu Vim 450ml', 'NTBC-VM', '8934567000966', 5, 'chai', 30000.00, 20000.00, 'active', 'Chất tẩy rửa nhà vệ sinh', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(97, 'Túi đựng rác 5kg (3 cuộn)', 'TDR-5KG', '8934567000973', 5, 'gói', 25000.00, 17000.00, 'active', 'Túi rác tự phân hủy', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(98, 'Bột thông cống 100g', 'BTC-100', '8934567000980', 5, 'gói', 15000.00, 10000.00, 'active', 'Hóa chất thông cống', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(99, 'Khăn lau đa năng 3M Scotch-Brite', 'KL-3MSB', '8934567000997', 5, 'cái', 40000.00, 28000.00, 'active', 'Khăn lau thấm nước', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(100, 'Nước lau kính Cif 500ml', 'NLK-CIF', '8934567001000', 5, 'chai', 35000.00, 24000.00, 'active', 'Làm sạch gương kính', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(101, 'Bánh quy bơ Danisa 454g', 'BQB-DAN', '8934567001017', 6, 'hộp', 90000.00, 65000.00, 'active', 'Bánh quy bơ hộp thiếc', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(102, 'Bánh Custas kem trứng hộp 6 cái', 'BC-KEM6', '8934567001024', 6, 'hộp', 35000.00, 24000.00, 'active', 'Bánh mềm nhân kem trứng', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(103, 'Kẹo cao su Doublemint', 'KCS-DM', '8934567001031', 6, 'gói', 10000.00, 6000.00, 'active', 'Kẹo cao su bạc hà', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(104, 'Bánh Goute mè giòn 144g', 'B-GME', '8934567001048', 6, 'gói', 25000.00, 17000.00, 'active', 'Bánh mặn giòn', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(105, 'Socola sữa Milo Cube', 'SC-MLC', '8934567001055', 6, 'gói', 50000.00, 35000.00, 'active', 'Socola viên ăn vặt', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(106, 'Bánh AFC lúa mì 200g', 'B-AFC', '8934567001062', 6, 'gói', 28000.00, 20000.00, 'active', 'Bánh quy ăn kiêng', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(107, 'Kẹo dẻo Haribo Gummy Bear', 'KD-HGB', '8934567001079', 6, 'gói', 30000.00, 21000.00, 'active', 'Kẹo dẻo hình gấu', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(108, 'Bánh mì sandwich lát (tươi)', 'BMS-LAT', '8934567001086', 6, 'gói', 18000.00, 12000.00, 'active', 'Bánh mì tươi ăn sáng', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(109, 'Thạch rau câu Zai Zai (hộp)', 'TRC-ZZ', '8934567001093', 6, 'hộp', 40000.00, 28000.00, 'active', 'Thạch rau câu nhiều vị', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(110, 'Bánh quy Oreo nhân kem 133g', 'BQ-OREO', '8934567001109', 6, 'gói', 15000.00, 10000.00, 'active', 'Bánh quy sô cô la', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(111, 'Rượu vang Đà Lạt Classic 750ml', 'RV-DL750', '8934567001116', 7, 'chai', 120000.00, 85000.00, 'active', 'Rượu vang đỏ phổ thông', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(112, 'Bia Tiger Crystal chai 330ml (thùng 24)', 'BTC-24', '8934567001123', 7, 'thùng', 400000.00, 300000.00, 'active', 'Bia Crystal nhẹ', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(113, 'Rượu Soju Chum Churum 360ml', 'RS-CC', '8934567001130', 7, 'chai', 65000.00, 45000.00, 'active', 'Rượu Soju Hàn Quốc', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(114, 'Bia Huda lon 330ml', 'B-HDA', '8934567001147', 7, 'lon', 13000.00, 9500.00, 'active', 'Bia địa phương miền Trung', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(115, 'Nước ngọt có gas 7Up lon 330ml', 'NG-7UP', '8934567001154', 7, 'lon', 10000.00, 7500.00, 'active', 'Nước ngọt chanh', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(116, 'Bia Larue chai 450ml', 'BL-450', '8934567001161', 7, 'chai', 18000.00, 13000.00, 'active', 'Chai bia truyền thống', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(117, 'Rượu Nếp Mới 500ml', 'RNM-500', '8934567001178', 7, 'chai', 50000.00, 35000.00, 'active', 'Rượu nếp truyền thống', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(118, 'Bia Strongbow Vị Dâu lon', 'BS-DV', '8934567001185', 7, 'lon', 20000.00, 15000.00, 'active', 'Cider trái cây', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(119, 'Bia Sapporo lon 330ml', 'BS-330', '8934567001192', 7, 'lon', 19000.00, 14000.00, 'active', 'Bia Nhật Bản', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(120, 'Rượu Whisky Johnnie Walker Red Label 750ml', 'RW-JWRL', '8934567001208', 7, 'chai', 550000.00, 400000.00, 'active', 'Rượu mạnh', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(121, 'Mì Tiến Vua Bò Hầm', 'M-TVBH', '8934567001215', 8, 'gói', 7000.00, 4500.00, 'active', 'Mì không chiên vị bò', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(122, 'Hủ tiếu Nam Vang Gói', 'HT-NVG', '8934567001222', 8, 'gói', 15000.00, 10000.00, 'active', 'Hủ tiếu ăn liền', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(123, 'Cháo Yến Mạch ăn liền 50g', 'CYM-50', '8934567001239', 8, 'gói', 9000.00, 6000.00, 'active', 'Cháo yến mạch ăn liền', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(124, 'Mì 3 Miền Tôm Chua Cay', 'M3M-TCC', '8934567001246', 8, 'gói', 5500.00, 3500.00, 'active', 'Mì phổ thông vị tôm chua cay', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(125, 'Miến Phú Hương Sườn Heo', 'MPH-SH', '8934567001253', 8, 'gói', 10000.00, 7000.00, 'active', 'Miến ăn liền vị sườn heo', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(126, 'Mì lẩu thái Gấu Đỏ', 'MLT-GD', '8934567001260', 8, 'gói', 6500.00, 4000.00, 'active', 'Mì gói vị lẩu thái', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(127, 'Bún riêu cua ăn liền', 'BRC-AL', '8934567001277', 8, 'gói', 13000.00, 9000.00, 'active', 'Bún ăn liền vị riêu cua', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(128, 'Cháo đậu xanh gói', 'CDX-GOI', '8934567001284', 8, 'gói', 7000.00, 4500.00, 'active', 'Cháo dinh dưỡng đậu xanh', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(129, 'Mì Reeva Lẩu nấm', 'M-RVLN', '8934567001291', 8, 'gói', 8000.00, 5500.00, 'active', 'Mì có sợi khoai tây', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(130, 'Phở khô Sông Hậu 400g', 'PK-SH400', '8934567001307', 8, 'gói', 20000.00, 14000.00, 'active', 'Phở khô làm bún', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(131, 'Thịt lợn hầm Tiên Yết 150g', 'TLH-TY', '8934567001314', 9, 'hộp', 35000.00, 25000.00, 'active', 'Thịt lợn hầm sẵn', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(132, 'Cá Ngừ Ngâm Dầu hộp 185g', 'CN-ND', '8934567001321', 9, 'hộp', 60000.00, 42000.00, 'active', 'Cá ngừ đóng hộp', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(133, 'Đậu cô ve muối chua 400g', 'DCVM-400', '8934567001338', 9, 'hũ', 25000.00, 17000.00, 'active', 'Rau củ ngâm chua', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(134, 'Sữa Đặc Ngôi Sao Phương Nam 380g', 'SD-NSPN', '8934567001345', 9, 'lon', 26000.00, 19000.00, 'active', 'Sữa đặc có đường', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(135, 'Lạp xưởng đóng gói 500g', 'LX-DG500', '8934567001352', 9, 'gói', 90000.00, 65000.00, 'active', 'Thực phẩm chế biến', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(136, 'Nước cốt gà Vifon 180g', 'NCG-VF', '8934567001369', 9, 'hộp', 45000.00, 30000.00, 'active', 'Nước cốt hầm xương', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(137, 'Thịt gà xé phay đóng hộp 150g', 'TGXP-150', '8934567001376', 9, 'hộp', 38000.00, 26000.00, 'active', 'Thịt gà đóng hộp ăn liền', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(138, 'Bò kho đóng hộp 300g', 'BK-DH300', '8934567001383', 9, 'hộp', 55000.00, 40000.00, 'active', 'Bò kho chế biến sẵn', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(139, 'Dứa (thơm) đóng hộp cắt lát 565g', 'DT-CLL', '8934567001390', 9, 'lon', 40000.00, 28000.00, 'active', 'Trái cây đóng hộp', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(140, 'Đậu phụ chiên đóng hộp 200g', 'DPC-DH', '8934567001406', 9, 'hộp', 20000.00, 13000.00, 'active', 'Đậu phụ chiên sẵn', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(141, 'Thuốc Lá Craven A Gói', 'TL-CA', '8934567001413', 10, 'gói', 32000.00, 24000.00, 'active', 'Thuốc lá', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(142, 'Thuốc Lá Marlboro Lights Gói', 'TL-MLT', '8934567001420', 10, 'gói', 45000.00, 33000.00, 'active', 'Thuốc lá nhẹ', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(143, 'Bật Lửa Đá Zippo (chưa đổ xăng)', 'BL-ZPO', '8934567001437', 10, 'cái', 350000.00, 250000.00, 'active', 'Bật lửa tái sử dụng', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(144, 'Xăng Bật Lửa Zippo 125ml', 'XBL-ZPO', '8934567001444', 10, 'chai', 50000.00, 35000.00, 'active', 'Nhiên liệu bật lửa', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(145, 'Giấy cuốn thuốc lá 100 tờ', 'GCT-100', '8934567001451', 10, 'tệp', 15000.00, 10000.00, 'active', 'Giấy cuốn thuốc', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(146, 'Tẩu hút thuốc lá nhỏ', 'THTL-N', '8934567001468', 10, 'cái', 80000.00, 55000.00, 'active', 'Dụng cụ hút thuốc', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(147, 'Thuốc Lá Thăng Long', 'TL-TL', '8934567001475', 10, 'gói', 25000.00, 18000.00, 'active', 'Thuốc lá phổ thông Việt Nam', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(148, 'Diêm hộp lớn 100 que', 'D-HL', '8934567001482', 10, 'hộp', 3000.00, 1500.00, 'active', 'Diêm dùng nhiều lần', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(149, 'Bật lửa điện sạc USB', 'BL-USB', '8934567001499', 10, 'cái', 120000.00, 80000.00, 'active', 'Bật lửa hiện đại', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(150, 'Giấy quấn thuốc lá Zig-Zag', 'GQTL-ZZ', '8934567001505', 10, 'gói', 20000.00, 13000.00, 'active', 'Giấy cuộn thuốc lá', '2025-12-29 17:08:00', NULL, NULL, '', '', 20),
(151, 'bánh quế socola GO CHOCO', 'SP37593', '3878270544027', 4, 'hộp', 30000.00, 25000.00, 'active', NULL, '2026-01-22 16:07:32', NULL, NULL, 'SP37593', 'bánh quế socola GO CHOCO', 10),
(152, 'Kem đánh răng crest', 'SP84990', '1794132717423', 2, 'Típ', 90000.00, 80000.00, 'active', NULL, '2026-01-22 16:16:12', NULL, NULL, 'SP84990', 'Kem đánh răng crest', 10),
(153, 'Bút bi Thiên Long', 'SP62545', '1227045324841', 4, 'Cây', 3000.00, 1500.00, 'active', NULL, '2026-01-22 16:34:52', NULL, NULL, 'SP62545', 'Bút bi Thiên Long', 10),
(154, 'Bcs', 'SP44611', '7300337854582', 5, 'hop', 70000.00, 50000.00, 'active', NULL, '2026-01-22 19:47:30', NULL, NULL, 'SP44611', 'Bcs', 1),
(155, 'Thùng 48 hộp sữa tươi tiệt trùng rất ít đường Vinamilk Green Farm 180ml', 'SP34850', '5029017434238', 1, 'thùng', 420000.00, 390000.00, 'active', NULL, '2026-01-25 16:04:58', NULL, NULL, 'SP34850', 'Thùng 48 hộp sữa tươi tiệt trùng rất ít đường Vinamilk Green Farm 180ml', 150);

-- --------------------------------------------------------

--
-- Table structure for table `product_costs`
--

CREATE TABLE `product_costs` (
  `id` bigint NOT NULL,
  `cost_price` decimal(15,2) NOT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `product_id` bigint NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `product_costs`
--

INSERT INTO `product_costs` (`id`, `cost_price`, `created_at`, `product_id`, `updated_at`) VALUES
(1, 25000.00, '2026-01-22 23:07:32.445522', 151, '2026-01-22 23:07:32.445541'),
(2, 80000.00, '2026-01-22 23:16:12.230848', 152, '2026-01-22 23:16:12.230862'),
(3, 1500.00, '2026-01-22 23:34:52.331324', 153, '2026-01-22 23:34:52.331330'),
(4, 50000.00, '2026-01-23 02:47:30.603900', 154, '2026-01-23 02:47:30.603909'),
(5, 9000.00, '2026-01-23 14:47:28.255344', 2, '2026-01-23 14:47:28.255370'),
(6, 390000.00, '2026-01-25 23:04:58.656164', 155, '2026-01-25 23:04:58.656174'),
(7, 3500.00, '2026-01-25 23:09:46.561217', 3, '2026-01-25 23:09:46.561223');

-- --------------------------------------------------------

--
-- Table structure for table `product_cost_histories`
--

CREATE TABLE `product_cost_histories` (
  `id` bigint NOT NULL,
  `product_id` bigint NOT NULL,
  `cost_price` decimal(15,2) NOT NULL,
  `quantity` int NOT NULL,
  `note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_by` bigint DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `product_cost_histories`
--

INSERT INTO `product_cost_histories` (`id`, `product_id`, `cost_price`, `quantity`, `note`, `created_by`, `created_at`) VALUES
(1, 151, 25000.00, 10, NULL, NULL, '2026-01-22 23:07:32.479610'),
(2, 152, 80000.00, 10, NULL, NULL, '2026-01-22 23:16:12.260094'),
(3, 153, 1500.00, 10, NULL, NULL, '2026-01-22 23:34:52.349602'),
(4, 154, 50000.00, 1, NULL, NULL, '2026-01-23 02:47:30.618015'),
(5, 2, 9000.00, 100, ' nhập ngày 23/01/2026\n', NULL, '2026-01-23 14:47:28.306615'),
(6, 155, 390000.00, 150, NULL, NULL, '2026-01-25 23:04:58.679371'),
(7, 3, 3500.00, 100, '', NULL, '2026-01-25 23:09:46.568152');

-- --------------------------------------------------------

--
-- Table structure for table `promotions`
--

CREATE TABLE `promotions` (
  `promotion_id` bigint NOT NULL COMMENT 'Khóa chính, mã duy nhất của chương trình khuyến mãi',
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
  `discount_type` enum('BUNDLE','FIXED','FIXED_AMOUNT','FREE_GIFT','PERCENT') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Bảng lưu trữ các chương trình khuyến mãi';

--
-- Dumping data for table `promotions`
--

INSERT INTO `promotions` (`promotion_id`, `name`, `description`, `promotion_type`, `discount_value`, `start_date`, `end_date`, `applies_to`, `status`, `created_at`, `updated_at`, `active`, `code`, `discount_type`) VALUES
(2034, 'Nước giải khác', 'toàn bộ nước giải khác', 'PERCENT', 20, '2026-01-25 08:34:00', '2026-02-06 08:34:00', 'ALL', 'PENDING', '2026-01-24 18:34:45', '2026-01-24 18:34:45', b'1', 'KMNGK-001', 'PERCENT'),
(2035, 'Dale hời cuối năm', NULL, 'FIXED_AMOUNT', 2000, '2026-01-25 20:53:00', '2026-02-06 20:53:00', 'ALL', 'PENDING', '2026-01-25 06:53:29', '2026-01-25 06:53:29', b'1', 'KMDHCN-001', 'FIXED'),
(2036, 'compo', NULL, 'BUNDLE', 0, '2026-01-25 21:11:00', '2026-02-05 21:11:00', 'ALL', 'PENDING', '2026-01-25 07:11:26', '2026-01-25 07:11:26', b'1', 'KMCOMP-001', 'BUNDLE'),
(2038, 'giảm tiền sản phẩm', NULL, 'FIXED_AMOUNT', 5000, '2026-01-25 21:35:00', '2026-02-21 21:35:00', 'ALL', 'PENDING', '2026-01-25 07:36:05', '2026-01-25 07:36:05', b'1', 'KMGTSP-001', 'FIXED'),
(2039, 'compo nước', NULL, 'BUNDLE', 0, '2026-01-25 21:37:00', '2026-02-07 21:37:00', 'ALL', 'PENDING', '2026-01-25 07:37:36', '2026-01-25 07:37:36', b'1', 'KMCN-001', 'BUNDLE'),
(2040, 'bcs', 'bcs', 'FIXED_AMOUNT', 6000, '2026-01-25 21:38:00', '2026-02-07 21:38:00', 'ALL', 'PENDING', '2026-01-25 07:39:14', '2026-01-25 07:39:14', b'1', 'KMBCS-001', 'FIXED'),
(2041, 'compo nước giải khát', NULL, 'BUNDLE', 0, '2026-01-25 21:40:00', '2026-02-06 21:40:00', 'ALL', 'PENDING', '2026-01-25 07:40:41', '2026-01-25 07:40:41', b'1', 'KMCNGK-002', 'BUNDLE'),
(2042, 'giảm giá poca', NULL, 'FIXED_AMOUNT', 5000, '2026-01-25 21:44:00', '2026-02-07 21:44:00', 'ALL', 'PENDING', '2026-01-25 07:44:50', '2026-01-25 07:44:50', b'1', 'KMGGP-001', 'FIXED'),
(2043, 'Thái dúi', NULL, 'BUNDLE', 0, '2026-01-25 22:30:00', '2026-02-14 22:30:00', 'ALL', 'PENDING', '2026-01-25 08:30:39', '2026-01-25 08:30:39', b'1', 'KMTD-001', 'BUNDLE'),
(2044, 'giảm tiền sản phẩm', NULL, 'FIXED_AMOUNT', 4000, '2026-01-25 22:31:00', '2026-02-06 22:31:00', 'ALL', 'PENDING', '2026-01-25 08:32:04', '2026-01-25 08:32:04', b'1', 'KMGTSP-002', 'FIXED'),
(2045, 'Combo Siêu Tiết Kiệm - Tháng 1 2026', 'Mua combo sản phẩm với giá ưu đãi đặc biệt. Nhanh tay đặt hàng ngay hôm nay!', 'BUNDLE', 0, '2026-01-26 00:15:00', '2026-02-08 00:15:00', 'ALL', 'PENDING', '2026-01-25 10:16:18', '2026-01-25 10:16:18', b'1', 'COMBO-JAN26', 'BUNDLE'),
(2046, 'Flash Sale 15% - Tháng 1 2026', 'Giảm giá 15% cho sản phẩm được chọn. Nhanh tay đặt hàng ngay hôm nay!', 'PERCENT', 15, '2026-01-26 00:16:00', '2026-02-14 00:16:00', 'ALL', 'PENDING', '2026-01-25 10:17:09', '2026-01-25 10:17:09', b'1', 'SALE15-JAN26', 'PERCENT'),
(2047, 'Flash Sale 25% - Tháng 1 2026', 'Giảm giá 25% cho sản phẩm được chọn. Nhanh tay đặt hàng ngay hôm nay!', 'PERCENT', 25, '2026-01-26 02:04:00', '2026-02-28 02:05:00', 'ALL', 'PENDING', '2026-01-25 12:06:02', '2026-01-25 12:27:50', b'1', 'SALE25-JAN26', 'PERCENT'),
(2048, 'Flash Sale 40% - Tháng 1 2026', 'Giảm giá 40% cho sản phẩm được chọn. Nhanh tay đặt hàng ngay hôm nay!', 'PERCENT', 40, '2026-01-26 02:07:00', '2026-02-08 02:07:00', 'ALL', 'PENDING', '2026-01-25 12:08:08', '2026-01-25 13:29:14', b'0', 'SALE40-JAN26', 'PERCENT'),
(2049, 'Flash Sale 20% - Tháng 1 2026', 'Giảm giá 20% cho sản phẩm được chọn. Nhanh tay đặt hàng ngay hôm nay!', 'PERCENT', 20, '2026-01-26 02:29:00', '2026-02-13 02:29:00', 'ALL', 'PENDING', '2026-01-25 12:30:06', '2026-01-25 12:30:46', b'1', 'SALE20-JAN26', 'PERCENT'),
(2050, 'Flash Sale 10% - Tháng 1 2026', 'Giảm giá 10% cho sản phẩm được chọn. Nhanh tay đặt hàng ngay hôm nay!', 'PERCENT', 10, '2026-01-26 03:42:00', '2026-02-07 03:43:00', 'ALL', 'PENDING', '2026-01-25 13:43:17', '2026-01-25 13:43:17', b'1', 'SALE10-JAN26', 'PERCENT'),
(2051, 'Giảm Ngay 3.000đ - Tháng 1 2026', 'Giảm ngay 3.000đ khi mua sản phẩm được chọn. Nhanh tay đặt hàng ngay hôm nay!', 'FIXED_AMOUNT', 3000, '2026-01-26 04:42:00', '2026-02-08 04:42:00', 'ALL', 'PENDING', '2026-01-25 14:42:33', '2026-01-25 14:42:33', b'1', 'GIAM3K-JAN26', 'FIXED'),
(2052, 'Flash Sale 5% - Tháng 1 2026', 'Giảm giá 5% cho sản phẩm được chọn. Nhanh tay đặt hàng ngay hôm nay!', 'PERCENT', 5, '2026-01-26 06:05:00', '2026-02-15 06:05:00', 'ALL', 'PENDING', '2026-01-25 16:05:45', '2026-01-25 16:05:45', b'1', 'SALE5-JAN26', 'PERCENT'),
(2053, 'NiFi Test Promotion 10%', 'Test promotion for NiFi flow validation', NULL, 10, '2026-01-26 00:00:00', '2026-02-26 23:59:59', 'ALL', 'PENDING', '2026-01-26 06:27:54', '2026-01-26 06:27:54', b'1', 'NIFI_TEST_01', 'PERCENT'),
(2054, 'NiFi Test Fixed 50k', 'Test fixed discount', NULL, 50000, '2026-01-26 00:00:00', '2026-03-26 23:59:59', 'ALL', 'PENDING', '2026-01-26 06:27:54', '2026-01-26 06:27:54', b'1', 'NIFI_TEST_02', 'FIXED'),
(2055, 'NiFi Test Bundle Deal', 'Test bundle promotion', NULL, 0, '2026-01-26 00:00:00', '2026-02-28 23:59:59', 'ALL', 'PENDING', '2026-01-26 06:27:54', '2026-01-26 06:27:54', b'1', 'NIFI_TEST_03', 'BUNDLE');

-- --------------------------------------------------------

--
-- Table structure for table `promotion_targets`
--

CREATE TABLE `promotion_targets` (
  `promo_target_id` bigint NOT NULL COMMENT 'Khóa chính',
  `promotion_id` bigint NOT NULL COMMENT 'Khóa ngoại, liên kết với bảng promotions',
  `product_id` int DEFAULT NULL COMMENT 'Khóa ngoại, liên kết với products.product_id (Sản phẩm được áp dụng)',
  `category_id` bigint DEFAULT NULL,
  `min_order_value` decimal(15,2) DEFAULT '0.00' COMMENT 'Giá trị đơn hàng tối thiểu để áp dụng (nếu cần)',
  `max_discount_amount` decimal(15,2) DEFAULT NULL COMMENT 'Số tiền giảm tối đa (nếu là giảm %)',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `target_id` bigint DEFAULT NULL,
  `target_type` enum('BRANCH','CATEGORY','CUSTOMER_GROUP','PRODUCT') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `promotion_targets`
--

INSERT INTO `promotion_targets` (`promo_target_id`, `promotion_id`, `product_id`, `category_id`, `min_order_value`, `max_discount_amount`, `created_at`, `target_id`, `target_type`) VALUES
(52, 2034, NULL, NULL, 0.00, NULL, '2026-01-24 18:34:45', 1, 'CATEGORY'),
(53, 2035, NULL, NULL, 0.00, NULL, '2026-01-25 06:53:29', 14, 'PRODUCT'),
(54, 2040, NULL, NULL, 0.00, NULL, '2026-01-25 07:39:14', 154, 'PRODUCT'),
(56, 2042, NULL, NULL, 0.00, NULL, '2026-01-25 08:29:25', 62, 'PRODUCT'),
(57, 2044, NULL, NULL, 0.00, NULL, '2026-01-25 08:32:04', 110, 'PRODUCT'),
(58, 2046, NULL, NULL, 0.00, NULL, '2026-01-25 10:17:09', 26, 'PRODUCT'),
(68, 2047, NULL, NULL, 0.00, NULL, '2026-01-25 12:27:50', 127, 'PRODUCT'),
(69, 2047, NULL, NULL, 0.00, NULL, '2026-01-25 12:27:50', 92, 'PRODUCT'),
(71, 2049, NULL, NULL, 0.00, NULL, '2026-01-25 12:30:46', 106, 'PRODUCT'),
(72, 2048, NULL, NULL, 0.00, NULL, '2026-01-25 13:29:14', 10, 'PRODUCT'),
(73, 2048, NULL, NULL, 0.00, NULL, '2026-01-25 13:29:14', 27, 'PRODUCT'),
(74, 2050, NULL, NULL, 0.00, NULL, '2026-01-25 13:43:17', 29, 'PRODUCT'),
(75, 2051, NULL, NULL, 0.00, NULL, '2026-01-25 14:42:33', 48, 'PRODUCT'),
(76, 2052, NULL, NULL, 0.00, NULL, '2026-01-25 16:05:45', 155, 'PRODUCT'),
(77, 2053, NULL, NULL, 0.00, NULL, '2026-01-26 06:27:54', 1001, 'PRODUCT'),
(78, 2053, NULL, NULL, 0.00, NULL, '2026-01-26 06:27:54', 1002, 'PRODUCT'),
(79, 2054, NULL, NULL, 0.00, NULL, '2026-01-26 06:27:54', 5, 'CATEGORY'),
(80, 2055, NULL, NULL, 0.00, NULL, '2026-01-26 06:27:54', 2001, 'PRODUCT');

-- --------------------------------------------------------

--
-- Table structure for table `shelves`
--

CREATE TABLE `shelves` (
  `shelf_id` bigint NOT NULL,
  `warehouse_id` bigint NOT NULL,
  `shelf_code` varchar(50) NOT NULL,
  `shelf_name` varchar(100) DEFAULT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint NOT NULL,
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
  `note` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `password`, `email`, `full_name`, `phone_number`, `role`, `enabled`, `branch_id`, `created_at`, `updated_at`, `note`) VALUES
(1, 'admin', '$2a$10$7gz3idM0iA0ikYyibDutqe31yrWDdVh2NIRa1gCj0QXVNw9723f0G', 'admin@bizflow.com', 'Administrator', NULL, 'ADMIN', 1, NULL, '2025-12-21 10:47:36', '2025-12-21 10:47:36', NULL),
(2, 'owner', '$2a$10$iDS5.CarVV4hxkD1P5oVYePzl/M8gs3jse7bGOAjhQBZ6iefSllWy', 'owner@bizflow.com', 'Store Owner', NULL, 'OWNER', 1, NULL, '2025-12-21 10:47:36', '2025-12-21 10:47:36', NULL),
(3, 'test', '$2a$10$iDS5.CarVV4hxkD1P5oVYePzl/M8gs3jse7bGOAjhQBZ6iefSllWy', 'test@bizflow.com', 'Test User', NULL, 'EMPLOYEE', 1, NULL, '2025-12-21 10:47:36', '2025-12-21 10:47:36', NULL),
(4, 'vietphd', '$2a$10$hTmAfVr7LjuSr5AxSKrpJeleoHtsiZn1RuVH9jub038t4C5SAIhiq', 'nhanvien1@gmail.com', 'Phạm Huy Đức Việt ', '0902313141', 'EMPLOYEE', 1, NULL, '2025-12-24 16:44:38', '2026-01-02 14:08:05', NULL),
(7, 'Tutl', '$2a$10$0P6niSx/VIjhEfnjFVv.cOWuRpb.WTEhAvCEdTzUO9BFyuDVwp2je', 'Tutl@gmail.com', 'Trần Long Tứ', '0866066043', 'EMPLOYEE', 1, NULL, '2026-01-03 21:57:14', '2026-01-03 21:57:14', NULL),
(8, 'TanBinh', '$2a$10$C2DybkhUAxwMFkLTSIVnteX834ZBW/Glnvg2OKPZxVzNZJvAYCIyW', 'tanbinh@gmail.com', 'Tân Bình', '0866066042', 'OWNER', 1, 2, '2026-01-21 22:25:46', '2026-01-21 22:25:46', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `warehouses`
--

CREATE TABLE `warehouses` (
  `warehouse_id` bigint NOT NULL,
  `warehouse_name` varchar(255) NOT NULL,
  `address` varchar(255) DEFAULT NULL,
  `manager_id` bigint DEFAULT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `branches`
--
ALTER TABLE `branches`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `UK_hw68nd07qk3jrjfg70qxq9vb7` (`name`),
  ADD KEY `FK8lecw87wgj5h4k0x8klg4bnep` (`owner_id`);

--
-- Indexes for table `bundle_items`
--
ALTER TABLE `bundle_items`
  ADD PRIMARY KEY (`bundle_id`),
  ADD KEY `promotion_id` (`promotion_id`),
  ADD KEY `main_product_id` (`main_product_id`),
  ADD KEY `gift_product_id` (`gift_product_id`),
  ADD KEY `idx_bundle_product` (`product_id`);

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`category_id`),
  ADD KEY `fk_category_parent` (`parent_id`);

--
-- Indexes for table `customers`
--
ALTER TABLE `customers`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `inventory_stocks`
--
ALTER TABLE `inventory_stocks`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `UK_hii2068ogj2cdjykg0h9adjo0` (`product_id`);

--
-- Indexes for table `inventory_transactions`
--
ALTER TABLE `inventory_transactions`
  ADD PRIMARY KEY (`transaction_id`),
  ADD KEY `fk_it_product` (`product_id`),
  ADD KEY `fk_it_warehouse` (`warehouse_id`),
  ADD KEY `fk_it_shelf` (`shelf_id`),
  ADD KEY `fk_it_created_by` (`created_by`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `UK_9euhgrj490gy02d8abquh7jvu` (`invoice_number`),
  ADD KEY `FKpxtb8awmi0dk6smoh2vp1litg` (`customer_id`),
  ADD KEY `FK32ql8ubntj5uh44ph9659tiih` (`user_id`),
  ADD KEY `FKakl1p7xiogdupq1376fttx2xc` (`parent_order_id`);

--
-- Indexes for table `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `FKbioxgbv59vetrxe0ejfubep1w` (`order_id`),
  ADD KEY `FKocimc7dtr037rh4ls4l95nlfi` (`product_id`);

--
-- Indexes for table `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `FK81gagumt0r8y3rmudcgpbk42l` (`order_id`);

--
-- Indexes for table `point_history`
--
ALTER TABLE `point_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `FKoykoexosmdcwsmph7ubqmq22` (`customer_id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`product_id`),
  ADD UNIQUE KEY `sku` (`sku`),
  ADD KEY `fk_product_category` (`category_id`);

--
-- Indexes for table `product_costs`
--
ALTER TABLE `product_costs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `UK_emj5ou3kymldu462sbu36chhd` (`product_id`);

--
-- Indexes for table `product_cost_histories`
--
ALTER TABLE `product_cost_histories`
  ADD PRIMARY KEY (`id`),
  ADD KEY `FKagbnau0mqw831wgvk2h3v696m` (`product_id`);

--
-- Indexes for table `promotions`
--
ALTER TABLE `promotions`
  ADD PRIMARY KEY (`promotion_id`),
  ADD KEY `idx_start_end_date` (`start_date`,`end_date`);

--
-- Indexes for table `promotion_targets`
--
ALTER TABLE `promotion_targets`
  ADD PRIMARY KEY (`promo_target_id`),
  ADD KEY `promotion_id` (`promotion_id`),
  ADD KEY `product_id` (`product_id`),
  ADD KEY `category_id` (`category_id`),
  ADD KEY `idx_target_type_id` (`target_type`,`target_id`);

--
-- Indexes for table `shelves`
--
ALTER TABLE `shelves`
  ADD PRIMARY KEY (`shelf_id`),
  ADD KEY `fk_shelf_warehouse` (`warehouse_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `fk_user_branch` (`branch_id`);

--
-- Indexes for table `warehouses`
--
ALTER TABLE `warehouses`
  ADD PRIMARY KEY (`warehouse_id`),
  ADD KEY `fk_warehouse_manager` (`manager_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `branches`
--
ALTER TABLE `branches`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `bundle_items`
--
ALTER TABLE `bundle_items`
  MODIFY `bundle_id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Khóa chính, mã duy nhất của luật tặng/combo', AUTO_INCREMENT=43;

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `category_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `customers`
--
ALTER TABLE `customers`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `inventory_stocks`
--
ALTER TABLE `inventory_stocks`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=157;

--
-- AUTO_INCREMENT for table `inventory_transactions`
--
ALTER TABLE `inventory_transactions`
  MODIFY `transaction_id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=97;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=47;

--
-- AUTO_INCREMENT for table `order_items`
--
ALTER TABLE `order_items`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=106;

--
-- AUTO_INCREMENT for table `payments`
--
ALTER TABLE `payments`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=42;

--
-- AUTO_INCREMENT for table `point_history`
--
ALTER TABLE `point_history`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `product_id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=156;

--
-- AUTO_INCREMENT for table `product_costs`
--
ALTER TABLE `product_costs`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `product_cost_histories`
--
ALTER TABLE `product_cost_histories`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `promotions`
--
ALTER TABLE `promotions`
  MODIFY `promotion_id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Khóa chính, mã duy nhất của chương trình khuyến mãi', AUTO_INCREMENT=2056;

--
-- AUTO_INCREMENT for table `promotion_targets`
--
ALTER TABLE `promotion_targets`
  MODIFY `promo_target_id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Khóa chính', AUTO_INCREMENT=81;

--
-- AUTO_INCREMENT for table `shelves`
--
ALTER TABLE `shelves`
  MODIFY `shelf_id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `warehouses`
--
ALTER TABLE `warehouses`
  MODIFY `warehouse_id` bigint NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `branches`
--
ALTER TABLE `branches`
  ADD CONSTRAINT `FK8lecw87wgj5h4k0x8klg4bnep` FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `bundle_items`
--
ALTER TABLE `bundle_items`
  ADD CONSTRAINT `FKnovhg7gfyangkg1ftcjhmltw6` FOREIGN KEY (`promotion_id`) REFERENCES `promotions` (`promotion_id`);

--
-- Constraints for table `categories`
--
ALTER TABLE `categories`
  ADD CONSTRAINT `fk_category_parent` FOREIGN KEY (`parent_id`) REFERENCES `categories` (`category_id`) ON DELETE SET NULL;

--
-- Constraints for table `inventory_transactions`
--
ALTER TABLE `inventory_transactions`
  ADD CONSTRAINT `fk_it_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_it_shelf` FOREIGN KEY (`shelf_id`) REFERENCES `shelves` (`shelf_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_it_warehouse` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`warehouse_id`) ON DELETE SET NULL;

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `FK32ql8ubntj5uh44ph9659tiih` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `FKakl1p7xiogdupq1376fttx2xc` FOREIGN KEY (`parent_order_id`) REFERENCES `orders` (`id`),
  ADD CONSTRAINT `FKpxtb8awmi0dk6smoh2vp1litg` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`);

--
-- Constraints for table `order_items`
--
ALTER TABLE `order_items`
  ADD CONSTRAINT `FKbioxgbv59vetrxe0ejfubep1w` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  ADD CONSTRAINT `FKocimc7dtr037rh4ls4l95nlfi` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`);

--
-- Constraints for table `payments`
--
ALTER TABLE `payments`
  ADD CONSTRAINT `FK81gagumt0r8y3rmudcgpbk42l` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`);

--
-- Constraints for table `point_history`
--
ALTER TABLE `point_history`
  ADD CONSTRAINT `FKoykoexosmdcwsmph7ubqmq22` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`);

--
-- Constraints for table `product_cost_histories`
--
ALTER TABLE `product_cost_histories`
  ADD CONSTRAINT `FKagbnau0mqw831wgvk2h3v696m` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`);

--
-- Constraints for table `promotion_targets`
--
ALTER TABLE `promotion_targets`
  ADD CONSTRAINT `promotion_targets_ibfk_1` FOREIGN KEY (`promotion_id`) REFERENCES `promotions` (`promotion_id`);

--
-- Constraints for table `shelves`
--
ALTER TABLE `shelves`
  ADD CONSTRAINT `fk_shelf_warehouse` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`warehouse_id`) ON DELETE CASCADE;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `FK9o70sp9ku40077y38fk4wieyk` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
