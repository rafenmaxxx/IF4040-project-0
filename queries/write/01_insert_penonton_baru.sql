-- Registrasi penonton baru
\timing on

BEGIN;

EXPLAIN (ANALYZE, BUFFERS)
INSERT INTO penonton (nama_penonton, email, no_telp, alamat)
VALUES (
    'Benchmark Test User',
    'benchmark_user_' || floor(random() * 1000000)::text || '@example.com',
    '081234567890',
    'Jl. Benchmark No. 1, Bandung'
);

ROLLBACK;
