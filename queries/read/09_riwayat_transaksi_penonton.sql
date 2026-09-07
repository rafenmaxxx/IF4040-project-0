-- Riwayat transaksi (tiket + merchandise) milik satu penonton
\timing on

SELECT id_penonton
FROM tiket
GROUP BY id_penonton
HAVING COUNT(*) > 1
ORDER BY id_penonton
LIMIT 1 \gset sample_

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    'tiket' AS jenis_transaksi,
    t.id_tiket AS id_referensi,
    t.harga AS jumlah,
    t.status_pembayaran AS status,
    jp.nama_pertunjukan AS keterangan,
    jp.tanggal_mulai AS waktu
FROM tiket t
JOIN jadwal_pertunjukan jp ON jp.id_jadwal_pertunjukan = t.id_jadwal_pertunjukan
WHERE t.id_penonton = :sample_id_penonton

UNION ALL

SELECT
    'merch' AS jenis_transaksi,
    tm.id_transaksi AS id_referensi,
    tm.total_transaksi AS jumlah,
    NULL AS status,
    'Pembelian Merchandise' AS keterangan,
    tm.waktu_transaksi AS waktu
FROM transaksi_merch tm
WHERE tm.id_penonton = :sample_id_penonton
ORDER BY waktu DESC;
