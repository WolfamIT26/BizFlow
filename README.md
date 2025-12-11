# 🚀 BizFlow - Hệ Thống Quản Lý Bán Hàng và Tồn Kho

## 📋 Mô tả dự án

BizFlow là hệ thống quản lý bán hàng và tồn kho được xây dựng bằng **Spring Boot**, giúp các cửa hàng quản lý:
- ✅ Sản phẩm và giá
- ✅ Tồn kho (nhập/xuất)
- ✅ Đơn hàng và hóa đơn
- ✅ Khách hàng và công nợ
- ✅ Nhân viên và phân quyền
- ✅ Báo cáo doanh thu

## 🛠️ Công nghệ sử dụng

- **Backend**: Spring Boot 3.1.5
- **Database**: MySQL 8.0
- **Security**: Spring Security + JWT
- **API Documentation**: Swagger/OpenAPI
- **Build Tool**: Maven
- **Java Version**: 17

## 📦 Cài đặt

### Yêu cầu hệ thống:
- Java JDK 17+
- Maven 3.6+
- MySQL 8.0+

### Bước 1: Clone dự án
```bash
git clone https://github.com/tutl0371/xdpm_huongdoituong_nhom2.git
cd xdpm_huongdoituong_nhom2
```

### Bước 2: Tạo database
```bash
mysql -u root -p < data/init.sql
```

### Bước 3: Cấu hình database
Sửa file `src/main/resources/application.properties`:
```properties
spring.datasource.url=jdbc:mysql://localhost:3306/bizflow_db
spring.datasource.username=root
spring.datasource.password=your_password
```

### Bước 4: Build dự án
```bash
mvn clean install
```

### Bước 5: Chạy ứng dụng
```bash
mvn spring-boot:run
```

Ứng dụng sẽ chạy tại: `http://localhost:8080/api`

## 📚 API Documentation

Swagger UI: `http://localhost:8080/api/swagger-ui.html`

API Docs: `http://localhost:8080/api/api-docs`

## 🔑 Tài khoản mặc định

- **Username**: `admin`
- **Password**: `admin123`
- **Role**: ADMIN

## 🏗️ Cấu trúc dự án

```
src/main/java/com/example/bizflow/
├── config/          # Cấu hình Spring (Security, CORS, Swagger)
├── controllers/     # REST API Controllers
├── services/        # Business Logic
├── repositories/    # Data Access Layer (JPA)
├── entities/        # Database Entities
├── dto/             # Data Transfer Objects
├── enums/           # Enums (UserRole, OrderStatus, v.v.)
├── exceptions/      # Custom Exceptions
├── utils/           # Utilities (JWT, Date, Response)
├── mapper/          # Entity <-> DTO Mappers
└── payload/         # API Response Models
```

## 🐳 Chạy với Docker (Optional)

```bash
docker-compose up -d
```

## 🧪 Chạy tests

```bash
mvn test
```

## 📝 License

MIT License

## 👥 Tác giả

Nhóm 2 - Phát triển ứng dụng hướng đối tượng
