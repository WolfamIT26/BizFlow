# Hướng Dẫn Restore Database Sau Khi Pull Code

## Các Bước Thực Hiện

### 1. Pull code mới từ Git
```bash
git pull origin main
```

### 2. Start Docker containers
```bash
docker-compose up -d
```

### 3. Chờ MySQL khởi động (10-15 giây)
```bash
sleep 15
```

### 4. Restore database

#### Cách 1: Dùng script tự động (Khuyến nghị)
```bash
./scripts/restore-latest-backup.sh
```

#### Cách 2: Restore thủ công
```bash
docker-compose exec -T mysql mysql -u root -p123456 bizflow_db < db/init/database-full.sql
```

### 5. Kiểm tra database đã có dữ liệu
```bash
docker-compose exec mysql mysql -u root -p123456 bizflow_db -e "SELECT COUNT(*) as total_products FROM products"
```

Kết quả phải là: **150 products**

---

## Xử Lý Lỗi

### Nếu báo lỗi "Can't connect to MySQL"
```bash
# Kiểm tra MySQL container
docker-compose ps mysql

# Nếu chưa chạy, start lại
docker-compose up -d mysql

# Chờ 15 giây rồi restore lại
sleep 15
./scripts/restore-latest-backup.sh
```

### Nếu muốn xóa database cũ và restore lại từ đầu
```bash
# Xóa containers và volumes
docker-compose down -v

# Start lại
docker-compose up -d

# Chờ MySQL khởi động
sleep 15

# Restore database
./scripts/restore-latest-backup.sh
```

---

## Thông Tin Database

- **File backup**: `db/init/database-full.sql` (73KB)
- **Nội dung**:
  - 150 sản phẩm
  - 37 đơn hàng
  - 6 users
  - 14 chương trình khuyến mãi
  - Tất cả dữ liệu và cấu trúc bảng đầy đủ

- **MySQL info**:
  - Host: localhost:3307
  - User: root
  - Password: 123456
  - Database: bizflow_db
