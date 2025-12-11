/*
 * File: Order.java
 * Mô tả: Entity ánh xạ bảng Order trong database
 * Chức năng: Lưu thông tin đơn hàng (mã đơn, ngày tạo, khách hàng, nhân viên),
 *            lưu tổng tiền, trạng thái (PENDING, PAID, DEBT), ghi chú
 */

// TODO: Tạo class Order với annotation @Entity, @Table(name = "orders")
// - Fields:
//   + @Id @GeneratedValue Long id
//   + @Column(unique = true, nullable = false) String orderCode (mã đơn hàng)
//   + @Temporal(TemporalType.TIMESTAMP) @Column(nullable = false) Date createdAt (ngày tạo)
//   + @ManyToOne @JoinColumn(nullable = false) Customer customer (khách hàng)
//   + @ManyToOne @JoinColumn(nullable = false) User employee (nhân viên bán hàng)
//   + @Column(nullable = false) BigDecimal totalAmount (tổng tiền)
//   + @Column(nullable = false) BigDecimal discountAmount (tiền chiết khấu)
//   + @Enumerated(EnumType.STRING) @Column(nullable = false) OrderStatus status (PENDING, PAID, DEBT)
//   + String notes (ghi chú)
//   + @Temporal(TemporalType.TIMESTAMP) Date updatedAt (ngày cập nhật)
//   + @OneToMany(mappedBy = "order", cascade = CascadeType.ALL) List<OrderItem> items (danh sách sản phẩm)
// - Constructors: No-arg, Full-arg
// - Getters/Setters

