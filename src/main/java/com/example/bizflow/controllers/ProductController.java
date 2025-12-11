/*
 * File: ProductController.java
 * Mô tả: Controller xử lý tất cả yêu cầu liên quan đến sản phẩm
 * Chức năng: Tạo sản phẩm mới, xem danh sách sản phẩm, cập nhật thông tin sản phẩm,
 *            xóa sản phẩm, quản lý giá sản phẩm
 */

// TODO: Tạo class ProductController với annotation @RestController, @RequestMapping("/api/products")
// - Inject ProductService
// - Method createProduct(@RequestBody ProductDTO dto):
//   + POST /api/products
//   + Gọi productService.createProduct(dto)
//   + Trả về product object mới
// - Method getProducts(@RequestParam keyword, @RequestParam page):
//   + GET /api/products
//   + Gọi productService.searchProducts(keyword, page)
//   + Trả về danh sách sản phẩm phân trang
// - Method getProductById(@PathVariable id):
//   + GET /api/products/{id}
//   + Gọi productService.getProductById(id)
//   + Trả về chi tiết sản phẩm
// - Method updateProduct(@PathVariable id, @RequestBody ProductDTO dto):
//   + PUT /api/products/{id}
//   + Gọi productService.updateProduct(id, dto)
//   + Trả về sản phẩm được cập nhật
// - Method deleteProduct(@PathVariable id):
//   + DELETE /api/products/{id}
//   + Gọi productService.deleteProduct(id)
//   + Trả về thông báo success

