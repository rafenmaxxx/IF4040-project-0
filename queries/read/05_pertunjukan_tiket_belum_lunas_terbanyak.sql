-- Pertunjukan dengan tiket belum lunas terbanyak
\timing on

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    jp.id_jadwal_pertunjukan,
    jp.nama_pertunjukan,
    COUNT(t.id_tiket) AS jumlah_belum_lunas
FROM jadwal_pertunjukan jp
JOIN tiket t ON t.id_jadwal_pertunjukan = jp.id_jadwal_pertunjukan
WHERE t.status_pembayaran = 'Belum Lunas'
GROUP BY jp.id_jadwal_pertunjukan, jp.nama_pertunjukan
ORDER BY jumlah_belum_lunas DESC
LIMIT 1;
