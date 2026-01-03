# 🔧 Hướng dẫn Setup Database cho Teammate

## ❓ Vấn đề: phpMyAdmin trống trơn sau khi pull code

Nếu bạn pull code về và chạy `docker compose up` nhưng phpMyAdmin không có database, đây là **LÝ DO** và **GIẢI PHÁP**:

### 🔍 Tại sao không có database?

MySQL Docker container chỉ **tự động import** file SQL từ folder `db/init/` **LẦN ĐẦU TIÊN** tạo database.

Nếu bạn đã chạy Docker Compose trước đó, MySQL volume (`mysql_data`) đã tồn tại → MySQL sẽ **BỎ QUA** các file init SQL mới.

---

## ✅ Giải pháp: RESET Database Volume

### Cách 1: Xóa volume và rebuild (KHUYẾN NGHỊ)

```bash
# Bước 1: Dừng tất cả containers và XÓA VOLUME
docker compose down -v

# Bước 2: Chạy lại (database sẽ tự động import)
docker compose up -d

# Bước 3: Kiểm tra logs
docker compose logs mysql
```

### Cách 2: Xóa volume cụ thể

```bash
# Xem danh sách volumes
docker volume ls

# Xóa volume MySQL (tên có thể khác, check bằng lệnh trên)
docker volume rm xdpm_huongdoituong_nhom2_mysql_data

# Chạy lại
docker compose up -d
```

### Cách 3: Import thủ công (nếu cách trên không work)

```bash
# Copy file SQL vào container
docker cp db/init/database-backup.sql bizflow-mysql:/tmp/

# Import vào MySQL
docker exec -i bizflow-mysql mysql -uroot -p123456 bizflow_db < db/init/database-backup.sql

# Hoặc exec vào container
docker exec -it bizflow-mysql bash
mysql -uroot -p123456 bizflow_db < /tmp/database-backup.sql
exit
```

---

## 📋 Checklist sau khi setup

Kiểm tra database đã import thành công:

1. **Mở phpMyAdmin**: http://localhost:8081
   - Server: `mysql`
   - Username: `root`
   - Password: `123456`

2. **Kiểm tra các bảng**:
   - Database `bizflow_db` có đầy đủ bảng: `users`, `products`, `orders`, `customers`, `categories`...
   - Bảng `users` có user: `admin`, `owner`, `test`, `vietphd`
   - Bảng `categories` có 10 categories
   - Bảng `products` có sản phẩm (nếu có trong backup)

3. **Test đăng nhập**:
   - Frontend: http://localhost
   - Username: `admin` / Password: `admin123`
   - Username: `vietphd` / Password: `123456`

---

## 🚨 Lưu ý quan trọng

### Khi nào cần reset database?

- ✅ Lần đầu tiên clone/pull code về
- ✅ Khi teammate push file SQL mới (database-backup.sql update)
- ✅ Khi có lỗi database schema
- ✅ Khi phpMyAdmin hiện database trống

### Khi nào KHÔNG cần reset?

- ❌ Khi chỉ sửa code backend/frontend (không sửa database)
- ❌ Khi restart container bình thường
- ❌ Khi đã có database và đang làm việc bình thường

---

## 🆘 Troubleshooting

### Lỗi: "Error response from daemon: volume is in use"

```bash
# Dừng tất cả containers trước
docker compose down

# Sau đó xóa volume
docker volume rm xdpm_huongdoituong_nhom2_mysql_data

# Chạy lại
docker compose up -d
```

### Database import nhưng vẫn trống

```bash
# Kiểm tra logs MySQL
docker compose logs mysql | grep -i error

# Kiểm tra file SQL có lỗi syntax không
docker exec bizflow-mysql ls -la /docker-entrypoint-initdb.d/
```

### phpMyAdmin không connect được MySQL

```bash
# Kiểm tra MySQL container đã chạy chưa
docker ps | grep mysql

# Restart phpMyAdmin
docker compose restart phpmyadmin
```

---

## 💡 Tips

1. **Backup data trước khi reset**: Nếu bạn có data quan trọng, export ra trước:
   ```bash
   docker exec bizflow-mysql mysqldump -uroot -p123456 bizflow_db > my-backup.sql
   ```

2. **Tự động reset mỗi lần pull code mới**:
   ```bash
   git pull origin main && docker compose down -v && docker compose up -d
   ```

3. **Kiểm tra MySQL ready**: 
   ```bash
   docker exec bizflow-mysql mysql -uroot -p123456 -e "SHOW DATABASES;"
   ```

---

Nếu vẫn gặp vấn đề, hãy liên hệ Phạm Huy Đức Việt (@WolfamIT26) hoặc xem logs chi tiết:
```bash
docker compose logs mysql -f
```
