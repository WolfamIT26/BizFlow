# 📊 PHÂN TÍCH HỆ THỐNG KHUYẾN MÃI BIZFLOW POS

**Ngày phân tích:** 25/01/2026  
**Phiên bản:** 1.8.3

---

## 📋 MỤC LỤC

1. [Tổng quan hệ thống](#tổng-quan-hệ-thống)
2. [Chức năng Backend (BE)](#chức-năng-backend-be)
3. [Chức năng Frontend (FE)](#chức-năng-frontend-fe)
4. [Luồng xử lý khuyến mãi](#luồng-xử-lý-khuyến-mãi)
5. [Đề xuất phát triển mới](#đề-xuất-phát-triển-mới)

---

## 🎯 TỔNG QUAN HỆ THỐNG

### Kiến trúc
- **Backend:** Java Spring Boot (Microservice: promotion-service)
- **Frontend:** HTML/CSS/JavaScript (Vanilla JS)
- **Database:** PostgreSQL/MySQL
- **API:** RESTful API với JWT Authentication

### Mô hình dữ liệu chính
```
Promotion (promotions)
├── PromotionTarget (promotion_targets) - Đối tượng áp dụng
└── BundleItem (bundle_items) - Chi tiết combo
```

---

## 🔧 CHỨC NĂNG BACKEND (BE)

### 1. **Entity & Model**

#### **Promotion Entity** (`promotion-service/entity/Promotion.java`)
```java
- id: Long - ID khuyến mãi
- code: String - Mã khuyến mãi (unique)
- name: String - Tên khuyến mãi
- description: String - Mô tả
- discountType: Enum - Loại giảm giá
  * PERCENT - Giảm theo %
  * FIXED / FIXED_AMOUNT - Giảm số tiền cố định
  * BUNDLE - Combo mua tặng
  * FREE_GIFT - Tặng kèm
- discountValue: Double - Giá trị giảm
- startDate: LocalDateTime - Ngày bắt đầu
- endDate: LocalDateTime - Ngày kết thúc
- active: Boolean - Trạng thái hoạt động
- targets: List<PromotionTarget> - Danh sách đối tượng
- bundleItems: List<BundleItem> - Danh sách combo
```

#### **PromotionTarget Entity**
```java
- targetType: String - Loại đối tượng (PRODUCT/CATEGORY)
- targetId: Long - ID sản phẩm hoặc danh mục
```

#### **BundleItem Entity**
```java
- mainProductId: Long - ID sản phẩm mua
- giftProductId: Long - ID sản phẩm tặng
- mainQuantity: Integer - Số lượng mua
- giftQuantity: Integer - Số lượng tặng
- status: String - Trạng thái
```

### 2. **REST API Endpoints** (`PromotionController.java`)

| Method | Endpoint | Chức năng | Quyền |
|--------|----------|-----------|-------|
| GET | `/api/v1/promotions` | Lấy danh sách khuyến mãi | Public |
| GET | `/api/v1/promotions?search=...&type=...` | Tìm kiếm & filter | Public |
| GET | `/api/v1/promotions/active` | Lấy KM đang hoạt động | Public |
| GET | `/api/v1/promotions/code/{code}` | Lấy KM theo mã | Public |
| GET | `/api/v1/promotions/generate-code` | Sinh mã KM tự động | Public |
| POST | `/api/v1/promotions` | Tạo khuyến mãi mới | OWNER/ADMIN |
| PUT | `/api/v1/promotions/{id}` | Cập nhật khuyến mãi | OWNER/ADMIN |
| DELETE | `/api/v1/promotions/{id}` | Xóa khuyến mãi | OWNER/ADMIN |
| PATCH | `/api/v1/promotions/{id}/deactivate` | Tạm dừng KM | OWNER/ADMIN |

### 3. **Business Logic** (`PromotionServiceImpl.java`)

#### Chức năng có sẵn:
- ✅ **CRUD khuyến mãi:** Tạo, đọc, cập nhật, xóa
- ✅ **Tìm kiếm & Filter:** Theo tên, loại, đối tượng áp dụng
- ✅ **Sinh mã tự động:** Generate promotion code
- ✅ **Kích hoạt/Vô hiệu hóa:** Active/Deactivate promotion
- ✅ **Quản lý targets:** PRODUCT và CATEGORY targets
- ✅ **Quản lý bundle:** Combo mua x tặng y

#### Chức năng chưa có:
- ❌ **Tính toán giá tự động:** Calculate discounted price
- ❌ **Apply promotion:** Áp dụng KM vào đơn hàng
- ❌ **Validation rules:** Kiểm tra điều kiện áp dụng
- ❌ **Promotion priority:** Ưu tiên KM khi overlap
- ❌ **Usage tracking:** Theo dõi số lần sử dụng
- ❌ **Promotion analytics:** Thống kê hiệu quả KM

### 4. **Integration với Order Service** (`bizflow-app/OrderController.java`)

```java
// Đã có: Tính giá khuyến mãi
private BigDecimal calculateDiscountedPrice(BigDecimal basePrice, Promotion promotion) {
    switch (promotion.getDiscountType()) {
        case PERCENT -> basePrice * (1 - value/100)
        case FIXED -> basePrice - value
        case BUNDLE -> value
        case FREE_GIFT -> basePrice
    }
}

// Đã có: Áp dụng KM cho sản phẩm
private BigDecimal resolvePromotionalPrice(Product product, List<Promotion> promotions) {
    // Chọn khuyến mãi tốt nhất
    // Tính giá sau giảm
}
```

---

## 💻 CHỨC NĂNG FRONTEND (FE)

### 1. **Trang quản lý khuyến mãi** (`owner-promotions.html`)

#### Chức năng Owner/Admin:
- ✅ **Xem danh sách:** Hiển thị tất cả khuyến mãi
- ✅ **Filter:** Lọc theo loại, trạng thái
- ✅ **Tìm kiếm:** Search theo mã/tên
- ✅ **Tạo mới:** Dialog thêm khuyến mãi
  - Chọn loại giảm (%, tiền, combo)
  - Thêm đối tượng áp dụng (sản phẩm/danh mục)
  - Autocomplete tìm sản phẩm với dropdown
  - Thiết lập thời gian bắt đầu/kết thúc
  - Quản lý combo mua tặng
- ✅ **Sửa:** Cập nhật thông tin KM
- ✅ **Xóa:** Xóa khuyến mãi
- ✅ **Tạm dừng:** Deactivate promotion
- ✅ **Sinh mã tự động:** Generate code từ tên

### 2. **Trang xem khuyến mãi** (`promotions.html`)

#### Chức năng Employee:
- ✅ **Xem sản phẩm KM:** Grid hiển thị sản phẩm đang giảm giá
- ✅ **Thông tin chi tiết:**
  - Giá gốc vs giá KM
  - Loại khuyến mãi (%, tiền, combo)
  - Thời hạn áp dụng
  - Bundle info (mua x tặng y)
- ✅ **Filter:** Lọc theo loại KM
- ✅ **Search:** Tìm sản phẩm KM
- ✅ **Badge hiển thị:** Tag "KM" trên sản phẩm

### 3. **POS Dashboard** (`employee-dashboard.js`)

#### Tích hợp khuyến mãi trong bán hàng:
```javascript
// Promotion Index - Map sản phẩm → khuyến mãi
promotionIndex: Map<productId, {promo, price, label}>

// Load danh sách KM khi khởi động
async function loadPromotionIndex()

// Build index: Product → Best Promotion
function buildPromotionIndex(promos, products)

// Chọn KM tốt nhất cho sản phẩm
function selectBestPromotion(product, promos)

// Tính giá sau KM
function getPromoPrice(basePrice, promo)
```

#### Hiển thị trong giỏ hàng:
- ✅ **Badge KM:** Hiển thị tag "KM" trên sản phẩm
- ✅ **Giá gốc gạch ngang:** Strike-through original price
- ✅ **Giá KM hiển thị:** Show promotional price
- ✅ **Label KM:** Hiển thị loại giảm (Giảm 20%, Giảm 5000đ, Combo)
- ✅ **Tính tổng:** Tự động tính với giá KM
- ✅ **Hóa đơn:** In thông tin KM trên hóa đơn

#### Tổng hợp giảm giá:
```
Tạm tính: 100,000đ
Khuyến mãi: -15,000đ (từ promotion)
Giảm giá thành viên: -5,000đ (từ loyalty points)
Tổng cộng: 80,000đ
```

### 4. **Invoice & Reports**

- ✅ **Hóa đơn:** Hiển thị sản phẩm có KM
- ✅ **Receipt:** In thông tin khuyến mãi
- ✅ **Báo cáo:** Track số lượng KM áp dụng (discountCount)

---

## 🔄 LUỒNG XỬ LÝ KHUYẾN MÃI

### 1. **Luồng tạo khuyến mãi** (Owner/Admin)
```
1. Owner mở dialog tạo KM
2. Nhập thông tin:
   - Mã & tên KM
   - Loại giảm (%, tiền, combo)
   - Giá trị giảm
   - Thời gian áp dụng
3. Thêm đối tượng áp dụng:
   - Chọn sản phẩm (autocomplete search)
   - Hoặc chọn danh mục
4. Nếu combo: Thêm bundle items
   - Sản phẩm mua
   - Sản phẩm tặng
   - Số lượng
5. Lưu → POST /api/v1/promotions
6. Backend lưu vào DB
```

### 2. **Luồng áp dụng khuyến mãi** (POS)
```
1. Load products & promotions khi khởi động
2. Build promotion index:
   - Map mỗi productId → best promotion
   - Tính giá sau KM
3. Hiển thị sản phẩm:
   - Show badge "KM"
   - Hiển thị giá gốc gạch ngang
   - Hiển thị giá KM
4. Thêm vào giỏ:
   - Lưu giá KM vào cart item
   - Tự động tính tổng
5. Thanh toán:
   - Tổng = Σ(giá KM × số lượng)
   - Áp dụng thêm giảm giá thành viên
6. Tạo đơn → POST /api/orders
7. In hóa đơn với thông tin KM
```

### 3. **Luồng kiểm tra KM hợp lệ**
```javascript
function isPromotionActive(promo) {
    // Kiểm tra active flag
    if (!promo.active) return false;
    
    // Kiểm tra thời gian
    const now = new Date();
    const start = parseDate(promo.startDate);
    const end = parseDate(promo.endDate);
    
    return (!start || now >= start) && (!end || now <= end);
}
```

---

## 💡 ĐỀ XUẤT PHÁT TRIỂN MỚI

### 🎯 **PRIORITY 1: TỰ ĐỘNG HÓA & THÔNG MINH**

#### 1.1. **Gợi ý sản phẩm khuyến mãi thông minh** ⭐⭐⭐⭐⭐

**Mô tả:** Hệ thống tự động gợi ý thêm sản phẩm KM vào giỏ khi phát hiện cơ hội.

**Tính năng:**
```javascript
// Khi thêm sản phẩm vào giỏ
function addToCart(product, quantity) {
    // Thêm sản phẩm
    cart.push({...});
    
    // 🆕 Kiểm tra gợi ý KM
    const suggestions = checkPromotionOpportunities(cart);
    
    if (suggestions.length > 0) {
        showPromotionSuggestionModal(suggestions);
    }
}

// Gợi ý thông minh
function checkPromotionOpportunities(cart) {
    const suggestions = [];
    
    // 1. Kiểm tra combo "mua X tặng Y"
    activePromotions.forEach(promo => {
        if (promo.discountType === 'BUNDLE') {
            const bundle = promo.bundleItems[0];
            const mainInCart = cart.find(i => i.productId === bundle.mainProductId);
            
            if (mainInCart && mainInCart.quantity >= bundle.mainQuantity) {
                // Có đủ sản phẩm mua → Gợi ý thêm quà tặng
                suggestions.push({
                    type: 'BUNDLE_GIFT',
                    promo: promo,
                    message: `Bạn đã mua ${mainInCart.quantity} ${mainInCart.name}. Thêm ${bundle.giftProductName} miễn phí?`,
                    action: () => addGiftProduct(bundle.giftProductId, bundle.giftQuantity)
                });
            } else if (mainInCart && mainInCart.quantity < bundle.mainQuantity) {
                // Gần đủ → Gợi ý mua thêm
                const needed = bundle.mainQuantity - mainInCart.quantity;
                suggestions.push({
                    type: 'BUNDLE_UPSELL',
                    promo: promo,
                    message: `Mua thêm ${needed} ${mainInCart.name} để nhận ${bundle.giftProductName} miễn phí!`,
                    action: () => setQty(mainInCart.index, bundle.mainQuantity)
                });
            }
        }
    });
    
    // 2. Kiểm tra "mua X giảm Y%"
    activePromotions.forEach(promo => {
        if (promo.minQuantity) {
            const targetInCart = cart.find(i => 
                promo.targets.some(t => t.targetId === i.productId)
            );
            if (targetInCart && targetInCart.quantity < promo.minQuantity) {
                const needed = promo.minQuantity - targetInCart.quantity;
                suggestions.push({
                    type: 'QUANTITY_DISCOUNT',
                    promo: promo,
                    message: `Mua thêm ${needed} để được giảm ${promo.discountValue}%!`,
                    savings: calculatePotentialSavings(targetInCart, promo, needed)
                });
            }
        }
    });
    
    // 3. Kiểm tra "mua A được giảm B"
    // 4. Kiểm tra "mua đủ X sản phẩm từ danh mục Y"
    // ...
    
    return suggestions.sort((a, b) => b.savings - a.savings);
}
```

**UI/UX:**
```html
<!-- Modal gợi ý KM -->
<div class="promotion-suggestion-modal">
    <h3>🎁 Cơ hội tiết kiệm!</h3>
    <div class="suggestion-item">
        <div class="suggestion-icon">🎉</div>
        <div class="suggestion-content">
            <p class="suggestion-message">
                Mua thêm 1 Coca Cola để nhận Snack Poca miễn phí!
            </p>
            <p class="suggestion-savings">Tiết kiệm: 15,000đ</p>
        </div>
        <button class="btn-apply">Thêm ngay</button>
    </div>
</div>
```

**Backend mở rộng:**
```java
// PromotionOpportunityService.java
@Service
public class PromotionOpportunityService {
    
    // Phân tích giỏ hàng và tìm cơ hội KM
    public List<PromotionSuggestion> analyzCart(List<CartItem> cart) {
        // Logic phân tích
    }
    
    // Tính tiết kiệm tiềm năng
    public BigDecimal calculatePotentialSavings(CartItem item, Promotion promo, int additionalQty) {
        // Logic tính toán
    }
}

// API endpoint mới
@PostMapping("/api/v1/promotions/suggestions")
public ResponseEntity<List<PromotionSuggestion>> getPromotionSuggestions(
    @RequestBody CartAnalysisRequest request
) {
    // Trả về gợi ý
}
```

**Database mở rộng:**
```sql
-- Thêm cột vào Promotion
ALTER TABLE promotions ADD COLUMN min_quantity INTEGER;
ALTER TABLE promotions ADD COLUMN min_total_amount DECIMAL(10,2);
ALTER TABLE promotions ADD COLUMN max_usage_per_customer INTEGER;
ALTER TABLE promotions ADD COLUMN priority INTEGER DEFAULT 0;

-- Bảng tracking usage
CREATE TABLE promotion_usage (
    id BIGSERIAL PRIMARY KEY,
    promotion_id BIGINT REFERENCES promotions(promotion_id),
    order_id BIGINT,
    customer_id BIGINT,
    used_at TIMESTAMP DEFAULT NOW(),
    discount_amount DECIMAL(10,2)
);
```

---

#### 1.2. **Tự động thêm quà tặng vào giỏ** ⭐⭐⭐⭐⭐

**Mô tả:** Khi khách mua đủ số lượng sản phẩm theo bundle, tự động thêm quà tặng.

```javascript
// Hook vào sự kiện thay đổi giỏ hàng
function onCartChanged() {
    checkAndAutoAddGifts();
}

function checkAndAutoAddGifts() {
    const activeBundles = getActiveBundlePromotions();
    
    activeBundles.forEach(promo => {
        promo.bundleItems.forEach(bundle => {
            const mainItem = cart.find(i => i.productId === bundle.mainProductId);
            
            if (mainItem && mainItem.quantity >= bundle.mainQuantity) {
                // Có đủ điều kiện → Tự động thêm quà
                const giftInCart = cart.find(i => 
                    i.productId === bundle.giftProductId && 
                    i.isFreeGift === true
                );
                
                const eligibleGiftQty = Math.floor(mainItem.quantity / bundle.mainQuantity) * bundle.giftQuantity;
                
                if (!giftInCart) {
                    // Thêm quà mới
                    addGiftToCart(bundle.giftProductId, eligibleGiftQty, promo);
                } else if (giftInCart.quantity !== eligibleGiftQty) {
                    // Cập nhật số lượng quà
                    updateGiftQuantity(giftInCart.index, eligibleGiftQty);
                }
            } else {
                // Không đủ điều kiện → Xóa quà nếu có
                removeGiftIfExists(bundle.giftProductId, promo.id);
            }
        });
    });
}

function addGiftToCart(productId, quantity, promo) {
    const product = products.find(p => p.id === productId);
    cart.push({
        productId: product.id,
        productName: product.name,
        productPrice: 0, // Miễn phí
        quantity: quantity,
        isFreeGift: true,
        promoId: promo.id,
        promoCode: promo.code,
        promoLabel: `🎁 Quà tặng - ${promo.name}`
    });
    renderCart();
    updateTotal();
    showGiftNotification(product.name, quantity);
}
```

**UI hiển thị:**
```html
<div class="cart-item gift-item">
    <span class="gift-badge">🎁 TẶNG</span>
    <span class="name">Snack Poca</span>
    <span>1</span>
    <span>0đ</span>
    <span class="gift-label">Quà tặng combo</span>
</div>
```

---

#### 1.3. **Flash Sale & Time-limited Promotions** ⭐⭐⭐⭐

**Mô tả:** Khuyến mãi giới hạn thời gian với countdown timer.

**Backend:**
```java
@Entity
public class Promotion {
    // ... existing fields
    
    @Column(name = "is_flash_sale")
    private Boolean isFlashSale = false;
    
    @Column(name = "max_usage_count")
    private Integer maxUsageCount;
    
    @Column(name = "current_usage_count")
    private Integer currentUsageCount = 0;
    
    @Column(name = "stock_limit")
    private Integer stockLimit; // Giới hạn số lượng sản phẩm KM
}

// Service
public boolean canUsePromotion(Long promotionId) {
    Promotion promo = findById(promotionId);
    
    // Kiểm tra thời gian
    if (!isInValidTimePeriod(promo)) return false;
    
    // Kiểm tra số lần sử dụng
    if (promo.getMaxUsageCount() != null && 
        promo.getCurrentUsageCount() >= promo.getMaxUsageCount()) {
        return false;
    }
    
    // Kiểm tra stock
    if (promo.getStockLimit() != null && 
        getPromotionalStock(promo) <= 0) {
        return false;
    }
    
    return true;
}
```

**Frontend:**
```javascript
// Countdown timer
function startFlashSaleCountdown(endTime) {
    const timerEl = document.getElementById('flashSaleTimer');
    
    const interval = setInterval(() => {
        const now = new Date().getTime();
        const distance = endTime - now;
        
        if (distance < 0) {
            clearInterval(interval);
            timerEl.innerHTML = "ĐÃ KẾT THÚC";
            removeFlashSaleProducts();
            return;
        }
        
        const hours = Math.floor(distance / (1000 * 60 * 60));
        const minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
        const seconds = Math.floor((distance % (1000 * 60)) / 1000);
        
        timerEl.innerHTML = `⏰ ${hours}:${minutes}:${seconds}`;
    }, 1000);
}
```

---

### 🎯 **PRIORITY 2: ĐIỀU KIỆN & QUY TẮC**

#### 2.1. **Promotion Rules Engine** ⭐⭐⭐⭐

**Mô tả:** Hệ thống quy tắc linh hoạt cho khuyến mãi.

```java
@Entity
public class PromotionRule {
    @Id
    private Long id;
    
    @ManyToOne
    private Promotion promotion;
    
    @Enumerated(EnumType.STRING)
    private RuleType ruleType;
    
    private String ruleCondition; // JSON format
    
    public enum RuleType {
        MIN_PURCHASE_AMOUNT,    // Tổng đơn tối thiểu
        MIN_QUANTITY,           // Số lượng tối thiểu
        CUSTOMER_TIER,          // Hạng thành viên
        DAY_OF_WEEK,           // Ngày trong tuần
        TIME_OF_DAY,           // Giờ trong ngày
        FIRST_PURCHASE,        // Lần mua đầu
        PAYMENT_METHOD,        // Phương thức thanh toán
        CATEGORY_COMBINATION   // Mua từ nhiều danh mục
    }
}

// Example conditions (JSON):
{
    "minAmount": 100000,
    "minQuantity": 3,
    "allowedTiers": ["VANG", "BACH_KIM", "KIM_CUONG"],
    "allowedDays": ["MON", "TUE", "WED"],
    "timeRange": {"from": "10:00", "to": "14:00"},
    "paymentMethods": ["CASH", "CARD"]
}
```

#### 2.2. **Stackable Promotions** ⭐⭐⭐

**Mô tả:** Cho phép áp dụng nhiều khuyến mãi cùng lúc.

```java
@Entity
public class Promotion {
    // ... existing fields
    
    @Column(name = "is_stackable")
    private Boolean isStackable = false;
    
    @Column(name = "stack_priority")
    private Integer stackPriority = 0;
    
    @ElementCollection
    @CollectionTable(name = "promotion_conflicts")
    private Set<Long> conflictingPromotionIds; // Các KM xung đột
}

// Service
public List<Promotion> getApplicablePromotions(CartItem item, List<Promotion> allPromos) {
    List<Promotion> applicable = new ArrayList<>();
    
    for (Promotion promo : allPromos) {
        if (!canApply(promo, item)) continue;
        
        // Kiểm tra xung đột
        boolean hasConflict = applicable.stream()
            .anyMatch(p -> promo.getConflictingPromotionIds().contains(p.getId()));
        
        if (!hasConflict || promo.getIsStackable()) {
            applicable.add(promo);
        }
    }
    
    // Sắp xếp theo priority
    applicable.sort(Comparator.comparing(Promotion::getStackPriority).reversed());
    
    return applicable;
}
```

---

### 🎯 **PRIORITY 3: PHÂN TÍCH & BÁO CÁO**

#### 3.1. **Promotion Analytics Dashboard** ⭐⭐⭐⭐

**Chức năng:**
- 📊 Hiệu quả khuyến mãi (conversion rate)
- 💰 Doanh thu từ KM vs doanh thu thường
- 📈 Xu hướng sử dụng KM
- 🎯 Top sản phẩm KM bán chạy
- 👥 Phân tích theo nhóm khách hàng

**API:**
```java
@GetMapping("/api/v1/promotions/analytics")
public PromotionAnalytics getAnalytics(
    @RequestParam LocalDate startDate,
    @RequestParam LocalDate endDate
) {
    return analyticsService.analyze(startDate, endDate);
}
```

#### 3.2. **A/B Testing Promotions** ⭐⭐⭐

**Mô tả:** So sánh hiệu quả của 2 chiến lược KM.

---

### 🎯 **PRIORITY 4: TRẢI NGHIỆM KHÁCH HÀNG**

#### 4.1. **Loyalty Point Integration** ⭐⭐⭐⭐⭐

**Mô tả:** Tích hợp điểm thưởng với khuyến mãi.

```javascript
// Combo: Khuyến mãi + Điểm thưởng
function calculateFinalPrice(product, quantity) {
    let price = product.price;
    
    // 1. Áp dụng khuyến mãi sản phẩm
    if (product.hasPromo) {
        price = product.promoPrice;
    }
    
    // 2. Áp dụng giảm giá từ điểm tích lũy
    const memberDiscount = calculateMemberDiscount(price * quantity);
    
    // 3. Tính điểm thưởng nhận được
    const pointsEarned = Math.floor((price * quantity) / 1000);
    
    return {
        finalPrice: price - memberDiscount,
        totalSavings: (product.price - price) + memberDiscount,
        pointsEarned: pointsEarned
    };
}
```

#### 4.2. **Personalized Promotions** ⭐⭐⭐

**Mô tả:** Khuyến mãi cá nhân hóa dựa trên lịch sử mua hàng.

---

### 🎯 **PRIORITY 5: QUẢN TRỊ & MARKETING**

#### 5.1. **Promotion Templates** ⭐⭐⭐

**Mô tả:** Mẫu khuyến mãi có sẵn để tạo nhanh.

```javascript
const PROMOTION_TEMPLATES = [
    {
        name: "Flash Sale Cuối Tuần",
        type: "PERCENT",
        value: 30,
        schedule: "Thứ 7 - Chủ Nhật",
        target: "Tất cả sản phẩm"
    },
    {
        name: "Mua 2 Tặng 1",
        type: "BUNDLE",
        pattern: "2:1",
        target: "Sản phẩm chọn lọc"
    },
    {
        name: "Giảm 50k Đơn 200k",
        type: "FIXED",
        value: 50000,
        minAmount: 200000
    }
];
```

#### 5.2. **Scheduled Promotions** ⭐⭐⭐⭐

**Mô tả:** Lên lịch kích hoạt/tắt KM tự động.

```java
@Scheduled(cron = "0 0 * * * *") // Mỗi giờ
public void checkScheduledPromotions() {
    LocalDateTime now = LocalDateTime.now();
    
    // Kích hoạt KM đến giờ
    List<Promotion> toActivate = promotionRepository
        .findByActiveAndStartDateBefore(false, now);
    toActivate.forEach(p -> p.setActive(true));
    
    // Tắt KM hết hạn
    List<Promotion> toDeactivate = promotionRepository
        .findByActiveAndEndDateBefore(true, now);
    toDeactivate.forEach(p -> p.setActive(false));
    
    promotionRepository.saveAll(toActivate);
    promotionRepository.saveAll(toDeactivate);
}
```

---

## 📊 BẢNG TỔNG HỢP ĐỀ XUẤT

| STT | Tính năng | Độ ưu tiên | Độ khó | Thời gian ước tính |
|-----|-----------|------------|--------|-------------------|
| 1 | Gợi ý sản phẩm KM thông minh | ⭐⭐⭐⭐⭐ | Trung bình | 2-3 tuần |
| 2 | Tự động thêm quà tặng | ⭐⭐⭐⭐⭐ | Dễ | 1 tuần |
| 3 | Flash Sale & Countdown | ⭐⭐⭐⭐ | Trung bình | 1-2 tuần |
| 4 | Promotion Rules Engine | ⭐⭐⭐⭐ | Khó | 3-4 tuần |
| 5 | Stackable Promotions | ⭐⭐⭐ | Trung bình | 2 tuần |
| 6 | Analytics Dashboard | ⭐⭐⭐⭐ | Trung bình | 2-3 tuần |
| 7 | A/B Testing | ⭐⭐⭐ | Khó | 3 tuần |
| 8 | Loyalty Point Integration | ⭐⭐⭐⭐⭐ | Dễ | 1 tuần |
| 9 | Personalized Promotions | ⭐⭐⭐ | Khó | 4 tuần |
| 10 | Promotion Templates | ⭐⭐⭐ | Dễ | 3-5 ngày |
| 11 | Scheduled Promotions | ⭐⭐⭐⭐ | Dễ | 1 tuần |

---

## 🚀 LỘ TRÌNH PHÁT TRIỂN ĐỀ XUẤT

### **Phase 1: Quick Wins (Tháng 1-2)**
1. ✅ Tự động thêm quà tặng vào giỏ
2. ✅ Loyalty Point Integration
3. ✅ Promotion Templates
4. ✅ Scheduled Promotions

### **Phase 2: Core Features (Tháng 3-4)**
1. ✅ Gợi ý sản phẩm KM thông minh
2. ✅ Flash Sale & Countdown
3. ✅ Promotion Rules Engine
4. ✅ Analytics Dashboard

### **Phase 3: Advanced (Tháng 5-6)**
1. ✅ Stackable Promotions
2. ✅ A/B Testing
3. ✅ Personalized Promotions
4. ✅ AI-powered recommendations

---

## 📝 KẾT LUẬN

Hệ thống khuyến mãi hiện tại của BizFlow POS đã có nền tảng vững chắc với:
- ✅ CRUD đầy đủ cho quản lý KM
- ✅ Hỗ trợ nhiều loại khuyến mãi (%, tiền, combo)
- ✅ Tích hợp tốt vào POS workflow
- ✅ UI/UX thân thiện

**Điểm mạnh:**
- Kiến trúc microservice tốt (promotion-service riêng biệt)
- API RESTful chuẩn
- Frontend responsive và dễ sử dụng
- Tính toán giá KM chính xác

**Điểm cần cải thiện:**
- Chưa có gợi ý thông minh cho người dùng
- Chưa tự động hóa việc thêm quà tặng
- Thiếu analytics và reporting
- Chưa có rules engine linh hoạt
- Chưa personalization

**Ưu tiên phát triển:**
1. **Gợi ý KM thông minh** - Tăng doanh thu ngay lập tức
2. **Tự động thêm quà tặng** - Cải thiện UX, giảm lỗi
3. **Analytics** - Đo lường hiệu quả KM
4. **Rules Engine** - Linh hoạt trong chiến lược marketing

---

**Người phân tích:** GitHub Copilot  
**Ngày:** 25/01/2026  
**Version:** 1.0
