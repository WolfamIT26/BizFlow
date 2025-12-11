/*
 * File: AuthService.java
 * Mô tả: Service xử lý logic xác thực và JWT
 * Chức năng: Xác thực người dùng (kiểm tra username/password),
 *            tạo JWT token, xác thực JWT token, làm mới token,
 *            lấy thông tin user từ token
 */

// TODO: Tạo class AuthService với annotation @Service
// - Inject UserRepository, PasswordEncoder, JwtUtil
// - Method authenticate(String username, String password):
//   + Tìm user trong DB theo username
//   + So sánh password đã mã hóa
//   + Nếu đúng, gọi generateToken(user) để tạo JWT
//   + Trả về token, refreshToken, expiresIn
// - Method generateToken(User user):
//   + Gọi JwtUtil.generateToken(user) để tạo JWT
//   + Token chứa: userId, username, role, expiresAt
//   + Trả về token string
// - Method validateToken(String token):
//   + Gọi JwtUtil.validateToken(token)
//   + Kiểm tra token hợp lệ, chưa hết hạn
//   + Trả về true/false
// - Method refreshToken(String oldToken):
//   + Xác thực oldToken
//   + Lấy user từ oldToken
//   + Tạo token mới
//   + Trả về token mới
// - Method getUserFromToken(String token):
//   + Gọi JwtUtil.getUserFromToken(token)
//   + Lấy userId từ token
//   + Truy vấn User từ DB
//   + Trả về user object

