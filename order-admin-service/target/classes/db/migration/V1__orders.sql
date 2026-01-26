CREATE TABLE IF NOT EXISTS order_summaries (
    id BIGINT PRIMARY KEY,
    user_id BIGINT,
    user_name TEXT,
    total_amount NUMERIC(19,2),
    created_at TIMESTAMP WITHOUT TIME ZONE,
    status TEXT
);

CREATE TABLE IF NOT EXISTS order_items (
    id BIGINT PRIMARY KEY,
    order_id BIGINT REFERENCES order_summaries(id) ON DELETE CASCADE,
    product_id BIGINT,
    product_name TEXT,
    quantity INTEGER,
    line_total NUMERIC(19,2)
);
