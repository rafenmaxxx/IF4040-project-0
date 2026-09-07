-- Validasi kupon berdasarkan kode saat checkout
\timing on

SELECT kode_kupon
FROM kupon
WHERE is_redeemed = FALSE AND tanggal_kedaluwarsa > CURRENT_DATE
LIMIT 1 \gset sample_

EXPLAIN (ANALYZE, BUFFERS)
SELECT id_kupon, kode_kupon, persen_diskon, tanggal_kedaluwarsa, is_redeemed
FROM kupon
WHERE kode_kupon = :'sample_kode_kupon'
    AND is_redeemed = FALSE
    AND tanggal_kedaluwarsa > CURRENT_DATE;
