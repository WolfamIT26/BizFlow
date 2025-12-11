/*
 * File: DateUtil.java
 * Mô tả: Utility class xử lý ngày tháng
 * Chức năng: Định dạng ngày tháng, chuyển đổi giữa các định dạng,
 *            tính khoảng thời gian, so sánh ngày tháng
 */

// TODO: Tạo class DateUtil (class utilities, có thể là static)
// - Constant: static final String DATE_FORMAT = "dd/MM/yyyy"
// - Method formatDate(Date date):
//   + Format Date -> String dạng dd/MM/yyyy
//   + Sử dụng SimpleDateFormat hoặc DateTimeFormatter
//   + Trả về String định dạng
// - Method formatDateTime(Date date):
//   + Format Date -> String dạng dd/MM/yyyy HH:mm:ss
//   + Trả về String
// - Method parseDate(String dateStr):
//   + Parse String -> Date
//   + Trả về Date
// - Method getDaysDifference(Date date1, Date date2):
//   + Tính số ngày giữa 2 ngày
//   + Trả về long
// - Method isDateBetween(Date date, Date startDate, Date endDate):
//   + Kiểm tra date có nằm giữa startDate và endDate không
//   + Trả về boolean
// - Method addDays(Date date, int days):
//   + Cộng số ngày vào date
//   + Trả về Date mới

