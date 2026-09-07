-- Hapus satu pertunjukan yang sudah berlalu beserta seluruh relasinya
\timing on

SELECT jp.id_jadwal_pertunjukan
FROM jadwal_pertunjukan jp
WHERE jp.tanggal_mulai < DATE '2026-11-01'
ORDER BY jp.id_jadwal_pertunjukan
LIMIT 1 \gset j_

BEGIN;

EXPLAIN (ANALYZE, BUFFERS)
DELETE FROM jadwal_pertunjukan
WHERE id_jadwal_pertunjukan = :j_id_jadwal_pertunjukan;

ROLLBACK;
