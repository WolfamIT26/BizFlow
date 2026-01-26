CREATE TABLE IF NOT EXISTS user_profiles (
    id BIGINT PRIMARY KEY,
    username TEXT NOT NULL,
    full_name TEXT,
    email TEXT,
    phone_number TEXT,
    role TEXT,
    enabled BOOLEAN,
    branch_id BIGINT,
    branch_name TEXT,
    created_at TIMESTAMP WITH TIME ZONE,
    normalized_text TEXT
);

CREATE TABLE IF NOT EXISTS customer_profiles (
    id BIGINT PRIMARY KEY,
    name TEXT NOT NULL,
    phone TEXT,
    email TEXT,
    tier TEXT,
    total_points INTEGER,
    updated_at TIMESTAMP WITH TIME ZONE,
    normalized_text TEXT
);
