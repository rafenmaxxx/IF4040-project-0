-- Pembelian satu tiket reguler dengan kupon
\timing on

SELECT id_penonton FROM penonton ORDER BY id_penonton LIMIT 1 \gset p_
SELECT id_jadwal_pertunjukan FROM jadwal_pertunjukan ORDER BY id_jadwal_pertunjukan LIMIT 1 \gset j_
SELECT id_kupon FROM kupon
WHERE is_redeemed = FALSE AND tanggal_kedaluwarsa > CURRENT_DATE
ORDER BY id_kupon LIMIT 1 \gset k_

BEGIN;

EXPLAIN (ANALYZE, BUFFERS)
INSERT INTO tiket (harga, status_pembayaran, id_penonton, id_jadwal_pertunjukan, id_kupon)
VALUES (250000, 'Lunas', :p_id_penonton, :j_id_jadwal_pertunjukan, :k_id_kupon);

ROLLBACK;
