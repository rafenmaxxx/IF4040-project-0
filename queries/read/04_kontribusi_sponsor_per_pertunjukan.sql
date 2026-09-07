-- Total kontribusi sponsor per pertunjukan
\timing on

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    jp.id_jadwal_pertunjukan,
    jp.nama_pertunjukan,
    COALESCE(SUM(s.kontribusi), 0) AS total_kontribusi_sponsor
FROM jadwal_pertunjukan jp
LEFT JOIN sponsor_pertunjukan sp ON sp.id_jadwal_pertunjukan = jp.id_jadwal_pertunjukan
LEFT JOIN sponsor s ON s.id_sponsor = sp.id_sponsor
GROUP BY jp.id_jadwal_pertunjukan, jp.nama_pertunjukan
ORDER BY total_kontribusi_sponsor DESC;
