-- 10 penonton dengan total pengeluaran terbesar (tiket + merchandise)
\timing on

EXPLAIN (ANALYZE, BUFFERS)
WITH pengeluaran_tiket AS (
    SELECT id_penonton, SUM(harga) AS total_tiket
    FROM tiket
    WHERE status_pembayaran = 'Lunas'
    GROUP BY id_penonton
),
pengeluaran_merch AS (
    SELECT id_penonton, SUM(total_transaksi) AS total_merch
    FROM transaksi_merch
    GROUP BY id_penonton
)
SELECT
    p.id_penonton,
    p.nama_penonton,
    COALESCE(pt.total_tiket, 0) + COALESCE(pm.total_merch, 0) AS total_pengeluaran
FROM penonton p
LEFT JOIN pengeluaran_tiket pt ON pt.id_penonton = p.id_penonton
LEFT JOIN pengeluaran_merch pm ON pm.id_penonton = p.id_penonton
ORDER BY total_pengeluaran DESC
LIMIT 10;
