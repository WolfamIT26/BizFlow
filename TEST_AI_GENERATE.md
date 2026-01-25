# ✨ TEST AI AUTO-GENERATE PROMOTION NAME & CODE

## 🎯 Tính năng đã implement

AI tự động tạo **Tên**, **Code** và **Mô tả** cho khuyến mãi dựa trên:
- Loại giảm giá (%, cố định, combo)
- Giá trị giảm
- Sản phẩm/danh mục được chọn
- Thời gian hiện tại

---

## 🚀 CÁCH TEST

### **Bước 1: Mở trang Owner Promotions**
```
http://localhost:3000/pages/owner-promotions.html
```

### **Bước 2: Click "+ Thêm khuyến mãi"**

### **Bước 3: Điền thông tin cơ bản**

#### **Test Case 1: Giảm % sản phẩm**
1. Loại giảm: **Giảm %**
2. Giá trị giảm: **20**
3. Click **"+ Thêm đối tượng"**
4. Loại: **Sản phẩm**
5. Tìm và chọn: **Coca Cola** (hoặc bất kỳ sản phẩm nào)
6. Click nút **✨ AI**

**Kết quả mong đợi:**
```
Tên:  Flash Sale 20% Coca Cola - Tháng 1 2026
Code: SALE20-COCO-JAN26
Mô tả: Giảm giá 20% cho sản phẩm được chọn. Áp dụng cho: Coca Cola 1.5L. Nhanh tay đặt hàng ngay hôm nay!
```

---

#### **Test Case 2: Giảm tiền cố định**
1. Loại giảm: **Giảm tiền**
2. Giá trị giảm: **50000**
3. Thêm sản phẩm: **Mì Hảo Hảo**
4. Click nút **✨ AI**

**Kết quả mong đợi:**
```
Tên:  Giảm Ngay 50.000đ Mì Hảo - Tháng 1 2026
Code: GIAM50K-MIHA-JAN26
Mô tả: Giảm ngay 50.000đ khi mua sản phẩm được chọn. Áp dụng cho: Mì Hảo Hảo. Nhanh tay đặt hàng ngay hôm nay!
```

---

#### **Test Case 3: Combo (Bundle)**
1. Loại giảm: **Combo**
2. Giá trị giảm: **1** (Mua 1 tặng 1)
3. Không cần chọn sản phẩm trước
4. Click nút **✨ AI**

**Kết quả mong đợi:**
```
Tên:  Combo Siêu Tiết Kiệm - Tháng 1 2026
Code: COMBO-JAN26
Mô tả: Mua combo sản phẩm với giá ưu đãi đặc biệt. Nhanh tay đặt hàng ngay hôm nay!
```

---

#### **Test Case 4: Nhiều sản phẩm**
1. Loại giảm: **Giảm %**
2. Giá trị giảm: **15**
3. Thêm 3 sản phẩm khác nhau
4. Click nút **✨ AI**

**Kết quả mong đợi:**
```
Tên:  Flash Sale 15% Đa Sản Phẩm - Tháng 1 2026
Code: SALE15-COCO-JAN26  (lấy sản phẩm đầu tiên)
Mô tả: Giảm giá 15% cho sản phẩm được chọn. Áp dụng cho: Coca Cola, Mì Hảo Hảo, Sữa TH và 0 sản phẩm khác. Nhanh tay đặt hàng ngay hôm nay!
```

---

## 🎨 UI FEATURES

### **Nút AI Button**
- Gradient đẹp mắt: 🎨 Purple to Blue
- Icon: ✨ sparkle
- Hover: Nâng lên + shadow
- Loading state: "⏳ AI đang tạo..."

### **Success Animation**
- Background flash màu xanh (green)
- Smooth transition 0.3s
- Hiển thị message: "✨ AI đã tạo tên & code thành công!"

---

## 🔧 TECHNICAL DETAILS

### **Backend API Endpoint**
```
POST http://localhost:5000/api/generate-promotion-details
```

**Request Body:**
```json
{
  "discount_type": "PERCENT",
  "discount_value": 20,
  "targets": [
    {
      "id": 123,
      "name": "Coca Cola 1.5L",
      "type": "PRODUCT"
    }
  ],
  "month": 1,
  "year": 2026
}
```

**Response:**
```json
{
  "name": "Flash Sale 20% Coca Cola - Tháng 1 2026",
  "code": "SALE20-COCO-JAN26",
  "description": "Giảm giá 20% cho sản phẩm được chọn. Áp dụng cho: Coca Cola 1.5L. Nhanh tay đặt hàng ngay hôm nay!",
  "timestamp": "2026-01-25T16:20:40.123456"
}
```

---

## 🧪 MANUAL API TEST

### **Test với curl (PowerShell):**
```powershell
Invoke-RestMethod -Uri "http://localhost:5000/api/generate-promotion-details" `
  -Method Post `
  -Body '{"discount_type":"PERCENT","discount_value":20,"targets":[{"id":123,"name":"Coca Cola 1.5L","type":"PRODUCT"}],"month":1,"year":2026}' `
  -ContentType "application/json"
```

### **Expected Output:**
```
name                                     code              description
----                                     ----              -----------
Flash Sale 20% Coca Cola - Tháng 1 2026 SALE20-COCO-JAN26 Giảm giá 20% cho sản phẩm được chọn...
```

---

## 🎯 ALGORITHM LOGIC

### **Name Generation:**
1. **Base Name:**
   - PERCENT → "Flash Sale X%"
   - FIXED → "Giảm Ngay Xđ"
   - BUNDLE → "Combo Siêu Tiết Kiệm"
   - FREE_GIFT → "Mua Là Có Quà"

2. **Product Context:**
   - 1 sản phẩm → Add short name
   - Nhiều sản phẩm → "Đa Sản Phẩm"

3. **Time Period:**
   - Format: "Tháng X YYYY"

### **Code Generation:**
1. **Type Prefix:**
   - PERCENT → "SALEX" (X = discount value)
   - FIXED → "GIAMXK" (X = value/1000)
   - BUNDLE → "COMBO"
   - FREE_GIFT → "GIFT"

2. **Product Code:**
   - Extract 3-4 letters from product name
   - Examples: "Coca Cola" → "COCO", "Mì Hảo Hảo" → "MIHA"
   - Handle Vietnamese: "Sữa" → "SUA"

3. **Time Suffix:**
   - Format: "MMMYY"
   - Examples: "JAN26", "FEB26", "DEC26"

### **Description Generation:**
1. Main benefit statement
2. Product list (max 3, then "+ X sản phẩm khác")
3. Call to action

---

## ✅ VALIDATION

### **Kiểm tra trước khi call AI:**
- ✅ Loại giảm đã chọn
- ✅ Giá trị giảm > 0
- ❌ Không bắt buộc phải có sản phẩm (optional)

### **Error Handling:**
- Nếu AI Service không chạy → Show error message
- Nếu API lỗi → Show user-friendly message
- Button disabled khi đang loading

---

## 📊 BENEFITS

### **Cho Owner:**
✅ **Tiết kiệm thời gian** - Không cần nghĩ tên & code  
✅ **Nhất quán** - Tên và code theo format chuẩn  
✅ **Hấp dẫn** - Tên catchy, dễ nhớ  
✅ **SEO-friendly** - Code rõ ràng, có ý nghĩa  

### **Cho Developers:**
✅ **Không ảnh hưởng code cũ** - Thêm feature mới hoàn toàn độc lập  
✅ **Dễ maintain** - Code sạch, rõ ràng  
✅ **Scalable** - Dễ thêm logic mới (seasonality, events...)  
✅ **Testable** - API độc lập, dễ test  

---

## 🔮 FUTURE ENHANCEMENTS

### **Version 2.0 Ideas:**
1. **Context-aware suggestions:**
   - Detect holidays → "Khuyến Mãi Tết", "Sale Black Friday"
   - Detect season → "Giải Nhiệt Mùa Hè"

2. **Smart thresholds:**
   - Suggest optimal discount % based on margin
   - Warning if discount too low/high

3. **Multilingual:**
   - Generate English names for international stores
   - Support other languages

4. **A/B Testing:**
   - Generate multiple variations
   - Let owner pick the best one

5. **Historical analysis:**
   - Learn from past promotions
   - "This format generated 30% more sales"

---

## 📝 NOTES

- AI Service phải chạy trên port **5000**
- Frontend phải access được localhost:5000 (CORS enabled)
- Không lưu history của AI generations (stateless)
- Có thể gọi API nhiều lần để tạo tên mới

---

**Status:** ✅ HOÀN THÀNH  
**Date:** 25/01/2026  
**Version:** 1.0.0
