# Responsive Dashboard - Academic Overview

Tugas Praktikum Minggu 2: Declarative UI & Responsive Design
**Nama**: Destian Dwi H  
**NIM**: 244107020203  
**Kelas**: TI-3E  

---

## AI Prompt Challenge Documentation

### 1. Prompt Desain
**Prompt**: *"Bandingkan dua tata letak dashboard akademik untuk Flutter: versi GridView dan versi LayoutBuilder + Column. Jelaskan trade-off responsif dan aksesibilitasnya."*

**Hasil Perbandingan Layout**:
* **Versi `GridView` (`GridView.count` / `GridView.builder`)**:
  * **Responsif**: Sangat efisien untuk kisi 2D seragam. Pengaturan jumlah kolom (`crossAxisCount`) dapat disesuaikan otomatis berdasarkan lebar layar. Membutuhkan `shrinkWrap: true` dan `physics: NeverScrollableScrollPhysics()` jika ditaruh di dalam scrollable parent.
  * **Aksesibilitas**: Pembaca layar (*Screen Reader*) membaca elemen secara berurutan sebagai kisi/grid.
  * **Trade-off**: Kurang fleksibel jika tinggi tiap elemen/kartu bervariasi (*fixed aspect ratio*).
* **Versi `LayoutBuilder` + `Column`**:
  * **Responsif**: Sangat fleksibel dalam mengecek `constraints.maxWidth` dan mengembalikan struktur layout yang berbeda secara eksplisit.
  * **Aksesibilitas**: Alur pembacaan linier top-to-bottom yang sangat prediktif bagi pembaca layar.
  * **Trade-off**: Membutuhkan lebih banyak *boilerplate code*.

---

### 2. Prompt Penguatan Konsep
**Prompt**: *"Jelaskan kapan penggunaan Expanded justru menyebabkan overflow di dalam Row, beri contoh kode yang gagal dan perbaikannya."*

**Penjelasan**:
`Expanded` di dalam `Row` menyebabkan *overflow/error* jika `Row` tersebut berada di dalam *parent widget* yang memberikan batas lebar tidak terbatas (*unbounded width*), seperti `SingleChildScrollView` dengan arah horizontal.

**Contoh Kode Gagal**:
```dart
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: [
      Expanded( // ❌ Error: Unbounded width
        child: Text('Info Akademik'),
      ),
    ],
  ),
)

//Perbaikan//
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: [
      SizedBox( // ✅ Gunakan batas lebar pasti
        width: 200,
        child: Text('Info Akademik'),
      ),
    ],
  ),
)