/*
 * File: CustomerService.java
 * Mô tả: Service xử lý logic liên quan đến khách hàng
 * Chức năng: Quản lý thông tin khách hàng (CRUD), quản lý công nợ,
 *            tính tổng công nợ, kiểm tra khách hàng nợ quá hạn,
 *            ghi nhận lịch sử giao dịch khách hàng
 */

// TODO: Tạo class CustomerService với annotation @Service, @Transactional
// - Inject CustomerRepository, DebtRepository, CustomerMapper
// - Method createCustomer(CustomerDTO dto):
//   + Validate dữ liệu (tên, số điện thoại, v.v.)
//   + Map CustomerDTO -> Customer entity
//   + Lưu vào DB
//   + Trả về customer
// - Method searchCustomers(String keyword, int page):
//   + Truy vấn theo tên hoặc số điện thoại
//   + Phân trang
//   + Trả về danh sách
// - Method getCustomerById(Long id):
//   + Truy vấn customer theo id
//   + Load thông tin công nợ
//   + Trả về customer
// - Method updateCustomer(Long id, CustomerDTO dto):
//   + Lấy customer từ DB
//   + Cập nhật các field
//   + Lưu vào DB
//   + Trả về customer
// - Method getCustomerDebt(Long customerId):
//   + Truy vấn Debt theo customer id
//   + Tính tổng công nợ
//   + Trả về tổng nợ và chi tiết
// - Method addDebt(Long customerId, BigDecimal amount, Date dueDate):
//   + Tạo Debt object
//   + Lưu vào DB
//   + Trả về debt
// - Method payDebt(Long debtId, BigDecimal amountPaid):
//   + Lấy debt từ DB
//   + Cập nhật số tiền đã trả
//   + Nếu nợ = 0, đánh dấu PAID
//   + Lưu vào DB
//   + Trả về debt
// - Method getCustomerTransactions(Long customerId, int page):
//   + Truy vấn Order theo customer id
//   + Phân trang
//   + Trả về danh sách

