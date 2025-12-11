/*
 * File: JwtUtil.java
 * Mô tả: Utility class xử lý JWT (JSON Web Token)
 * Chức năng: Tạo JWT token, xác thực JWT token, lấy thông tin từ token,
 *            kiểm tra token hết hạn, refresh token
 */

// TODO: Tạo class JwtUtil với annotation @Component hoặc @Service
// - Inject @Value("${jwt.secret}") String jwtSecret
// - Inject @Value("${jwt.expiration}") long jwtExpiration (milliseconds)
// - Method generateToken(User user):
//   + Tạo Claims với userId, username, role
//   + Set expiration time = now + jwtExpiration
//   + Ký token bằng jwtSecret
//   + Trả về token string
// - Method validateToken(String token):
//   + Parse token bằng jwtSecret
//   + Kiểm tra token hết hạn chưa
//   + Trả về true nếu hợp lệ, throw exception nếu không hợp lệ
// - Method getUserIdFromToken(String token):
//   + Parse token
//   + Lấy claim userId
//   + Trả về userId
// - Method getUsernameFromToken(String token):
//   + Parse token
//   + Lấy claim username
//   + Trả về username
// - Method getRoleFromToken(String token):
//   + Parse token
//   + Lấy claim role
//   + Trả về role
// - Method isTokenExpired(String token):
//   + Kiểm tra expiration date < now
//   + Trả về true/false

