-- Hapus (tutup) akun penonton beserta seluruh riwayatnya
\timing on

SELECT p.id_penonton
FROM penonton p
LEFT JOIN tiket t ON t.id_penonton = p.id_penonton
LEFT JOIN transaksi_merch tm ON tm.id_penonton = p.id_penonton
GROUP BY p.id_penonton
ORDER BY COUNT(DISTINCT t.id_tiket) + COUNT(DISTINCT tm.id_transaksi) DESC
LIMIT 1 \gset p_

BEGIN;

EXPLAIN (ANALYZE, BUFFERS)
DELETE FROM penonton
WHERE id_penonton = :p_id_penonton;

ROLLBACK;
