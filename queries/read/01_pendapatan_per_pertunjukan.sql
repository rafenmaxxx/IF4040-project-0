-- Total pendapatan per pertunjukan (tiket reguler vs VIP)
\timing on

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    jp.id_jadwal_pertunjukan,
    jp.nama_pertunjukan,
    COALESCE(SUM(t.harga), 0) AS total_pendapatan,
    COALESCE(SUM(CASE WHEN tv.id_tiket IS NULL THEN t.harga END), 0) AS pendapatan_reguler,
    COALESCE(SUM(CASE WHEN tv.id_tiket IS NOT NULL THEN t.harga END), 0) AS pendapatan_vip
FROM jadwal_pertunjukan jp
LEFT JOIN tiket t
    ON t.id_jadwal_pertunjukan = jp.id_jadwal_pertunjukan
    AND t.status_pembayaran = 'Lunas'
LEFT JOIN tiket_vip tv ON tv.id_tiket = t.id_tiket
GROUP BY jp.id_jadwal_pertunjukan, jp.nama_pertunjukan
ORDER BY total_pendapatan DESC;
