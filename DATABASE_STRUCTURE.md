# BIZFLOW - CƠ SỞ DỮ LIỆU 24 BẢNG - CHUẨN DỰ ÁN

## 📊 TỔNG QUAN KIẾN TRÚC

```
┌─────────────────────────────────────────────────────────────┐
│                     BIZFLOW DATABASE                        │
│                     24 BẢNG CHÍNH                          │
└─────────────────────────────────────────────────────────────┘
```

## 🧱 NHÓM 1: HỆ THỐNG & PHÂN QUYỀN (5 bảng)

### Sơ đồ quan hệ:
```
users ────┐
          ├──> user_roles <──── roles
shops <───┘         │
   │                │
   └────> audit_logs
```

### Chi tiết:
1. **roles** - Vai trò hệ thống (ADMIN, OWNER, EMPLOYEE)
2. **users** - Tài khoản người dùng
3. **user_roles** - Phân quyền mềm (1 user nhiều role, khác shop)
4. **shops** - Cửa hàng/Chi nhánh (mỗi owner có shop riêng)
5. **audit_logs** - Nhật ký hệ thống (ai làm gì, khi nào)

### Mối quan hệ:
- `user_roles.user_id` → `users.id`
- `user_roles.role_id` → `roles.id`
- `user_roles.shop_id` → `shops.id` (NULL = toàn hệ thống)
- `shops.owner_id` → `users.id`
- `audit_logs.user_id` → `users.id`
- `audit_logs.shop_id` → `shops.id`

---

## 🧱 NHÓM 2: SẢN PHẨM (6 bảng)

### Sơ đồ quan hệ:
```
categories
    │
    ├──> products ────┬──> product_units
    │                 ├──> product_prices
    │                 ├──> product_images
    │                 └──> product_status_logs
```

### Chi tiết:
6. **categories** - Danh mục sản phẩm (có thể phân cấp)
7. **products** - Sản phẩm gốc
8. **product_units** - Đơn vị tính (chai/thùng/gói...)
9. **product_prices** - Lịch sử giá (theo shop hoặc toàn hệ thống)
10. **product_images** - Nhiều ảnh cho 1 sản phẩm
11. **product_status_logs** - Lịch sử trạng thái (ẩn/hiện/khóa)

### Mối quan hệ:
- `categories.parent_id` → `categories.id` (cây phân cấp)
- `products.category_id` → `categories.id`
- `product_units.product_id` → `products.id`
- `product_prices.product_id` → `products.id`
- `product_prices.shop_id` → `shops.id`
- `product_images.product_id` → `products.id`
- `product_status_logs.product_id` → `products.id`

---

## 🧱 NHÓM 3: KHO & NHẬP HÀNG (5 bảng)

### Sơ đồ quan hệ:
```
suppliers ──> stock_imports ──> stock_import_items ──> products
                   │
                   └──> inventory <──── inventory_transactions
                           │
                         shops
```

### Chi tiết:
12. **suppliers** - Nhà cung cấp
13. **stock_imports** - Phiếu nhập kho
14. **stock_import_items** - Chi tiết phiếu nhập
15. **inventory** - Tồn kho hiện tại (theo shop)
16. **inventory_transactions** - Lịch sử xuất nhập tồn

### Mối quan hệ:
- `stock_imports.supplier_id` → `suppliers.id`
- `stock_imports.shop_id` → `shops.id`
- `stock_imports.imported_by` → `users.id`
- `stock_import_items.stock_import_id` → `stock_imports.id`
- `stock_import_items.product_id` → `products.id`
- `inventory.product_id` → `products.id`
- `inventory.shop_id` → `shops.id`
- `inventory_transactions.product_id` → `products.id`
- `inventory_transactions.shop_id` → `shops.id`

### Logic tồn kho:
- Mỗi lần nhập/xuất → tạo record trong `inventory_transactions`
- Cập nhật `inventory.quantity_on_hand`
- `quantity_reserved` = số lượng trong đơn hàng chưa thanh toán

---

## 🧱 NHÓM 4: BÁN HÀNG (4 bảng)

### Sơ đồ quan hệ:
```
customers ──> orders ──┬──> order_items ──> products
                       ├──> payments
                       └──> receipts
```

### Chi tiết:
17. **orders** - Đơn hàng/Hóa đơn
18. **order_items** - Chi tiết đơn hàng
19. **payments** - Thanh toán (tiền mặt/QR/chuyển khoản)
20. **receipts** - Biên lai/hóa đơn in

### Mối quan hệ:
- `orders.shop_id` → `shops.id`
- `orders.customer_id` → `customers.id`
- `orders.employee_id` → `users.id`
- `order_items.order_id` → `orders.id`
- `order_items.product_id` → `products.id`
- `payments.order_id` → `orders.id`
- `receipts.order_id` → `orders.id`
- `receipts.issued_by` → `users.id`

---

## 🧱 NHÓM 5: KHÁCH HÀNG & ĐIỂM (4 bảng)

### Sơ đồ quan hệ:
```
customers ──┬──> customer_debts ──> orders
            ├──> loyalty_points
            └──> membership_tiers (logic)
```

### Chi tiết:
21. **customers** - Khách hàng
22. **customer_debts** - Công nợ
23. **loyalty_points** - Điểm tích lũy
24. **membership_tiers** - Hạng thành viên (Đồng/Bạc/Vàng)

### Mối quan hệ:
- `customer_debts.customer_id` → `customers.id`
- `customer_debts.order_id` → `orders.id`
- `loyalty_points.customer_id` → `customers.id`
- Hạng thành viên được xác định dựa vào `loyalty_points.total_points`

---

## 📈 LUỒNG DỮ LIỆU CHÍNH

### 1. NHẬP HÀNG:
```
1. Tạo stock_imports
2. Thêm stock_import_items
3. Tạo inventory_transactions (IMPORT)
4. Cập nhật inventory.quantity_on_hand += số lượng nhập
```

### 2. BÁN HÀNG:
```
1. Tạo orders
2. Thêm order_items
3. Tạo inventory_transactions (SALE)
4. Cập nhật inventory.quantity_on_hand -= số lượng bán
5. Tạo payments
6. Tạo receipts
7. Cộng điểm loyalty_points cho khách hàng
8. Ghi audit_logs
```

### 3. QUẢN LÝ GIÁ:
```
1. Thay đổi giá sản phẩm
2. Lưu vào product_prices (lịch sử)
3. Cập nhật products.base_price
4. Ghi audit_logs
```

### 4. PHÂN QUYỀN:
```
1. Tạo user
2. Gán role qua user_roles
3. Nếu OWNER → tạo shop
4. Nếu EMPLOYEE → gán vào shop
```

---

## 🔍 CÁC CHỈ MỤC QUAN TRỌNG

### Tối ưu tìm kiếm:
- `users`: `idx_username`, `idx_email`
- `products`: `idx_code`, `idx_barcode`, `idx_category`
- `orders`: `idx_shop_id`, `idx_customer_id`, `idx_order_date`
- `inventory`: `uk_product_shop` (unique)
- `inventory_transactions`: `idx_product_shop`, `idx_created_at`

### Tối ưu báo cáo:
- `audit_logs`: `idx_timestamp`, `idx_action`
- `payments`: `idx_payment_date`, `idx_status`
- `customer_debts`: `idx_status`, `idx_due_date`

---

## 📋 CÁC TRUY VẤN THƯỜNG DÙNG

### 1. Xem tồn kho của 1 shop:
```sql
SELECT p.name, i.quantity_on_hand, i.quantity_reserved
FROM inventory i
JOIN products p ON i.product_id = p.id
WHERE i.shop_id = ?
```

### 2. Lịch sử giá sản phẩm:
```sql
SELECT old_price, new_price, effective_from, reason
FROM product_prices
WHERE product_id = ?
ORDER BY effective_from DESC
```

### 3. Doanh thu theo ngày:
```sql
SELECT DATE(order_date) as date, SUM(final_amount) as revenue
FROM orders
WHERE shop_id = ? AND status = 'COMPLETED'
GROUP BY DATE(order_date)
```

### 4. Công nợ khách hàng:
```sql
SELECT c.name, cd.debt_amount, cd.paid_amount, cd.remaining_amount, cd.due_date
FROM customer_debts cd
JOIN customers c ON cd.customer_id = c.id
WHERE cd.status IN ('UNPAID', 'PARTIAL')
```

### 5. Sản phẩm bán chạy:
```sql
SELECT p.name, SUM(oi.quantity) as total_sold
FROM order_items oi
JOIN products p ON oi.product_id = p.id
JOIN orders o ON oi.order_id = o.id
WHERE o.shop_id = ? AND o.status = 'COMPLETED'
GROUP BY p.id
ORDER BY total_sold DESC
LIMIT 10
```

---

## ✅ KIỂM TRA ĐỦ 24 BẢNG

### Nhóm 1 - Hệ thống (5):
- [x] roles
- [x] users
- [x] user_roles
- [x] shops
- [x] audit_logs

### Nhóm 2 - Sản phẩm (6):
- [x] categories
- [x] products
- [x] product_units
- [x] product_prices
- [x] product_images
- [x] product_status_logs

### Nhóm 3 - Kho (5):
- [x] suppliers
- [x] stock_imports
- [x] stock_import_items
- [x] inventory
- [x] inventory_transactions

### Nhóm 4 - Bán hàng (4):
- [x] orders
- [x] order_items
- [x] payments
- [x] receipts

### Nhóm 5 - Khách hàng (4):
- [x] customers
- [x] customer_debts
- [x] loyalty_points
- [x] membership_tiers

**TỔNG: 24 BẢNG ✅**

---

## 🎯 ĐIỂM MẠNH CỦA THIẾT KẾ

1. **Phân quyền linh hoạt**: 1 user có thể có nhiều role ở nhiều shop khác nhau
2. **Lịch sử đầy đủ**: Giá, trạng thái, tồn kho đều có tracking
3. **Đa shop**: Mỗi owner quản lý shop riêng, admin xem toàn bộ
4. **Audit trail**: Mọi thao tác quan trọng đều ghi log
5. **Tồn kho chính xác**: Có bảng transaction để kiểm tra lịch sử
6. **Công nợ rõ ràng**: Theo dõi khách nợ, hạn thanh toán
7. **Tích điểm & hạng**: Khuyến khích khách hàng quay lại

---

## 🚀 HƯỚNG DẪN SỬ DỤNG

### Bước 1: Tạo database
```bash
mysql -u root -p < db/init/001_schema_new.sql
```

### Bước 2: Import dữ liệu mẫu
```bash
mysql -u root -p < db/init/002_seed_new.sql
```

### Bước 3: Kiểm tra
```sql
USE bizflow_db;
SHOW TABLES;  -- Phải thấy 24 bảng
```

---

## 📝 GHI CHÚ

- Tất cả bảng đều có `created_at` hoặc `updated_at` để tracking
- Sử dụng `BIGINT` cho ID để tránh tràn số
- `DECIMAL(15,2)` cho tiền tệ (tối đa 999 tỷ)
- `VARCHAR` đủ dài để chứa dữ liệu thực tế
- Foreign key có `ON DELETE CASCADE` hoặc `SET NULL` hợp lý
- Index được tạo cho các cột thường xuyên query

---

**Thiết kế bởi: BizFlow Team**  
**Ngày: 2024-12-23**  
**Version: 2.0 - Production Ready**
