# 📝 QUICK REFERENCE - 24 BẢNG BIZFLOW

## ⚡ CÀI ĐẶT NHANH

### Option 1: Script tự động (Recommended)
```bash
chmod +x setup_database.sh
./setup_database.sh
```

### Option 2: Thủ công
```bash
mysql -u root -p < db/init/001_schema_new.sql
mysql -u root -p < db/init/002_seed_new.sql
mysql -u root -p < db/init/test_database.sql
```

### Option 3: Docker
```bash
docker-compose up -d db
docker exec -it bizflow_db mysql -u root -p bizflow_db
```

---

## 🎯 24 BẢNG - TÓM TẮT NHANH

### 🔐 NHÓM 1: HỆ THỐNG (5)
```
roles           → Vai trò (ADMIN/OWNER/EMPLOYEE)
users           → Tài khoản
user_roles      → Phân quyền (N-N)
shops           → Cửa hàng
audit_logs      → Nhật ký hệ thống
```

### 📦 NHÓM 2: SẢN PHẨM (6)
```
categories           → Danh mục
products             → Sản phẩm
product_units        → Đơn vị tính
product_prices       → Lịch sử giá
product_images       → Hình ảnh
product_status_logs  → Lịch sử trạng thái
```

### 📊 NHÓM 3: KHO (5)
```
suppliers              → Nhà cung cấp
stock_imports          → Phiếu nhập
stock_import_items     → Chi tiết nhập
inventory              → Tồn kho
inventory_transactions → Giao dịch kho
```

### 🛒 NHÓM 4: BÁN HÀNG (4)
```
orders        → Đơn hàng
order_items   → Chi tiết đơn
payments      → Thanh toán
receipts      → Hóa đơn
```

### 👤 NHÓM 5: KHÁCH HÀNG (4)
```
customers          → Khách hàng
customer_debts     → Công nợ
loyalty_points     → Điểm tích lũy
membership_tiers   → Hạng thành viên
```

---

## 🔑 TÀI KHOẢN MẪU

| Username | Password | Role | Mô tả |
|----------|----------|------|-------|
| admin | admin123 | ADMIN | Quản trị toàn hệ thống |
| owner1 | owner123 | OWNER | Chủ Shop 1 (HCM) |
| owner2 | owner123 | OWNER | Chủ Shop 2 (HN) |
| emp1 | emp123 | EMPLOYEE | Nhân viên Shop 1 |
| emp2 | emp123 | EMPLOYEE | Nhân viên Shop 2 |

---

## 📊 QUERY NHANH

### Xem tồn kho
```sql
SELECT p.name, i.quantity_on_hand, i.quantity_reserved
FROM inventory i
JOIN products p ON i.product_id = p.id
WHERE i.shop_id = 1;
```

### Doanh thu hôm nay
```sql
SELECT SUM(final_amount) as today_revenue
FROM orders
WHERE DATE(order_date) = CURDATE() AND status = 'COMPLETED';
```

### Top 5 sản phẩm bán chạy
```sql
SELECT p.name, SUM(oi.quantity) as sold
FROM products p
JOIN order_items oi ON p.id = oi.product_id
JOIN orders o ON oi.order_id = o.id
WHERE o.status = 'COMPLETED'
GROUP BY p.id
ORDER BY sold DESC
LIMIT 5;
```

### Công nợ khách hàng
```sql
SELECT c.name, SUM(cd.remaining_amount) as debt
FROM customers c
JOIN customer_debts cd ON c.id = cd.customer_id
WHERE cd.status = 'UNPAID'
GROUP BY c.id;
```

---

## 🔍 KIỂM TRA NHANH

```sql
-- Đếm số bảng (phải = 24-26)
SELECT COUNT(*) FROM information_schema.tables 
WHERE table_schema = 'bizflow_db';

-- Liệt kê bảng
SHOW TABLES;

-- Đếm records
SELECT 'Products' as table_name, COUNT(*) as count FROM products
UNION ALL SELECT 'Orders', COUNT(*) FROM orders
UNION ALL SELECT 'Customers', COUNT(*) FROM customers;
```

---

## 🚨 TROUBLESHOOTING

### Lỗi kết nối MySQL
```bash
# Kiểm tra MySQL chạy chưa
sudo systemctl status mysql    # Linux
brew services list             # macOS

# Khởi động MySQL
sudo systemctl start mysql     # Linux
brew services start mysql      # macOS
```

### Lỗi quyền
```sql
GRANT ALL PRIVILEGES ON bizflow_db.* TO 'root'@'localhost';
FLUSH PRIVILEGES;
```

### Reset toàn bộ
```bash
mysql -u root -p < db/init/migration.sql
```

---

## 📁 FILES QUAN TRỌNG

```
✅ 001_schema_new.sql     → Schema 24 bảng
✅ 002_seed_new.sql       → Dữ liệu mẫu
✅ test_database.sql      → Script test
✅ migration.sql          → Migrate từ cũ
✅ setup_database.sh      → Script tự động
✅ DATABASE_STRUCTURE.md  → Tài liệu đầy đủ
✅ ERD_DIAGRAM.md         → Sơ đồ quan hệ
✅ SUMMARY.md             → Tóm tắt
✅ QUICK_REFERENCE.md     → File này
```

---

## 💡 TIPS

1. **Backup thường xuyên:**
   ```bash
   mysqldump -u root -p bizflow_db > backup.sql
   ```

2. **Restore từ backup:**
   ```bash
   mysql -u root -p bizflow_db < backup.sql
   ```

3. **Export dữ liệu:**
   ```bash
   mysql -u root -p bizflow_db -e "SELECT * FROM products" > products.csv
   ```

4. **Xem cấu trúc bảng:**
   ```sql
   DESCRIBE products;
   SHOW CREATE TABLE orders;
   ```

5. **Xem indexes:**
   ```sql
   SHOW INDEX FROM inventory;
   ```

---

## ✅ CHECKLIST DEMO THẦY

- [ ] Database có đủ 24 bảng
- [ ] Có dữ liệu mẫu trong các bảng
- [ ] Foreign keys hoạt động đúng
- [ ] Query test chạy OK
- [ ] Giải thích được từng bảng
- [ ] Giải thích được mối quan hệ
- [ ] Demo được 1 flow hoàn chỉnh (VD: bán hàng)
- [ ] Trả lời được câu hỏi về thiết kế

---

## 🎓 CÂU HỎI THẦY HAY HỎI

**Q: Tại sao cần bảng user_roles thay vì lưu role trong users?**
A: Để 1 user có thể có nhiều role ở nhiều shop khác nhau. VD: user A là OWNER ở shop 1, nhưng là EMPLOYEE ở shop 2.

**Q: Tại sao cần inventory_transactions?**
A: Để tracking lịch sử xuất nhập tồn. Nếu chỉ có inventory thì không biết tồn thay đổi do đâu (nhập hàng? bán hàng? điều chỉnh?).

**Q: Tại sao product_prices là bảng riêng?**
A: Để lưu lịch sử thay đổi giá. Biết được sản phẩm giá bao nhiêu vào thời điểm nào, ai thay đổi.

**Q: Sự khác biệt giữa quantity_on_hand và quantity_reserved?**
A: 
- quantity_on_hand: Số lượng thực tế trong kho
- quantity_reserved: Số lượng khách đã đặt nhưng chưa thanh toán
- quantity_available = on_hand - reserved

**Q: Làm sao phân biệt ADMIN và OWNER?**
A: 
- ADMIN: user_roles.shop_id = NULL (toàn hệ thống)
- OWNER: user_roles.shop_id = <ID shop cụ thể>

---

**🎯 Chúc bạn demo thành công!**
