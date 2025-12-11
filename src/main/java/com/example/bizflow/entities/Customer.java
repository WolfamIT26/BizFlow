/*
 * File: Customer.java
 * Mô tả: Entity ánh xạ bảng Customer trong database
 * Chức năng: Lưu thông tin khách hàng (tên, số điện thoại, địa chỉ, email),
 *            lưu loại khách hàng (cá nhân/doanh nghiệp), ghi chú
 */

// TODO: Tạo class Customer với annotation @Entity, @Table(name = "customers")
// - Fields:
//   + @Id @GeneratedValue Long id
//   + @Column(nullable = false) String name (tên khách hàng)
//   + @Column(unique = true) String phoneNumber (số điện thoại)
//   + String address (địa chỉ)
//   + String email (email)
//   + String customerType (loại: CÁ NHÂN hay DOANH NGHIỆP)
//   + String taxCode (mã số thuế, nếu có)
//   + String representativeName (đại diện - nếu là doanh nghiệp)
//   + String representativePhone (sđt đại diện)
//   + @Temporal(TemporalType.TIMESTAMP) Date createdAt
//   + @Temporal(TemporalType.TIMESTAMP) Date updatedAt
//   + String notes (ghi chú)
//   + @Column(nullable = false) boolean active (có hoạt động hay không)
// - Constructors: No-arg, Full-arg
// - Getters/Setters

