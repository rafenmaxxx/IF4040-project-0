#!/usr/bin/env python3
"""
seed.py - Script Seeding Database IF4040 Project-0
Menggunakan library 'Faker' (locale: id_ID) untuk menghasilkan data realistis berbahasa Indonesia.
Output ditulis ke 'init-scripts/02-seed.sql' dan mendukung eksekusi langsung ke PostgreSQL.
"""

import sys
import os
import random
from datetime import datetime, timedelta, date
import argparse

try:
    from faker import Faker
except ImportError:
    print("[!] Error: Library 'faker' belum terpasang.")
    print("    Silakan buat virtual environment dan pasang dependensi:")
    print("        python -m venv venv")
    print("        # Di Windows: .\\venv\\Scripts\\activate")
    print("        # Di Linux/macOS: source venv/bin/activate")
    print("        pip install -r requirements.txt")
    sys.exit(1)

# Default seed for reproducibility
SEED_DEFAULT = 42

# Domain-specific presets for festival context
GENRES = [
    "Pop", "Indie Pop", "Rock", "Alternative Rock", "Jazz", "Neo-Soul",
    "Folk Pop", "Hip-Hop", "R&B", "Electronic / EDM", "City Pop", "Progressive Rock"
]

COUNTRIES = [
    "Indonesia", "Inggris", "Amerika Serikat", "Jepang", "Korea Selatan",
    "Australia", "Belanda", "Islandia", "Singapura", "Thailand"
]

VENDOR_SERVICES = [
    "Sound System & Tata Suara Konser",
    "Panggung & Konstruksi Truss Rigging",
    "Genset & Distribusi Catu Daya Listrik",
    "Videotron & Tata Layar LED Screen",
    "Keamanan & Pengamanan Kerumunan (Crowd Control)",
    "Ticketing Gateway & Scanner Akses Gerbang",
    "Layanan Medis & Ambulans Siaga Festival",
    "Katering & Konsumsi Artis / Kru",
    "Pengelolaan Sampah & Kebersihan (Green Team)",
    "Penyedia Barikade Penonton (Mojo Barrier)",
    "Special Effects, Pyro, & Laser Panggung",
    "Transportasi & Shuttle Logistik Artis"
]

SPONSOR_TIERS = ["Platinum Sponsor", "Gold Sponsor", "Silver Sponsor", "Official Partner"]

VENUE_TEMPLATES = [
    ("Stadion Utama Gelora Bung Karno", 77000),
    ("Indonesia Convention Exhibition (ICE) BSD", 15000),
    ("Jakarta International Expo (JIExpo) Arena", 12000),
    ("Sasana Budaya Ganesha (Sabuga) ITB", 3500),
    ("Stadion Gelora Bandung Lautan Api (GBLA)", 38000),
    ("Garuda Wisnu Kencana (GWK) Cultural Park", 25000),
    ("Jogja Expo Center (JEC)", 8000),
    ("Stadion Manahan Solo", 20000),
    ("Grand City Convention Hall Surabaya", 5000),
    ("Trans Convention Centre Bandung", 4000),
    ("Istora Senayan Gelora Bung Karno", 7100),
    ("Beach City International Stadium Ancol", 10000),
    ("Tennis Indoor Senayan", 3800),
    ("Balai Sarbini Jakarta", 1300),
    ("Eldorado Dome Lembang", 4500),
    ("The Kasablanka Hall", 3200),
    ("DBL Arena Surabaya", 4000),
    ("Stadion Jatidiri Semarang", 25000)
]

FASILITAS_POOL = [
    "Toilet VIP", "Toilet Reguler", "Musholla & Tempat Wudhu", "Ruang Medis & P3K",
    "Area Parkir VIP", "Area Parkir Reguler", "Food & Beverage Court",
    "Locker Room / Penitipan Barang", "Booth Merchandise Resmi", "Charging Station Corner",
    "Akses Kursi Roda / Ramah Disabilitas", "Ruang Tunggu Artis / Green Room",
    "Photo Booth Area", "Water Refill Station Gratis", "Area Khusus Merokok"
]

MERCH_BASE_ITEMS = [
    ("T-Shirt Official Tour 2026", 185000),
    ("T-Shirt Vintage Acid Wash", 210000),
    ("T-Shirt Lineup Festival Glow In The Dark", 235000),
    ("Hoodie Zipper Heavyweight", 385000),
    ("Pullover Hoodie Oversized", 360000),
    ("Totebag Canvas Premium", 95000),
    ("Lanyard Satin Eksklusif + Card Holder", 45000),
    ("Gantungan Kunci Akrilik 2 Sisi", 30000),
    ("Enamel Pin Set Edisi Terbatas", 65000),
    ("Topi Bucket Hat Reversible", 125000),
    ("Topi Baseball Cap Bordir", 110000),
    ("Tumbler Stainless Steel 500ml", 165000),
    ("Poster Konser A2 Hologram Foil", 75000),
    ("Sticker Pack Waterproof Vinyl (Isi 10)", 35000),
    ("Wristband Gelang Silikon Resmi", 25000),
    ("Jas Hujan Portable Poncho Festival", 40000),
    ("Kipas Angin Mini Portable USB", 55000),
    ("Kacamata Hitam Festival Edition", 65000),
    ("Pouch Kanvas Serbaguna", 50000),
    ("Sling Bag Compact Cordura", 145000)
]

MERCH_COLORS = ["Hitam", "Putih", "Navy", "Emerald", "Maroon", "Charcoal", "Sage Green", "Lilac", "Oatmeal"]


def escape_sql(val):
    if val is None:
        return "NULL"
    if isinstance(val, (int, float)):
        return str(val)
    if isinstance(val, bool):
        return "TRUE" if val else "FALSE"
    if isinstance(val, (date, datetime)):
        return f"'{val.strftime('%Y-%m-%d %H:%M:%S')}'" if isinstance(val, datetime) else f"'{val.strftime('%Y-%m-%d')}'"
    s = str(val).replace("'", "''")
    return f"'{s}'"


def generate_seed_data(scale_factor=10, seed=42):
    random.seed(seed)
    Faker.seed(seed)
    fake = Faker("id_ID")

    # 1. PENONTON (50 * scale = ~500 records)
    num_penonton = 50 * scale_factor
    penonton_list = []
    used_emails = set()

    for i in range(1, num_penonton + 1):
        nama = fake.name()
        # Generate clean unique email
        raw_email = fake.ascii_free_email()
        clean_user = raw_email.split("@")[0].replace(".", "_")
        domain = raw_email.split("@")[1]
        email = f"{clean_user}_{i}@{domain}"
        while email in used_emails:
            email = f"{clean_user}_{i}_{random.randint(100, 999)}@{domain}"
        used_emails.add(email)

        # Phone: format and clean within VARCHAR(20)
        raw_phone = fake.phone_number()
        clean_phone = "".join([c for c in raw_phone if c.isdigit() or c == "+"])[:20]
        if not clean_phone.startswith("08") and not clean_phone.startswith("+62"):
            clean_phone = f"08{random.randint(11, 99)}{random.randint(1000000, 9999999)}"

        alamat = fake.address().replace("\n", ", ")
        penonton_list.append((i, nama, email, clean_phone, alamat))

    # 2. ITEM MERCH (15 * scale = ~150 records)
    num_merch = 15 * scale_factor
    merch_list = []
    for i in range(1, num_merch + 1):
        base_name, base_price = random.choice(MERCH_BASE_ITEMS)
        color = random.choice(MERCH_COLORS)
        edition = f"Edisi {i}" if i > len(MERCH_BASE_ITEMS) else "Official"
        nama_item = f"{base_name} ({color}) - {edition}"
        price_var = round((base_price * random.uniform(0.85, 1.25)) / 5000) * 5000
        merch_list.append((i, nama_item, int(price_var)))

    # 3. KUPON (25 * scale = ~250 records)
    num_kupon = 25 * scale_factor
    kupon_list = []
    used_coupon_codes = set()
    today = date(2026, 9, 1)

    for i in range(1, num_kupon + 1):
        prefix = random.choice(["FEST", "PROMO", "DISKON", "HEMAT", "VIP", "EARLY", "FLASH", "MUSIC", "IF4040"])
        code = f"{prefix}{fake.bothify(text='??-###').upper()}"
        while code in used_coupon_codes:
            code = f"{prefix}{fake.bothify(text='???-####').upper()}"
        used_coupon_codes.add(code)

        persen_diskon = round(random.choice([5.0, 10.0, 15.0, 20.0, 25.0, 30.0, 35.0, 50.0]), 2)
        if random.random() < 0.15:
            tgl_exp = fake.date_between(start_date="-60d", end_date="-1d")
        else:
            tgl_exp = fake.date_between(start_date="+15d", end_date="+180d")

        # Initial insert MUST be FALSE so trigger can check & update to TRUE upon ticket/merch insertion
        kupon_list.append((i, code, persen_diskon, tgl_exp, False))

    # 4. ARTIS (12 * scale = ~120 records)
    num_artis = 12 * scale_factor
    artis_list = []
    for i in range(1, num_artis + 1):
        if random.random() < 0.65:
            # Soloist: Indonesian or Foreign Name
            nama_artis = fake.name()
            negara = "Indonesia" if random.random() < 0.8 else random.choice(COUNTRIES)
        else:
            # Band / Collective
            prefix = random.choice(["The", "Project", "Orchestra", "Sound of", "Collective", "Kolektif", "Symphony"])
            word = random.choice(["Senja", "Bintang", "Harmoni", "Nusantara", "Distorsi", "Aurora", "Gema", "Wave", "Echo"])
            nama_artis = f"{prefix} {word} {i}"
            negara = random.choice(COUNTRIES)

        genre = random.choice(GENRES)
        contact_user = nama_artis.lower().replace(" ", "").replace(".", "")[:15]
        kontak = f"management@{contact_user}.id"
        biografi = f"Artis beraliran {genre} asal {negara}. {fake.sentence(nb_words=10)}"
        artis_list.append((i, nama_artis, genre, negara, kontak, biografi))

    # 5. VENDOR (8 * scale = ~80 records)
    num_vendor = 8 * scale_factor
    vendor_list = []
    for i in range(1, num_vendor + 1):
        nama_vendor = f"{fake.company()} Solutions {i}"
        layanan = random.choice(VENDOR_SERVICES)
        vendor_list.append((i, nama_vendor, layanan))

    # 6. SPONSOR (6 * scale = ~60 records)
    num_sponsor = 6 * scale_factor
    sponsor_list = []
    for i in range(1, num_sponsor + 1):
        nama_sponsor = fake.company()
        tier = random.choice(SPONSOR_TIERS)
        if "Platinum" in tier:
            kontribusi = random.randint(500, 1500) * 1000000
        elif "Gold" in tier:
            kontribusi = random.randint(250, 490) * 1000000
        elif "Silver" in tier:
            kontribusi = random.randint(100, 240) * 1000000
        else:
            kontribusi = random.randint(25, 95) * 1000000
        sponsor_list.append((i, nama_sponsor, tier, kontribusi))

    # 7. PANITIA (15 * scale = ~150 records)
    num_panitia = 15 * scale_factor
    panitia_list = []
    for i in range(1, num_panitia + 1):
        nama = fake.name()
        phone = f"08{random.randint(11, 99)}{random.randint(1000000, 9999999)}"
        kontak_panitia = f"{nama} ({phone})"
        peran = fake.job()
        panitia_list.append((i, kontak_panitia, peran))

    # 8. LOKASI PERTUNJUKAN (4 * scale = ~40 records)
    num_lokasi = 4 * scale_factor
    lokasi_list = []
    for i in range(1, num_lokasi + 1):
        if i <= len(VENUE_TEMPLATES):
            base_l, base_kap = VENUE_TEMPLATES[i - 1]
            nama_lokasi = base_l
            kapasitas = base_kap
        else:
            base_l, base_kap = random.choice(VENUE_TEMPLATES)
            nama_lokasi = f"{base_l} Stage {i}"
            kapasitas = int(base_kap * random.uniform(0.5, 1.2))
        lokasi_list.append((i, nama_lokasi, kapasitas))

    # 9. FASILITAS (dependent on lokasi)
    fasilitas_list = []
    for lok_id, _, _ in lokasi_list:
        k = random.randint(2, 5)
        chosen = random.sample(FASILITAS_POOL, k)
        for fas in chosen:
            fasilitas_list.append((lok_id, fas))

    # 10. JADWAL PERTUNJUKAN (8 * scale = ~80 records)
    num_jadwal = 8 * scale_factor
    jadwal_list = []
    base_date = datetime(2026, 10, 1, 14, 0)

    for i in range(1, num_jadwal + 1):
        tgl_mulai = base_date + timedelta(days=(i * 2) % 60, hours=random.randint(0, 5))
        jam_mulai = tgl_mulai.replace(hour=random.choice([15, 16, 17, 18, 19, 20]), minute=random.choice([0, 30]))
        durasi = random.choice([90, 120, 150, 180, 240, 300])
        lok_id = random.choice(lokasi_list)[0]
        fest_theme = random.choice(["Soundwave", "Harmoni Ria", "Konser Akbar", "Festival Senja", "Nusantara Fest", "Rock In Campus"])
        nama_pertunjukan = f"Pertunjukan Musik Spektakuler #{i} - {fest_theme}"
        jadwal_list.append((i, nama_pertunjukan, tgl_mulai, jam_mulai, durasi, lok_id))

    # 11. JUNCTIONS ON JADWAL
    artis_pertunjukan_list = set()
    for j_id, _, _, _, _, _ in jadwal_list:
        num_lineup = random.randint(1, 4)
        for a_id in random.sample(range(1, num_artis + 1), num_lineup):
            artis_pertunjukan_list.add((j_id, a_id))

    vendor_pertunjukan_list = set()
    for j_id, _, _, _, _, _ in jadwal_list:
        num_v = random.randint(2, 4)
        for v_id in random.sample(range(1, num_vendor + 1), num_v):
            vendor_pertunjukan_list.add((j_id, v_id))

    sponsor_pertunjukan_list = set()
    for j_id, _, _, _, _, _ in jadwal_list:
        num_s = random.randint(1, 4)
        for s_id in random.sample(range(1, num_sponsor + 1), num_s):
            sponsor_pertunjukan_list.add((j_id, s_id))

    panitia_pertunjukan_list = set()
    for j_id, _, _, _, _, _ in jadwal_list:
        num_p = random.randint(3, 6)
        for p_id in random.sample(range(1, num_panitia + 1), num_p):
            panitia_pertunjukan_list.add((p_id, j_id))

    # 12. COUPON DISTRIBUTION LOGIC (CRITICAL FOR TRIGGER check_and_redeem_kupon)
    # Each coupon can be redeemed AT MOST ONCE across tiket and transaksi_merch
    coupon_pool = list(range(1, num_kupon + 1))
    random.shuffle(coupon_pool)

    num_coupons_tiket = int(num_kupon * 0.35)
    num_coupons_merch = int(num_kupon * 0.25)

    coupons_for_tiket = coupon_pool[:num_coupons_tiket]
    coupons_for_merch = coupon_pool[num_coupons_tiket:num_coupons_tiket + num_coupons_merch]

    kupon_discount_map = {k[0]: float(k[2]) for k in kupon_list}
    item_price_map = {m[0]: m[2] for m in merch_list}

    # 13. TIKET & TIKET VIP (100 * scale = ~1000 records)
    num_tiket = 100 * scale_factor
    num_vip = int(num_tiket * 0.25)

    tiket_list = []
    ticket_coupons_queue = list(coupons_for_tiket)

    for i in range(1, num_tiket + 1):
        is_vip_candidate = (i <= num_vip)
        if is_vip_candidate:
            harga = random.choice([750000, 1000000, 1250000, 1500000, 2000000])
            status = "Lunas"
        else:
            harga = random.choice([150000, 250000, 350000, 500000])
            status = "Lunas" if random.random() < 0.88 else "Belum Lunas"

        id_p = random.randint(1, num_penonton)
        id_j = random.randint(1, num_jadwal)

        id_k = None
        if ticket_coupons_queue and random.random() < 0.30:
            id_k = ticket_coupons_queue.pop(0)

        tiket_list.append((i, harga, status, id_p, id_j, id_k))

    tiket_vip_list = [i for i in range(1, num_vip + 1)]

    # 14. FREEBIES FOR VIP TICKETS
    freebies_list = set()
    for v_id in tiket_vip_list:
        num_free = random.choice([1, 2])
        for it_id in random.sample(range(1, num_merch + 1), num_free):
            freebies_list.add((v_id, it_id))

    # 15. TRANSAKSI MERCH & INFO MERCH (35 * scale = ~350 transactions)
    num_transaksi = 35 * scale_factor
    transaksi_merch_list = []
    info_merch_list = []
    merch_coupons_queue = list(coupons_for_merch)

    for t_id in range(1, num_transaksi + 1):
        id_p = random.randint(1, num_penonton)

        num_items = random.randint(1, 4)
        chosen_items = random.sample(range(1, num_merch + 1), num_items)

        subtotal = 0
        for it_id in chosen_items:
            qty = random.randint(1, 3)
            info_merch_list.append((t_id, it_id, qty))
            subtotal += item_price_map[it_id] * qty

        id_k = None
        discount_pct = 0.0
        if merch_coupons_queue and random.random() < 0.40:
            id_k = merch_coupons_queue.pop(0)
            discount_pct = kupon_discount_map.get(id_k, 0.0)

        total_transaksi = int(round(subtotal * (1.0 - (discount_pct / 100.0))))

        waktu = datetime(2026, 10, 1, 12, 0) + timedelta(
            days=random.randint(0, 45),
            hours=random.randint(0, 10),
            minutes=random.randint(0, 59)
        )
        transaksi_merch_list.append((t_id, waktu, total_transaksi, id_p, id_k))

    return {
        "penonton": penonton_list,
        "item_merch": merch_list,
        "kupon": kupon_list,
        "artis": artis_list,
        "vendor": vendor_list,
        "sponsor": sponsor_list,
        "panitia": panitia_list,
        "lokasi_pertunjukan": lokasi_list,
        "fasilitas": fasilitas_list,
        "jadwal_pertunjukan": jadwal_list,
        "artis_pertunjukan": sorted(list(artis_pertunjukan_list)),
        "vendor_pertunjukan": sorted(list(vendor_pertunjukan_list)),
        "sponsor_pertunjukan": sorted(list(sponsor_pertunjukan_list)),
        "panitia_pertunjukan": sorted(list(panitia_pertunjukan_list)),
        "tiket": tiket_list,
        "tiket_vip": tiket_vip_list,
        "freebies": sorted(list(freebies_list)),
        "transaksi_merch": transaksi_merch_list,
        "info_merch": info_merch_list
    }


def build_sql_script(data):
    lines = []
    lines.append("-- ====================================================================")
    lines.append("-- 02-seed.sql - Automated Database Seeder for IF4040 Project-0")
    lines.append(f"-- Generated At: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    lines.append("-- Tables seeded in topological dependency order (Faker id_ID)")
    lines.append("-- ====================================================================")
    lines.append("")
    lines.append("BEGIN;")
    lines.append("")

    def append_batch(table_name, columns, rows, batch_size=200):
        lines.append(f"-- --------------------------------------------------------------------")
        lines.append(f"-- Table: {table_name} ({len(rows)} rows)")
        lines.append(f"-- --------------------------------------------------------------------")
        cols_str = ", ".join(columns)
        for i in range(0, len(rows), batch_size):
            batch = rows[i:i + batch_size]
            vals_strs = []
            for row in batch:
                formatted_vals = [escape_sql(v) for v in row]
                vals_strs.append(f"  ({', '.join(formatted_vals)})")
            lines.append(f"INSERT INTO {table_name} ({cols_str}) VALUES")
            lines.append(",\n".join(vals_strs) + ";")
        lines.append("")

    # 1. Independent Tables
    append_batch("penonton", ["id_penonton", "nama_penonton", "email", "no_telp", "alamat"], data["penonton"])
    append_batch("item_merch", ["id_item", "nama_item", "harga_satuan"], data["item_merch"])
    append_batch("kupon", ["id_kupon", "kode_kupon", "persen_diskon", "tanggal_kedaluwarsa", "is_redeemed"], data["kupon"])
    append_batch("artis", ["id_artis", "nama_artis", "genre", "asal_negara", "kontak_artis", "biografi"], data["artis"])
    append_batch("vendor", ["id_vendor", "nama_vendor", "jenis_layanan"], data["vendor"])
    append_batch("sponsor", ["id_sponsor", "nama_perusahaan", "jenis_sponsor", "kontribusi"], data["sponsor"])
    append_batch("panitia", ["id_panitia", "kontak_panitia", "peran"], data["panitia"])
    append_batch("lokasi_pertunjukan", ["id_lokasi", "nama_lokasi", "kapasitas"], data["lokasi_pertunjukan"])

    # 2. Dependent Tables (Level 1)
    append_batch("fasilitas", ["id_lokasi", "nama_fasilitas"], data["fasilitas"])
    append_batch("jadwal_pertunjukan", ["id_jadwal_pertunjukan", "nama_pertunjukan", "tanggal_mulai", "jam_mulai", "durasi", "id_lokasi"], data["jadwal_pertunjukan"])

    # 3. Junctions on Jadwal
    append_batch("artis_pertunjukan", ["id_jadwal_pertunjukan", "id_artis"], data["artis_pertunjukan"])
    append_batch("vendor_pertunjukan", ["id_jadwal_pertunjukan", "id_vendor"], data["vendor_pertunjukan"])
    append_batch("sponsor_pertunjukan", ["id_jadwal_pertunjukan", "id_sponsor"], data["sponsor_pertunjukan"])
    append_batch("panitia_pertunjukan", ["id_panitia", "id_jadwal_pertunjukan"], data["panitia_pertunjukan"])

    # 4. Tiket & Subtypes
    append_batch("tiket", ["id_tiket", "harga", "status_pembayaran", "id_penonton", "id_jadwal_pertunjukan", "id_kupon"], data["tiket"])

    vip_rows = [(v,) for v in data["tiket_vip"]]
    append_batch("tiket_vip", ["id_tiket"], vip_rows)
    append_batch("freebies", ["id_tiket", "id_item"], data["freebies"])

    # 5. Merch Transactions & Details
    append_batch("transaksi_merch", ["id_transaksi", "waktu_transaksi", "total_transaksi", "id_penonton", "id_kupon"], data["transaksi_merch"])
    append_batch("info_merch", ["id_transaksi", "id_item", "jumlah_item"], data["info_merch"])

    # 6. Sequence Synchronization
    lines.append("-- --------------------------------------------------------------------")
    lines.append("-- Sync PostgreSQL Sequences for all SERIAL primary keys")
    lines.append("-- --------------------------------------------------------------------")
    serial_tables = [
        ("penonton", "id_penonton"),
        ("item_merch", "id_item"),
        ("kupon", "id_kupon"),
        ("artis", "id_artis"),
        ("vendor", "id_vendor"),
        ("sponsor", "id_sponsor"),
        ("panitia", "id_panitia"),
        ("lokasi_pertunjukan", "id_lokasi"),
        ("jadwal_pertunjukan", "id_jadwal_pertunjukan"),
        ("tiket", "id_tiket"),
        ("transaksi_merch", "id_transaksi")
    ]
    for tbl, col in serial_tables:
        lines.append(f"SELECT setval(pg_get_serial_sequence('{tbl}', '{col}'), coalesce(max({col}), 1)) FROM {tbl};")

    lines.append("")
    lines.append("COMMIT;")
    lines.append("")
    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description="Generate SQL seeding script for IF4040 Project-0 Database using Faker (id_ID)")
    parser.add_argument("--scale", type=int, default=10, help="Scale factor multiplier (default: 10)")
    parser.add_argument("--seed", type=int, default=SEED_DEFAULT, help="Random seed for reproducibility (default: 42)")
    parser.add_argument("--output", type=str, default="init-scripts/02-seed.sql", help="Output file path (default: init-scripts/02-seed.sql)")
    parser.add_argument("--direct-db", action="store_true", help="Execute SQL directly to running PostgreSQL database")
    parser.add_argument("--host", default="localhost", help="PostgreSQL host (default: localhost)")
    parser.add_argument("--port", default=5432, type=int, help="PostgreSQL port (default: 5432)")
    parser.add_argument("--dbname", default="project0_db", help="PostgreSQL database name (default: project0_db)")
    parser.add_argument("--user", default="admin", help="PostgreSQL user (default: admin)")
    parser.add_argument("--password", default="password123", help="PostgreSQL password (default: password123)")

    args = parser.parse_args()

    print(f"[*] Generating mock data with Faker (id_ID), scale factor: {args.scale}x (seed: {args.seed})...")
    data = generate_seed_data(scale_factor=args.scale, seed=args.seed)

    print(f"[+] Generated entities summary:")
    print(f"    - Penonton:             {len(data['penonton']):,} baris")
    print(f"    - Item Merch:           {len(data['item_merch']):,} baris")
    print(f"    - Kupon:                {len(data['kupon']):,} baris")
    print(f"    - Artis:                {len(data['artis']):,} baris")
    print(f"    - Vendor:               {len(data['vendor']):,} baris")
    print(f"    - Sponsor:              {len(data['sponsor']):,} baris")
    print(f"    - Panitia:              {len(data['panitia']):,} baris")
    print(f"    - Lokasi:               {len(data['lokasi_pertunjukan']):,} baris")
    print(f"    - Fasilitas:            {len(data['fasilitas']):,} baris")
    print(f"    - Jadwal Pertunjukan:   {len(data['jadwal_pertunjukan']):,} baris")
    print(f"    - Artis Pertunjukan:    {len(data['artis_pertunjukan']):,} baris")
    print(f"    - Vendor Pertunjukan:   {len(data['vendor_pertunjukan']):,} baris")
    print(f"    - Sponsor Pertunjukan:  {len(data['sponsor_pertunjukan']):,} baris")
    print(f"    - Panitia Pertunjukan:  {len(data['panitia_pertunjukan']):,} baris")
    print(f"    - Tiket:                {len(data['tiket']):,} baris")
    print(f"    - Tiket VIP:            {len(data['tiket_vip']):,} baris")
    print(f"    - Freebies:             {len(data['freebies']):,} baris")
    print(f"    - Transaksi Merch:      {len(data['transaksi_merch']):,} baris")
    print(f"    - Info Merch:           {len(data['info_merch']):,} baris")

    # Build SQL
    sql_content = build_sql_script(data)

    out_dir = os.path.dirname(args.output)
    if out_dir and not os.path.exists(out_dir):
        os.makedirs(out_dir, exist_ok=True)

    with open(args.output, "w", encoding="utf-8") as f:
        f.write(sql_content)

    file_size = os.path.getsize(args.output)
    print(f"[+] Successfully wrote SQL seed to '{args.output}' ({file_size / 1024:.1f} KB)")

    if args.direct_db:
        print(f"[*] Connecting directly to PostgreSQL at {args.host}:{args.port}/{args.dbname}...")
        try:
            import psycopg
            conn = psycopg.connect(
                host=args.host,
                port=args.port,
                dbname=args.dbname,
                user=args.user,
                password=args.password
            )
            with conn.cursor() as cur:
                print("[*] Executing seed SQL in database...")
                cur.execute(sql_content)
                conn.commit()
            conn.close()
            print("[+] Direct database seeding completed successfully!")
        except ImportError:
            print("[!] Error: 'psycopg' library is required for --direct-db flag. Please install it with 'pip install psycopg'.")
            sys.exit(1)
        except Exception as e:
            print(f"[!] Database connection/execution failed: {e}")
            sys.exit(1)

    print("[OK] Seeding process done!")


if __name__ == "__main__":
    main()
