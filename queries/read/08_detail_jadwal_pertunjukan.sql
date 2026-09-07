-- Detail satu pertunjukan: lineup artis, vendor, sponsor, panitia, fasilitas, dan tiket terjual
\timing on

SELECT jp.id_jadwal_pertunjukan
FROM jadwal_pertunjukan jp
JOIN artis_pertunjukan ap ON ap.id_jadwal_pertunjukan = jp.id_jadwal_pertunjukan
GROUP BY jp.id_jadwal_pertunjukan
ORDER BY COUNT(*) DESC
LIMIT 1 \gset sample_

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    jp.id_jadwal_pertunjukan,
    jp.nama_pertunjukan,
    jp.tanggal_mulai,
    jp.jam_mulai,
    jp.durasi,
    lp.nama_lokasi,
    lp.kapasitas,
    (
        SELECT array_agg(f.nama_fasilitas)
        FROM fasilitas f
        WHERE f.id_lokasi = lp.id_lokasi
    ) AS fasilitas,
    (
        SELECT array_agg(a.nama_artis)
        FROM artis_pertunjukan ap2
        JOIN artis a ON a.id_artis = ap2.id_artis
        WHERE ap2.id_jadwal_pertunjukan = jp.id_jadwal_pertunjukan
    ) AS lineup_artis,
    (
        SELECT array_agg(v.nama_vendor)
        FROM vendor_pertunjukan vp
        JOIN vendor v ON v.id_vendor = vp.id_vendor
        WHERE vp.id_jadwal_pertunjukan = jp.id_jadwal_pertunjukan
    ) AS daftar_vendor,
    (
        SELECT array_agg(s.nama_perusahaan)
        FROM sponsor_pertunjukan sp
        JOIN sponsor s ON s.id_sponsor = sp.id_sponsor
        WHERE sp.id_jadwal_pertunjukan = jp.id_jadwal_pertunjukan
    ) AS daftar_sponsor,
    (
        SELECT array_agg(pn.kontak_panitia)
        FROM panitia_pertunjukan pp
        JOIN panitia pn ON pn.id_panitia = pp.id_panitia
        WHERE pp.id_jadwal_pertunjukan = jp.id_jadwal_pertunjukan
    ) AS daftar_panitia,
    COUNT(t.id_tiket) AS tiket_terjual
FROM jadwal_pertunjukan jp
JOIN lokasi_pertunjukan lp ON lp.id_lokasi = jp.id_lokasi
LEFT JOIN tiket t ON t.id_jadwal_pertunjukan = jp.id_jadwal_pertunjukan
WHERE jp.id_jadwal_pertunjukan = :sample_id_jadwal_pertunjukan
GROUP BY
    jp.id_jadwal_pertunjukan, jp.nama_pertunjukan, jp.tanggal_mulai, jp.jam_mulai,
    jp.durasi, lp.nama_lokasi, lp.kapasitas, lp.id_lokasi;
