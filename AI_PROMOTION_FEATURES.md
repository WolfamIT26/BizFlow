# 🎯 CHỨC NĂNG AI NHỎ CHO PROMOTION SYSTEM

**Ngày:** 25/01/2026  
**Mục tiêu:** Tính năng AI nhỏ gọn, dễ implement, tích hợp vào promotion có sẵn

---

## 🚀 TOP 5 TÍNH NĂNG AI NHỎ (1-2 TUẦN/FEATURE)

---

## 1️⃣ GỢI Ý SẢN PHẨM NÊN KHUYẾN MÃI ⭐⭐⭐⭐⭐

### **Mục đích**
Khi owner mở form tạo khuyến mãi, AI tự động gợi ý:
- Sản phẩm nào **nên** giảm giá (tồn kho cao, bán chậm)
- Giảm bao nhiêu % là **tối ưu**
- Thời gian khuyến mãi phù hợp

### **UI Integration**

```html
<!-- Trong owner-promotions.html -->
<div class="ai-suggestions-panel" id="aiSuggestions" style="display:none">
    <div class="ai-header">
        <span>🤖 AI gợi ý khuyến mãi</span>
        <button onclick="loadAiSuggestions()">🔄 Làm mới</button>
    </div>
    
    <div id="suggestionsList">
        <!-- AI suggestions sẽ được render ở đây -->
    </div>
</div>

<style>
.ai-suggestions-panel {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border-radius: 12px;
    padding: 20px;
    margin-bottom: 20px;
    color: white;
}

.suggestion-card {
    background: rgba(255,255,255,0.95);
    border-radius: 8px;
    padding: 15px;
    margin: 10px 0;
    color: #333;
    cursor: pointer;
    transition: transform 0.2s;
}

.suggestion-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
}

.ai-badge {
    display: inline-block;
    background: #667eea;
    color: white;
    padding: 4px 12px;
    border-radius: 12px;
    font-size: 12px;
    font-weight: bold;
}

.confidence-meter {
    height: 6px;
    background: #e0e0e0;
    border-radius: 3px;
    overflow: hidden;
    margin-top: 8px;
}

.confidence-fill {
    height: 100%;
    background: linear-gradient(90deg, #4caf50, #8bc34a);
    transition: width 0.3s;
}
</style>
```

### **JavaScript Implementation**

```javascript
// Trong owner-promotions.html
async function loadAiSuggestions() {
    const btn = event?.target;
    if (btn) btn.disabled = true;
    
    try {
        const response = await fetch('http://localhost:5000/api/promotion-suggestions', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                context: 'create_promotion',
                limit: 5
            })
        });
        
        const data = await response.json();
        renderAiSuggestions(data.suggestions);
        
    } catch (error) {
        console.error('AI suggestions error:', error);
        showToast('Không thể tải gợi ý AI', 'error');
    } finally {
        if (btn) btn.disabled = false;
    }
}

function renderAiSuggestions(suggestions) {
    const container = document.getElementById('suggestionsList');
    
    if (!suggestions || suggestions.length === 0) {
        container.innerHTML = '<p style="text-align:center;opacity:0.7">Không có gợi ý nào lúc này</p>';
        return;
    }
    
    container.innerHTML = suggestions.map(sug => `
        <div class="suggestion-card" onclick='applyAiSuggestion(${JSON.stringify(sug)})'>
            <div style="display:flex; justify-content:space-between; align-items:start;">
                <div style="flex:1">
                    <h4 style="margin:0 0 8px 0">
                        <span class="ai-badge">${sug.priority}</span>
                        ${sug.product_name}
                    </h4>
                    <p style="margin:4px 0; font-size:14px; color:#666">
                        ${sug.reason}
                    </p>
                    <div style="margin-top:8px; font-size:13px; color:#999">
                        📦 Tồn kho: <strong>${sug.inventory}</strong> | 
                        📊 Bán chậm: <strong>${sug.days_slow}</strong> ngày |
                        💰 Giá: <strong>${formatPrice(sug.current_price)}</strong>
                    </div>
                </div>
                <div style="text-align:right; margin-left:20px;">
                    <div style="font-size:24px; font-weight:bold; color:#667eea">
                        -${sug.recommended_discount}%
                    </div>
                    <div style="font-size:12px; color:#666; margin-top:4px">
                        Dự kiến bán: ${sug.expected_sales}
                    </div>
                </div>
            </div>
            
            <div class="confidence-meter">
                <div class="confidence-fill" style="width: ${sug.confidence * 100}%"></div>
            </div>
            <div style="text-align:right; font-size:11px; color:#999; margin-top:4px">
                Độ tin cậy: ${(sug.confidence * 100).toFixed(0)}%
            </div>
        </div>
    `).join('');
    
    document.getElementById('aiSuggestions').style.display = 'block';
}

function applyAiSuggestion(suggestion) {
    // Tự động điền form khuyến mãi
    const confirmed = confirm(
        `Áp dụng gợi ý AI?\n\n` +
        `Sản phẩm: ${suggestion.product_name}\n` +
        `Giảm giá: ${suggestion.recommended_discount}%\n` +
        `Lý do: ${suggestion.reason}`
    );
    
    if (!confirmed) return;
    
    // Fill form
    document.getElementById('promotionName').value = 
        `Flash Sale - ${suggestion.product_name}`;
    
    document.getElementById('discountType').value = 'PERCENT';
    document.getElementById('discountValue').value = suggestion.recommended_discount;
    
    // Set dates (7 days from now)
    const today = new Date();
    const endDate = new Date(today);
    endDate.setDate(endDate.getDate() + 7);
    
    document.getElementById('startDate').value = today.toISOString().split('T')[0];
    document.getElementById('endDate').value = endDate.toISOString().split('T')[0];
    
    // Add product to target
    addTargetRow();
    const lastRow = document.querySelector('#targetList .inline-row:last-child');
    lastRow.querySelector('.target-type').value = 'PRODUCT';
    lastRow.querySelector('.target-type').dispatchEvent(new Event('change'));
    
    setTimeout(() => {
        const productSelect = lastRow.querySelector('.product-search');
        const productId = suggestion.product_id;
        const productName = suggestion.product_name;
        
        // Set value
        productSelect.value = `${formatLabelId(productId)} - ${productName}`;
        
        // Set hidden select
        const hiddenSelect = lastRow.querySelector('.target-id');
        const option = document.createElement('option');
        option.value = productId;
        option.textContent = productName;
        hiddenSelect.appendChild(option);
        hiddenSelect.value = productId;
        
        showToast('✅ Đã áp dụng gợi ý AI!', 'success');
        
        // Scroll to form
        document.querySelector('.modal-container').scrollTop = 0;
        
    }, 100);
}

// Load AI suggestions khi mở form tạo mới
document.getElementById('addPromotionBtn')?.addEventListener('click', () => {
    setTimeout(() => {
        loadAiSuggestions();
    }, 500);
});
```

### **Backend AI Service (Python)**

```python
# ai_service/app.py
from flask import Flask, request, jsonify
from datetime import datetime, timedelta
import pandas as pd
import numpy as np

app = Flask(__name__)

@app.route('/api/promotion-suggestions', methods=['POST'])
def get_promotion_suggestions():
    """
    Gợi ý sản phẩm nên khuyến mãi
    
    Logic:
    1. Lấy sản phẩm có inventory cao + bán chậm
    2. Tính discount % tối ưu
    3. Dự đoán impact
    4. Rank theo priority
    """
    data = request.json
    limit = data.get('limit', 5)
    
    # Lấy data từ database
    products = get_products_with_metrics()
    
    # Score từng sản phẩm
    suggestions = []
    for product in products:
        score = calculate_promotion_priority(product)
        
        if score > 0.5:  # Threshold
            suggestion = {
                'product_id': product['id'],
                'product_name': product['name'],
                'current_price': product['price'],
                'inventory': product['inventory'],
                'days_slow': product['days_since_last_sale'],
                'recommended_discount': calculate_optimal_discount(product),
                'expected_sales': predict_sales_with_discount(product),
                'reason': generate_reason(product),
                'priority': get_priority_label(score),
                'confidence': score
            }
            suggestions.append(suggestion)
    
    # Sort by score
    suggestions.sort(key=lambda x: x['confidence'], reverse=True)
    
    return jsonify({
        'suggestions': suggestions[:limit],
        'timestamp': datetime.now().isoformat()
    })


def calculate_promotion_priority(product):
    """
    Tính điểm ưu tiên khuyến mãi
    
    Factors:
    - Inventory level (càng cao càng ưu tiên)
    - Days since last sale (càng lâu càng ưu tiên)
    - Profit margin (đủ margin để giảm giá)
    - Seasonality (sản phẩm theo mùa)
    """
    score = 0.0
    
    # 1. Inventory pressure (0-0.4)
    inventory_ratio = product['inventory'] / product['avg_inventory']
    if inventory_ratio > 2.0:  # Gấp đôi bình thường
        score += 0.4
    elif inventory_ratio > 1.5:
        score += 0.3
    elif inventory_ratio > 1.2:
        score += 0.2
    
    # 2. Sales velocity (0-0.3)
    days_slow = product['days_since_last_sale']
    if days_slow > 14:
        score += 0.3
    elif days_slow > 7:
        score += 0.2
    elif days_slow > 3:
        score += 0.1
    
    # 3. Profit margin (0-0.2)
    margin = (product['price'] - product['cost']) / product['price']
    if margin > 0.4:  # Margin tốt, có thể giảm nhiều
        score += 0.2
    elif margin > 0.25:
        score += 0.1
    
    # 4. Perishability (0-0.1)
    if product.get('expiry_date'):
        days_to_expiry = (product['expiry_date'] - datetime.now()).days
        if days_to_expiry < 7:
            score += 0.1
    
    return min(score, 1.0)


def calculate_optimal_discount(product):
    """
    Tính % discount tối ưu
    
    Strategy:
    - High inventory + slow sales → 20-30%
    - Medium inventory → 10-15%
    - Near expiry → 30-50%
    - Maintain minimum profit margin
    """
    margin = (product['price'] - product['cost']) / product['price']
    inventory_ratio = product['inventory'] / product['avg_inventory']
    days_slow = product['days_since_last_sale']
    
    # Base discount
    discount = 10
    
    # Adjust based on inventory
    if inventory_ratio > 2.0:
        discount += 15
    elif inventory_ratio > 1.5:
        discount += 10
    
    # Adjust based on sales velocity
    if days_slow > 14:
        discount += 10
    elif days_slow > 7:
        discount += 5
    
    # Check expiry
    if product.get('expiry_date'):
        days_to_expiry = (product['expiry_date'] - datetime.now()).days
        if days_to_expiry < 7:
            discount += 20
    
    # Ensure minimum margin (10%)
    max_discount = (margin - 0.1) * 100
    discount = min(discount, max_discount)
    
    # Round to 5%
    discount = round(discount / 5) * 5
    
    return max(5, min(discount, 50))  # Between 5-50%


def predict_sales_with_discount(product):
    """
    Dự đoán số lượng bán được nếu có discount
    
    Simple model:
    - Mỗi 10% discount → tăng 20-30% sales
    """
    avg_daily_sales = product.get('avg_daily_sales', 5)
    discount = calculate_optimal_discount(product)
    
    # Elasticity: -2.5 (mỗi 1% discount tăng 2.5% demand)
    elasticity = 2.5
    demand_increase = (discount / 100) * elasticity
    
    # Predict for 7 days
    predicted_daily = avg_daily_sales * (1 + demand_increase)
    predicted_total = predicted_daily * 7
    
    return int(predicted_total)


def generate_reason(product):
    """
    Generate human-readable reason
    """
    reasons = []
    
    inventory_ratio = product['inventory'] / product['avg_inventory']
    if inventory_ratio > 1.5:
        reasons.append(f"Tồn kho cao ({product['inventory']} sp)")
    
    days_slow = product['days_since_last_sale']
    if days_slow > 7:
        reasons.append(f"Bán chậm ({days_slow} ngày)")
    
    if product.get('expiry_date'):
        days_to_expiry = (product['expiry_date'] - datetime.now()).days
        if days_to_expiry < 14:
            reasons.append(f"Sắp hết hạn ({days_to_expiry} ngày)")
    
    if not reasons:
        reasons.append("Tối ưu doanh thu")
    
    return " • ".join(reasons)


def get_priority_label(score):
    """Priority badge"""
    if score >= 0.8:
        return "KHẨN CẤP"
    elif score >= 0.6:
        return "CAO"
    elif score >= 0.4:
        return "TRUNG BÌNH"
    else:
        return "THẤP"


def get_products_with_metrics():
    """
    Lấy products với metrics từ database
    
    TODO: Connect to real database
    """
    # Mock data for demo
    return [
        {
            'id': 123,
            'name': 'Coca Cola 1.5L',
            'price': 20000,
            'cost': 15000,
            'inventory': 500,
            'avg_inventory': 200,
            'days_since_last_sale': 15,
            'avg_daily_sales': 10,
            'category': 'Nước giải khát'
        },
        {
            'id': 456,
            'name': 'Mì Hảo Hảo thùng 30 gói',
            'price': 95000,
            'cost': 80000,
            'inventory': 120,
            'avg_inventory': 50,
            'days_since_last_sale': 8,
            'avg_daily_sales': 3,
            'category': 'Mì ăn liền'
        },
        {
            'id': 789,
            'name': 'Sữa TH True Milk 1L',
            'price': 35000,
            'cost': 28000,
            'inventory': 80,
            'avg_inventory': 100,
            'days_since_last_sale': 2,
            'avg_daily_sales': 15,
            'expiry_date': datetime.now() + timedelta(days=5),
            'category': 'Sữa'
        }
    ]


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
```

---

## 2️⃣ VALIDATION KHUYẾN MÃI THÔNG MINH ⭐⭐⭐⭐

### **Mục đích**
Khi owner tạo/sửa khuyến mãi, AI kiểm tra và cảnh báo:
- ⚠️ Giảm giá quá sâu (lỗ)
- ⚠️ Trùng lặp với KM khác
- ⚠️ Không hiệu quả (quá thấp)
- ✅ Gợi ý cải thiện

### **Implementation**

```javascript
// Validate trước khi submit
async function validatePromotionWithAI(payload) {
    const response = await fetch('http://localhost:5000/api/validate-promotion', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
    });
    
    const result = await response.json();
    
    if (!result.valid) {
        // Show warnings
        const warnings = result.warnings.map(w => 
            `<li>${w.message}</li>`
        ).join('');
        
        const confirmed = confirm(
            `⚠️ AI phát hiện vấn đề:\n\n${result.warnings.map(w => w.message).join('\n')}\n\nVẫn tiếp tục?`
        );
        
        return confirmed;
    }
    
    // Show suggestions
    if (result.suggestions && result.suggestions.length > 0) {
        showAiSuggestions(result.suggestions);
    }
    
    return true;
}
```

```python
# Backend validation
@app.route('/api/validate-promotion', methods=['POST'])
def validate_promotion():
    """Validate promotion với AI"""
    promotion = request.json
    
    warnings = []
    suggestions = []
    
    # 1. Check margin
    if promotion['discountType'] == 'PERCENT':
        if promotion['discountValue'] > 40:
            warnings.append({
                'type': 'margin_risk',
                'severity': 'high',
                'message': f"Giảm {promotion['discountValue']}% có thể gây lỗ!"
            })
    
    # 2. Check overlap
    overlaps = check_overlapping_promotions(promotion)
    if overlaps:
        warnings.append({
            'type': 'overlap',
            'severity': 'medium',
            'message': f"Trùng với {len(overlaps)} khuyến mãi khác"
        })
    
    # 3. Check effectiveness
    if promotion['discountValue'] < 5:
        suggestions.append({
            'type': 'effectiveness',
            'message': "Giảm dưới 5% thường ít hiệu quả. Gợi ý: 10-15%"
        })
    
    # 4. Check duration
    start = datetime.fromisoformat(promotion['startDate'])
    end = datetime.fromisoformat(promotion['endDate'])
    duration = (end - start).days
    
    if duration < 2:
        suggestions.append({
            'type': 'duration',
            'message': "Thời gian quá ngắn. Gợi ý: 3-7 ngày"
        })
    elif duration > 30:
        warnings.append({
            'type': 'duration',
            'severity': 'low',
            'message': "Khuyến mãi quá dài có thể giảm urgency"
        })
    
    return jsonify({
        'valid': len([w for w in warnings if w['severity'] == 'high']) == 0,
        'warnings': warnings,
        'suggestions': suggestions
    })
```

---

## 3️⃣ AUTO-GENERATE PROMOTION NAME & CODE ⭐⭐⭐⭐

### **Mục đích**
AI tự động tạo tên và code khuyến mãi hấp dẫn

### **Examples**
- Sản phẩm: Coca Cola, -20% → "FLASH20-COCA-JAN26"
- Bundle: Mì + Trứng → "COMBO-MI-TRUNG-SAVE15"
- Free gift → "BUY2-GET1-SNACKS"

```javascript
async function generatePromotionDetails() {
    const discountType = document.getElementById('discountType').value;
    const discountValue = document.getElementById('discountValue').value;
    const targets = getSelectedTargets();
    
    const response = await fetch('http://localhost:5000/api/generate-promotion-details', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            discountType,
            discountValue,
            targets,
            context: {
                month: new Date().getMonth() + 1,
                year: new Date().getFullYear()
            }
        })
    });
    
    const data = await response.json();
    
    // Auto-fill
    document.getElementById('promotionName').value = data.name;
    document.getElementById('promotionCode').value = data.code;
    document.getElementById('promotionDescription').value = data.description;
    
    showToast('✨ AI đã tạo tên & code!', 'success');
}
```

```python
@app.route('/api/generate-promotion-details', methods=['POST'])
def generate_promotion_details():
    """Auto-generate promotion name, code, description"""
    data = request.json
    
    discount_type = data['discountType']
    discount_value = data['discountValue']
    targets = data['targets']
    month = data['context']['month']
    year = data['context']['year']
    
    # Generate name
    if discount_type == 'PERCENT':
        name = f"Flash Sale {discount_value}%"
    elif discount_type == 'BUNDLE':
        name = "Combo Siêu Tiết Kiệm"
    elif discount_type == 'FREE_GIFT':
        name = "Mua Là Có Quà"
    else:
        name = f"Giảm {format_currency(discount_value)}"
    
    # Add time context
    month_name = get_month_name(month)
    name += f" - {month_name} {year}"
    
    # Generate code
    code_parts = []
    
    # Type prefix
    if discount_type == 'PERCENT':
        code_parts.append(f"SALE{discount_value}")
    elif discount_type == 'BUNDLE':
        code_parts.append("COMBO")
    elif discount_type == 'FREE_GIFT':
        code_parts.append("GIFT")
    
    # Product/category prefix
    if targets and len(targets) > 0:
        target_name = targets[0]['name'][:4].upper()
        code_parts.append(target_name)
    
    # Month code
    month_code = ['JAN','FEB','MAR','APR','MAY','JUN',
                  'JUL','AUG','SEP','OCT','NOV','DEC'][month-1]
    code_parts.append(f"{month_code}{str(year)[-2:]}")
    
    code = "-".join(code_parts)
    
    # Generate description
    description = generate_description(discount_type, discount_value, targets)
    
    return jsonify({
        'name': name,
        'code': code,
        'description': description
    })
```

---

## 4️⃣ PROMOTION PERFORMANCE PREDICTOR ⭐⭐⭐

### **Mục đích**
Dự đoán hiệu quả của khuyến mãi trước khi tạo

```javascript
async function predictPromotionImpact() {
    const payload = buildPayload();
    
    const response = await fetch('http://localhost:5000/api/predict-impact', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
    });
    
    const prediction = await response.json();
    
    // Show prediction panel
    showPredictionPanel(prediction);
}

function showPredictionPanel(prediction) {
    const panel = document.createElement('div');
    panel.className = 'prediction-panel';
    panel.innerHTML = `
        <h4>📊 Dự đoán hiệu quả</h4>
        <div class="prediction-metrics">
            <div class="metric">
                <span class="label">Doanh thu dự kiến</span>
                <span class="value">${formatPrice(prediction.expected_revenue)}</span>
            </div>
            <div class="metric">
                <span class="label">Số đơn hàng</span>
                <span class="value">${prediction.expected_orders}</span>
            </div>
            <div class="metric">
                <span class="label">Tăng trưởng</span>
                <span class="value ${prediction.growth_rate > 0 ? 'positive' : 'negative'}">
                    ${prediction.growth_rate > 0 ? '+' : ''}${prediction.growth_rate}%
                </span>
            </div>
            <div class="metric">
                <span class="label">ROI</span>
                <span class="value">${prediction.roi}%</span>
            </div>
        </div>
        <p class="prediction-note">${prediction.note}</p>
    `;
    
    document.querySelector('.modal-body').prepend(panel);
}
```

---

## 5️⃣ SMART BUNDLE SUGGESTIONS ⭐⭐⭐⭐⭐

### **Mục đích**
Gợi ý combo sản phẩm nào nên bán cùng nhau (association rules)

```javascript
async function suggestBundles() {
    const response = await fetch('http://localhost:5000/api/suggest-bundles');
    const data = await response.json();
    
    showBundleSuggestions(data.bundles);
}

function showBundleSuggestions(bundles) {
    const html = bundles.map(bundle => `
        <div class="bundle-suggestion" onclick='applyBundle(${JSON.stringify(bundle)})'>
            <div class="bundle-products">
                <strong>${bundle.main_product}</strong>
                <span>+</span>
                <strong>${bundle.gift_product}</strong>
            </div>
            <div class="bundle-stats">
                <span>Thường mua cùng: ${bundle.confidence}%</span>
                <span>Tiết kiệm: ${formatPrice(bundle.savings)}</span>
            </div>
        </div>
    `).join('');
    
    document.getElementById('bundleSuggestions').innerHTML = html;
}
```

```python
@app.route('/api/suggest-bundles', methods=['GET'])
def suggest_bundles():
    """
    Gợi ý bundle dựa trên association rules
    (Frequent Itemsets Mining)
    """
    from mlxtend.frequent_patterns import apriori, association_rules
    
    # Get transaction data
    transactions = get_transaction_history()
    
    # Build item matrix
    basket = transactions.groupby(['order_id', 'product_id'])['quantity'].sum().unstack().fillna(0)
    basket = basket.applymap(lambda x: 1 if x > 0 else 0)
    
    # Find frequent itemsets
    frequent_itemsets = apriori(basket, min_support=0.02, use_colnames=True)
    
    # Generate rules
    rules = association_rules(frequent_itemsets, metric="lift", min_threshold=1.2)
    
    # Convert to bundle suggestions
    bundles = []
    for idx, row in rules.iterrows():
        main_product = list(row['antecedents'])[0]
        gift_product = list(row['consequents'])[0]
        
        bundles.append({
            'main_product_id': main_product,
            'main_product': get_product_name(main_product),
            'gift_product_id': gift_product,
            'gift_product': get_product_name(gift_product),
            'confidence': round(row['confidence'] * 100, 1),
            'lift': round(row['lift'], 2),
            'savings': calculate_bundle_savings(main_product, gift_product)
        })
    
    # Sort by lift
    bundles.sort(key=lambda x: x['lift'], reverse=True)
    
    return jsonify({
        'bundles': bundles[:10]
    })
```

---

## 📦 DEPLOYMENT

### **Cập nhật AI Service**

```dockerfile
# ai_service/Dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy code
COPY app.py .

# Expose port
EXPOSE 5000

CMD ["python", "app.py"]
```

```txt
# ai_service/requirements.txt
Flask==3.0.0
Flask-CORS==4.0.0
pandas==2.1.0
numpy==1.26.0
scikit-learn==1.3.0
mlxtend==0.23.0
```

### **Update docker-compose.yml**

```yaml
services:
  ai-service:
    build: ./ai_service
    ports:
      - "5000:5000"
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/bizflow
    volumes:
      - ./ai_service:/app
    restart: unless-stopped
```

---

## 🚀 LỘ TRÌNH IMPLEMENT

### **Tuần 1: AI Suggestion Panel**
- [ ] UI cho suggestion panel trong owner-promotions.html
- [ ] Backend API `/api/promotion-suggestions`
- [ ] Integration & testing
- [ ] Deploy to production

### **Tuần 2: Validation & Auto-generate**
- [ ] Validation logic
- [ ] Auto-generate name/code
- [ ] Bundle suggestions
- [ ] Testing

### **Tuần 3-4: Polish & Monitor**
- [ ] Performance optimization
- [ ] Add analytics tracking
- [ ] User feedback loop
- [ ] Documentation

---

## 💡 KẾT LUẬN

**Tính năng nào nên làm trước?**

1. **AI Suggestion Panel** ⭐⭐⭐⭐⭐
   - ROI cao nhất
   - User-visible feature
   - Giải quyết pain point: "Không biết nên KM sản phẩm nào"
   - 1 tuần implement

2. **Smart Bundle Suggestions** ⭐⭐⭐⭐⭐  
   - Trả lời đúng câu hỏi của bạn
   - Tự động gợi ý combo
   - Dựa trên data thực tế
   - 1 tuần implement

3. **Auto-generate Name/Code** ⭐⭐⭐⭐
   - Tiện lợi
   - Tiết kiệm thời gian
   - 2-3 ngày implement

Bạn muốn tôi implement cái nào trước? 🚀
