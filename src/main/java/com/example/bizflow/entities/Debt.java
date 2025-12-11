/*
 * File: Debt.java
 * Mô tả: Entity ánh xạ bảng Debt trong database
 * Chức năng: Lưu thông tin công nợ (khách hàng, tổng nợ, ngày tạo),
 *            lưu trạng thái (nợ/đã thanh toán), ngày thanh toán
 */

// TODO: Tạo class Debt với annotation @Entity, @Table(name = "debts")
// - Fields:
//   + @Id @GeneratedValue Long id
//   + @ManyToOne @JoinColumn(nullable = false) Customer customer (khách hàng)
//   + @ManyToOne @JoinColumn Order order (đơn hàng liên quan)
//   + @Column(nullable = false) BigDecimal amount (tổng số nợ)
//   + @Column(nullable = false) BigDecimal paidAmount (số tiền đã trả)
//   + BigDecimal remainingAmount (số tiền còn nợ)
//   + @Temporal(TemporalType.TIMESTAMP) Date createdAt (ngày tạo công nợ)
//   + @Temporal(TemporalType.TIMESTAMP) Date dueDate (ngày đến hạn thanh toán)
//   + @Temporal(TemporalType.TIMESTAMP) Date paidAt (ngày thanh toán)
//   + String status (UNPAID, PARTIAL_PAID, PAID)
//   + String notes (ghi chú)
// - Constructors: No-arg, Full-arg
// - Getters/Setters

