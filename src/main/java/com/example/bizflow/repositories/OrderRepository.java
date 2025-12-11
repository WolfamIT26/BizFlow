/*
 * File: OrderRepository.java
 * Mô tả: Repository tương tác với bảng Order trong database
 * Chức năng: Truy vấn, lưu, cập nhật, xóa đơn hàng,
 *            tìm kiếm theo trạng thái, khách hàng, thời gian
 */

// TODO: Tạo interface OrderRepository extends JpaRepository<Order, Long>
// - Method findByStatus(OrderStatus status):
//   + Truy vấn Order theo trạng thái (PENDING, PAID, DEBT)
//   + Trả về List<Order> hoặc Page<Order>
// - Method findByCustomerId(Long customerId):
//   + Truy vấn đơn hàng của khách hàng
//   + Trả về List<Order> hoặc Page<Order>
// - Method findByCreatedAtBetween(Date startDate, Date endDate):
//   + Truy vấn đơn hàng trong khoảng thời gian
//   + Trả về List<Order>
// - Method findByEmployeeId(Long employeeId):
//   + Truy vấn đơn hàng của nhân viên
//   + Trả về List<Order>
// - Method findByStatusAndCreatedAtBetween(OrderStatus status, Date startDate, Date endDate):
//   + Truy vấn kết hợp theo trạng thái và thời gian
//   + Trả về List<Order>

