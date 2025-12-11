/*
 * File: OrderService.java
 * Mô tả: Service xử lý logic liên quan đến đơn hàng
 * Chức năng: Tạo đơn hàng mới, tính toán giá, trừ tồn kho,
 *            ghi công nợ cho khách hàng, cập nhật trạng thái đơn hàng,
 *            tính chiết khấu, xử lý thanh toán
 */

// TODO: Tạo class OrderService với annotation @Service, @Transactional
// - Inject OrderRepository, OrderItemRepository, ProductService, InventoryService, CustomerService, DebtService
// - Method createOrder(OrderRequest request):
//   + Tạo Order object mới, ghi nhận ngày tạo, nhân viên, khách hàng
//   + Lặp danh sách OrderItem trong request:
//     * Lấy thông tin sản phẩm từ ProductService
//     * Kiểm tra tồn kho có đủ không
//     * Tính tổng tiền, chiết khấu
//     * Trừ tồn kho qua InventoryService
//   + Ghi công nợ nếu khách hàng trả góp
//   + Lưu Order và danh sách OrderItem vào DB
//   + Trả về order object
// - Method getOrders(String status, int page):
//   + Truy vấn Order theo status (PENDING, PAID, DEBT)
//   + Phân trang
//   + Trả về danh sách
// - Method getOrderById(Long id):
//   + Truy vấn Order theo id
//   + Load danh sách OrderItem
//   + Trả về order object
// - Method updateOrderStatus(Long id, OrderStatus status):
//   + Lấy order từ DB
//   + Cập nhật status
//   + Nếu status = PAID, xóa công nợ
//   + Lưu vào DB
//   + Trả về order
// - Method generateInvoice(Long id):
//   + Lấy order từ DB
//   + Tạo file PDF/Excel chứa thông tin order
//   + Trả về file

