/*
 * File: ApiResponse.java
 * Mô tả: Class định nghĩa cấu trúc response API chuẩn
 * Chức năng: Định nghĩa các field (status, message, data, timestamp),
 *            dùng để trả về response thống nhất cho tất cả API endpoint
 */

// TODO: Tạo class ApiResponse<T>
// - Fields:
//   + int status (HTTP status code: 200, 400, 404, 500, v.v.)
//   + String message (mô tả kết quả: "Success", "Error", v.v.)
//   + T data (dữ liệu trả về, có thể null)
//   + @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss") LocalDateTime timestamp (thời gian tạo response)
//   + String path (API path, nếu cần)
// - Constructors:
//   + ApiResponse(int status, String message, T data)
//   + ApiResponse(int status, String message)
// - Getters/Setters
// - toString() để debug

