-- Transaksi pembelian merchandise multi-item dengan kupon
\timing on

SELECT id_penonton FROM penonton ORDER BY id_penonton LIMIT 1 OFFSET 2 \gset p_
SELECT id_kupon FROM kupon
WHERE is_redeemed = FALSE AND tanggal_kedaluwarsa > CURRENT_DATE
ORDER BY id_kupon LIMIT 1 OFFSET 1 \gset k_
SELECT id_item FROM item_merch ORDER BY id_item LIMIT 1 \gset i1_
SELECT id_item FROM item_merch ORDER BY id_item LIMIT 1 OFFSET 1 \gset i2_
SELECT id_item FROM item_merch ORDER BY id_item LIMIT 1 OFFSET 2 \gset i3_

BEGIN;

EXPLAIN (ANALYZE, BUFFERS)
WITH transaksi_baru AS (
    INSERT INTO transaksi_merch (total_transaksi, id_penonton, id_kupon)
    VALUES (450000, :p_id_penonton, :k_id_kupon)
    RETURNING id_transaksi
)
INSERT INTO info_merch (id_transaksi, id_item, jumlah_item)
SELECT transaksi_baru.id_transaksi, items.item_id, items.qty
FROM transaksi_baru,
     (VALUES (:i1_id_item, 2), (:i2_id_item, 1), (:i3_id_item, 3)) AS items(item_id, qty);

ROLLBACK;
