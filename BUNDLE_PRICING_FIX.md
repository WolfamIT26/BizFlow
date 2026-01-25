# Bundle Pricing Fix - Mua 3 Tặng 1

## Vấn Đề
Khi có khuyến mãi combo "mua 3 tặng 1", hệ thống tính giá không đúng. Theo logic đúng:
- Mua 3 chai → trả tiền 3 chai (chưa đủ để được tặng)
- Mua 4 chai → trả tiền 3 chai, chai thứ 4 miễn phí (0đ)
- Mua 7 chai → 1 combo (trả 3) + 3 chai lẻ (trả 3) = trả 6 chai
- Mua 8 chai → 2 combo (trả 6) = trả 6 chai, được tặng 2 chai

## Giải Pháp

### 1. Sửa Hàm `getPromoPrice()` (dòng ~1112-1155)
Thêm logic tính giá dựa trên số lượng cho promotion BUNDLE:

```javascript
case 'BUNDLE':
    const bundle = promo.bundleItems[0];
    const mainQty = Number(bundle.mainQuantity) || 3;  // Số lượng phải mua
    const giftQty = Number(bundle.giftQuantity) || 1;  // Số lượng được tặng
    const setSize = mainQty + giftQty;  // Tổng số trong 1 combo
    
    // Tính số combo hoàn chỉnh
    const completeSets = Math.floor(qty / setSize);
    
    // Tính số sản phẩm lẻ (chưa đủ thành combo)
    const remainingQty = qty % setSize;
    
    // Giá = (số combo × số phải trả trong combo × giá gốc) + (số lẻ × giá gốc)
    const bundlePrice = (completeSets * mainQty * basePrice) + (remainingQty * basePrice);
    
    // Trả về giá trung bình mỗi sản phẩm
    return bundlePrice / qty;
```

**Ví dụ:** Nước giá 10,000đ/chai, combo mua 3 tặng 1:
- Mua 1 chai: Trả 10,000đ (giá gốc)
- Mua 3 chai: Trả 30,000đ (giá gốc × 3)
- Mua 4 chai: Trả 30,000đ (1 combo, chỉ trả 3 chai) → Giá TB: 7,500đ/chai
- Mua 7 chai: Trả 60,000đ (1 combo + 3 lẻ) → Giá TB: 8,571đ/chai
- Mua 8 chai: Trả 60,000đ (2 combo, chỉ trả 6 chai) → Giá TB: 7,500đ/chai

### 2. Sửa Hàm `addToCart()` (dòng ~568-650)
Khi thêm sản phẩm vào giỏ có sẵn, tính lại giá theo số lượng mới:

```javascript
if (existingItem) {
    const newQty = existingItem.quantity + qty;
    
    // Nếu có promotion BUNDLE, tính lại giá
    if (promoInfo?.promo && normalizeDiscountType(promoInfo.promo.discountType) === 'BUNDLE') {
        existingItem.productPrice = getPromoPrice(basePrice, promoInfo.promo, newQty);
    }
    
    existingItem.quantity = newQty;
}
```

### 3. Sửa Hàm `updateQty()` (dòng ~1296-1302)
Khi nhấn nút +/- để thay đổi số lượng, tính lại giá:

```javascript
function updateQty(idx, change) {
    if (cart[idx] && !cart[idx].isReturnItem) {
        cart[idx].quantity = Math.max(1, cart[idx].quantity + change);
        
        // Tính lại giá cho BUNDLE promotion
        const item = cart[idx];
        if (item.promoId) {
            const promoInfo = promotionIndex.get(item.productId);
            if (promoInfo?.promo && normalizeDiscountType(promoInfo.promo.discountType) === 'BUNDLE') {
                const product = products.find(p => p.id === item.productId);
                const basePrice = product ? product.sellingPrice : item.productPrice;
                item.productPrice = getPromoPrice(basePrice, promoInfo.promo, item.quantity);
            }
        }
        
        renderCart();
        updateTotal();
    }
}
```

### 4. Sửa Hàm `setQty()` (dòng ~1304-1310)
Khi nhập số lượng trực tiếp, tính lại giá:

```javascript
function setQty(idx, value) {
    const qty = parseInt(value, 10) || 1;
    if (cart[idx] && !cart[idx].isReturnItem) {
        cart[idx].quantity = Math.max(1, qty);
        
        // Tính lại giá cho BUNDLE promotion
        const item = cart[idx];
        if (item.promoId) {
            const promoInfo = promotionIndex.get(item.productId);
            if (promoInfo?.promo && normalizeDiscountType(promoInfo.promo.discountType) === 'BUNDLE') {
                const product = products.find(p => p.id === item.productId);
                const basePrice = product ? product.sellingPrice : item.productPrice;
                item.productPrice = getPromoPrice(basePrice, promoInfo.promo, item.quantity);
            }
        }
        
        renderCart();
        updateTotal();
    }
}
```

## Kiểm Tra
Sau khi deploy, hãy test các trường hợp sau:

1. **Mua 1-3 sản phẩm:** Trả giá gốc cho tất cả
2. **Mua 4 sản phẩm:** Giá TB giảm 25% (trả 3, được 4)
3. **Mua 5-7 sản phẩm:** Giá TB dao động từ 20% đến 14.3%
4. **Mua 8 sản phẩm:** Giá TB giảm 25% (trả 6, được 8)
5. **Thay đổi số lượng trong giỏ:** Giá tự động cập nhật đúng
6. **Thêm sản phẩm vào giỏ có sẵn:** Giá tính lại theo tổng số lượng mới

## Files Đã Sửa
- `FE/assets/js/employee-dashboard.js`
  - Hàm `getPromoPrice()` - Dòng ~1112-1155
  - Hàm `addToCart()` - Dòng ~568-650
  - Hàm `updateQty()` - Dòng ~1296-1302
  - Hàm `setQty()` - Dòng ~1304-1310

## Deploy
```bash
docker compose up -d --build frontend
```

## Kết Quả
✅ Giá combo tính đúng theo số lượng  
✅ Sản phẩm tặng chỉ áp dụng sau khi mua đủ số lượng yêu cầu  
✅ Giá tự động cập nhật khi thay đổi số lượng trong giỏ  
✅ Logic áp dụng đúng cho tất cả cách thêm/sửa số lượng
