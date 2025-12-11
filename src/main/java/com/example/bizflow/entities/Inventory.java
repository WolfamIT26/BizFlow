/*
 * File: Inventory.java
 * Mô tả: Entity ánh xạ bảng Inventory trong database
 * Chức năng: Lưu thông tin tồn kho (mã sản phẩm, số lượng tồn kho),
 *            lưu ngày cập nhật, vị trí lưu trữ, lịch sử nhập xuất
 */

// TODO: Tạo class Inventory với annotation @Entity, @Table(name = "inventory")
// - Fields:
//   + @Id @GeneratedValue Long id
//   + @OneToOne @JoinColumn(unique = true, nullable = false) Product product (sản phẩm)
//   + @Column(nullable = false) int quantity (số lượng tồn kho hiện tại)
//   + int minStock (số lượng dù không nên dưới)
//   + int maxStock (số lượng tối đa)
//   + String location (vị trí lưu trữ: kho 1, kệ A, v.v.)
//   + @Temporal(TemporalType.TIMESTAMP) Date lastUpdated (ngày cập nhật gần nhất)
//   + @Temporal(TemporalType.TIMESTAMP) Date createdAt (ngày tạo)
//   + String notes (ghi chú)
// - Constructors: No-arg, Full-arg
// - Getters/Setters

