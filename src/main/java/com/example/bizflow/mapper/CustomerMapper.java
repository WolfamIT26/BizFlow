/*
 * File: CustomerMapper.java
 * Mô tả: Mapper chuyển đổi giữa Customer entity và CustomerDTO
 * Chức năng: Map Customer entity sang CustomerDTO để trả về response,
 *            map CustomerDTO sang Customer entity để lưu vào database
 */

// TODO: Tạo interface CustomerMapper (sử dụng MapStruct hoặc tạo class)
// Option 1: Sử dụng MapStruct
// - Annotation @Mapper(componentModel = "spring")
// - Method CustomerDTO toDTO(Customer entity);
// - Method Customer toEntity(CustomerDTO dto);
// Option 2: Tạo class với @Component
// - Method toDTO(Customer entity):
//   + Tạo CustomerDTO mới
//   + Copy các field từ entity sang dto
//   + Trả về dto
// - Method toEntity(CustomerDTO dto):
//   + Tạo Customer mới
//   + Copy các field từ dto sang entity
//   + Trả về entity

