/*
 * File: ProductDTO.java
 * Mô tả: DTO cho request/response liên quan đến sản phẩm
 * Chức năng: Chứa thông tin sản phẩm (tên, giá, danh mục, mô tả),
 *            dùng để nhận dữ liệu từ client hoặc trả về response
 */

// TODO: Tạo class ProductDTO
// - Fields:
//   + Long id (nếu cập nhật)
//   + @NotBlank String code (mã sản phẩm)
//   + @NotBlank String name (tên sản phẩm)
//   + String category (danh mục)
//   + String unit (đơn vị tính)
//   + @NotNull @DecimalMin("0.01") BigDecimal sellingPrice (giá bán)
//   + @NotNull @DecimalMin("0.01") BigDecimal costPrice (giá vốn)
//   + String description (mô tả)
//   + String imageUrl (link hình ảnh)
//   + boolean active (có hoạt động hay không)
// - Constructors: No-arg, Full-arg
// - Getters/Setters

