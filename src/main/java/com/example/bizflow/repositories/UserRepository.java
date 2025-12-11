/*
 * File: UserRepository.java
 * Mô tả: Repository tương tác với bảng User trong database
 * Chức năng: Truy vấn, lưu, cập nhật, xóa người dùng,
 *            tìm kiếm user theo username, email, role
 */

// TODO: Tạo interface UserRepository extends JpaRepository<User, Long>
// - Method findByUsername(String username):
//   + Truy vấn User theo username
//   + Trả về Optional<User>
// - Method findByEmail(String email):
//   + Truy vấn User theo email
//   + Trả về Optional<User>
// - Method findByRole(UserRole role):
//   + Truy vấn tất cả User có role nhất định
//   + Trả về List<User>
// - Method findByUsernameContainingIgnoreCase(String keyword):
//   + Tìm kiếm theo tên (không phân biệt hoa thường)
//   + Trả về List<User>
// - Method existsByUsername(String username):
//   + Kiểm tra username có tồn tại không
//   + Trả về boolean
// - Method existsByEmail(String email):
//   + Kiểm tra email có tồn tại không
//   + Trả về boolean

