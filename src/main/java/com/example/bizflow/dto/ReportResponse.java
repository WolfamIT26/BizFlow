/*
 * File: ReportResponse.java
 * Mô tả: DTO cho response báo cáo/dashboard
 * Chức năng: Chứa dữ liệu báo cáo (tổng doanh thu, số đơn, số khách hàng, sản phẩm bán chạy),
 *            trả về cho client để hiển thị trên dashboard
 */

// TODO: Tạo class ReportResponse
// - Fields:
//   + BigDecimal totalRevenue (tổng doanh thu)
//   + long totalOrders (tổng số đơn hàng)
//   + long totalCustomers (tổng số khách hàng)
//   + long totalProducts (tổng số sản phẩm)
//   + BigDecimal totalDebt (tổng công nợ chưa thanh toán)
//   + BigDecimal inventoryValue (giá trị tồn kho)
//   + List<TopProductDTO> topProducts (sản phẩm bán chạy)
//   + List<OrderByMonth> ordersByMonth (đơn hàng theo tháng)
// - Inner class TopProductDTO:
//   + Long productId
//   + String productName
//   + int totalQuantitySold (tổng số bán)
//   + BigDecimal totalAmount (tổng tiền)
// - Inner class OrderByMonth:
//   + String month (năm-tháng)
//   + int count (số đơn)
//   + BigDecimal amount (tổng tiền)
// - Constructors: No-arg, Full-arg
// - Getters/Setters

