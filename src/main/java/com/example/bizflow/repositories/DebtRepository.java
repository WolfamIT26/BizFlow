/*
 * File: DebtRepository.java
 * Mô tả: Repository tương tác với bảng Debt trong database
 * Chức năng: Truy vấn, lưu, cập nhật, xóa thông tin công nợ,
 *            tìm kiếm theo khách hàng, trạng thái, ngày tháng
 */

// TODO: Tạo interface DebtRepository extends JpaRepository<Debt, Long>
// - Method findByCustomerId(Long customerId):
//   + Truy vấn công nợ của khách hàng
//   + Trả về List<Debt> hoặc Page<Debt>
// - Method findByStatus(String status):
//   + Truy vấn theo trạng thái (nợ/đã thanh toán)
//   + Trả về List<Debt>
// - Method findByCustomerIdAndStatus(Long customerId, String status):
//   + Truy vấn công nợ khách hàng theo trạng thái
//   + Trả về List<Debt>
// - @Query("SELECT SUM(d.amount) FROM Debt d WHERE d.customer.id = :customerId AND d.status = 'UNPAID'"):
//   + Tính tổng công nợ chưa thanh toán
//   + Trả về BigDecimal
// - Method findByDueDateLessThanAndStatus(Date dueDate, String status):
//   + Tìm công nợ quá hạn thanh toán
//   + Trả về List<Debt>

