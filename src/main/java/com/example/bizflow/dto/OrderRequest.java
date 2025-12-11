/*
 * File: OrderRequest.java
 * Mô tả: DTO cho request tạo đơn hàng mới
 * Chức năng: Nhận dữ liệu từ client (khách hàng, danh sách sản phẩm, số lượng, giá),
 *            truyền sang OrderService để tạo đơn
 */

// TODO: Tạo class OrderRequest
// - Fields:
//   + Long customerId (id khách hàng)
//   + List<OrderItemRequest> items (danh sách sản phẩm)
//   + BigDecimal discountAmount (tổng chiết khấu, nếu có)
//   + String notes (ghi chú đơn hàng)
// - Inner class OrderItemRequest:
//   + Long productId (id sản phẩm)
//   + int quantity (số lượng)
//   + BigDecimal price (giá bán, nếu ghi đè)
//   + BigDecimal discount (chiết khấu, nếu có)
// - Constructors: No-arg, Full-arg
// - Getters/Setters

