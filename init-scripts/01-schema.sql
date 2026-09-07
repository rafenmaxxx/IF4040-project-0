-- 01-schema.sql (PostgreSQL)

-- independent entities
CREATE TABLE penonton (
    id_penonton SERIAL PRIMARY KEY,
    nama_penonton VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    no_telp VARCHAR(20),
    alamat TEXT
);

CREATE TABLE item_merch (
    id_item SERIAL PRIMARY KEY,
    nama_item VARCHAR(100) NOT NULL,
    harga_satuan BIGINT NOT NULL -- dalam rupiah
);

CREATE TABLE kupon (
    id_kupon SERIAL PRIMARY KEY,
    kode_kupon VARCHAR(20) UNIQUE NOT NULL,
    persen_diskon DECIMAL(5, 2) NOT NULL CHECK (persen_diskon >= 0 AND persen_diskon <= 100),
    tanggal_kedaluwarsa DATE NOT NULL,
    is_redeemed BOOLEAN DEFAULT FALSE
);

CREATE TABLE artis (
    id_artis SERIAL PRIMARY KEY,
    nama_artis VARCHAR(100) NOT NULL,
    genre VARCHAR(50),
    asal_negara VARCHAR(50),
    kontak_artis VARCHAR(100),
    biografi TEXT
);

CREATE TABLE vendor (
    id_vendor SERIAL PRIMARY KEY,
    nama_vendor VARCHAR(100) NOT NULL,
    jenis_layanan VARCHAR(100) NOT NULL
);

CREATE TABLE sponsor (
    id_sponsor SERIAL PRIMARY KEY,
    nama_perusahaan VARCHAR(100) NOT NULL,
    jenis_sponsor VARCHAR(100) NOT NULL,
    kontribusi BIGINT NOT NULL  -- dalam rupiah
);

CREATE TABLE panitia (
    id_panitia SERIAL PRIMARY KEY,
    kontak_panitia VARCHAR(100) NOT NULL,
    peran VARCHAR(50) NOT NULL
);

CREATE TABLE lokasi_pertunjukan (
    id_lokasi SERIAL PRIMARY KEY,
    nama_lokasi VARCHAR(100) NOT NULL,
    kapasitas INT NOT NULL
);

-- dependent & relational entities
CREATE TABLE jadwal_pertunjukan (
    id_jadwal_pertunjukan SERIAL PRIMARY KEY,
    nama_pertunjukan VARCHAR(150) NOT NULL,
    tanggal_mulai TIMESTAMP NOT NULL,
    jam_mulai TIMESTAMP NOT NULL,
    durasi INT NOT NULL, -- dalam menit
    id_lokasi INT NOT NULL,
    CONSTRAINT fk_lokasi_jadwal FOREIGN KEY (id_lokasi) REFERENCES lokasi_pertunjukan(id_lokasi) ON DELETE CASCADE
);

CREATE TABLE tiket (
    id_tiket SERIAL PRIMARY KEY,
    harga BIGINT NOT NULL,
    status_pembayaran VARCHAR(20) NOT NULL CHECK (status_pembayaran IN ('Lunas', 'Belum Lunas')),
    id_penonton INT NOT NULL,
    id_jadwal_pertunjukan INT NOT NULL,
    id_kupon INT, -- Nullable

    CONSTRAINT fk_penonton_tiket FOREIGN KEY (id_penonton) REFERENCES penonton(id_penonton) ON DELETE CASCADE,
    CONSTRAINT fk_jadwal_tiket FOREIGN KEY (id_jadwal_pertunjukan) REFERENCES jadwal_pertunjukan(id_jadwal_pertunjukan) ON DELETE CASCADE,
    CONSTRAINT fk_kupon_tiket FOREIGN KEY (id_kupon) REFERENCES kupon(id_kupon) ON DELETE SET NULL
);

CREATE TABLE transaksi_merch (
    id_transaksi SERIAL PRIMARY KEY,
    waktu_transaksi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_transaksi BIGINT NOT NULL, --dalam rupiah
    id_penonton INT NOT NULL,
    id_kupon INT, -- Nullable
    CONSTRAINT fk_penonton_transaksi FOREIGN KEY (id_penonton) REFERENCES penonton(id_penonton) ON DELETE CASCADE,
    CONSTRAINT fk_kupon_transaksi FOREIGN KEY (id_kupon) REFERENCES kupon(id_kupon) ON DELETE SET NULL
);

CREATE TABLE fasilitas (
    id_lokasi INT NOT NULL,
    nama_fasilitas VARCHAR(100) NOT NULL,
    PRIMARY KEY (id_lokasi, nama_fasilitas),
    CONSTRAINT fk_lokasi_fasilitas FOREIGN KEY (id_lokasi) REFERENCES lokasi_pertunjukan(id_lokasi) ON DELETE CASCADE
);

-- inheritance
CREATE TABLE tiket_vip (
    id_tiket INT PRIMARY KEY,
    CONSTRAINT fk_tiket_vip FOREIGN KEY (id_tiket) REFERENCES tiket(id_tiket) ON DELETE CASCADE
);

-- junction tables (many-to-many relationships)
CREATE TABLE info_merch (
    id_transaksi INT NOT NULL,
    id_item INT NOT NULL,
    jumlah_item INT NOT NULL,
    PRIMARY KEY (id_transaksi, id_item),
    CONSTRAINT fk_transaksi FOREIGN KEY (id_transaksi) REFERENCES transaksi_merch(id_transaksi) ON DELETE CASCADE,
    CONSTRAINT fk_item_transaksi FOREIGN KEY (id_item) REFERENCES item_merch(id_item) ON DELETE CASCADE
);

CREATE TABLE freebies (
    id_tiket INT NOT NULL,
    id_item INT NOT NULL,
    PRIMARY KEY (id_tiket, id_item),
    CONSTRAINT fk_tiket_freebies FOREIGN KEY (id_tiket) REFERENCES tiket_vip(id_tiket) ON DELETE CASCADE,
    CONSTRAINT fk_item_freebies FOREIGN KEY (id_item) REFERENCES item_merch(id_item) ON DELETE CASCADE
);

CREATE TABLE artis_pertunjukan (
    id_jadwal_pertunjukan INT NOT NULL,
    id_artis INT NOT NULL,
    PRIMARY KEY (id_jadwal_pertunjukan, id_artis),
    CONSTRAINT fk_jadwal_artis FOREIGN KEY (id_jadwal_pertunjukan) REFERENCES jadwal_pertunjukan(id_jadwal_pertunjukan) ON DELETE CASCADE,
    CONSTRAINT fk_artis FOREIGN KEY (id_artis) REFERENCES artis(id_artis) ON DELETE CASCADE
);

CREATE TABLE vendor_pertunjukan (
    id_jadwal_pertunjukan INT NOT NULL,
    id_vendor INT NOT NULL,
    PRIMARY KEY (id_jadwal_pertunjukan, id_vendor),
    CONSTRAINT fk_jadwal_vendor FOREIGN KEY (id_jadwal_pertunjukan) REFERENCES jadwal_pertunjukan(id_jadwal_pertunjukan) ON DELETE CASCADE,
    CONSTRAINT fk_vendor FOREIGN KEY (id_vendor) REFERENCES vendor(id_vendor) ON DELETE CASCADE
);

CREATE TABLE sponsor_pertunjukan (
    id_jadwal_pertunjukan INT NOT NULL,
    id_sponsor INT NOT NULL,
    PRIMARY KEY (id_jadwal_pertunjukan, id_sponsor),
    CONSTRAINT fk_jadwal_sponsor FOREIGN KEY (id_jadwal_pertunjukan) REFERENCES jadwal_pertunjukan(id_jadwal_pertunjukan) ON DELETE CASCADE,
    CONSTRAINT fk_sponsor FOREIGN KEY (id_sponsor) REFERENCES sponsor(id_sponsor) ON DELETE CASCADE
);

CREATE TABLE panitia_pertunjukan (
    id_jadwal_pertunjukan INT NOT NULL,
    id_panitia INT NOT NULL,
    PRIMARY KEY (id_panitia, id_jadwal_pertunjukan),
    CONSTRAINT fk_jadwal_panitia FOREIGN KEY (id_jadwal_pertunjukan) REFERENCES jadwal_pertunjukan(id_jadwal_pertunjukan) ON DELETE CASCADE,
    CONSTRAINT fk_panitia FOREIGN KEY (id_panitia) REFERENCES panitia(id_panitia) ON DELETE CASCADE
);

-- index pendukung kolom FK yang sering di-join/filter (Postgres tidak meng-index kolom FK
-- secara otomatis, hanya sisi yang direferensikan/PK)
CREATE INDEX idx_tiket_jadwal ON tiket (id_jadwal_pertunjukan);
CREATE INDEX idx_tiket_penonton ON tiket (id_penonton);
CREATE INDEX idx_tiket_kupon ON tiket (id_kupon);
CREATE INDEX idx_transaksi_penonton ON transaksi_merch (id_penonton);
CREATE INDEX idx_transaksi_kupon ON transaksi_merch (id_kupon);
CREATE INDEX idx_info_merch_item ON info_merch (id_item);
CREATE INDEX idx_artis_pertunjukan_artis ON artis_pertunjukan (id_artis);
CREATE INDEX idx_sponsor_pertunjukan_sponsor ON sponsor_pertunjukan (id_sponsor);
CREATE INDEX idx_vendor_pertunjukan_vendor ON vendor_pertunjukan (id_vendor);
CREATE INDEX idx_panitia_pertunjukan_jadwal ON panitia_pertunjukan (id_jadwal_pertunjukan);
CREATE INDEX idx_jadwal_lokasi ON jadwal_pertunjukan (id_lokasi);
CREATE INDEX idx_jadwal_tanggal_mulai ON jadwal_pertunjukan (tanggal_mulai);

-- trigger untuk status redeem kupon
CREATE OR REPLACE FUNCTION check_and_redeem_kupon()
RETURNS TRIGGER AS $$
DECLARE
    status_redeem BOOLEAN;
BEGIN
    -- jika transaksi ini menggunakan kupon (tidak NULL), dan kupon tersebut baru saja
    -- dipasang (INSERT, atau UPDATE yang mengganti id_kupon) -- bukan UPDATE lain yang
    -- kebetulan menyentuh baris yang kuponnya sudah lama ter-redeem
    IF NEW.id_kupon IS NOT NULL
       AND (TG_OP = 'INSERT' OR NEW.id_kupon IS DISTINCT FROM OLD.id_kupon) THEN

        -- ambil status kupon dari tabel kupon
        SELECT is_redeemed INTO status_redeem 
        FROM kupon 
        WHERE id_kupon = NEW.id_kupon;
        
        IF status_redeem = TRUE THEN
            -- tolak jika sudah dipakai
            RAISE EXCEPTION 'Gagal: Kupon dengan ID % sudah pernah digunakan (is_redeemed = TRUE).', NEW.id_kupon;
        ELSE
            -- ubah status redeem menjadi TRUE jika belum dipakai
            UPDATE kupon 
            SET is_redeemed = TRUE 
            WHERE id_kupon = NEW.id_kupon;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- pasang trigger pada tabel tiket
CREATE TRIGGER trg_redeem_kupon_tiket
BEFORE INSERT OR UPDATE ON tiket
FOR EACH ROW EXECUTE FUNCTION check_and_redeem_kupon();

-- pasang trigger pada tabel transaksi_merch
CREATE TRIGGER trg_redeem_kupon_merch
BEFORE INSERT OR UPDATE ON transaksi_merch
FOR EACH ROW EXECUTE FUNCTION check_and_redeem_kupon();