/*
 * File: CustomerController.java
 * Mô tả: Controller xử lý tất cả yêu cầu liên quan đến khách hàng
 * Chức năng: Quản lý thông tin khách hàng (thêm, sửa, xóa, xem danh sách),
 *            quản lý công nợ khách hàng, lịch sử giao dịch
 */

// TODO: Tạo class CustomerController với annotation @RestController, @RequestMapping("/api/customers")
// - Inject CustomerService
// - Method createCustomer(@RequestBody CustomerDTO dto):
//   + POST /api/customers
//   + Gọi customerService.createCustomer(dto)
//   + Trả về customer object mới
// - Method getCustomers(@RequestParam keyword, @RequestParam page):
//   + GET /api/customers
//   + Gọi customerService.searchCustomers(keyword, page)
//   + Trả về danh sách khách hàng phân trang
// - Method getCustomerById(@PathVariable id):
//   + GET /api/customers/{id}
//   + Gọi customerService.getCustomerById(id)
//   + Trả về thông tin khách hàng
// - Method updateCustomer(@PathVariable id, @RequestBody CustomerDTO dto):
//   + PUT /api/customers/{id}
//   + Gọi customerService.updateCustomer(id, dto)
//   + Trả về customer được cập nhật
// - Method getCustomerDebt(@PathVariable id):
//   + GET /api/customers/{id}/debt
//   + Gọi customerService.getCustomerDebt(id)
//   + Trả về tổng công nợ và chi tiết
// - Method getCustomerTransactions(@PathVariable id, @RequestParam page):
//   + GET /api/customers/{id}/transactions
//   + Gọi customerService.getCustomerTransactions(id, page)
//   + Trả về lịch sử giao dịch

