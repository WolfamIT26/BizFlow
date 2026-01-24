SELECT
  p.promotion_id,
  p.code,
  p.name,
  p.description,
  p.discount_type AS discountType,
  p.discount_value AS discountValue,
  p.start_date AS startDate,
  p.end_date AS endDate,
  p.active,
  COALESCE(
    (
      SELECT JSON_ARRAYAGG(JSON_OBJECT('targetType', pt.target_type, 'targetId', pt.target_id))
      FROM promotion_targets pt
      WHERE pt.promotion_id = p.promotion_id
    ),
    JSON_ARRAY()
  ) AS targets,
  COALESCE(
    (
      SELECT JSON_ARRAYAGG(JSON_OBJECT(
        'productId', bi.product_id,
        'quantity', bi.quantity,
        'mainProductId', bi.main_product_id,
        'mainQuantity', bi.main_quantity,
        'giftProductId', bi.gift_product_id,
        'giftQuantity', bi.gift_quantity,
        'giftDiscountType', bi.gift_discount_type,
        'giftDiscountValue', bi.gift_discount_value,
        'status', bi.status
      ))
      FROM bundle_items bi
      WHERE bi.promotion_id = p.promotion_id
    ),
    JSON_ARRAY()
  ) AS bundleItems
FROM promotions p;
