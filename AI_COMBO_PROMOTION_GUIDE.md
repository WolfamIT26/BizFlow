# 🤖 HƯỚNG DẪN TÍCH HỢP AI GỢI Ý COMBO KHUYẾN MÃI

**Ngày tạo:** 25/01/2026  
**Version:** 1.0.0

---

## 📋 MỤC LỤC

1. [Tổng quan](#tổng-quan)
2. [API Endpoints](#api-endpoints)
3. [Tích hợp Frontend](#tích-hợp-frontend)
4. [Ví dụ sử dụng](#ví-dụ-sử-dụng)
5. [Testing](#testing)

---

## 🎯 TỔNG QUAN

### Tính năng

AI Service mới hỗ trợ 2 chức năng chính cho combo khuyến mãi:

1. **Phân tích giỏ hàng** (`/api/analyze-cart-promotions`)
   - Kiểm tra sản phẩm trong giỏ có combo KM không
   - Xác định đủ điều kiện nhận quà tự động
   - Gợi ý mua thêm nếu gần đủ điều kiện

2. **Kiểm tra khuyến mãi sản phẩm** (`/api/check-product-promotions`)
   - Hiển thị thông báo combo khi click vào sản phẩm
   - Ví dụ: "🎁 Mua 3 tặng 1" cho Aquafina

### Luồng hoạt động

```
┌─────────────────────────────────────────────────────────────┐
│  1. Nhân viên thêm sản phẩm vào giỏ (Aquafina x1)          │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  2. Frontend gọi check-product-promotions                   │
│     → Hiển thị thông báo: "Mua 3 tặng 1"                    │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  3. Nhân viên thêm tiếp (Aquafina x2 → total 3)            │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  4. Frontend gọi analyze-cart-promotions                    │
│     → AI phát hiện: đủ 3 sản phẩm!                          │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  5. Tự động thêm 1 Aquafina (quà tặng) vào giỏ             │
│     → Hiển thị: "🎉 Bạn được tặng 1 Aquafina!"              │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔌 API ENDPOINTS

### 1. Phân tích giỏ hàng - `/api/analyze-cart-promotions`

**Method:** `POST`  
**Content-Type:** `application/json`

#### Request Body

```json
{
  "cart_items": [
    {
      "product_id": 123,
      "product_name": "Nước suối Aquafina 500ml",
      "quantity": 3,
      "price": 5000
    },
    {
      "product_id": 456,
      "product_name": "Coca Cola 330ml",
      "quantity": 2,
      "price": 8000
    }
  ],
  "promotions": [
    {
      "id": 1,
      "code": "COMBO-AQUA-JAN26",
      "name": "Combo Aquafina - Mua 3 Tặng 1",
      "discount_type": "BUNDLE",
      "discount_value": 0,
      "active": true,
      "bundle_items": [
        {
          "bundle_id": 1,
          "main_product_id": 123,
          "main_product_name": "Nước suối Aquafina 500ml",
          "gift_product_id": 123,
          "gift_product_name": "Nước suối Aquafina 500ml",
          "main_quantity": 3,
          "gift_quantity": 1
        }
      ]
    }
  ]
}
```

#### Response

```json
{
  "suggestions": [
    {
      "promotion_id": 1,
      "promotion_code": "COMBO-AQUA-JAN26",
      "promotion_name": "Combo Aquafina - Mua 3 Tặng 1",
      "main_product_id": 123,
      "main_product_name": "Nước suối Aquafina 500ml",
      "gift_product_id": 123,
      "gift_product_name": "Nước suối Aquafina 500ml",
      "required_quantity": 3,
      "current_quantity": 3,
      "gift_quantity": 1,
      "is_eligible": true,
      "message": "🎉 Bạn được tặng 1 Nước suối Aquafina 500ml! (Mua 3 tặng 1)",
      "suggestion_type": "ELIGIBLE"
    }
  ],
  "auto_add_gifts": [
    {
      "product_id": 123,
      "product_name": "Nước suối Aquafina 500ml",
      "quantity": 1,
      "price": 0,
      "is_free_gift": true,
      "promo_id": 1,
      "promo_code": "COMBO-AQUA-JAN26",
      "promo_name": "Combo Aquafina - Mua 3 Tặng 1"
    }
  ]
}
```

#### Các loại Suggestion Type

| Type | Mô tả | Ví dụ |
|------|-------|-------|
| `ELIGIBLE` | Đủ điều kiện nhận quà | "🎉 Bạn được tặng 1 Aquafina!" |
| `UPSELL` | Gần đủ điều kiện | "💡 Mua thêm 1 để nhận quà!" |
| `INFO` | Thông tin chung | "ℹ️ Combo mua 3 tặng 1" |

---

### 2. Kiểm tra khuyến mãi sản phẩm - `/api/check-product-promotions`

**Method:** `POST`  
**Content-Type:** `application/json`

#### Request Body

```json
{
  "product_id": 123,
  "promotions": [
    {
      "id": 1,
      "code": "COMBO-AQUA-JAN26",
      "name": "Combo Aquafina - Mua 3 Tặng 1",
      "discount_type": "BUNDLE",
      "discount_value": 0,
      "active": true,
      "bundle_items": [
        {
          "bundle_id": 1,
          "main_product_id": 123,
          "main_product_name": "Nước suối Aquafina 500ml",
          "gift_product_id": 123,
          "gift_product_name": "Nước suối Aquafina 500ml",
          "main_quantity": 3,
          "gift_quantity": 1
        }
      ]
    }
  ]
}
```

#### Response

```json
{
  "product_id": 123,
  "has_combo": true,
  "combos": [
    {
      "promotion_id": 1,
      "promotion_code": "COMBO-AQUA-JAN26",
      "promotion_name": "Combo Aquafina - Mua 3 Tặng 1",
      "main_product_id": 123,
      "main_product_name": "Nước suối Aquafina 500ml",
      "gift_product_id": 123,
      "gift_product_name": "Nước suối Aquafina 500ml",
      "required_quantity": 3,
      "gift_quantity": 1,
      "message": "🎁 Mua 3 tặng 1 Nước suối Aquafina 500ml",
      "display_label": "Combo 3+1"
    }
  ]
}
```

---

## 💻 TÍCH HỢP FRONTEND

### 1. Thêm Service Helper

Tạo file `FE/assets/js/combo-promotion-ai.js`:

```javascript
// Combo Promotion AI Service Helper
const ComboPromotionAI = {
    API_BASE_URL: 'http://localhost:5000',
    
    /**
     * Phân tích giỏ hàng và lấy gợi ý combo
     */
    async analyzeCart(cartItems, promotions) {
        try {
            const response = await fetch(`${this.API_BASE_URL}/api/analyze-cart-promotions`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    cart_items: cartItems,
                    promotions: promotions
                })
            });
            
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            
            return await response.json();
        } catch (error) {
            console.error('Error analyzing cart:', error);
            return { suggestions: [], auto_add_gifts: [] };
        }
    },
    
    /**
     * Kiểm tra khuyến mãi combo cho 1 sản phẩm
     */
    async checkProductPromotions(productId, promotions) {
        try {
            const response = await fetch(`${this.API_BASE_URL}/api/check-product-promotions`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    product_id: productId,
                    promotions: promotions
                })
            });
            
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            
            return await response.json();
        } catch (error) {
            console.error('Error checking product promotions:', error);
            return { has_combo: false, combos: [] };
        }
    }
};
```

---

### 2. Cập nhật Employee Dashboard

Chỉnh sửa `FE/assets/js/employee-dashboard.js`:

```javascript
// THÊM VÀO ĐẦU FILE
let allPromotions = []; // Lưu tất cả khuyến mãi đang hoạt động

// THÊM HÀM LOAD PROMOTIONS
async function loadPromotions() {
    try {
        const response = await fetch(`${API_BASE_URL}/api/v1/promotions/active`, {
            headers: {
                'Authorization': `Bearer ${sessionStorage.getItem('token')}`
            }
        });
        
        if (!response.ok) throw new Error('Failed to load promotions');
        
        allPromotions = await response.json();
        console.log('Loaded promotions:', allPromotions.length);
    } catch (error) {
        console.error('Error loading promotions:', error);
    }
}

// GỌI KHI KHỞI ĐỘNG
async function initialize() {
    await loadProducts();
    await loadPromotions(); // ← THÊM DÒNG NÀY
    await loadPromotionIndex();
    // ... các hàm khởi tạo khác
}

// THÊM HÀM HIỂN THỊ THÔNG BÁO COMBO KHI CLICK SẢN PHẨM
async function onProductClick(product) {
    // Kiểm tra combo promotion cho sản phẩm này
    const result = await ComboPromotionAI.checkProductPromotions(
        product.id,
        allPromotions
    );
    
    if (result.has_combo && result.combos.length > 0) {
        // Hiển thị thông báo combo
        const combo = result.combos[0]; // Lấy combo đầu tiên
        showComboNotification(combo.message);
    }
    
    // Thêm sản phẩm vào giỏ như bình thường
    addToCart(product);
}

// HÀM HIỂN THỊ THÔNG BÁO COMBO
function showComboNotification(message) {
    // Tạo notification element
    const notification = document.createElement('div');
    notification.className = 'combo-notification';
    notification.innerHTML = `
        <div class="combo-notification-content">
            <i class="fas fa-gift"></i>
            <span>${message}</span>
        </div>
    `;
    
    // Thêm vào body
    document.body.appendChild(notification);
    
    // Tự động ẩn sau 3 giây
    setTimeout(() => {
        notification.classList.add('fade-out');
        setTimeout(() => notification.remove(), 300);
    }, 3000);
}

// CHỈNH SỬA HÀM addToCart ĐỂ PHÂN TÍCH COMBO
async function addToCart(product) {
    // Thêm sản phẩm vào giỏ (logic hiện tại)
    const existingItem = cart.find(item => item.productId === product.id);
    
    if (existingItem) {
        existingItem.quantity++;
    } else {
        cart.push({
            productId: product.id,
            productName: product.name,
            productPrice: product.price,
            quantity: 1,
            isFreeGift: false
        });
    }
    
    // Render giỏ hàng
    renderCart();
    updateTotal();
    
    // ← THÊM: Phân tích combo sau khi thêm sản phẩm
    await analyzeCartForCombo();
}

// HÀM MỚI: PHÂN TÍCH GIỎ HÀNG VÀ TỰ ĐỘNG THÊM QUÀ
async function analyzeCartForCombo() {
    // Chuyển đổi giỏ hàng sang format cho AI
    const cartItems = cart
        .filter(item => !item.isFreeGift) // Chỉ gửi sản phẩm thật, không gửi quà tặng
        .map(item => ({
            product_id: item.productId,
            product_name: item.productName,
            quantity: item.quantity,
            price: item.productPrice
        }));
    
    // Gọi AI phân tích
    const result = await ComboPromotionAI.analyzeCart(cartItems, allPromotions);
    
    // Hiển thị suggestions (ELIGIBLE hoặc UPSELL)
    if (result.suggestions.length > 0) {
        displayComboSuggestions(result.suggestions);
    }
    
    // Tự động thêm quà tặng
    if (result.auto_add_gifts.length > 0) {
        result.auto_add_gifts.forEach(gift => {
            autoAddGiftToCart(gift);
        });
    }
}

// HIỂN THỊ GỢI Ý COMBO
function displayComboSuggestions(suggestions) {
    suggestions.forEach(suggestion => {
        if (suggestion.suggestion_type === 'ELIGIBLE') {
            // Đủ điều kiện - Hiển thị thông báo vui mừng
            showComboNotification(suggestion.message);
        } else if (suggestion.suggestion_type === 'UPSELL') {
            // Gần đủ - Hiển thị gợi ý mua thêm
            showUpsellSuggestion(suggestion);
        }
    });
}

// HIỂN THỊ GỢI Ý MUA THÊM
function showUpsellSuggestion(suggestion) {
    const modal = document.createElement('div');
    modal.className = 'upsell-modal';
    modal.innerHTML = `
        <div class="upsell-content">
            <button class="close-btn" onclick="this.parentElement.parentElement.remove()">×</button>
            <div class="upsell-icon">💡</div>
            <h3>Cơ hội tiết kiệm!</h3>
            <p>${suggestion.message}</p>
            <div class="upsell-actions">
                <button class="btn-secondary" onclick="this.closest('.upsell-modal').remove()">
                    Để sau
                </button>
                <button class="btn-primary" onclick="quickAddProduct(${suggestion.main_product_id}, ${suggestion.required_quantity}); this.closest('.upsell-modal').remove();">
                    Thêm ngay
                </button>
            </div>
        </div>
    `;
    
    document.body.appendChild(modal);
}

// TỰ ĐỘNG THÊM QUÀ TẶNG VÀO GIỎ
function autoAddGiftToCart(gift) {
    // Kiểm tra xem quà đã có trong giỏ chưa
    const existingGift = cart.find(
        item => item.productId === gift.product_id && item.isFreeGift === true
    );
    
    if (existingGift) {
        // Cập nhật số lượng nếu đã có
        if (existingGift.quantity !== gift.quantity) {
            existingGift.quantity = gift.quantity;
            renderCart();
            updateTotal();
        }
    } else {
        // Thêm quà mới
        cart.push({
            productId: gift.product_id,
            productName: gift.product_name,
            productPrice: 0,
            quantity: gift.quantity,
            isFreeGift: true,
            promoId: gift.promo_id,
            promoCode: gift.promo_code,
            promoLabel: `🎁 ${gift.promo_name}`
        });
        
        renderCart();
        updateTotal();
        
        // Hiển thị thông báo
        showComboNotification(`🎉 Đã thêm ${gift.quantity} ${gift.product_name} (Quà tặng)`);
    }
}

// XÓA QUÀ TẶNG KHI KHÔNG ĐỦ ĐIỀU KIỆN
async function onCartItemQuantityChange(index, newQuantity) {
    cart[index].quantity = newQuantity;
    
    if (newQuantity <= 0) {
        cart.splice(index, 1);
    }
    
    renderCart();
    updateTotal();
    
    // Phân tích lại giỏ hàng để cập nhật quà tặng
    await removeIneligibleGifts();
    await analyzeCartForCombo();
}

// XÓA QUÀ TẶNG KHÔNG HỢP LỆ
async function removeIneligibleGifts() {
    // Lấy danh sách quà tặng hợp lệ từ AI
    const cartItems = cart
        .filter(item => !item.isFreeGift)
        .map(item => ({
            product_id: item.productId,
            product_name: item.productName,
            quantity: item.quantity,
            price: item.productPrice
        }));
    
    const result = await ComboPromotionAI.analyzeCart(cartItems, allPromotions);
    const validGiftIds = new Set(result.auto_add_gifts.map(g => g.product_id));
    
    // Xóa quà tặng không hợp lệ
    const initialLength = cart.length;
    cart = cart.filter(item => {
        if (item.isFreeGift && !validGiftIds.has(item.productId)) {
            return false; // Xóa
        }
        return true; // Giữ lại
    });
    
    if (cart.length < initialLength) {
        renderCart();
        updateTotal();
    }
}
```

---

### 3. Thêm CSS cho Notifications

Thêm vào `FE/assets/css/employee-dashboard.css`:

```css
/* Combo Notification */
.combo-notification {
    position: fixed;
    top: 20px;
    right: 20px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    padding: 15px 20px;
    border-radius: 10px;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.3);
    z-index: 10000;
    animation: slideIn 0.3s ease-out;
}

.combo-notification-content {
    display: flex;
    align-items: center;
    gap: 10px;
    font-size: 14px;
    font-weight: 500;
}

.combo-notification-content i {
    font-size: 20px;
}

.combo-notification.fade-out {
    animation: fadeOut 0.3s ease-out;
}

@keyframes slideIn {
    from {
        transform: translateX(100%);
        opacity: 0;
    }
    to {
        transform: translateX(0);
        opacity: 1;
    }
}

@keyframes fadeOut {
    from {
        opacity: 1;
    }
    to {
        opacity: 0;
    }
}

/* Upsell Modal */
.upsell-modal {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.5);
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 9999;
    animation: fadeIn 0.2s ease-out;
}

.upsell-content {
    background: white;
    padding: 30px;
    border-radius: 15px;
    max-width: 400px;
    text-align: center;
    position: relative;
    box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
}

.upsell-content .close-btn {
    position: absolute;
    top: 10px;
    right: 15px;
    background: none;
    border: none;
    font-size: 24px;
    cursor: pointer;
    color: #999;
}

.upsell-icon {
    font-size: 48px;
    margin-bottom: 15px;
}

.upsell-content h3 {
    color: #333;
    margin-bottom: 15px;
}

.upsell-content p {
    color: #666;
    margin-bottom: 20px;
    line-height: 1.6;
}

.upsell-actions {
    display: flex;
    gap: 10px;
    justify-content: center;
}

.upsell-actions button {
    padding: 10px 20px;
    border: none;
    border-radius: 8px;
    cursor: pointer;
    font-weight: 500;
    transition: all 0.3s;
}

.btn-primary {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
}

.btn-primary:hover {
    transform: translateY(-2px);
    box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
}

.btn-secondary {
    background: #e0e0e0;
    color: #666;
}

.btn-secondary:hover {
    background: #d0d0d0;
}

/* Gift Item trong giỏ hàng */
.cart-item.gift-item {
    background: linear-gradient(90deg, #fff5e6 0%, #ffe6f0 100%);
    border-left: 4px solid #ff6b9d;
}

.gift-badge {
    display: inline-block;
    background: linear-gradient(135deg, #ff6b9d 0%, #ff8c42 100%);
    color: white;
    padding: 2px 8px;
    border-radius: 5px;
    font-size: 11px;
    font-weight: bold;
    margin-right: 5px;
}

.gift-label {
    color: #ff6b9d;
    font-size: 12px;
    font-style: italic;
}
```

---

### 4. Cập nhật HTML để load script

Thêm vào `FE/pages/employee-dashboard.html`:

```html
<!-- Trước thẻ đóng </body> -->
<script src="../assets/js/combo-promotion-ai.js"></script>
<script src="../assets/js/employee-dashboard.js"></script>
```

---

## 🧪 VÍ DỤ SỬ DỤNG

### Scenario 1: Khách mua đủ combo

```javascript
// Giỏ hàng: 3 Aquafina
const cart = [
    { product_id: 123, product_name: "Aquafina 500ml", quantity: 3, price: 5000 }
];

// Khuyến mãi: Mua 3 tặng 1
const promotions = [
    {
        id: 1,
        code: "COMBO-AQUA-JAN26",
        name: "Combo Aquafina",
        discount_type: "BUNDLE",
        discount_value: 0,
        active: true,
        bundle_items: [
            {
                main_product_id: 123,
                main_product_name: "Aquafina 500ml",
                gift_product_id: 123,
                gift_product_name: "Aquafina 500ml",
                main_quantity: 3,
                gift_quantity: 1
            }
        ]
    }
];

// Kết quả:
// → Hiển thị: "🎉 Bạn được tặng 1 Aquafina 500ml!"
// → Tự động thêm 1 Aquafina (giá 0đ) vào giỏ
```

### Scenario 2: Gợi ý mua thêm

```javascript
// Giỏ hàng: 2 Aquafina (thiếu 1 để đủ combo)
const cart = [
    { product_id: 123, product_name: "Aquafina 500ml", quantity: 2, price: 5000 }
];

// Kết quả:
// → Modal hiển thị: "💡 Mua thêm 1 Aquafina để nhận 1 chai miễn phí!"
// → Button "Thêm ngay" để tự động tăng số lượng lên 3
```

### Scenario 3: Nhiều combo cùng lúc

```javascript
// Giỏ hàng: 6 Aquafina
const cart = [
    { product_id: 123, product_name: "Aquafina 500ml", quantity: 6, price: 5000 }
];

// Combo: Mua 3 tặng 1
// Kết quả:
// → 6 sản phẩm mua = 2 sets (6 / 3 = 2)
// → Tự động thêm 2 Aquafina (quà tặng)
// → Hiển thị: "🎉 Bạn được tặng 2 Aquafina!"
```

---

## 🔬 TESTING

### 1. Test API với cURL

```bash
# Test analyze cart
curl -X POST http://localhost:5000/api/analyze-cart-promotions \
  -H "Content-Type: application/json" \
  -d '{
    "cart_items": [
      {"product_id": 123, "product_name": "Aquafina 500ml", "quantity": 3, "price": 5000}
    ],
    "promotions": [
      {
        "id": 1,
        "code": "COMBO-AQUA",
        "name": "Combo Aquafina",
        "discount_type": "BUNDLE",
        "discount_value": 0,
        "active": true,
        "bundle_items": [
          {
            "bundle_id": 1,
            "main_product_id": 123,
            "main_product_name": "Aquafina 500ml",
            "gift_product_id": 123,
            "gift_product_name": "Aquafina 500ml",
            "main_quantity": 3,
            "gift_quantity": 1
          }
        ]
      }
    ]
  }'
```

### 2. Test với Postman

1. Import collection từ file `postman_collection.json`
2. Chạy test cases:
   - ✅ Test ELIGIBLE (đủ điều kiện)
   - ✅ Test UPSELL (gần đủ)
   - ✅ Test nhiều combo
   - ✅ Test không có combo

### 3. Test Frontend

1. Khởi động Docker:
   ```bash
   docker compose up -d
   ```

2. Mở POS Dashboard: http://localhost:8080/pages/employee-dashboard.html

3. Test cases:
   - ✅ Click vào sản phẩm có combo → Hiển thị thông báo
   - ✅ Thêm 2 sản phẩm → Modal gợi ý mua thêm
   - ✅ Thêm đủ 3 sản phẩm → Tự động thêm quà
   - ✅ Giảm số lượng < 3 → Xóa quà tự động

---

## 📊 MONITORING & DEBUGGING

### Console Logs

Khi phát triển, kiểm tra console logs:

```javascript
// AI Service response
console.log('Analyze result:', result);
// → {suggestions: [...], auto_add_gifts: [...]}

// Cart state
console.log('Current cart:', cart);
// → [{productId: 123, quantity: 3, isFreeGift: false}, ...]
```

### Network Tab

Kiểm tra API calls trong DevTools → Network:
- POST `/api/analyze-cart-promotions` (mỗi khi giỏ thay đổi)
- POST `/api/check-product-promotions` (khi click sản phẩm)

### Common Issues

| Vấn đề | Nguyên nhân | Giải pháp |
|--------|------------|-----------|
| Không tự động thêm quà | AI Service chưa chạy | `docker compose up -d` |
| Modal không hiện | CSS chưa load | Kiểm tra `<link>` tag |
| Quà bị trùng | Logic kiểm tra sai | Xem `existingGift` check |

---

## 🚀 DEPLOYMENT

### Production Checklist

- [ ] AI Service running trên port 5000
- [ ] CORS configured cho production domain
- [ ] Error handling cho network failures
- [ ] Analytics tracking cho combo conversions
- [ ] Database backup trước khi deploy

### Environment Variables

```bash
# AI Service
AI_SERVICE_URL=http://localhost:5000

# Frontend
VITE_AI_SERVICE_URL=${AI_SERVICE_URL}
```

---

## 📝 CHANGELOG

### Version 1.0.0 (25/01/2026)

- ✅ API phân tích giỏ hàng
- ✅ API kiểm tra khuyến mãi sản phẩm
- ✅ Tự động thêm quà tặng
- ✅ Gợi ý mua thêm (upsell)
- ✅ UI notifications & modals
- ✅ CSS styling cho combo features

---

## 🤝 SUPPORT

Nếu có vấn đề khi tích hợp, liên hệ:
- **GitHub Issues:** [BizFlow Repository]
- **Email:** support@bizflow.com
- **Slack:** #bizflow-dev

---

**Tài liệu được tạo bởi:** GitHub Copilot  
**Ngày cập nhật:** 25/01/2026
