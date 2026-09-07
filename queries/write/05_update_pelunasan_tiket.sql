-- Pelunasan status pembayaran satu tiket
\timing on

SELECT id_tiket FROM tiket
WHERE status_pembayaran = 'Belum Lunas'
ORDER BY id_tiket LIMIT 1 \gset t_

BEGIN;

EXPLAIN (ANALYZE, BUFFERS)
UPDATE tiket
SET status_pembayaran = 'Lunas'
WHERE id_tiket = :t_id_tiket;

ROLLBACK;
