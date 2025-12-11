/*
 * File: GlobalExceptionHandler.java
 * Mô tả: Handler xử lý lỗi tập trung cho toàn bộ ứng dụng
 * Chức năng: Bắt tất cả các exception, trả về response lỗi chuẩn,
 *            ghi log lỗi, xử lý lỗi validation
 */

// TODO: Tạo class GlobalExceptionHandler với annotation @RestControllerAdvice
// - Method handleResourceNotFoundException(ResourceNotFoundException ex):
//   + @ExceptionHandler(ResourceNotFoundException.class)
//   + Return ResponseEntity<ApiResponse> với status 404
// - Method handleBadRequestException(BadRequestException ex):
//   + @ExceptionHandler(BadRequestException.class)
//   + Return ResponseEntity<ApiResponse> với status 400
// - Method handleUnauthorizedException(UnauthorizedException ex):
//   + @ExceptionHandler(UnauthorizedException.class)
//   + Return ResponseEntity<ApiResponse> với status 401/403
// - Method handleValidationException(MethodArgumentNotValidException ex):
//   + @ExceptionHandler(MethodArgumentNotValidException.class)
//   + Bắt lỗi validation (@NotBlank, @NotNull, v.v.)
//   + Return ResponseEntity với danh sách lỗi chi tiết
// - Method handleGlobalException(Exception ex):
//   + @ExceptionHandler(Exception.class)
//   + Xử lý mọi exception không được xử lý riêng
//   + Ghi log error
//   + Return ResponseEntity<ApiResponse> với status 500

