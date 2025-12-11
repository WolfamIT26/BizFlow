/*
 * File: InventoryController.java
 * Mô tả: Controller xử lý tất cả yêu cầu liên quan đến tồn kho
 * Chức năng: Nhập kho sản phẩm, cập nhật tồn kho, xuất kho,
 *            xem thống kê tồn kho hiện tại, lịch sử nhập xuất
 */

// TODO: Tạo class InventoryController với annotation @RestController, @RequestMapping("/api/inventory")
// - Inject InventoryService
// - Method importInventory(@RequestBody inventory):
//   + POST /api/inventory/import
//   + Gọi inventoryService.importInventory(inventory)
//   + Cập nhật tồn kho, ghi nhận lịch sử nhập
//   + Trả về inventory object cập nhật
// - Method exportInventory(@RequestBody inventory):
//   + POST /api/inventory/export
//   + Gọi inventoryService.exportInventory(inventory)
//   + Giảm tồn kho, ghi nhận lịch sử xuất
//   + Trả về inventory object cập nhật
// - Method getInventory(@RequestParam productId):
//   + GET /api/inventory?productId={id}
//   + Gọi inventoryService.getInventoryByProduct(productId)
//   + Trả về thông tin tồn kho của sản phẩm
// - Method getInventoryHistory(@PathVariable productId, @RequestParam page):
//   + GET /api/inventory/{productId}/history
//   + Gọi inventoryService.getInventoryHistory(productId, page)
//   + Trả về lịch sử nhập xuất phân trang

