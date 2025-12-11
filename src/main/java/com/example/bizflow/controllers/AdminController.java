/*
 * File: AdminController.java
 * Mô tả: Controller xử lý quản lý tài khoản chủ cửa hàng (Admin)
 * Chức năng: Tạo tài khoản chủ cửa hàng, cập nhật hồ sơ chủ cửa hàng,
 *            quản lý cấp phép, xem lịch sử hoạt động, cấu hình hệ thống
 */

// TODO: Tạo class AdminController với annotation @RestController, @RequestMapping("/api/admin")
// - Require @PreAuthorize("hasRole('ADMIN')")
// - Inject EmployeeService, ReportService
// - Method createAdmin(@RequestBody user):
//   + POST /api/admin/accounts
//   + Gọi employeeService.createAdmin(user)
//   + Mã hóa password, gán role ADMIN
//   + Trả về user object mới
// - Method updateAdminProfile(@PathVariable id, @RequestBody user):
//   + PUT /api/admin/accounts/{id}
//   + Gọi employeeService.updateEmployee(id, user)
//   + Trả về admin được cập nhật
// - Method getActivityLog(@RequestParam page):
//   + GET /api/admin/activity-log
//   + Gọi reportService.getActivityLog(page)
//   + Trả về lịch sử hoạt động của hệ thống
// - Method updateSystemConfig(@RequestBody config):
//   + PUT /api/admin/config
//   + Cập nhật cấu hình hệ thống
//   + Trả về config mới

