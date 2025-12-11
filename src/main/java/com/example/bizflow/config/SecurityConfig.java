/*
 * File: SecurityConfig.java
 * Mô tả: Cấu hình bảo mật hệ thống
 * Chức năng: Cấu hình JWT authentication, phân quyền người dùng (ADMIN, OWNER, EMPLOYEE),
 *            cấu hình Spring Security, xác thực yêu cầu HTTP
 */

// TODO: Tạo class SecurityConfig với annotation @Configuration
// - Extends WebSecurityConfigurerAdapter (hoặc implement SecurityFilterChain)
// - Tạo bean JwtAuthenticationFilter để xác thực JWT từ header
// - Cấu hình HttpSecurity:
//   + Disable CSRF (vì dùng JWT)
//   + Cho phép /auth/** không cần xác thực
//   + Yêu cầu xác thực cho các endpoint khác
//   + Cấu hình phân quyền (hasRole "ADMIN", "OWNER", "EMPLOYEE")
//   + Thêm JwtAuthenticationFilter trước UsernamePasswordAuthenticationFilter
// - Cấu hình AuthenticationManager để xác thực username/password

