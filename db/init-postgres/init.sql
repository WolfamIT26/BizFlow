DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = 'branch_admin') THEN
    EXECUTE 'CREATE DATABASE branch_admin';
  END IF;
END
$$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = 'order_admin') THEN
    EXECUTE 'CREATE DATABASE order_admin';
  END IF;
END
$$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = 'user_admin') THEN
    EXECUTE 'CREATE DATABASE user_admin';
  END IF;
END
$$;
