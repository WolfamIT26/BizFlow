# FastAPI AI microservice for product suggestions
# Vietnamese comments for clarity
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

app = FastAPI(title="BizFlow AI Service", version="1.0.0")

# Enable CORS for frontend integration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class ProductIn(BaseModel):
    id: int
    code: str
    name: str
    category: str | None = None

class SuggestRequest(BaseModel):
    products: List[ProductIn]

class Suggestion(BaseModel):
    product_id: int
    suggested_ids: List[int]
    reason: str

class SuggestResponse(BaseModel):
    suggestions: List[Suggestion]

# Models for promotion name & code generation
class PromotionTarget(BaseModel):
    id: int
    name: str
    type: str  # PRODUCT, CATEGORY, ALL

class GeneratePromotionRequest(BaseModel):
    discount_type: str  # PERCENT, FIXED, BUNDLE, FREE_GIFT
    discount_value: float
    targets: Optional[List[PromotionTarget]] = []
    month: Optional[int] = None
    year: Optional[int] = None

class GeneratePromotionResponse(BaseModel):
    name: str
    code: str
    description: str
    timestamp: str

@app.get("/health")
async def health():
    return {"status": "ok"}

@app.post("/suggest-products", response_model=SuggestResponse)
async def suggest_products(req: SuggestRequest):
    # Dummy heuristic: suggest next two IDs in list order
    suggestions: List[Suggestion] = []
    all_ids = [p.id for p in req.products]
    for p in req.products:
        idx = all_ids.index(p.id)
        next_ids = []
        if idx + 1 < len(all_ids):
            next_ids.append(all_ids[idx + 1])
        if idx + 2 < len(all_ids):
            next_ids.append(all_ids[idx + 2])
        suggestions.append(Suggestion(
            product_id=p.id,
            suggested_ids=next_ids,
            reason="Heuristic based on list proximity"
        ))
    return SuggestResponse(suggestions=suggestions)


@app.post("/api/generate-promotion-details", response_model=GeneratePromotionResponse)
async def generate_promotion_details(req: GeneratePromotionRequest):
    """
    Tự động tạo tên, code và mô tả cho khuyến mãi
    
    Examples:
    - Input: Coca Cola, -20% PERCENT
      Output: name="Flash Sale 20% - Tháng 1 2026"
              code="SALE20-COCA-JAN26"
    
    - Input: Bundle Mì + Trứng
      Output: name="Combo Siêu Tiết Kiệm - Tháng 1 2026"
              code="COMBO-MI-JAN26"
    """
    now = datetime.now()
    month = req.month if req.month else now.month
    year = req.year if req.year else now.year
    
    # Generate name
    name = _generate_promotion_name(
        req.discount_type,
        req.discount_value,
        req.targets,
        month,
        year
    )
    
    # Generate code
    code = _generate_promotion_code(
        req.discount_type,
        req.discount_value,
        req.targets,
        month,
        year
    )
    
    # Generate description
    description = _generate_description(
        req.discount_type,
        req.discount_value,
        req.targets
    )
    
    return GeneratePromotionResponse(
        name=name,
        code=code,
        description=description,
        timestamp=now.isoformat()
    )


def _generate_promotion_name(
    discount_type: str,
    discount_value: float,
    targets: List[PromotionTarget],
    month: int,
    year: int
) -> str:
    """Generate catchy promotion name"""
    
    # Month names in Vietnamese
    month_names = [
        "", "Tháng 1", "Tháng 2", "Tháng 3", "Tháng 4", "Tháng 5", "Tháng 6",
        "Tháng 7", "Tháng 8", "Tháng 9", "Tháng 10", "Tháng 11", "Tháng 12"
    ]
    
    # Base name by discount type
    if discount_type == "PERCENT":
        base_name = f"Flash Sale {int(discount_value)}%"
    elif discount_type == "FIXED":
        # Format discount value as currency
        formatted_value = f"{int(discount_value):,}đ".replace(",", ".")
        base_name = f"Giảm Ngay {formatted_value}"
    elif discount_type == "BUNDLE":
        base_name = "Combo Siêu Tiết Kiệm"
    elif discount_type == "FREE_GIFT":
        base_name = "Mua Là Có Quà"
    else:
        base_name = "Khuyến Mãi Đặc Biệt"
    
    # Add product/category context if available
    if targets and len(targets) > 0:
        first_target = targets[0]
        # Extract short product name (first 2-3 words)
        short_name = _extract_short_name(first_target.name)
        if len(targets) == 1:
            base_name = f"{base_name} {short_name}"
        elif len(targets) > 1:
            base_name = f"{base_name} Đa Sản Phẩm"
    
    # Add time period
    full_name = f"{base_name} - {month_names[month]} {year}"
    
    return full_name


def _generate_promotion_code(
    discount_type: str,
    discount_value: float,
    targets: List[PromotionTarget],
    month: int,
    year: int
) -> str:
    """Generate promotion code (uppercase, no spaces, dashes)"""
    
    code_parts = []
    
    # Type prefix
    if discount_type == "PERCENT":
        code_parts.append(f"SALE{int(discount_value)}")
    elif discount_type == "FIXED":
        # Use K for thousands (e.g., 50K for 50,000)
        value_k = int(discount_value / 1000)
        code_parts.append(f"GIAM{value_k}K")
    elif discount_type == "BUNDLE":
        code_parts.append("COMBO")
    elif discount_type == "FREE_GIFT":
        code_parts.append("GIFT")
    else:
        code_parts.append("PROMO")
    
    # Product/category code
    if targets and len(targets) > 0:
        first_target = targets[0]
        # Extract 3-4 letter code from name
        product_code = _extract_product_code(first_target.name)
        code_parts.append(product_code)
    
    # Month code (JAN, FEB, MAR, ...)
    month_codes = [
        "", "JAN", "FEB", "MAR", "APR", "MAY", "JUN",
        "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"
    ]
    month_code = month_codes[month]
    
    # Year (last 2 digits)
    year_code = str(year)[-2:]
    
    code_parts.append(f"{month_code}{year_code}")
    
    # Join with dash
    final_code = "-".join(code_parts)
    
    return final_code.upper()


def _generate_description(
    discount_type: str,
    discount_value: float,
    targets: List[PromotionTarget]
) -> str:
    """Generate promotion description"""
    
    descriptions = []
    
    # Main description
    if discount_type == "PERCENT":
        descriptions.append(f"Giảm giá {int(discount_value)}% cho sản phẩm được chọn.")
    elif discount_type == "FIXED":
        formatted_value = f"{int(discount_value):,}đ".replace(",", ".")
        descriptions.append(f"Giảm ngay {formatted_value} khi mua sản phẩm được chọn.")
    elif discount_type == "BUNDLE":
        descriptions.append("Mua combo sản phẩm với giá ưu đãi đặc biệt.")
    elif discount_type == "FREE_GIFT":
        descriptions.append("Mua sản phẩm chính, nhận ngay quà tặng hấp dẫn.")
    
    # Add target info
    if targets and len(targets) > 0:
        target_names = [t.name for t in targets[:3]]  # Max 3 names
        if len(targets) == 1:
            descriptions.append(f"Áp dụng cho: {target_names[0]}.")
        elif len(targets) <= 3:
            descriptions.append(f"Áp dụng cho: {', '.join(target_names)}.")
        else:
            descriptions.append(f"Áp dụng cho: {', '.join(target_names)} và {len(targets) - 3} sản phẩm khác.")
    
    # Call to action
    descriptions.append("Nhanh tay đặt hàng ngay hôm nay!")
    
    return " ".join(descriptions)


def _extract_short_name(full_name: str) -> str:
    """Extract short name from full product name"""
    # Remove common words and take first 2-3 meaningful words
    words = full_name.split()
    
    # Filter out size/unit words
    skip_words = ["chai", "lon", "hộp", "gói", "thùng", "túi", "kg", "g", "ml", "l"]
    meaningful_words = [w for w in words if w.lower() not in skip_words and not w.replace(".", "").isdigit()]
    
    # Take first 2 words max
    short_words = meaningful_words[:2] if len(meaningful_words) >= 2 else meaningful_words
    
    return " ".join(short_words)


def _extract_product_code(product_name: str) -> str:
    """Extract 3-4 letter code from product name"""
    # Convert Vietnamese to ASCII approximation
    vietnamese_map = {
        'á': 'a', 'à': 'a', 'ả': 'a', 'ã': 'a', 'ạ': 'a',
        'ă': 'a', 'ắ': 'a', 'ằ': 'a', 'ẳ': 'a', 'ẵ': 'a', 'ặ': 'a',
        'â': 'a', 'ấ': 'a', 'ầ': 'a', 'ẩ': 'a', 'ẫ': 'a', 'ậ': 'a',
        'é': 'e', 'è': 'e', 'ẻ': 'e', 'ẽ': 'e', 'ẹ': 'e',
        'ê': 'e', 'ế': 'e', 'ề': 'e', 'ể': 'e', 'ễ': 'e', 'ệ': 'e',
        'í': 'i', 'ì': 'i', 'ỉ': 'i', 'ĩ': 'i', 'ị': 'i',
        'ó': 'o', 'ò': 'o', 'ỏ': 'o', 'õ': 'o', 'ọ': 'o',
        'ô': 'o', 'ố': 'o', 'ồ': 'o', 'ổ': 'o', 'ỗ': 'o', 'ộ': 'o',
        'ơ': 'o', 'ớ': 'o', 'ờ': 'o', 'ở': 'o', 'ỡ': 'o', 'ợ': 'o',
        'ú': 'u', 'ù': 'u', 'ủ': 'u', 'ũ': 'u', 'ụ': 'u',
        'ư': 'u', 'ứ': 'u', 'ừ': 'u', 'ử': 'u', 'ữ': 'u', 'ự': 'u',
        'ý': 'y', 'ỳ': 'y', 'ỷ': 'y', 'ỹ': 'y', 'ỵ': 'y',
        'đ': 'd'
    }
    
    # Normalize name
    normalized = product_name.lower()
    for vn_char, ascii_char in vietnamese_map.items():
        normalized = normalized.replace(vn_char, ascii_char)
    
    # Split into words
    words = normalized.split()
    
    # Filter meaningful words (remove numbers, units)
    skip_words = ["chai", "lon", "hop", "goi", "thung", "tui", "kg", "g", "ml", "l"]
    meaningful = [w for w in words if w not in skip_words and not w.isdigit() and len(w) > 1]
    
    if len(meaningful) == 0:
        return "PROD"
    
    # Strategy 1: If single word, take first 4 chars
    if len(meaningful) == 1:
        return meaningful[0][:4].upper()
    
    # Strategy 2: If multiple words, take first 2 chars from first 2 words
    if len(meaningful) >= 2:
        code = meaningful[0][:2] + meaningful[1][:2]
        return code.upper()
    
    # Fallback
    return meaningful[0][:4].upper()


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=5000)
