/*
 * File: ProductMapper.java
 * Mô tả: Mapper chuyển đổi giữa Product entity và ProductDTO
 * Chức năng: Map Product entity sang ProductDTO để trả về response,
 *            map ProductDTO sang Product entity để lưu vào database
 */

// TODO: Tạo interface ProductMapper (sử dụng MapStruct hoặc tạo class)
// Option 1: Sử dụng MapStruct
// - Annotation @Mapper(componentModel = "spring")
// - @Mapping(source = "id", target = "id")
// - Method ProductDTO toDTO(Product entity);
// - Method Product toEntity(ProductDTO dto);
// Option 2: Tạo class với @Component
// - Method toDTO(Product entity):
//   + Tạo ProductDTO mới
//   + Copy các field từ entity sang dto
//   + Trả về dto
// - Method toEntity(ProductDTO dto):
//   + Tạo Product mới
//   + Copy các field từ dto sang entity
//   + Trả về entity

