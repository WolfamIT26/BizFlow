/*
 * File: AuthController.java
 * Mô tả: Controller xử lý tất cả yêu cầu liên quan đến xác thực
 * Chức năng: Xử lý đăng nhập, đăng xuất, làm mới token (refresh token),
 *            trả về JWT token sau khi xác thực thành công
 */

// TODO: Tạo class AuthController với annotation @RestController, @RequestMapping("/api/auth")
// - Inject AuthService
// - Method login(LoginRequest request):
//   + POST /api/auth/login
//   + Gọi authService.authenticate(username, password)
//   + Trả về token, refreshToken, expiresIn
// - Method refreshToken(String oldToken):
//   + POST /api/auth/refresh-token
//   + Gọi authService.refreshToken(oldToken)
//   + Trả về token mới
// - Method logout():
//   + POST /api/auth/logout
//   + Xóa token từ session (nếu cần)
//   + Trả về thông báo success

