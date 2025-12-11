/*
 * File: ProductRepository.java
 * Mô tả: Repository tương tác với bảng Product trong database
 * Chức năng: Truy vấn, lưu, cập nhật, xóa sản phẩm,
 *            tìm kiếm theo tên, danh mục, khoảng giá
 */

// TODO: Tạo interface ProductRepository extends JpaRepository<Product, Long>
// - Method findByNameContainingIgnoreCase(String keyword):
//   + Tìm kiếm sản phẩm theo tên (không phân biệt hoa thường)
//   + Trả về Page<Product> hoặc List<Product>
// - Method findByCategory(String category):
//   + Truy vấn sản phẩm theo danh mục
//   + Trả về List<Product>
// - Method findByPriceBetween(BigDecimal minPrice, BigDecimal maxPrice):
//   + Truy vấn sản phẩm trong khoảng giá
//   + Trả về List<Product>
// - Method findByCodeIgnoreCase(String code):
//   + Tìm kiếm theo mã sản phẩm
//   + Trả về Optional<Product>
// - Method existsByCode(String code):
//   + Kiểm tra mã sản phẩm có tồn tại không
//   + Trả về boolean

