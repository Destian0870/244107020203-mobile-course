# AI Challenge & Verification Report - Week 5 (Offline-First Notes)

**Nama:** Destian Dwi Hardika  
**NIM:** 244107020203  
**Kelas:** TI-2F / Semester 4  

---

## 1. AI Prompt
Prompt yang digunakan untuk analisis perbandingan penyimpanan data lokal pada aplikasi Flutter:

> "Aplikasi Flutter Offline Notes: CRUD catatan + preferensi tema. Bandingkan SharedPreferences, Hive, sqflite (SQLite), dan Drift untuk dua kebutuhan ini. 
> Requirements:
> - Kriteria: kompleksitas query, kebutuhan relasi, reaktivitas (stream), type-safety, ukuran boilerplate, dan kemudahan testing.
> - Beri rekomendasi final: mana untuk preferensi, mana untuk catatan, beserta alasannya dalam 1 tabel.
> - Tunjukkan skema tabel/kotak untuk 1000+ catatan.
> - Jelaskan trade-off setiap pilihan."

---

## 2. Tabel Perbandingan Storage

| Kriteria | SharedPreferences | Hive | sqflite (SQLite) | Drift |
| :--- | :--- | :--- | :--- | :--- |
| **Kompleksitas Query** | Sangat Rendah (Key-Value) | Rendah (Box & Key-Value) | Tinggi (Native SQL, JOIN, WHERE, Agregasi) | Tinggi (Type-safe SQL Builder & Streams) |
| **Kebutuhan Relasi** | Tidak Mendukung | Tidak Mendukung (NoSQL) | Mendukung Penuh (Foreign Key, Relasi Tabel) | Mendukung Penuh (Type-safe Relational) |
| **Reaktivitas (Stream)** | Tidak Ada | Terbatas (Watch box) | Manual (Perlu StreamController / Riverpod) | Sangat Baik (Native Watch Streams) |
| **Type-Safety** | Rendah (Dynamic Casting) | Sedang (TypeAdapters) | Rendah (Mapping manual Map<String, dynamic>) | Sangat Tinggi (Generated Code) |
| **Ukuran Boilerplate** | Sangat Kecil | Kecil | Sedang | Tinggi (Membutuhkan build_runner) |
| **Kemudahan Testing** | Sangat Mudah | Mudah | Sedang | Kompleks |

---

## 3. Rekomendasi Final & Alasan Justifikasi

| Kebutuhan Storage | Teknologi Terpilih | Alasan & Justifikasi |
| :--- | :--- | :--- |
| **Preferensi Tema (Settings)** | **SharedPreferences** | Data preferensi aplikasi bersifat sederhana (*key-value* seperti status boolean *dark mode*). SharedPreferences sangat ringan, cepat, minim konfigurasi, dan tidak memerlukan overhead skema basis data. |
| **Koleksi Catatan (Notes)** | **sqflite (SQLite)** | Koleksi catatan memerlukan basis data relasional terstruktur yang mendukung kolom khusus seperti `dirty` (status *flag* sinkronisasi) dan `updated_at`. SQLite memberikan kontrol penuh terhadap eksekusi SQL native dan performa indexing yang optimal saat menangani ribuan catatan. |

---

## 4. Skema Tabel untuk 1000+ Catatan (SQLite)

Untuk menangani 1000+ catatan secara optimal beserta kebutuhan mekanisme *offline-first sync*, digunakan skema tabel dan *indexing* berikut:

```sql
CREATE TABLE notes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  dirty INTEGER NOT NULL DEFAULT 1 -- 1 = Offline (Perlu sync), 0 = Synced
);

-- Indexing untuk mempercepat pencarian & pengurutan pada 1000+ data
CREATE INDEX idx_notes_updated_at ON notes(updated_at DESC);
CREATE INDEX idx_notes_dirty ON notes(dirty);