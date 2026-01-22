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
      SELECT JSON_ARRAYAGG(JSON_OBJECT('productId', bi.product_id, 'quantity', bi.quantity))
      FROM bundle_items bi
      WHERE bi.promotion_id = p.promotion_id
    ),
    JSON_ARRAY()
  ) AS bundleItems
FROM promotions p;
