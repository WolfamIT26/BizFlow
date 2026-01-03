# Hướng dẫn Setup Project BizFlow

## Yêu cầu
- Docker & Docker Compose
- Git

## Các bước cài đặt

### 1. Clone repository
```bash
git clone https://github.com/WolfamIT26/BizFlow.git
cd BizFlow
```

### 2. Kiểm tra file database có sẵn
```bash
ls -lh db/init/
```
Phải thấy các file: `init.sql`, `database-backup.sql`, `schema-backup.sql`

### 3. Khởi động Docker containers
```bash
docker compose up -d
```

### 4. Chờ MySQL khởi động (khoảng 30 giây)
```bash
docker logs bizflow-mysql --tail 20
```
Chờ thấy dòng: `ready for connections`

### 5. Import database
```bash
docker exec -i bizflow-mysql mysql -u root -p123456 bizflow_db < db/init/database-backup.sql
```

### 6. Restart backend để load dữ liệu
```bash
docker restart bizflow-backend
```

### 7. Kiểm tra ứng dụng
- Frontend: http://localhost:3000/pages/login.html
- Backend API: http://localhost:8000/api
- phpMyAdmin: http://localhost:8081 (user: `root`, password: `123456`)

## Tài khoản mặc định

**Admin:**
- Username: `admin`
- Password: `admin123`

**Owner:**
- Username: `owner`
- Password: `password`

**Nhân viên:**
- Username: `test` hoặc `vietphd`
- Password: `password`

## Xử lý lỗi

### Lỗi: "Access denied for user"
```bash
docker exec -i bizflow-mysql mysql -u root -p123456 -e "SHOW DATABASES;"
```

### Reset database
```bash
docker exec -i bizflow-mysql mysql -u root -p123456 -e "DROP DATABASE IF EXISTS bizflow_db; CREATE DATABASE bizflow_db;"
docker exec -i bizflow-mysql mysql -u root -p123456 bizflow_db < db/init/database-backup.sql
docker restart bizflow-backend
```

### Rebuild toàn bộ
```bash
docker compose down -v
docker compose build --no-cache
docker compose up -d
# Chờ 30s rồi import database như bước 5
```
