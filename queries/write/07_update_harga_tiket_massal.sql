-- Penyesuaian harga (+10%) untuk seluruh tiket belum lunas pada satu pertunjukan
\timing on

SELECT jp.id_jadwal_pertunjukan
FROM jadwal_pertunjukan jp
JOIN tiket t ON t.id_jadwal_pertunjukan = jp.id_jadwal_pertunjukan
WHERE t.status_pembayaran = 'Belum Lunas'
GROUP BY jp.id_jadwal_pertunjukan
ORDER BY COUNT(*) DESC
LIMIT 1 \gset j_

BEGIN;

EXPLAIN (ANALYZE, BUFFERS)
UPDATE tiket
SET harga = ROUND(harga * 1.10)
WHERE id_jadwal_pertunjukan = :j_id_jadwal_pertunjukan
    AND status_pembayaran = 'Belum Lunas';

ROLLBACK;
