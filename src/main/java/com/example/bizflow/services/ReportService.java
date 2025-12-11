/*
 * File: ReportService.java
 * Mô tả: Service xử lý logic liên quan đến báo cáo
 * Chức năng: Tính toán doanh thu, thống kê sản phẩm bán chạy,
 *            báo cáo doanh số theo thời gian, báo cáo công nợ,
 *            tạo dữ liệu cho dashboard
 */

// TODO: Tạo class ReportService với annotation @Service
// - Inject OrderRepository, OrderItemRepository, CustomerRepository, InventoryRepository, DebtRepository
// - Method getDashboardData():
//   + Tính tổng doanh thu (sum Order tổng tiền)
//   + Đếm số order
//   + Đếm số khách hàng
//   + Trả về object chứa tất cả dữ liệu
// - Method getTopProducts(int limit, Date startDate, Date endDate):
//   + Truy vấn OrderItem trong khoảng thời gian
//   + Group by product, sum quantity
//   + Sort giảm dần
//   + Limit kết quả
//   + Trả về danh sách
// - Method getRevenueBySalesman(Date startDate, Date endDate):
//   + Truy vấn Order theo ngày tạo
//   + Group by salesman (employee), sum tổng tiền
//   + Trả về danh sách
// - Method getDebtReport():
//   + Truy vấn Debt chưa thanh toán
//   + Tính tổng nợ
//   + Đếm công nợ nợ quá hạn
//   + Trả về report object
// - Method getInventoryReport():
//   + Truy vấn tất cả Inventory
//   + Tính tổng giá trị tồn kho
//   + Lọc sản phẩm tồn kho ít (< mốc ngưỡng)
//   + Trả về report object
// - Method getActivityLog(int page):
//   + Truy vấn log hoạt động hệ thống (nếu có)
//   + Phân trang
//   + Trả về danh sách

