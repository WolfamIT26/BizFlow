/*
 * File: User.java
 * Mô tả: Entity ánh xạ bảng User trong database
 * Chức năng: Lưu thông tin người dùng (username, password, email, họ tên, số điện thoại),
 *            lưu role (ADMIN, OWNER, EMPLOYEE), trạng thái tài khoản
 */

// TODO: Tạo class User với annotation @Entity, @Table(name = "users")
// - Fields:
//   + @Id @GeneratedValue Long id
//   + @Column(unique = true, nullable = false) String username
//   + @Column(nullable = false) String password (mã hóa BCrypt)
//   + @Column(unique = true, nullable = false) String email
//   + String fullName (họ tên)
//   + String phoneNumber (điện thoại)
//   + @Enumerated(EnumType.STRING) UserRole role (ADMIN, OWNER, EMPLOYEE)
//   + @Column(nullable = false) boolean enabled (đã kích hoạt)
//   + @Temporal(TemporalType.TIMESTAMP) Date createdAt (ngày tạo)
//   + @Temporal(TemporalType.TIMESTAMP) Date updatedAt (ngày cập nhật)
//   + String note (ghi chú)
// - Constructors: No-arg, Full-arg
// - Getters/Setters

