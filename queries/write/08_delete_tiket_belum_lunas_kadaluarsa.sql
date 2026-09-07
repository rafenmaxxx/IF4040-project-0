-- Hapus tiket belum lunas untuk pertunjukan yang sudah berlalu
\timing on

BEGIN;

EXPLAIN (ANALYZE, BUFFERS)
DELETE FROM tiket
WHERE status_pembayaran = 'Belum Lunas'
    AND id_jadwal_pertunjukan IN (
        SELECT id_jadwal_pertunjukan
        FROM jadwal_pertunjukan
        WHERE tanggal_mulai < DATE '2026-11-01'
    );

ROLLBACK;
