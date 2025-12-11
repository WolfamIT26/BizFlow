/*
 * File: CustomerRepository.java
 * Mô tả: Repository tương tác với bảng Customer trong database
 * Chức năng: Truy vấn, lưu, cập nhật, xóa thông tin khách hàng,
 *            tìm kiếm theo tên, số điện thoại, địa chỉ
 */

// TODO: Tạo interface CustomerRepository extends JpaRepository<Customer, Long>
// - Method findByNameContainingIgnoreCase(String keyword):
//   + Tìm kiếm khách hàng theo tên (không phân biệt hoa thường)
//   + Trả về Page<Customer> hoặc List<Customer>
// - Method findByPhoneNumber(String phoneNumber):
//   + Tìm kiếm theo số điện thoại
//   + Trả về Optional<Customer>
// - Method findByEmailContainingIgnoreCase(String email):
//   + Tìm kiếm theo email
//   + Trả về Optional<Customer>
// - Method findByAddressContainingIgnoreCase(String address):
//   + Tìm kiếm theo địa chỉ
//   + Trả về List<Customer>
// - Method findByCustomerType(String type):
//   + Truy vấn theo loại khách hàng (cá nhân/doanh nghiệp)
//   + Trả về List<Customer>

