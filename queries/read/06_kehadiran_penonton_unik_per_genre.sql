-- Total kehadiran dan penonton unik per genre musik
\timing on

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    a.genre,
    COUNT(t.id_penonton) AS total_kehadiran,
    COUNT(DISTINCT t.id_penonton) AS jumlah_penonton_unik
FROM artis a
JOIN artis_pertunjukan ap ON ap.id_artis = a.id_artis
JOIN jadwal_pertunjukan jp ON jp.id_jadwal_pertunjukan = ap.id_jadwal_pertunjukan
JOIN tiket t ON t.id_jadwal_pertunjukan = jp.id_jadwal_pertunjukan
GROUP BY a.genre
ORDER BY total_kehadiran DESC;
