# BizFlow - Hệ thống quản lý bán hàng và tồn kho (Microservices)

## 📋 Mô tả
BizFlow là hệ thống quản lý bán hàng và tồn kho theo kiến trúc **microservices**. Mỗi service chạy độc lập, có **schema database riêng**, giao tiếp qua **API Gateway**, hỗ trợ **message queue**, **cache**, **monitoring** và **ETL**.

## 🧩 Danh sách microservices
**Core (9 services):**
- `auth-service` (8081) – Xác thực, phân quyền, JWT
- `user-service` (8084) – Quản lý nhân viên
- `product-service` (8082) – Sản phẩm, danh mục
- `inventory-service` (8085) – Tồn kho, nhập/xuất
- `order-service` (8083) – Đơn hàng, giỏ hàng
- `customer-service` (8086) – Khách hàng, công nợ
- `promotion-service` (8087) – Khuyến mãi
- `payment-service` (8088) – Thanh toán, hóa đơn
- `report-service` (8089) – Báo cáo thống kê

**Optional:**
- `ai_service` (5000) – AI gợi ý
- `worker-service` (8092) – Background jobs
- `fcm-service` (8091) – Firebase Cloud Messaging (skeleton)

## 🛠️ Công nghệ
- **Backend:** Spring Boot 3.1.5, Java 21
- **Frontend:** Nginx + HTML/CSS/JS
- **Database:** MySQL 8 (1 container, nhiều schema)
- **Cache:** Redis
- **Message Queue:** RabbitMQ + Kafka
- **API Gateway:** Spring Cloud Gateway + Kong (optional layer)
- **Monitoring:** Prometheus + Grafana
- **ETL/Orchestration:** Apache NiFi
- **AI Service:** FastAPI (Python)
- **DevOps:** Docker, Docker Compose

## 📁 Cấu trúc dự án
```
BizFlow/
├── auth-service/
├── user-service/
├── product-service/
├── inventory-service/
├── order-service/
├── customer-service/
├── promotion-service/
├── payment-service/
├── report-service/
├── worker-service/
├── fcm-service/
├── gateway/
├── ai_service/
├── FE/
├── db/init/
├── kong/
├── prometheus/
└── docker-compose.yml
```

## 🚀 Cài đặt và chạy
### 1) Lần đầu hoặc khi reset database
```bash
docker compose down -v
docker compose up --build -d
```

### 2) Các lần sau
```bash
docker compose up -d
```

## 🔌 Các cổng dịch vụ
- Gateway: `8000`
- Auth: `8081`
- Product: `8082`
- Order: `8083`
- User: `8084`
- Inventory: `8085`
- Customer: `8086`
- Promotion: `8087`
- Payment: `8088`
- Report: `8089`
- AI: `5000`
- FCM: `8091`
- Worker: `8092`
- PHPMyAdmin: `8080`
- NiFi: `8090`
- Kong Proxy/Admin: `8010/8011`
- Prometheus: `9090`
- Grafana: `3001`

## ✅ Lưu ý
- MySQL tự tạo schemas qua `db/init/001_create_schemas.sql`
- Mỗi service dùng schema riêng trong MySQL
- Gateway route qua `/api/*`

