/*
 * File: ProductService.java
 * Mô tả: Service xử lý logic liên quan đến sản phẩm
 * Chức năng: Quản lý thông tin sản phẩm (CRUD), quản lý giá sản phẩm,
 *            tìm kiếm sản phẩm, lọc sản phẩm theo danh mục,
 *            kiểm tra tồn kho
 */

// TODO: Tạo class ProductService với annotation @Service
// - Inject ProductRepository, InventoryRepository, ProductMapper
// - Method createProduct(ProductDTO dto):
//   + Validate dữ liệu (tên, giá > 0, v.v.)
//   + Map ProductDTO -> Product entity
//   + Lưu vào DB
//   + Trả về product object
// - Method searchProducts(String keyword, int page):
//   + Truy vấn sản phẩm theo tên hoặc mã
//   + Phân trang
//   + Trả về danh sách
// - Method getProductById(Long id):
//   + Truy vấn sản phẩm theo id
//   + Throw ResourceNotFoundException nếu không tìm thấy
//   + Trả về product
// - Method updateProduct(Long id, ProductDTO dto):
//   + Lấy product từ DB
//   + Cập nhật các field từ dto
//   + Lưu vào DB
//   + Trả về product
// - Method deleteProduct(Long id):
//   + Lấy product từ DB
//   + Kiểm tra còn tồn kho không
//   + Xóa product
//   + Trả về thông báo
// - Method updatePrice(Long id, BigDecimal newPrice):
//   + Lấy product từ DB
//   + Cập nhật giá
//   + Lưu vào DB
//   + Trả về product

