# 🗄️ HƯỚNG DẪN CÀI ĐẶT DATABASE - 24 BẢNG

## 📋 MỤC LỤC
1. [Tổng quan](#tổng-quan)
2. [Cấu trúc database](#cấu-trúc-database)
3. [Cài đặt](#cài-đặt)
4. [Migration từ schema cũ](#migration)
5. [Kiểm tra](#kiểm-tra)
6. [Các truy vấn thường dùng](#truy-vấn)

---

## 🎯 TỔNG QUAN

Database **BizFlow** được thiết kế với **24 bảng** chia thành 5 nhóm chức năng:

### Nhóm 1: Hệ thống & Phân quyền (5 bảng)
- `roles` - Vai trò
- `users` - Người dùng
- `user_roles` - Phân quyền
- `shops` - Cửa hàng
- `audit_logs` - Nhật ký

### Nhóm 2: Sản phẩm (6 bảng)
- `categories` - Danh mục
- `products` - Sản phẩm
- `product_units` - Đơn vị tính
- `product_prices` - Lịch sử giá
- `product_images` - Hình ảnh
- `product_status_logs` - Lịch sử trạng thái

### Nhóm 3: Kho & Nhập hàng (5 bảng)
- `suppliers` - Nhà cung cấp
- `stock_imports` - Phiếu nhập
- `stock_import_items` - Chi tiết nhập
- `inventory` - Tồn kho
- `inventory_transactions` - Giao dịch kho

### Nhóm 4: Bán hàng (4 bảng)
- `orders` - Đơn hàng
- `order_items` - Chi tiết đơn
- `payments` - Thanh toán
- `receipts` - Hóa đơn

### Nhóm 5: Khách hàng & Điểm (4 bảng)
- `customers` - Khách hàng
- `customer_debts` - Công nợ
- `loyalty_points` - Điểm tích lũy
- `membership_tiers` - Hạng thành viên

---

## 🚀 CÀI ĐẶT

### Yêu cầu:
- MySQL 5.7+ hoặc MariaDB 10.2+
- Quyền tạo database

### Cách 1: Cài đặt mới (Recommended)

#### Bước 1: Tạo database và schema
```bash
cd db/init
mysql -u root -p < 001_schema_new.sql
```

#### Bước 2: Import dữ liệu mẫu
```bash
mysql -u root -p < 002_seed_new.sql
```

#### Bước 3: Kiểm tra
```bash
mysql -u root -p < test_database.sql
```

### Cách 2: Sử dụng Docker (Nhanh nhất)

#### Bước 1: Build và chạy
```bash
# Từ thư mục gốc project
docker-compose up -d db
```

#### Bước 2: Kiểm tra logs
```bash
docker-compose logs db
```

#### Bước 3: Kết nối
```bash
docker exec -it bizflow_db mysql -u root -p bizflow_db
```

---

## 🔄 MIGRATION TỪ SCHEMA CŨ

**⚠️ CẢNH BÁO:** Script này sẽ XÓA toàn bộ dữ liệu cũ!

### Bước 1: Backup database cũ
```bash
mysqldump -u root -p bizflow_db > backup_$(date +%Y%m%d_%H%M%S).sql
```

### Bước 2: Chạy migration
```bash
mysql -u root -p < db/init/migration.sql
```

### Bước 3: Verify
```sql
USE bizflow_db;
SHOW TABLES;
-- Phải có 24-26 bảng
```

---

## ✅ KIỂM TRA

### 1. Kiểm tra số lượng bảng
```sql
USE bizflow_db;
SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'bizflow_db';
-- Kết quả: 24-26
```

### 2. Kiểm tra dữ liệu mẫu
```sql
SELECT 'Users' as table_name, COUNT(*) as count FROM users
UNION ALL SELECT 'Products', COUNT(*) FROM products
UNION ALL SELECT 'Orders', COUNT(*) FROM orders;
```

### 3. Test quan hệ
```sql
-- Kiểm tra user có role
SELECT u.username, r.name as role, s.name as shop
FROM user_roles ur
JOIN users u ON ur.user_id = u.id
JOIN roles r ON ur.role_id = r.id
LEFT JOIN shops s ON ur.shop_id = s.id;
```

---

## 📊 CÁC TRUY VẤN THƯỜNG DÙNG

### 1. Dashboard Admin - Tổng quan hệ thống
```sql
SELECT 
    (SELECT COUNT(*) FROM users) as total_users,
    (SELECT COUNT(*) FROM shops WHERE is_active = TRUE) as active_shops,
    (SELECT COUNT(*) FROM products WHERE is_active = TRUE) as active_products,
    (SELECT COUNT(*) FROM orders WHERE DATE(order_date) = CURDATE()) as today_orders,
    (SELECT SUM(final_amount) FROM orders WHERE DATE(order_date) = CURDATE() AND status = 'COMPLETED') as today_revenue;
```

### 2. Tồn kho theo shop
```sql
SELECT 
    p.code,
    p.name,
    i.quantity_on_hand,
    i.quantity_reserved,
    (i.quantity_on_hand - i.quantity_reserved) as available,
    i.min_stock_level,
    CASE 
        WHEN i.quantity_on_hand < i.min_stock_level THEN 'CẦN NHẬP'
        WHEN i.quantity_on_hand > i.max_stock_level THEN 'TỒN DƯ'
        ELSE 'BÌNH THƯỜNG'
    END as status
FROM inventory i
JOIN products p ON i.product_id = p.id
WHERE i.shop_id = 1
ORDER BY i.quantity_on_hand ASC;
```

### 3. Doanh thu theo ngày (7 ngày gần nhất)
```sql
SELECT 
    DATE(order_date) as date,
    COUNT(*) as total_orders,
    SUM(final_amount) as revenue,
    AVG(final_amount) as avg_order_value
FROM orders
WHERE shop_id = 1 
  AND status = 'COMPLETED'
  AND order_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
GROUP BY DATE(order_date)
ORDER BY date DESC;
```

### 4. Top 10 sản phẩm bán chạy
```sql
SELECT 
    p.code,
    p.name,
    SUM(oi.quantity) as total_sold,
    SUM(oi.total_price) as revenue,
    COUNT(DISTINCT o.id) as order_count
FROM products p
JOIN order_items oi ON p.id = oi.product_id
JOIN orders o ON oi.order_id = o.id
WHERE o.shop_id = 1 
  AND o.status = 'COMPLETED'
  AND o.order_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY p.id
ORDER BY total_sold DESC
LIMIT 10;
```

### 5. Công nợ khách hàng
```sql
SELECT 
    c.customer_code,
    c.name,
    c.phone,
    SUM(cd.remaining_amount) as total_debt,
    COUNT(cd.id) as debt_count,
    MIN(cd.due_date) as nearest_due_date,
    CASE 
        WHEN MIN(cd.due_date) < CURDATE() THEN 'QUÁ HẠN'
        WHEN MIN(cd.due_date) <= DATE_ADD(CURDATE(), INTERVAL 7 DAY) THEN 'SẮP ĐẾN HẠN'
        ELSE 'BÌNH THƯỜNG'
    END as debt_status
FROM customers c
JOIN customer_debts cd ON c.id = cd.customer_id
WHERE cd.status IN ('UNPAID', 'PARTIAL')
GROUP BY c.id
ORDER BY total_debt DESC;
```

### 6. Lịch sử xuất nhập tồn
```sql
SELECT 
    it.created_at,
    p.name as product,
    it.transaction_type,
    it.quantity_change,
    it.reference_type,
    it.note,
    u.full_name as performed_by
FROM inventory_transactions it
JOIN products p ON it.product_id = p.id
LEFT JOIN users u ON it.performed_by = u.id
WHERE it.shop_id = 1
  AND it.product_id = 1
ORDER BY it.created_at DESC
LIMIT 20;
```

### 7. Báo cáo nhân viên
```sql
SELECT 
    u.username,
    u.full_name,
    COUNT(o.id) as total_orders,
    SUM(o.final_amount) as total_revenue,
    AVG(o.final_amount) as avg_order_value
FROM users u
JOIN orders o ON u.id = o.employee_id
WHERE o.shop_id = 1
  AND o.status = 'COMPLETED'
  AND o.order_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY u.id
ORDER BY total_revenue DESC;
```

### 8. Thống kê khách hàng VIP
```sql
SELECT 
    c.customer_code,
    c.name,
    c.phone,
    lp.total_points,
    mt.tier_name,
    mt.discount_percent,
    COUNT(o.id) as total_orders,
    SUM(o.final_amount) as total_spent
FROM customers c
LEFT JOIN loyalty_points lp ON c.id = lp.customer_id
LEFT JOIN membership_tiers mt ON lp.total_points >= mt.min_points
LEFT JOIN orders o ON c.id = o.customer_id AND o.status = 'COMPLETED'
WHERE lp.total_points >= 100
GROUP BY c.id
ORDER BY lp.total_points DESC;
```

---

## 🔐 TẠO USER VÀ PHÂN QUYỀN

### Tạo user mới trong MySQL
```sql
-- Tạo user cho backend
CREATE USER 'bizflow_app'@'localhost' IDENTIFIED BY 'StrongPassword123!';
GRANT ALL PRIVILEGES ON bizflow_db.* TO 'bizflow_app'@'localhost';
FLUSH PRIVILEGES;
```

### Tạo user trong hệ thống
```sql
-- Tạo admin
INSERT INTO users (username, password, email, full_name, enabled) 
VALUES ('admin', '$2a$10$...', 'admin@bizflow.com', 'Admin', TRUE);

-- Gán role admin
INSERT INTO user_roles (user_id, role_id, shop_id) 
VALUES (1, 1, NULL);

-- Tạo owner và shop
INSERT INTO users (username, password, email, full_name, enabled) 
VALUES ('owner1', '$2a$10$...', 'owner1@bizflow.com', 'Owner 1', TRUE);

INSERT INTO shops (name, address, owner_id, is_active) 
VALUES ('Shop 1', 'Địa chỉ shop', 2, TRUE);

INSERT INTO user_roles (user_id, role_id, shop_id) 
VALUES (2, 2, 1);
```

---

## 🛠️ TROUBLESHOOTING

### Lỗi: Foreign key constraint fails
```sql
-- Tắt tạm foreign key check
SET FOREIGN_KEY_CHECKS = 0;
-- Chạy câu lệnh của bạn
-- ...
-- Bật lại
SET FOREIGN_KEY_CHECKS = 1;
```

### Lỗi: Table already exists
```sql
-- Xóa tất cả bảng và tạo lại
SOURCE db/init/migration.sql
```

### Kiểm tra charset
```sql
SHOW CREATE DATABASE bizflow_db;
-- Phải là utf8mb4
```

---

## 📞 HỖ TRỢ

- **Document**: [DATABASE_STRUCTURE.md](DATABASE_STRUCTURE.md)
- **ERD Diagram**: Xem file ảnh đính kèm
- **Test Script**: `db/init/test_database.sql`

---

**Version**: 2.0  
**Last Update**: 2024-12-23  
**Author**: BizFlow Team
