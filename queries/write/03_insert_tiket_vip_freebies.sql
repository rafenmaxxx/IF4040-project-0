-- Pembelian satu tiket VIP beserta merchandise gratisnya (freebies)
\timing on

SELECT id_penonton FROM penonton ORDER BY id_penonton LIMIT 1 OFFSET 1 \gset p_
SELECT id_jadwal_pertunjukan FROM jadwal_pertunjukan ORDER BY id_jadwal_pertunjukan LIMIT 1 \gset j_
SELECT id_item FROM item_merch ORDER BY id_item LIMIT 1 \gset i1_
SELECT id_item FROM item_merch ORDER BY id_item LIMIT 1 OFFSET 1 \gset i2_

BEGIN;

EXPLAIN (ANALYZE, BUFFERS)
WITH tiket_baru AS (
    INSERT INTO tiket (harga, status_pembayaran, id_penonton, id_jadwal_pertunjukan, id_kupon)
    VALUES (1500000, 'Lunas', :p_id_penonton, :j_id_jadwal_pertunjukan, NULL)
    RETURNING id_tiket
), vip_baru AS (
    INSERT INTO tiket_vip (id_tiket)
    SELECT id_tiket FROM tiket_baru
    RETURNING id_tiket
)
INSERT INTO freebies (id_tiket, id_item)
SELECT vip_baru.id_tiket, item_id
FROM vip_baru, unnest(ARRAY[:i1_id_item, :i2_id_item]) AS item_id;

ROLLBACK;
