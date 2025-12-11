/*
 * File: CorsConfig.java
 * Mô tả: Cấu hình CORS (Cross-Origin Resource Sharing)
 * Chức năng: Cho phép frontend gọi API từ domain khác, cấu hình các header cho phép
 */

// TODO: Tạo class CorsConfig với annotation @Configuration
// - Override method addCorsMappings(CorsRegistry registry)
// - Cấu hình CORS:
//   + allowedOrigins: Cho phép domain nào (ví dụ: "http://localhost:3000", "http://localhost:8080")
//   + allowedMethods: Cho phép HTTP methods (GET, POST, PUT, DELETE, OPTIONS)
//   + allowedHeaders: Cho phép headers (Content-Type, Authorization, v.v.)
//   + allowCredentials: true để cho phép cookie
//   + maxAge: Thời gian cache CORS response (3600 giây)
// - Áp dụng cho tất cả endpoint ("/api/**")

