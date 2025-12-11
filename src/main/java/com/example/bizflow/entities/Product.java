/*
 * File: Product.java
 * Mô tả: Entity ánh xạ bảng Product trong database
 * Chức năng: Lưu thông tin sản phẩm (mã sản phẩm, tên, danh mục, đơn vị tính),
 *            lưu giá bán, giá vốn, mô tả, hình ảnh
 */

// TODO: Tạo class Product với annotation @Entity, @Table(name = "products")
// - Fields:
//   + @Id @GeneratedValue Long id
//   + @Column(unique = true, nullable = false) String code (mã sản phẩm)
//   + @Column(nullable = false) String name (tên sản phẩm)
//   + String category (danh mục)
//   + String unit (đơn vị tính: cái, bộ, hộp, v.v.)
//   + @Column(nullable = false) BigDecimal sellingPrice (giá bán)
//   + @Column(nullable = false) BigDecimal costPrice (giá vốn)
//   + String description (mô tả)
//   + String imageUrl (link hình ảnh)
//   + @Column(nullable = false) boolean active (có hoạt động hay không)
//   + @Temporal(TemporalType.TIMESTAMP) Date createdAt
//   + @Temporal(TemporalType.TIMESTAMP) Date updatedAt
// - Constructors: No-arg, Full-arg
// - Getters/Setters

