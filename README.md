# BizFlow - Hệ thống quản lý bán hàng và tồn kho

## 📖 Mục lục
1. [Mô tả](#mô-tả)
2. [Tính năng](#tính-năng)
3. [Công nghệ](#công-nghệ)
4. [Cấu trúc dự án](#cấu-trúc-dự-án)
5. [Cài đặt và chạy](#cài-đặt-và-chạy)
6. [Hướng dẫn sử dụng](#hướng-dẫn-sử-dụng)
7. [API Documentation](#api-documentation)
8. [Troubleshooting](#troubleshooting)
9. [Bước tiếp theo](#bước-tiếp-theo)

---

## 📋 Mô tả

BizFlow là hệ thống quản lý bán hàng và tồn kho được xây dựng bằng:
- **Backend**: Java Spring Boot 3.1.5 + MySQL
- **Frontend**: HTML5, CSS3, JavaScript

> Dự án có hai bộ schema:
> - Full 24 bảng: cho mô hình nhiều cửa hàng, nhiều nghiệp vụ.
> - Small 13 bảng: gọn cho hộ kinh doanh nhỏ (dùng file db/init/001_schema_small.sql + 002_seed_small.sql).

Hệ thống cung cấp giải pháp quản lý toàn diện cho các cửa hàng và doanh nghiệp nhỏ.

---

## ✨ Tính năng

### ✅ Phiên bản hiện tại (v1.0.0)

#### Chức năng Đăng Nhập
- ✅ Xác thực người dùng với username và password
- ✅ Mã hóa mật khẩu bằng BCrypt
- ✅ Tạo JWT tokens (Access Token + Refresh Token)
- ✅ Ghi nhớ đăng nhập
- ✅ Giao diện đẹp, responsive
- ✅ Dashboard sau đăng nhập
- ✅ Logout function

#### Dashboard
- ✅ Hiển thị thông tin người dùng
- ✅ Hiển thị tokens
- ✅ Menu chức năng chính (placeholder cho phát triển tiếp)

---

## 🛠️ Công nghệ

### Backend
| Thành phần | Phiên bản |
|-----------|---------|
| Java | 21 |
| Spring Boot | 3.1.5 |
| Spring Security | 6.1.5 |
| Spring Data JPA | 3.1.5 |
| JWT (jjwt) | 0.11.5 |
| MySQL Connector | Latest |
| BCrypt | Spring Security |

### Frontend
| Thành phần | Mô tả |
|-----------|------|
| HTML 5 | Markup |
| CSS 3 | Styling (Gradient, Flexbox, Animation) |
| JavaScript ES6+ | Interactivity |

### DevOps
| Thành phần | Mục đích |
|-----------|--------|
| Docker | Containerization |
| Docker Compose | Multi-container orchestration |
| Maven | Build automation |

---

## 📁 Cấu trúc dự án

```
xdpm_huongdoituong_nhom2/
├── src/
│   ├── main/
│   │   ├── java/com/example/bizflow/
│   │   │   ├── BizflowApplication.java          ← Main class
│   │   │   ├── controller/
│   │   │   │   └── AuthController.java          ← Login API
│   │   │   ├── service/
│   │   │   │   └── AuthService.java             ← Business logic
│   │   │   ├── entity/
│   │   │   │   └── User.java                    ← Database model
│   │   │   ├── repository/
│   │   │   │   └── UserRepository.java          ← DB query
│   │   │   ├── dto/
│   │   │   │   ├── LoginRequest.java            ← Input
│   │   │   │   └── LoginResponse.java           ← Output
│   │   │   ├── util/
│   │   │   │   ├── PasswordEncoder.java         ← BCrypt
│   │   │   │   └── JwtUtil.java                 ← JWT tokens
│   │   │   └── config/
│   │   │       └── CorsConfig.java              ← CORS setup
│   │   └── resources/
│   │       ├── application.yml                  ← Config
│   │       └── static/
│   │           ├── index.html                   ← Login page
│   │           ├── dashboard.html               ← After login
│   │           ├── script.js                    ← Login logic
│   │           ├── style.css                    ← Login styling
│   │           └── test.html                    ← API test page
│   └── test/
├── data/
│   └── init.sql                                 ← Database setup
├── pom.xml                                      ← Maven config
├── Dockerfile                                   ← Docker build
├── docker-compose.yml                           ← Docker Compose
├── setup.sh                                     ← Setup script
└── README.md                                    ← This file
```

---

## 🚀 Cài đặt và chạy

### Yêu cầu

- **Java**: 21+
- **Maven**: 3.8+
- **MySQL**: 8.0+ (hoặc Docker)
- **Node.js**: Optional (chỉ nếu cần)

### Option 1: Chạy trực tiếp (khuyến nghị cho phát triển)

#### Bước 1: Chuẩn bị MySQL

```bash
# Nếu MySQL đã chạy local
mysql -u root < data/init.sql

# Hoặc chạy MySQL qua Docker
docker run -d \
  --name bizflow-mysql \
  -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_DATABASE=bizflow_db \
  -v $(pwd)/data/init.sql:/docker-entrypoint-initdb.d/init.sql \
  mysql:8.0
```

#### Bước 2: Build project

```bash
mvn clean install -DskipTests
```

#### Bước 3: Chạy ứng dụng

```bash
java -jar target/bizflow-1.0.0.jar
```

**Ứng dụng chạy tại**: http://localhost:8080

---

### Option 2: Chạy qua Docker Compose

#### ⚠️ LẦN ĐẦU TIÊN hoặc khi cần RESET DATABASE:

```bash
# Xóa volume MySQL cũ (nếu có) để import database mới
docker compose down -v

# Build và chạy (database sẽ tự động import từ db/init/)
docker compose up --build -d

# Hoặc nếu đã build rồi
docker compose up -d
```

#### Các lần sau (không cần reset database):

```bash
# Chạy background
docker compose up -d

# View logs
docker compose logs -f backend

# Stop
docker compose down
```

> **LƯU Ý QUAN TRỌNG**: MySQL chỉ import file SQL từ `db/init/` **lần đầu tiên** tạo container. Nếu bạn pull code mới có database update, **phải chạy `docker compose down -v`** để xóa volume cũ trước khi chạy lại!

---

### Option 3: Dùng script tự động

```bash
# Linux/Mac
bash setup.sh

# Windows (PowerShell)
.\setup.ps1
```

---

## 📖 Hướng dẫn sử dụng

### 1. Truy cập ứng dụng

Mở browser và truy cập:
```
http://localhost:8080
```

### 2. Đăng nhập

Sử dụng tài khoản demo:

| Field | Giá trị |
|-------|--------|
| **Username** | admin |
| **Password** | admin123 |

Hoặc tài khoản thứ 2:

| Field | Giá trị |
|-------|--------|
| **Username** | test |
| **Password** | test123 |

### 3. Sau khi đăng nhập thành công

- ✅ Chuyển hướng tự động đến Dashboard
- ✅ Hiển thị thông tin người dùng
- ✅ Hiển thị Access Token
- ✅ Menu chức năng chính (placeholder)
- ✅ Nút Đăng xuất

### 4. Đăng xuất

Click nút "Đăng xuất" ở navbar để quay về trang login.

---

## 🔌 API Documentation

### Base URL
```
http://localhost:8080/api
```

### 1. Login Endpoint

**Endpoint:**
```http
POST /auth/login
```

**Headers:**
```
Content-Type: application/json
```

**Request Body:**
```json
{
  "username": "admin",
  "password": "admin123"
}
```

**Success Response (200 OK):**
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "role": "ADMIN",
  "userId": 1,
  "username": "admin"
}
```

**Error Response (401 Unauthorized):**
```json
{
  "error": "Tên đăng nhập hoặc mật khẩu không chính xác"
}
```

**cURL Example:**
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

### 2. Health Check

**Endpoint:**
```http
GET /auth/health
```

**Response:**
```json
{
  "status": "UP",
  "message": "Auth service is running"
}
```

---

## 🎯 Luồng đăng nhập

```
┌─────────────┐
│  Login Page │ (index.html)
├─────────────┘
│
└──> Nhập username + password
     ↓
     POST /api/auth/login
     ↓
┌─────────────────────────┐
│  Backend Processing     │
├─────────────────────────┤
│ 1. Check user exists    │
│ 2. Verify password      │
│ 3. Generate JWT tokens  │
│ 4. Return response      │
└─────────────────────────┘
     ↓
┌─────────────────────────┐
│  Frontend lưu tokens    │ (localStorage)
├─────────────────────────┤
│ - accessToken           │
│ - refreshToken          │
│ - userId                │
│ - username              │
│ - role                  │
└─────────────────────────┘
     ↓
┌─────────────┐
│ Dashboard   │ (dashboard.html)
├─────────────┘
│
└──> Hiển thị thông tin user
     Có thể logout
```

---

## 🔒 Bảo mật

### Password Encoding
- Sử dụng **BCrypt** từ Spring Security
- Mặc định: 10 rounds
- Mật khẩu luôn được hash, không lưu dạng plain text

### JWT Token
- **Algorithm**: HS256 (HMAC with SHA-256)
- **Access Token Expiration**: 1 giờ (3600000 ms)
- **Refresh Token Expiration**: 24 giờ (86400000 ms)
- **Secret Key**: Cấu hình trong `application.yml`

### CORS
- Cho phép tất cả origins (*)
- Cho phép GET, POST, PUT, DELETE, OPTIONS
- Cho phép tất cả headers
- Max age: 3600 giây

### HTTPS
- Khuyến khích sử dụng HTTPS trong production
- Hiện tại: HTTP cho development

---

## 🐛 Troubleshooting

### Vấn đề 1: Connection refused to MySQL

**Lỗi:**
```
Could not connect to database server: java.sql.SQLException: Cannot get JDBC Connection
```

**Giải pháp:**

```bash
# Kiểm tra MySQL chạy chưa
mysql -u root -e "SELECT 1"

# Nếu lỗi, restart MySQL
brew services restart mysql

# Nếu chưa cài, cài qua Homebrew
brew install mysql
brew services start mysql

# Chạy init.sql
mysql -u root < data/init.sql
```

### Vấn đề 2: Port 8080 đã được sử dụng

**Lỗi:**
```
Address already in use
```

**Giải pháp:**

```bash
# Tìm process dùng port 8080
lsof -i :8080

# Kill process
kill -9 <PID>

# Hoặc thay đổi port trong application.yml
server:
  port: 8081
```

### Vấn đề 3: Build lỗi

**Lỗi:**
```
[ERROR] COMPILATION ERROR
```

**Giải pháp:**

```bash
# Clear cache và rebuild
mvn clean install -DskipTests

# Hoặc
rm -rf target/ && mvn clean install -DskipTests
```

### Vấn đề 4: Cannot connect to Docker daemon

**Lỗi:**
```
Cannot connect to the Docker daemon at unix:///var/run/docker.sock
```

**Giải pháp:**

```bash
# Start Docker Desktop (macOS)
open /Applications/Docker.app

# Hoặc chạy local mà không dùng Docker
java -jar target/bizflow-1.0.0.jar
```

### Vấn đề 5: Đã có user 'admin' rồi khi chạy init.sql

**Lỗi:**
```
ERROR 1062 (23000) at line 167: Duplicate entry 'admin'
```

**Giải pháp:**

```bash
# Bỏ qua, database đã có rồi. Chạy app bình thường
java -jar target/bizflow-1.0.0.jar

# Nếu muốn reset, drop database và tạo lại
mysql -u root -e "DROP DATABASE IF EXISTS bizflow_db; DROP USER IF EXISTS 'bizflow'@'localhost'; CREATE DATABASE bizflow_db;"
mysql -u root < data/init.sql
```

---

## 📊 Database Schema

### Bảng: users

| Column | Type | Constraint | Mô tả |
|--------|------|-----------|------|
| id | BIGINT | PK, AUTO_INCREMENT | User ID |
| username | VARCHAR(50) | NOT NULL, UNIQUE | Tên đăng nhập |
| password | VARCHAR(255) | NOT NULL | Mật khẩu (hash) |
| email | VARCHAR(100) | NOT NULL, UNIQUE | Email |
| full_name | VARCHAR(100) | | Tên đầy đủ |
| phone_number | VARCHAR(20) | | Số điện thoại |
| role | VARCHAR(20) | NOT NULL | ADMIN, EMPLOYEE, ... |
| enabled | BOOLEAN | NOT NULL | Tài khoản hoạt động |
| created_at | TIMESTAMP | DEFAULT NOW() | Ngày tạo |
| updated_at | TIMESTAMP | ON UPDATE NOW() | Ngày cập nhật |
| note | TEXT | | Ghi chú |

### Dữ liệu mẫu

```sql
-- Admin account
Username: admin
Password: admin123 (hashed with BCrypt)
Role: ADMIN

-- Test account
Username: test
Password: test123 (hashed with BCrypt)
Role: EMPLOYEE
```

---

## ⚙️ Cấu hình

### application.yml

```yaml
spring:
  application:
    name: bizflow
  datasource:
    url: jdbc:mysql://localhost:3306/bizflow_db
    username: root
    password: 
    driver-class-name: com.mysql.cj.jdbc.Driver
  jpa:
    hibernate:
      ddl-auto: validate

server:
  port: 8080

app:
  jwt:
    secret: my-secret-key-for-jwt-token-generation-and-verification
    access-token-expiration: 3600000
    refresh-token-expiration: 86400000
```

### Docker Compose

```yaml
services:
  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: bizflow_db
    ports:
      - "3306:3306"

  app:
    build:
      context: .
      dockerfile: Dockerfile
    environment:
      SPRING_DATASOURCE_URL: jdbc:mysql://mysql:3306/bizflow_db
    ports:
      - "8080:8080"
    depends_on:
      - mysql
```

---

## 📈 Bước tiếp theo

### Phiên bản v1.1.0 (Proposed)
- [ ] Implement Refresh Token API
- [ ] Implement Quên mật khẩu
- [ ] Implement Tạo tài khoản mới (Register)
- [ ] Thêm Email validation
- [ ] Thêm 2FA (Two-Factor Authentication)
- [ ] Implement Role-based access control (RBAC)

### Phiên bản v1.2.0+ (Proposed)
- [ ] Quản lý khách hàng
- [ ] Quản lý sản phẩm
- [ ] Quản lý tồn kho
- [ ] Quản lý đơn hàng
- [ ] Quản lý công nợ
- [ ] Báo cáo & thống kê
- [ ] Audit logging
- [ ] Notification system

---

## 📞 Liên hệ & Hỗ trợ

**Nhóm phát triển**: Nhóm 2 - XDHTHDT

**Repository**: [GitHub](https://github.com/tutl0371/xdpm_huongdoituong_nhom2)

Nếu có vấn đề, vui lòng:
1. Kiểm tra lại troubleshooting section
2. Xem logs trong `/tmp/bizflow.log`
3. Mở issue trên GitHub

---

## 📄 License

MIT License - Tự do sử dụng cho mục đích học tập và thương mại

---

**Cập nhật gần nhất**: December 17, 2025

**Phiên bản hiện tại**: 1.0.0 (Login Feature Complete)

✨ **Chúc bạn sử dụng BizFlow vui vẻ!** ✨

echo "# hotfix" >> README.md

