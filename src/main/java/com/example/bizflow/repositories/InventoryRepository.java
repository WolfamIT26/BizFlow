/*
 * File: InventoryRepository.java
 * Mô tả: Repository tương tác với bảng Inventory trong database
 * Chức năng: Truy vấn, lưu, cập nhật, xóa thông tin tồn kho,
 *            tìm kiếm theo sản phẩm, kiểm tra tồn kho
 */

// TODO: Tạo interface InventoryRepository extends JpaRepository<Inventory, Long>
// - Method findByProductId(Long productId):
//   + Truy vấn tồn kho của một sản phẩm
//   + Trả về Optional<Inventory>
// - Method findByProductIdIn(List<Long> productIds):
//   + Truy vấn tồn kho của nhiều sản phẩm
//   + Trả về List<Inventory>
// - @Query("SELECT i FROM Inventory i WHERE i.quantity < :threshold"):
//   + Tìm các sản phẩm tồn kho dưới ngưỡng
//   + Trả về List<Inventory>
// - Method deleteByProductId(Long productId):
//   + Xóa tồn kho khi xóa sản phẩm

