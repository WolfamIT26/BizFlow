-- Seed branch admin data
INSERT INTO branch_metrics (id, name, revenue, order_count, active) VALUES
  (1, 'GTVT', 19767770.0, 36, TRUE),
  (2, 'Tân Bình', 0, 0, TRUE);

INSERT INTO branch_growth (id, branch_id, period_label, revenue, order_count) VALUES
  (1, 1, '2026-01', 19767770.0, 36);

INSERT INTO recent_users (id, full_name, registered_at) VALUES
  (8, 'Tân Bình', '2026-01-21 22:25:46'),
  (7, 'Trần Long Tứ', '2026-01-03 21:57:14'),
  (4, 'Phạm Huy Đức Việt ', '2025-12-24 16:44:38'),
  (1, 'Administrator', '2025-12-21 10:47:36'),
  (2, 'Store Owner', '2025-12-21 10:47:36');
