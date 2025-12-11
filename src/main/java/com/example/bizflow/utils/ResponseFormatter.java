/*
 * File: ResponseFormatter.java
 * Mô tả: Utility class chuẩn hóa API response
 * Chức năng: Định dạng response thành cấu trúc chuẩn (status, message, data),
 *            xử lý lỗi response, pagination response
 */

// TODO: Tạo class ResponseFormatter (utilities, có thể là static)
// - Method success(T data, String message):
//   + Trả về ApiResponse với status = 200, message, data
//   + Trả về ResponseEntity<ApiResponse>
// - Method success(T data):
//   + Gọi success(data, "Success")
// - Method error(String message, int statusCode):
//   + Trả về ApiResponse với status = statusCode, message, data = null
//   + Trả về ResponseEntity<ApiResponse>
// - Method error(String message):
//   + Gọi error(message, 400)
// - Method created(T data):
//   + Trả về ApiResponse với status = 201, message = "Created", data
//   + Trả về ResponseEntity<ApiResponse>
// - Method paginated(Page<T> page):
//   + Trả về ApiResponse chứa:
//     * data = page.getContent()
//     * totalPages
//     * totalElements
//     * currentPage
//     * pageSize
//   + Trả về ResponseEntity<ApiResponse>

