-- Seed user admin data
INSERT INTO user_profiles (id, username, full_name, email, phone_number, role, enabled, branch_id, branch_name, created_at, normalized_text) VALUES
  (1, 'admin', 'Administrator', 'admin@bizflow.com', NULL, 'ADMIN', TRUE, NULL, NULL, '2025-12-21 10:47:36', 'admin administrator admin@bizflow.com admin'),
  (2, 'owner', 'Store Owner', 'owner@bizflow.com', NULL, 'OWNER', TRUE, NULL, NULL, '2025-12-21 10:47:36', 'owner store owner owner@bizflow.com owner'),
  (3, 'test', 'Test User', 'test@bizflow.com', NULL, 'EMPLOYEE', TRUE, NULL, NULL, '2025-12-21 10:47:36', 'test test user test@bizflow.com employee'),
  (4, 'vietphd', 'Phạm Huy Đức Việt ', 'nhanvien1@gmail.com', '0902313141', 'EMPLOYEE', TRUE, NULL, NULL, '2025-12-24 16:44:38', 'vietphd phạm huy đức việt  nhanvien1@gmail.com 0902313141 employee'),
  (7, 'Tutl', 'Trần Long Tứ', 'Tutl@gmail.com', '0866066043', 'EMPLOYEE', TRUE, NULL, NULL, '2026-01-03 21:57:14', 'tutl trần long tứ tutl@gmail.com 0866066043 employee'),
  (8, 'TanBinh', 'Tân Bình', 'tanbinh@gmail.com', '0866066042', 'OWNER', TRUE, 2, 'Tân Bình', '2026-01-21 22:25:46', 'tanbinh tân bình tanbinh@gmail.com 0866066042 owner tân bình');

INSERT INTO customer_profiles (id, name, phone, email, tier, total_points, updated_at, normalized_text) VALUES
  (1, 'Pham viet', '0866066042', NULL, NULL, 44, NULL, 'pham viet 0866066042'),
  (2, 'Anh thái', '0866066043', NULL, NULL, 7518, NULL, 'anh thái 0866066043'),
  (5, 'Anh Tứ', '0866066044', NULL, NULL, 0, NULL, 'anh tứ 0866066044'),
  (6, 'Chị Vân', '0866066045', NULL, 'DONG', 243, NULL, 'chị vân 0866066045'),
  (7, 'Test Customer', '0962028826', NULL, 'DONG', 0, NULL, 'test customer 0962028826'),
  (8, 'Test Customer 2', '0928519177', NULL, 'DONG', 10, NULL, 'test customer 2 0928519177'),
  (10, 'Test UI Flow', '0996622189', NULL, 'DONG', 0, NULL, 'test ui flow 0996622189'),
  (11, 'Anh Trung', '0354970825', NULL, 'DONG', 0, NULL, 'anh trung 0354970825');
