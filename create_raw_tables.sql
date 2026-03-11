-- =====================================================
-- Assessment II - Create Raw Tables in PostgreSQL
-- Database: hevodb (Docker)
-- =====================================================

CREATE TABLE customers_raw (
    customer_id INT,
    email VARCHAR(255),
    phone VARCHAR(50),
    country_code VARCHAR(50),
    updated_at TIMESTAMP,
    created_at TIMESTAMP
);

CREATE TABLE orders_raw (
    order_id INT,
    customer_id INT,
    product_id VARCHAR(20),
    amount DECIMAL(10,2),
    created_at TIMESTAMP,
    currency VARCHAR(10)
);

CREATE TABLE products_raw (
    product_id VARCHAR(10),
    product_name VARCHAR(100),
    category VARCHAR(100),
    active_flag CHAR(1)
);

CREATE TABLE country_dim (
    country_name VARCHAR(100),
    iso_code VARCHAR(10)
);

-- Enable logical replication
ALTER TABLE customers_raw REPLICA IDENTITY FULL;
ALTER TABLE orders_raw REPLICA IDENTITY FULL;
ALTER TABLE products_raw REPLICA IDENTITY FULL;
ALTER TABLE country_dim REPLICA IDENTITY FULL;
