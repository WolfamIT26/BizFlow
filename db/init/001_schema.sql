-- BizFlow schema (subset + placeholders) with required 23 tables
CREATE DATABASE IF NOT EXISTS bizflow_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE bizflow_db;

-- Users
CREATE TABLE IF NOT EXISTS users (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  full_name VARCHAR(100),
  phone_number VARCHAR(20),
  role VARCHAR(20) NOT NULL,
  enabled BOOLEAN NOT NULL DEFAULT TRUE,
  branch_id BIGINT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  note TEXT
) ENGINE=InnoDB;

-- Branches
CREATE TABLE IF NOT EXISTS branches (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120) NOT NULL UNIQUE,
  address VARCHAR(255),
  phone VARCHAR(20),
  email VARCHAR(120),
  owner_id BIGINT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_branch_owner FOREIGN KEY (owner_id) REFERENCES users(id)
) ENGINE=InnoDB;

-- Add foreign key constraint for branch_id in users table
ALTER TABLE users ADD CONSTRAINT fk_user_branch FOREIGN KEY (branch_id) REFERENCES branches(id) ON DELETE SET NULL;

-- 2. audit_logs
CREATE TABLE IF NOT EXISTS audit_logs (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT,
  action VARCHAR(100),
  detail TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX(user_id),
  CONSTRAINT fk_audit_user FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB;

-- 3. customers
CREATE TABLE IF NOT EXISTS customers (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  phone VARCHAR(20),
  email VARCHAR(120),
  address VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 4. loyalty_points
CREATE TABLE IF NOT EXISTS loyalty_points (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  customer_id BIGINT NOT NULL,
  points INT NOT NULL DEFAULT 0,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_lp_customer FOREIGN KEY (customer_id) REFERENCES customers(id)
) ENGINE=InnoDB;

-- 5. loyalty_transactions
CREATE TABLE IF NOT EXISTS loyalty_transactions (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  customer_id BIGINT NOT NULL,
  change_points INT NOT NULL,
  reason VARCHAR(200),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_lpt_customer FOREIGN KEY (customer_id) REFERENCES customers(id)
) ENGINE=InnoDB;

-- 6. membership_tiers
CREATE TABLE IF NOT EXISTS membership_tiers (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  min_points INT NOT NULL
) ENGINE=InnoDB;

-- 7. product_categories
CREATE TABLE IF NOT EXISTS product_categories (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120) NOT NULL
) ENGINE=InnoDB;

-- 8. products
CREATE TABLE IF NOT EXISTS products (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  category_id BIGINT,
  code VARCHAR(50) UNIQUE NOT NULL,
  name VARCHAR(200) NOT NULL,
  price DECIMAL(15,2) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  CONSTRAINT fk_prod_cat FOREIGN KEY (category_id) REFERENCES product_categories(id)
) ENGINE=InnoDB;

-- 9. suppliers
CREATE TABLE IF NOT EXISTS suppliers (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  phone VARCHAR(20),
  email VARCHAR(120)
) ENGINE=InnoDB;

-- 10. purchase_orders
CREATE TABLE IF NOT EXISTS purchase_orders (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  supplier_id BIGINT,
  po_code VARCHAR(50) UNIQUE,
  total DECIMAL(15,2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_po_supplier FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
) ENGINE=InnoDB;

-- 11. purchase_order_items
CREATE TABLE IF NOT EXISTS purchase_order_items (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  purchase_order_id BIGINT NOT NULL,
  product_id BIGINT NOT NULL,
  quantity INT NOT NULL,
  unit_price DECIMAL(15,2) NOT NULL,
  CONSTRAINT fk_poi_po FOREIGN KEY (purchase_order_id) REFERENCES purchase_orders(id) ON DELETE CASCADE,
  CONSTRAINT fk_poi_prod FOREIGN KEY (product_id) REFERENCES products(id)
) ENGINE=InnoDB;

-- 12. orders
CREATE TABLE IF NOT EXISTS orders (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  order_code VARCHAR(50) UNIQUE,
  customer_id BIGINT,
  employee_id BIGINT,
  total_amount DECIMAL(15,2) NOT NULL,
  status VARCHAR(20) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES customers(id),
  CONSTRAINT fk_orders_employee FOREIGN KEY (employee_id) REFERENCES users(id)
) ENGINE=InnoDB;

-- 13. order_items
CREATE TABLE IF NOT EXISTS order_items (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  order_id BIGINT NOT NULL,
  product_id BIGINT NOT NULL,
  quantity INT NOT NULL,
  unit_price DECIMAL(15,2) NOT NULL,
  CONSTRAINT fk_oi_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  CONSTRAINT fk_oi_prod FOREIGN KEY (product_id) REFERENCES products(id)
) ENGINE=InnoDB;

-- 14. payment_logs
CREATE TABLE IF NOT EXISTS payment_logs (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  order_id BIGINT,
  amount DECIMAL(15,2) NOT NULL,
  method VARCHAR(30),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_pl_order FOREIGN KEY (order_id) REFERENCES orders(id)
) ENGINE=InnoDB;

-- 15. inventory_entries
CREATE TABLE IF NOT EXISTS inventory_entries (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  product_id BIGINT NOT NULL,
  change_qty INT NOT NULL,
  reason VARCHAR(120),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_ie_prod FOREIGN KEY (product_id) REFERENCES products(id)
) ENGINE=InnoDB;

-- 16. product_sales_stats
CREATE TABLE IF NOT EXISTS product_sales_stats (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  product_id BIGINT,
  sold_qty INT DEFAULT 0,
  revenue DECIMAL(15,2) DEFAULT 0,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_pss_prod FOREIGN KEY (product_id) REFERENCES products(id)
) ENGINE=InnoDB;

-- 17. ai_suggestions
CREATE TABLE IF NOT EXISTS ai_suggestions (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  product_id BIGINT,
  suggestion TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_ai_prod FOREIGN KEY (product_id) REFERENCES products(id)
) ENGINE=InnoDB;

-- 18. subscription_plans
CREATE TABLE IF NOT EXISTS subscription_plans (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  price DECIMAL(15,2) NOT NULL,
  features TEXT
) ENGINE=InnoDB;

-- 19. owners
CREATE TABLE IF NOT EXISTS owners (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT NOT NULL UNIQUE,
  company_name VARCHAR(200),
  CONSTRAINT fk_owner_user FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB;

-- 20. owner_subscriptions
CREATE TABLE IF NOT EXISTS owner_subscriptions (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  owner_id BIGINT NOT NULL,
  plan_id BIGINT NOT NULL,
  start_date DATE,
  end_date DATE,
  status VARCHAR(20),
  CONSTRAINT fk_os_owner FOREIGN KEY (owner_id) REFERENCES owners(id),
  CONSTRAINT fk_os_plan FOREIGN KEY (plan_id) REFERENCES subscription_plans(id)
) ENGINE=InnoDB;

-- 21. revenue_reports
CREATE TABLE IF NOT EXISTS revenue_reports (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  report_date DATE,
  total_revenue DECIMAL(15,2) DEFAULT 0
) ENGINE=InnoDB;

-- 22. debts
CREATE TABLE IF NOT EXISTS debts (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  customer_id BIGINT,
  amount DECIMAL(15,2) NOT NULL,
  remaining DECIMAL(15,2) NOT NULL,
  status VARCHAR(20),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_debt_customer FOREIGN KEY (customer_id) REFERENCES customers(id)
) ENGINE=InnoDB;

-- 23. debt_transactions
CREATE TABLE IF NOT EXISTS debt_transactions (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  debt_id BIGINT NOT NULL,
  paid_amount DECIMAL(15,2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_dt_debt FOREIGN KEY (debt_id) REFERENCES debts(id) ON DELETE CASCADE
) ENGINE=InnoDB;
