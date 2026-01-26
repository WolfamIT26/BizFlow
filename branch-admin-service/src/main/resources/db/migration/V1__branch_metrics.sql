CREATE TABLE IF NOT EXISTS branch_metrics (
    id BIGINT PRIMARY KEY,
    name TEXT NOT NULL,
    revenue NUMERIC(19,2),
    order_count BIGINT,
    active BOOLEAN
);

CREATE TABLE IF NOT EXISTS branch_growth (
    id BIGINT PRIMARY KEY,
    branch_id BIGINT NOT NULL,
    period_label TEXT NOT NULL,
    revenue NUMERIC(19,2),
    order_count BIGINT
);

CREATE TABLE IF NOT EXISTS recent_users (
    id BIGINT PRIMARY KEY,
    full_name TEXT,
    registered_at TIMESTAMP WITH TIME ZONE
);
