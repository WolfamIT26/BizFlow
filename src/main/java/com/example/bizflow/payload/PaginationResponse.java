/*
 * File: PaginationResponse.java
 * Mô tả: Class định nghĩa cấu trúc pagination response
 * Chức năng: Định nghĩa các field (totalPages, totalElements, currentPage, pageSize),
 *            dùng để trả về dữ liệu phân trang
 */

// TODO: Tạo class PaginationResponse<T>
// - Fields:
//   + List<T> content (danh sách dữ liệu)
//   + int totalPages (tổng số trang)
//   + long totalElements (tổng số phần tử)
//   + int currentPage (trang hiện tại, 0-indexed)
//   + int pageSize (kích thước trang)
//   + boolean hasNext (có trang tiếp theo không)
//   + boolean hasPrevious (có trang trước không)
// - Constructors:
//   + PaginationResponse(Page<T> page) - tạo từ Spring Data Page
//   + PaginationResponse() - no-arg
// - Getters/Setters
// - toString()

