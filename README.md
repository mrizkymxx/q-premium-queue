# Q-PREMIUM — Sistem Manajemen Antrian Digital

Aplikasi manajemen antrian real-time berbasis Flutter Web + Supabase, dirancang untuk lembaga kelas premium (perbankan, klinik, pelayanan publik terkemuka).

## Fitur Utama

- **Dashboard Operator** — Kelola antrian, panggil pelanggan, tandai selesai / lewati
- **Layar Monitor Publik** — Tampilan TV real-time dengan nomor antrian besar
- **Kiosk Pendaftaran** — Pelanggan mandiri ambil nomor antrian
- **Pengumuman Suara (TTS)** — Otomatis mengumumkan nomor via Web Speech API (Bahasa Indonesia)
- **Real-time Sync** — Semua layar tersinkronisasi langsung via Supabase Realtime
- **Statistik Harian** — Total, sedang dilayani, dan selesai hari ini

## Tech Stack

| Layer | Teknologi |
|---|---|
| Framework | Flutter (Dart) — Web target |
| State Management | Provider |
| Backend / Database | Supabase (PostgreSQL + Realtime) |
| Font | Inter (Google Fonts) |
| Animasi | flutter_animate |
| Deployment | Vercel |

## Setup & Menjalankan Lokal

### 1. Prasyarat

- Flutter SDK ≥ 3.0.0
- Supabase project dengan tabel `queue_transactions`

### 2. Environment Variables

Salin `.env.example` ke `.env` dan isi nilai:

```env
SUPABASE_URL=https://xxxxxxxxxx.supabase.co
SUPABASE_ANON_KEY=eyJ...
```

### 3. Jalankan di Browser

```bash
flutter pub get

flutter run -d chrome \
  --dart-define=SUPABASE_URL=<url> \
  --dart-define=SUPABASE_ANON_KEY=<key>
```

### 4. Build Produksi

```bash
bash build.sh
```

## Struktur Database (Supabase)

### Tabel: `queue_transactions`

| Kolom | Tipe | Keterangan |
|---|---|---|
| `id` | uuid (PK) | Auto-generated |
| `created_at` | timestamptz | Waktu pendaftaran |
| `customer_name` | text | Nama pelanggan |
| `queue_number` | integer | Nomor urut (auto dari trigger) |
| `queue_prefix` | text | Prefix kategori (default: 'A') |
| `status` | text | `waiting` / `calling` / `completed` / `skipped` |
| `called_at` | timestamptz | Waktu dipanggil |
| `completed_at` | timestamptz | Waktu selesai |
| `source` | text | Sumber pendaftaran (default: 'web') |

### SQL yang Diperlukan

Jalankan perintah ini di **SQL Editor** Supabase Anda:

```sql
-- Aktifkan Supabase Realtime untuk tabel queue_transactions
alter publication supabase_realtime add table queue_transactions;
-- (Opsional) Jika butuh data lama (old record) saat update/delete
alter table queue_transactions replica identity full;
-- Hitung antrian di depan nomor tertentu
create or replace function get_queue_ahead_count(target_number int)
returns int as $$
  select count(*)::int from queue_transactions
  where status = 'waiting' and queue_number < target_number;
$$ language sql;

-- Ambil antrian yang sedang dipanggil
create or replace function get_current_calling()
returns setof queue_transactions as $$
  select * from queue_transactions
  where status = 'calling'
  order by called_at desc limit 1;
$$ language sql;
```

## URL Screens

| URL | Fungsi |
|---|---|
| `/` | Menu Pemilihan Perangkat (Device Selection) |
| `/dashboard` | Dashboard Operator |
| `/monitor` | Layar Monitor Publik (TV) |
| `/register` | Kiosk Pendaftaran Mandiri |

## Deploy ke Vercel

Pastikan environment variables di Vercel Settings → Environment Variables:

```
SUPABASE_URL=...
SUPABASE_ANON_KEY=...
```

Build command: `bash build.sh`  
Output directory: `build/web`
