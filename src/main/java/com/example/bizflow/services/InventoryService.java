/*
 * File: InventoryService.java
 * Mô tả: Service xử lý logic liên quan đến tồn kho
 * Chức năng: Nhập kho sản phẩm, xuất kho, cập nhật tồn kho,
 *            kiểm tra tồn kho đủ, ghi nhận lịch sử nhập xuất,
 *            tính giá trị tồn kho
 */

// TODO: Tạo class InventoryService với annotation @Service, @Transactional
// - Inject InventoryRepository, ProductRepository
// - Method importInventory(Inventory inventory):
//   + Lấy sản phẩm từ product id
//   + Lấy tồn kho hiện tại
//   + Cộng số lượng nhập
//   + Ghi nhận lịch sử (type = IMPORT, quantity, date, note)
//   + Lưu inventory mới vào DB
//   + Trả về inventory
// - Method exportInventory(Inventory inventory):
//   + Lấy sản phẩm từ product id
//   + Kiểm tra tồn kho có đủ không
//   + Trừ số lượng xuất
//   + Ghi nhận lịch sử (type = EXPORT)
//   + Lưu inventory mới vào DB
//   + Trả về inventory
// - Method getInventoryByProductId(Long productId):
//   + Truy vấn inventory theo product id
//   + Trả về inventory object
// - Method hasEnoughInventory(Long productId, int quantity):
//   + Lấy tồn kho hiện tại
//   + So sánh quantity
//   + Trả về true/false
// - Method getInventoryHistory(Long productId, int page):
//   + Truy vấn lịch sử nhập xuất theo product id
//   + Phân trang
//   + Trả về danh sách
// - Method calculateInventoryValue():
//   + Lặp tất cả sản phẩm
//   + Tính giá trị = tồn kho * giá vốn
//   + Trả về tổng giá trị

