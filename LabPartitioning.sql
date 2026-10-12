DROP TABLE IF EXISTS orders_regular;
CREATE TABLE orders_regular (
    order_id      BIGSERIAL,
    created_at    TIMESTAMP NOT NULL DEFAULT now(),
    user_id       INT NOT NULL,
    amount        DECIMAL(10,2),
    status        TEXT
);

DROP TABLE IF EXISTS orders_partitioned;
CREATE TABLE orders_partitioned (
    order_id      BIGSERIAL,
    created_at    TIMESTAMP NOT NULL,
    user_id       INT NOT NULL,
    amount        DECIMAL(10,2),
    status        TEXT
) PARTITION BY RANGE (created_at);

CREATE TABLE orders_p2024_q1 PARTITION OF orders_partitioned FOR VALUES FROM ('2024-01-01') TO ('2024-04-01');
CREATE TABLE orders_p2024_q2 PARTITION OF orders_partitioned FOR VALUES FROM ('2024-04-01') TO ('2024-07-01');
CREATE TABLE orders_p2024_q3 PARTITION OF orders_partitioned FOR VALUES FROM ('2024-07-01') TO ('2024-10-01');
CREATE TABLE orders_p2024_q4 PARTITION OF orders_partitioned FOR VALUES FROM ('2024-10-01') TO ('2025-01-01');
CREATE TABLE orders_p2025_q1 PARTITION OF orders_partitioned FOR VALUES FROM ('2025-01-01') TO ('2025-04-01');
CREATE TABLE orders_p2025_q2 PARTITION OF orders_partitioned FOR VALUES FROM ('2025-04-01') TO ('2025-07-01');
CREATE TABLE orders_p2025_q3 PARTITION OF orders_partitioned FOR VALUES FROM ('2025-07-01') TO ('2025-10-01');
CREATE TABLE orders_p2025_q4 PARTITION OF orders_partitioned FOR VALUES FROM ('2025-10-01') TO ('2026-01-01');
CREATE TABLE orders_p_default PARTITION OF orders_partitioned DEFAULT;

INSERT INTO orders_regular (created_at, user_id, amount, status)
SELECT 
    timestamp '2024-01-01 00:00:00' + random() * interval '730 days', 
    (random() * 100000)::int,
    (random() * 10000)::decimal(10,2),
    (ARRAY['new','paid','shipped','delivered','cancelled'])[floor(random()*5)+1]
FROM generate_series(1, 10000000);

INSERT INTO orders_partitioned 
SELECT * FROM orders_regular;

CREATE INDEX idx_reg_user ON orders_regular(user_id);
CREATE INDEX idx_reg_date ON orders_regular(created_at);

CREATE INDEX idx_part_user ON orders_partitioned(user_id);
CREATE INDEX idx_part_date ON orders_partitioned(created_at);

ANALYZE;

EXPLAIN ANALYZE
SELECT COUNT(*)
FROM orders_regular
WHERE created_at BETWEEN '2025-04-01' AND '2025-06-30';

EXPLAIN ANALYZE
SELECT COUNT(*)
FROM orders_partitioned
WHERE created_at BETWEEN '2025-04-01' AND '2025-06-30';

EXPLAIN ANALYZE
SELECT COUNT(*)
FROM orders_regular
WHERE user_id = 99999;

EXPLAIN ANALYZE
SELECT COUNT(*)
FROM orders_partitioned
WHERE user_id = 99999;
