/*
 * File: OrderItem.java
 * Mô tả: Entity ánh xạ bảng OrderItem trong database (chi tiết từng sản phẩm trong đơn hàng)
 * Chức năng: Lưu thông tin từng dòng sản phẩm (mã đơn, mã sản phẩm, số lượng),
 *            lưu giá bán lúc bán, tiền chiết khấu, thành tiền
 */

// TODO: Tạo class OrderItem với annotation @Entity, @Table(name = "order_items")
// - Fields:
//   + @Id @GeneratedValue Long id
//   + @ManyToOne @JoinColumn(nullable = false) Order order (đơn hàng chủ)
//   + @ManyToOne @JoinColumn(nullable = false) Product product (sản phẩm)
//   + @Column(nullable = false) int quantity (số lượng)
//   + @Column(nullable = false) BigDecimal unitPrice (giá bán lúc tạo đơn)
//   + @Column(nullable = false) BigDecimal totalPrice (thành tiền = quantity * unitPrice)
//   + BigDecimal discountAmount (tiền chiết khấu của sản phẩm này)
//   + @Column(nullable = false) BigDecimal finalPrice (giá của sản phẩm này là tổng - chiết khấu)
//   + @Temporal(TemporalType.TIMESTAMP) Date createdAt
// - Constructors: No-arg, Full-arg
// - Getters/Setters

