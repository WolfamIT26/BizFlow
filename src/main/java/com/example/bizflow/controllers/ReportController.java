/*
 * File: ReportController.java
 * Mô tả: Controller xử lý tất cả yêu cầu liên quan đến báo cáo
 * Chức năng: Xem dashboard (tổng doanh thu, số đơn hàng, khách hàng),
 *            thống kê sản phẩm bán chạy, báo cáo doanh số theo thời gian,
 *            báo cáo công nợ, báo cáo tồn kho
 */

// TODO: Tạo class ReportController với annotation @RestController, @RequestMapping("/api/reports")
// - Inject ReportService
// - Method getDashboard():
//   + GET /api/reports/dashboard
//   + Gọi reportService.getDashboardData()
//   + Trả về: tổng doanh thu, số đơn hàng, số khách hàng, số sản phẩm tồn kho
// - Method getTopProducts(@RequestParam limit, @RequestParam startDate, @RequestParam endDate):
//   + GET /api/reports/top-products
//   + Gọi reportService.getTopProducts(limit, startDate, endDate)
//   + Trả về danh sách sản phẩm bán chạy nhất
// - Method getRevenueBySalesman(@RequestParam startDate, @RequestParam endDate):
//   + GET /api/reports/revenue-by-salesman
//   + Gọi reportService.getRevenueBySalesman(startDate, endDate)
//   + Trả về doanh số theo từng nhân viên bán hàng
// - Method getDebtReport():
//   + GET /api/reports/debt
//   + Gọi reportService.getDebtReport()
//   + Trả về tổng công nợ, công nợ nợ quá hạn
// - Method getInventoryReport():
//   + GET /api/reports/inventory
//   + Gọi reportService.getInventoryReport()
//   + Trả về giá trị tồn kho, các sản phẩm tồn kho ít

