/*
 * File: OrderController.java
 * Mô tả: Controller xử lý tất cả yêu cầu liên quan đến đơn hàng
 * Chức năng: Tạo đơn hàng mới, xem danh sách đơn hàng, xem chi tiết đơn hàng,
 *            cập nhật trạng thái đơn hàng, in/xuất hóa đơn
 */

// TODO: Tạo class OrderController với annotation @RestController, @RequestMapping("/api/orders")
// - Inject OrderService
// - Method createOrder(OrderRequest request):
//   + POST /api/orders
//   + Gọi orderService.createOrder(request)
//   + Trả về order object mới được tạo
// - Method getOrders(@RequestParam status, @RequestParam page):
//   + GET /api/orders
//   + Gọi orderService.getOrders(status, page)
//   + Trả về danh sách order phân trang
// - Method getOrderById(@PathVariable id):
//   + GET /api/orders/{id}
//   + Gọi orderService.getOrderById(id)
//   + Trả về chi tiết order kèm danh sách OrderItem
// - Method updateOrderStatus(@PathVariable id, @RequestBody status):
//   + PUT /api/orders/{id}/status
//   + Gọi orderService.updateOrderStatus(id, status)
//   + Trả về order được cập nhật
// - Method exportInvoice(@PathVariable id):
//   + GET /api/orders/{id}/invoice
//   + Gọi orderService.generateInvoice(id)
//   + Trả về file PDF hoặc Excel

