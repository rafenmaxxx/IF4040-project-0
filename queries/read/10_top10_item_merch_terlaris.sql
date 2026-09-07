-- 10 item merchandise terlaris berdasarkan jumlah terjual dan total pendapatan
\timing on

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    im.id_item,
    im.nama_item,
    SUM(inf.jumlah_item) AS total_terjual,
    SUM(inf.jumlah_item * im.harga_satuan) AS total_pendapatan
FROM info_merch inf
JOIN item_merch im ON im.id_item = inf.id_item
GROUP BY im.id_item, im.nama_item
ORDER BY total_pendapatan DESC
LIMIT 10;
