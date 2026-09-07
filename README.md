# Setup Database Project-0 IF4040

Direktori ini berisi konfigurasi *environment* PostgreSQL menggunakan Docker untuk pengerjaan Project-0 Pemodelan Data Lanjut. Skema tabel dan *business logic* (Trigger) sudah dikonfigurasi agar tereksekusi secara otomatis saat *container* pertama kali dibuat.

## Prasyarat
Pastikan sistem kamu sudah terpasang:
* **Docker** (dan Docker Compose)
* **SQL Client** (DBeaver, DataGrip, pgAdmin, atau ekstensi VSCode)

## Cara Menjalankan Environment
1. Buka terminal/CMD di dalam folder proyek ini (pastikan berada di direktori yang sama dengan file `docker-compose.yml`).
2. Jalankan perintah berikut untuk membangun dan menyalakan *container* di *background*:
    ```bash
    docker compose up -d
    ```
3. Tunggu beberapa saat untuk proses inisialisasi awal. Kamu bisa memverifikasi apakah *database* sudah siap dengan mengecek log:
    ```bash
    docker logs if4040-postgres
    ```
    *(Pastikan ada keterangan `database system is ready to accept connections` di baris akhir log)*.

## Kredensial Koneksi

Gunakan parameter berikut untuk melakukan koneksi dari SQL Client (seperti DBeaver/DataGrip) ke *database* lokalmu:

* **Host:** `localhost`
* **Port:** `5432`
* **Database:** `project0_db`
* **Username:** `admin`
* **Password:** `password123`

## Cara Reset Database (Hard Reset)

Apabila ada pembaruan pada *script* SQL di folder `init-scripts` dan kamu ingin mengulang *database* dari keadaan kosong, jalankan baris perintah ini (⚠️ **Peringatan: Seluruh *dummy data* akan hilang**):

```bash
docker compose down -v
docker compose up -d
```