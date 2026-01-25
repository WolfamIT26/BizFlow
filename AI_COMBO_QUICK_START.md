# 🤖 AI Combo Promotion - Quick Start

## 📦 Tính năng mới

Hệ thống AI gợi ý và tự động thêm quà tặng combo khuyến mãi vào giỏ hàng.

### ✨ Điểm nổi bật

- ✅ **Gợi ý thông minh**: Hiển thị thông báo combo khi click sản phẩm
- ✅ **Tự động thêm quà**: Khi đủ điều kiện, quà tặng tự động vào giỏ
- ✅ **Gợi ý mua thêm**: Modal đẹp gợi ý khi gần đủ điều kiện
- ✅ **UI/UX hấp dẫn**: Animations và thông báo bắt mắt

## 🚀 Cài đặt

### 1. Khởi động AI Service

```bash
cd BizFlow
docker compose up -d
```

AI Service sẽ chạy trên: http://localhost:5000

### 2. Kiểm tra kết nối

Mở trình duyệt: http://localhost:5000/health

Kết quả: `{"status":"ok"}`

### 3. Test UI

Mở file test: http://localhost:8080/test/test-combo-promotion-ai.html

## 📖 Ví dụ sử dụng

### Scenario 1: Khách mua đủ combo

```javascript
// Giỏ hàng có 3 Aquafina
// Combo: Mua 3 tặng 1

// ✅ Kết quả:
// - Hiển thị: "🎉 Bạn được tặng 1 Aquafina!"
// - Tự động thêm 1 Aquafina (giá 0đ) vào giỏ
```

### Scenario 2: Gợi ý mua thêm

```javascript
// Giỏ hàng có 2 Aquafina
// Combo: Mua 3 tặng 1

// ✅ Kết quả:
// - Modal: "💡 Mua thêm 1 để nhận quà!"
// - Button "Thêm ngay" tự động tăng số lượng
```

## 🔗 Tài liệu đầy đủ

Xem file: [AI_COMBO_PROMOTION_GUIDE.md](AI_COMBO_PROMOTION_GUIDE.md)

## 🧪 Test

1. **Test API**: Dùng cURL hoặc Postman
2. **Test UI**: Mở `test/test-combo-promotion-ai.html`
3. **Test tích hợp**: Vào POS dashboard và thử thêm sản phẩm

## 📞 Hỗ trợ

Nếu có vấn đề:
1. Kiểm tra Docker: `docker ps`
2. Xem logs: `docker logs bizflow-ai-service-1`
3. Đọc file [AI_COMBO_PROMOTION_GUIDE.md](AI_COMBO_PROMOTION_GUIDE.md)

---

**Version:** 1.0.0  
**Date:** 25/01/2026
