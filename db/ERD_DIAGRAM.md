# BIZFLOW - ERD DIAGRAM (Entity Relationship Diagram)

## Sơ đồ quan hệ đầy đủ 24 bảng

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│                            BIZFLOW DATABASE - 24 TABLES                          │
└──────────────────────────────────────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════════════════════════════════
                          NHÓM 1: HỆ THỐNG & PHÂN QUYỀN
═══════════════════════════════════════════════════════════════════════════════════

┌─────────────┐
│   roles     │
├─────────────┤
│ PK id       │
│    name     │◄────────┐
│ description │         │
└─────────────┘         │
                        │
┌─────────────┐         │         ┌──────────────┐
│   users     │         │         │  user_roles  │
├─────────────┤         └─────────┤──────────────┤
│ PK id       │◄──────────────────│ PK id        │
│    username │                   │ FK user_id   │
│    password │         ┌─────────┤ FK role_id   │
│    email    │         │         │ FK shop_id   │
│  full_name  │         │         └──────────────┘
│    phone    │         │
│   enabled   │         │
└─────────────┘         │
      │                 │
      │                 │
      │         ┌───────────────┐
      │         │    shops      │
      └────────►├───────────────┤
                │ PK id         │
                │    name       │
                │    address    │
                │ FK owner_id   │──┐
                │  is_active    │  │
                └───────────────┘  │
                        │          │
                        │          │
                ┌───────┴──────────┴───┐
                │    audit_logs        │
                ├──────────────────────┤
                │ PK id                │
                │ FK user_id           │
                │ FK shop_id           │
                │ FK target_employee_id│
                │    action            │
                │    timestamp         │
                │    detail            │
                └──────────────────────┘

═══════════════════════════════════════════════════════════════════════════════════
                            NHÓM 2: SẢN PHẨM
═══════════════════════════════════════════════════════════════════════════════════

┌────────────────┐
│  categories    │
├────────────────┤
│ PK id          │◄───┐
│    name        │    │
│ FK parent_id   │────┘ (self-reference)
│ display_order  │
│   is_active    │
└────────────────┘
        │
        │
        ▼
┌──────────────────┐
│    products      │
├──────────────────┤
│ PK id            │◄───────────────────────────┐
│ FK category_id   │                            │
│    code          │                            │
│    name          │                            │
│  base_price      │                            │
│   barcode        │                            │
│   is_active      │                            │
└──────────────────┘                            │
        │                                       │
        ├────────────┬──────────────┬───────────┼────────────┐
        │            │              │           │            │
        ▼            ▼              ▼           ▼            ▼
┌──────────────┐ ┌────────────┐ ┌────────────┐ ┌─────────────┐ ┌──────────────────┐
│product_units │ │product_    │ │product_    │ │product_     │ │product_status_   │
│              │ │prices      │ │images      │ │units        │ │logs              │
├──────────────┤ ├────────────┤ ├────────────┤ ├─────────────┤ ├──────────────────┤
│ PK id        │ │ PK id      │ │ PK id      │ │ PK id       │ │ PK id            │
│ FK product_id│ │FK product_ │ │FK product_ │ │FK product_id│ │ FK product_id    │
│   unit_name  │ │   id       │ │   id       │ │  unit_name  │ │    old_status    │
│conversion_   │ │FK shop_id  │ │ image_url  │ │conversion_  │ │    new_status    │
│   rate       │ │ old_price  │ │is_primary  │ │   rate      │ │ FK changed_by    │
│is_base_unit  │ │ new_price  │ │display_    │ │price_adjust │ │   changed_at     │
│price_adjust  │ │FK changed_ │ │  order     │ │             │ │    reason        │
│              │ │   by       │ │            │ │             │ │                  │
└──────────────┘ └────────────┘ └────────────┘ └─────────────┘ └──────────────────┘

═══════════════════════════════════════════════════════════════════════════════════
                          NHÓM 3: KHO & NHẬP HÀNG
═══════════════════════════════════════════════════════════════════════════════════

┌─────────────┐
│  suppliers  │
├─────────────┤
│ PK id       │
│    name     │
│   phone     │
│   email     │
│  is_active  │
└─────────────┘
        │
        │
        ▼
┌──────────────────┐
│  stock_imports   │
├──────────────────┤
│ PK id            │
│    import_code   │
│ FK supplier_id   │
│ FK shop_id       │───────┐
│ FK imported_by   │       │
│  total_amount    │       │
│     status       │       │
│   import_date    │       │
└──────────────────┘       │
        │                  │
        │                  │
        ▼                  │                 products
┌──────────────────┐       │                     │
│stock_import_     │       │                     │
│  items           │       │                     ▼
├──────────────────┤       │         ┌───────────────────┐
│ PK id            │       │         │    inventory      │
│ FK stock_import_ │       │         ├───────────────────┤
│    id            │       ├────────►│ PK id             │
│ FK product_id    │───────┤         │ FK product_id     │
│    quantity      │       │         │ FK shop_id        │
│   unit_price     │       │         │ quantity_on_hand  │
│   total_price    │       │         │quantity_reserved  │
└──────────────────┘       │         │min_stock_level    │
                           │         │max_stock_level    │
                           │         └───────────────────┘
                           │                  │
                           │                  │
                           │         ┌────────┴──────────┐
                           │         │  inventory_       │
                           │         │  transactions     │
                           │         ├───────────────────┤
                           │         │ PK id             │
                           └────────►│ FK product_id     │
                                     │ FK shop_id        │
                                     │ transaction_type  │
                                     │ quantity_change   │
                                     │ reference_type    │
                                     │ reference_id      │
                                     │ FK performed_by   │
                                     └───────────────────┘

═══════════════════════════════════════════════════════════════════════════════════
                              NHÓM 4: BÁN HÀNG
═══════════════════════════════════════════════════════════════════════════════════

                    customers
                        │
                        │
                        ▼
                ┌──────────────┐
                │   orders     │
                ├──────────────┤
                │ PK id        │
                │  order_code  │
                │ FK shop_id   │
                │FK customer_id│
                │FK employee_id│
                │ total_amount │
                │final_amount  │
                │   status     │
                └──────────────┘
                        │
        ┌───────────────┼───────────────┬────────────────┐
        │               │               │                │
        ▼               ▼               ▼                ▼
┌────────────┐  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│order_items │  │  payments    │ │  receipts    │ │customer_debts│
├────────────┤  ├──────────────┤ ├──────────────┤ ├──────────────┤
│ PK id      │  │ PK id        │ │ PK id        │ │ PK id        │
│FK order_id │  │ FK order_id  │ │ FK order_id  │ │FK customer_id│
│FK product_ │  │payment_method│ │receipt_number│ │FK order_id   │
│   id       │  │   amount     │ │FK issued_by  │ │ debt_amount  │
│  quantity  │  │payment_date  │ │ issued_date  │ │ paid_amount  │
│unit_price  │  │transaction_id│ │receipt_type  │ │remaining_    │
│total_price │  │   status     │ │  file_path   │ │  amount      │
│            │  │              │ │              │ │   status     │
└────────────┘  └──────────────┘ └──────────────┘ └──────────────┘

═══════════════════════════════════════════════════════════════════════════════════
                         NHÓM 5: KHÁCH HÀNG & ĐIỂM
═══════════════════════════════════════════════════════════════════════════════════

┌──────────────────┐
│   customers      │
├──────────────────┤
│ PK id            │◄────────────────────────┐
│  customer_code   │                         │
│     name         │                         │
│     phone        │                         │
│     email        │                         │
│    address       │                         │
│   is_active      │                         │
└──────────────────┘                         │
        │                                    │
        ├────────────────┬───────────────────┤
        │                │                   │
        ▼                ▼                   │
┌──────────────┐  ┌──────────────────┐      │
│loyalty_points│  │ customer_debts   │      │
├──────────────┤  ├──────────────────┤      │
│ PK id        │  │ PK id            │      │
│FK customer_id│  │ FK customer_id   │──────┘
│ total_points │  │ FK order_id      │
│available_    │  │  debt_amount     │
│  points      │  │  paid_amount     │
│ used_points  │  │ remaining_amount │
│              │  │    due_date      │
└──────────────┘  │     status       │
        │         └──────────────────┘
        │
        │  (logic: lấy tier dựa vào points)
        │
        ▼
┌──────────────────┐
│membership_tiers  │
├──────────────────┤
│ PK id            │
│   tier_name      │
│  min_points      │
│discount_percent  │
│    benefits      │
│  display_order   │
└──────────────────┘

═══════════════════════════════════════════════════════════════════════════════════
                         BẢNG BỔ SUNG (OPTIONAL)
═══════════════════════════════════════════════════════════════════════════════════

┌───────────────────┐          ┌─────────────────────┐
│ revenue_reports   │          │owner_subscriptions  │
├───────────────────┤          ├─────────────────────┤
│ PK id             │          │ PK id               │
│ FK shop_id        │          │ FK owner_id         │
│  report_date      │          │   plan_name         │
│ total_revenue     │          │    price            │
│  total_orders     │          │  start_date         │
│ total_customers   │          │   end_date          │
└───────────────────┘          │    status           │
                               │   features          │
                               └─────────────────────┘

═══════════════════════════════════════════════════════════════════════════════════
```

## LEGEND (Chú thích)

- `PK` = Primary Key (Khóa chính)
- `FK` = Foreign Key (Khóa ngoại)
- `──►` = Quan hệ 1-nhiều (One-to-Many)
- `◄──` = Quan hệ nhiều-1 (Many-to-One)

## MỐI QUAN HỆ CHÍNH

### 1:N (One-to-Many)
- 1 `role` → N `user_roles`
- 1 `user` → N `user_roles`
- 1 `user` → N `shops` (owner)
- 1 `shop` → N `orders`
- 1 `category` → N `products`
- 1 `product` → N `product_prices`, `product_images`, etc.
- 1 `customer` → N `orders`
- 1 `order` → N `order_items`, `payments`, `receipts`

### N:M (Many-to-Many) qua bảng trung gian
- `users` ↔ `roles` qua `user_roles`

### Self-Reference (Tự tham chiếu)
- `categories.parent_id` → `categories.id` (cây phân cấp)

## BUSINESS RULES

1. **Phân quyền**:
   - 1 user có thể có nhiều role
   - 1 user có thể quản lý nhiều shop (nếu là OWNER)
   - 1 shop chỉ có 1 owner

2. **Sản phẩm**:
   - 1 sản phẩm có nhiều đơn vị tính (chai, thùng, lốc...)
   - Giá sản phẩm có thể khác nhau theo shop
   - Lưu lịch sử thay đổi giá

3. **Kho**:
   - Tồn kho được tính riêng cho mỗi shop
   - Mọi thay đổi tồn kho đều ghi vào inventory_transactions
   - Công thức: `quantity_on_hand = sum(inventory_transactions.quantity_change)`

4. **Bán hàng**:
   - 1 đơn hàng có thể có nhiều phương thức thanh toán
   - Đơn hàng có thể thanh toán từng phần (partial payment)
   - Mỗi đơn hàng có thể in nhiều lần (receipts)

5. **Khách hàng**:
   - Điểm tích lũy tự động khi mua hàng
   - Hạng thành viên tự động dựa vào số điểm
   - Công nợ được tracking riêng

---

**Thiết kế bởi**: BizFlow Team  
**Version**: 2.0  
**Ngày**: 2024-12-23
