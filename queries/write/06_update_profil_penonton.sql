-- Update data profil penonton (nomor telepon dan alamat)
\timing on

SELECT id_penonton FROM penonton ORDER BY id_penonton LIMIT 1 \gset p_

BEGIN;

EXPLAIN (ANALYZE, BUFFERS)
UPDATE penonton
SET no_telp = '081298765432',
    alamat = 'Jl. Perubahan Alamat No. 99, Jakarta'
WHERE id_penonton = :p_id_penonton;

ROLLBACK;
