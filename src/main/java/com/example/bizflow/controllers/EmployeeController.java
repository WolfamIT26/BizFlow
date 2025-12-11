/*
 * File: EmployeeController.java
 * Mô tả: Controller xử lý quản lý tài khoản nhân viên
 * Chức năng: Tạo tài khoản nhân viên, cập nhật thông tin nhân viên,
 *            xóa nhân viên, xem danh sách nhân viên, phân quyền nhân viên
 */

// TODO: Tạo class EmployeeController với annotation @RestController, @RequestMapping("/api/employees")
// - Inject EmployeeService
// - Method createEmployee(@RequestBody user):
//   + POST /api/employees
//   + Gọi employeeService.createEmployee(user)
//   + Mã hóa password, gán role EMPLOYEE
//   + Trả về user object mới
// - Method getEmployees(@RequestParam page):
//   + GET /api/employees
//   + Gọi employeeService.getEmployees(page)
//   + Trả về danh sách nhân viên phân trang
// - Method getEmployeeById(@PathVariable id):
//   + GET /api/employees/{id}
//   + Gọi employeeService.getEmployeeById(id)
//   + Trả về thông tin nhân viên
// - Method updateEmployee(@PathVariable id, @RequestBody user):
//   + PUT /api/employees/{id}
//   + Gọi employeeService.updateEmployee(id, user)
//   + Trả về nhân viên được cập nhật
// - Method deleteEmployee(@PathVariable id):
//   + DELETE /api/employees/{id}
//   + Gọi employeeService.deleteEmployee(id)
//   + Trả về thông báo success

