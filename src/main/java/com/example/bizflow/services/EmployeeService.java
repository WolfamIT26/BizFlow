/*
 * File: EmployeeService.java
 * Mô tả: Service xử lý logic liên quan đến nhân viên
 * Chức năng: Tạo tài khoản nhân viên, cập nhật thông tin,
 *            xóa nhân viên, phân quyền nhân viên (role),
 *            kiểm tra quyền truy cập
 */

// TODO: Tạo class EmployeeService với annotation @Service
// - Inject UserRepository, PasswordEncoder
// - Method createEmployee(User user):
//   + Validate dữ liệu (username, email, v.v.)
//   + Kiểm tra username/email chưa tồn tại
//   + Mã hóa password bằng PasswordEncoder
//   + Set role = EMPLOYEE
//   + Lưu vào DB
//   + Trả về user
// - Method createAdmin(User user):
//   + Tương tự createEmployee
//   + Set role = ADMIN thay vì EMPLOYEE
// - Method getEmployees(int page):
//   + Truy vấn User có role = EMPLOYEE
//   + Phân trang
//   + Trả về danh sách
// - Method getEmployeeById(Long id):
//   + Truy vấn User theo id
//   + Throw ResourceNotFoundException nếu không tìm thấy
//   + Trả về user
// - Method updateEmployee(Long id, User user):
//   + Lấy user từ DB
//   + Cập nhật các field (tên, email, số điện thoại, v.v.)
//   + Nếu password được gửi, mã hóa password mới
//   + Lưu vào DB
//   + Trả về user
// - Method deleteEmployee(Long id):
//   + Lấy user từ DB
//   + Kiểm tra có đơn hàng chưa hoàn thành không
//   + Xóa user
//   + Trả về thông báo
// - Method changePassword(Long id, String oldPassword, String newPassword):
//   + Lấy user từ DB
//   + Xác thực oldPassword
//   + Mã hóa newPassword
//   + Lưu vào DB
//   + Trả về thông báo success

