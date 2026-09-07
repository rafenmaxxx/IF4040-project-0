-- Persentase okupansi setiap pertunjukan
\timing on

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    jp.id_jadwal_pertunjukan,
    jp.nama_pertunjukan,
    lp.nama_lokasi,
    lp.kapasitas,
    COUNT(t.id_tiket) AS jumlah_tiket_terjual,
    ROUND(COUNT(t.id_tiket) * 100.0 / lp.kapasitas, 2) AS persentase_okupansi
FROM jadwal_pertunjukan jp
JOIN lokasi_pertunjukan lp ON lp.id_lokasi = jp.id_lokasi
LEFT JOIN tiket t ON t.id_jadwal_pertunjukan = jp.id_jadwal_pertunjukan
GROUP BY jp.id_jadwal_pertunjukan, jp.nama_pertunjukan, lp.nama_lokasi, lp.kapasitas
ORDER BY persentase_okupansi DESC;
