# 🎯 Backend API để Tính Giá Promotion

## Tổng Quan

Đã tạo API mới trong Backend để tính giá khuyến mãi cho cart items. Logic tính toán được đẩy từ Frontend sang Backend để đảm bảo:
- ✅ Tính toán nhất quán
- ✅ Dễ maintain và debug
- ✅ Áp dụng đúng cho TẤT CẢ sản phẩm có promotion

## API Endpoint

### POST `/api/v1/promotions/calculate-prices`

**Mô tả:** Tính giá sau khuyến mãi cho các sản phẩm trong giỏ hàng.

**Request Body:**
```json
{
  "items": [
    {
      "productId": 3,
      "basePrice": 10000,
      "quantity": 4
    },
    {
      "productId": 5,
      "basePrice": 15000,
      "quantity": 2
    }
  ]
}
```

**Response:**
```json
[
  {
    "productId": 3,
    "basePrice": 10000,
    "finalPrice": 7500,
    "discount": 2500,
    "promoCode": "COMBO-JAN26",
    "promoName": "Combo Siêu Tiết Kiệm",
    "promoType": "BUNDLE",
    "quantity": 4
  },
  {
    "productId": 5,
    "basePrice": 15000,
    "finalPrice": 12750,
    "discount": 2250,
    "promoCode": "SALE15-JAN26",
    "promoName": "Flash Sale 15%",
    "promoType": "PERCENT",
    "quantity": 2
  }
]
```

## Logic Tính Giá

### 1. **BUNDLE (Mua X Tặng Y)**
```
Ví dụ: Mua 3 tặng 1
- 4 sản phẩm: 1 combo (trả 3) = 3 × giá gốc
- 7 sản phẩm: 1 combo (trả 3) + 3 lẻ (trả 3) = 6 × giá gốc
- 8 sản phẩm: 2 combo (trả 6) = 6 × giá gốc

Công thức:
- setSize = mainQty + giftQty
- completeSets = floor(quantity / setSize)
- remainingQty = quantity % setSize
- totalPrice = (completeSets × mainQty × basePrice) + (remainingQty × basePrice)
- finalPrice = totalPrice / quantity
```

### 2. **PERCENT (Giảm %)**
```
finalPrice = basePrice × (1 - percent / 100)
```

### 3. **FIXED (Giảm Tiền)**
```
finalPrice = max(0, basePrice - discountValue)
```

### 4. **FREE_GIFT (Tặng Quà)**
```
finalPrice = basePrice (không thay đổi giá sản phẩm chính)
```

## Ưu Tiên Promotion

Backend tự động chọn promotion tốt nhất:
1. **Ưu tiên BUNDLE** - Vì phụ thuộc vào số lượng mua
2. Sau đó chọn promotion có discount lớn nhất

## Sử Dụng Trong Frontend

### Tích hợp vào `addToCart()`

```javascript
async function addToCart(productId, productName, productPrice) {
    const qty = getCurrentQty();
    const product = products.find(p => p.id === productId) || {};
    const basePrice = Number(product.price) || productPrice || 0;
    
    // Gọi API Backend để tính giá
    const priceResponse = await calculatePriceFromBackend({
        productId: productId,
        basePrice: basePrice,
        quantity: qty
    });
    
    const resolvedPrice = priceResponse ? priceResponse.finalPrice : basePrice;
    
    // Thêm vào giỏ với giá đã tính
    cart.push({
        productId,
        productName,
        productPrice: resolvedPrice,
        quantity: qty,
        promoCode: priceResponse?.promoCode,
        promoName: priceResponse?.promoName
    });
    
    renderCart();
    updateTotal();
}

async function calculatePriceFromBackend(item) {
    try {
        const res = await fetch(`${API_BASE}/v1/promotions/calculate-prices`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${sessionStorage.getItem('accessToken') || ''}`
            },
            body: JSON.stringify({
                items: [item]
            })
        });
        
        if (!res.ok) return null;
        
        const data = await res.json();
        return data[0] || null;
    } catch (err) {
        console.error('Failed to calculate price:', err);
        return null;
    }
}
```

### Tích hợp vào `updateQty()` và `setQty()`

```javascript
async function updateQty(idx, change) {
    if (cart[idx] && !cart[idx].isReturnItem) {
        cart[idx].quantity = Math.max(1, cart[idx].quantity + change);
        
        // Recalculate price from backend
        const item = cart[idx];
        const product = products.find(p => p.id === item.productId);
        const basePrice = product ? product.price : item.productPrice;
        
        const priceResponse = await calculatePriceFromBackend({
            productId: item.productId,
            basePrice: basePrice,
            quantity: item.quantity
        });
        
        if (priceResponse) {
            item.productPrice = priceResponse.finalPrice;
            item.promoCode = priceResponse.promoCode;
            item.promoName = priceResponse.promoName;
        }
        
        renderCart();
        updateTotal();
    }
}
```

## Testing

### Test với cURL

```bash
# Test BUNDLE promotion (Mua 3 tặng 1)
curl -X POST http://localhost:8080/api/v1/promotions/calculate-prices \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "items": [
      {
        "productId": 3,
        "basePrice": 10000,
        "quantity": 4
      }
    ]
  }'

# Expected response:
# {
#   "productId": 3,
#   "finalPrice": 7500,  // (3 × 10000) / 4 = 7500
#   "discount": 2500
# }
```

### Test Cases

| Sản Phẩm | Số Lượng | Giá Gốc | Promotion | Kết Quả Mong Đợi |
|----------|----------|---------|-----------|------------------|
| Aquafina | 4 | 10,000đ | Mua 3 tặng 1 | 7,500đ/chai |
| Aquafina | 7 | 10,000đ | Mua 3 tặng 1 | 8,571đ/chai |
| Aquafina | 8 | 10,000đ | Mua 3 tặng 1 | 7,500đ/chai |
| Coca | 2 | 15,000đ | Giảm 15% | 12,750đ/chai |

## Migration Guide

### Bước 1: Deploy Backend
```bash
docker compose build backend
docker compose up -d backend
```

### Bước 2: Test API
```bash
# Verify endpoint is working
curl http://localhost:8080/api/v1/promotions/calculate-prices \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"items":[{"productId":3,"basePrice":10000,"quantity":4}]}'
```

### Bước 3: Update Frontend
1. Thêm hàm `calculatePriceFromBackend()`
2. Cập nhật `addToCart()` để gọi API
3. Cập nhật `updateQty()` và `setQty()` để gọi API

### Bước 4: Deploy Frontend
```bash
docker compose build frontend
docker compose up -d frontend
```

### Bước 5: Test End-to-End
1. Mở http://localhost:3000/pages/employee-dashboard.html
2. Thêm sản phẩm có BUNDLE promotion (4 sản phẩm)
3. Kiểm tra giá tính đúng
4. Thay đổi số lượng, kiểm tra giá cập nhật đúng

## Troubleshooting

### Issue: API trả về 500 Error
**Giải pháp:** Check logs backend:
```bash
docker logs bizflow-backend --tail=50
```

### Issue: Giá không cập nhật khi thay đổi số lượng
**Giải pháp:** Đảm bảo `updateQty()` và `setQty()` đã gọi API mới

### Issue: BUNDLE vẫn tính sai
**Giải pháp:** 
1. Kiểm tra bundleItems có dữ liệu: `mainQuantity`, `giftQuantity`
2. Kiểm tra promotion có active và trong thời gian hiệu lực
3. Check log API response

## Lợi Ích

✅ **Centralized Logic** - Tính toán ở 1 nơi duy nhất (Backend)
✅ **Consistent Calculations** - Tất cả sản phẩm đều tính đúng
✅ **Easy Debugging** - Backend log rõ ràng hơn
✅ **Scalable** - Dễ thêm loại promotion mới
✅ **Secure** - Không thể cheat giá từ Frontend

## Next Steps

1. ✅ Migrate logic từ Frontend sang Backend
2. ⏳ Test với tất cả promotion types
3. ⏳ Update Frontend để sử dụng API mới
4. ⏳ Remove old calculation logic từ Frontend
5. ⏳ Add caching để improve performance

---

**Updated:** 25/01/2026
**Version:** 1.0
