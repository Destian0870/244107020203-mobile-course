# 🤖 AI Challenge Report - Campus Notify Clean Architecture

## 1. AI Prompt

Prompt yang digunakan untuk meminta draf awal arsitektur kepada asisten AI:

```text
Project Flutter saya: campus_notify (auth + FCM + daftar pengumuman).

Kondisi kini:
- Folder lib/{data, providers, pages, messaging}.
- Repository tercampur dengan implementasi.
- Widget memanggil Dio secara langsung.

Tugas:
1. Usulkan struktur feature-first Clean Architecture
   (presentation/domain/data) untuk fitur auth + announcements.
2. Untuk tiap file lama, sebutkan tujuan barunya (pindah/pecah/hapus).
3. Tandai bagian yang over-engineering bila diterapkan ke CRUD sederhana,
   dan kapan use case benar-benar dibutuhkan vs repository langsung.
4. Tunjukkan wiring DI dengan Riverpod (tanpa package DI tambahan).

Jelaskan trade-off setiap keputusan.
```

## 2. Pemetaan dan Tujuan File Lama

| File Lama | Tujuan Baru / Tindakan | Alasan dan Analisis |
|---|---|---|
| `data/auth_repository.dart` | **Dipecah menjadi 3 file:**<br><br>1. `features/auth/domain/entities/auth_session.dart`<br>2. `features/auth/domain/repositories/auth_repository.dart`<br>3. `features/auth/data/repositories/auth_repository_impl.dart` | Memisahkan entity, kontrak repository, dan implementasi repository. Kontrak abstrak ditempatkan di domain, sedangkan logika implementasi Dio/HTTP ditempatkan di data. |
| `data/api_errors.dart` | **Pindah dan ubah:** `core/failures.dart` | Memusatkan representasi kegagalan aplikasi agar dapat digunakan oleh berbagai fitur tanpa membuat domain bergantung pada layer data. |
| `providers/auth_provider.dart` | **Pindah:** `features/auth/presentation/providers/` | Mengelompokkan provider berdasarkan fitur dan mengganti instansiasi manual repository dengan Dependency Injection melalui Riverpod. |
| `pages/login_page.dart` | **Pindah:** `features/auth/presentation/pages/login_page.dart` | Mengelompokkan halaman login ke dalam fitur autentikasi sesuai pendekatan Feature-First. |

## 3. Analisis Over-Engineering vs. Kapan Use Case Dibutuhkan

### A. Use Case Tidak Selalu Dibutuhkan

Untuk operasi CRUD sederhana yang hanya meneruskan pemanggilan repository, seperti mengambil daftar pengumuman atau melakukan toggle sederhana, pembuatan class use case khusus, misalnya `GetAnnouncementsUseCase`, dapat menjadi **over-engineering**.

Alasannya:
- Menambah boilerplate code.
- Menambah jumlah file dan class yang harus dikelola.
- Tidak memberikan nilai tambah apabila hanya meneruskan pemanggilan repository tanpa logika tambahan.

**Solusi:** Notifier atau StateNotifier dapat langsung memanggil method dari repository interface apabila operasinya sederhana.

### B. Kapan Use Case Dibutuhkan?

Use case bermanfaat ketika suatu operasi memiliki aturan atau alur bisnis yang perlu dipisahkan dari presentation layer.

Contohnya:

1. **Menggabungkan beberapa repository**  
   Misalnya, memvalidasi sesi pengguna, mengambil profil, dan menyinkronkan data lokal dalam satu alur.

2. **Menjalankan aturan bisnis yang kompleks**  
   Misalnya, memastikan syarat tertentu terpenuhi sebelum permintaan API dilakukan.

3. **Mengatur alur transformasi dan validasi bisnis**  
   Misalnya, memvalidasi data, menghitung nilai tertentu, dan mengatur hasil operasi sebelum dikembalikan kepada presentation layer.

**Kesimpulan:** Use case bukan kewajiban untuk setiap operasi. Gunakan ketika terdapat logika bisnis yang layak dipisahkan, bukan sekadar untuk menambah lapisan arsitektur.

## 4. Wiring Dependency Injection (DI) dengan Riverpod

Proses penyambungan dependensi (*dependency wiring*) dilakukan melalui provider Riverpod. Dengan pendekatan ini, widget dan notifier tidak perlu membuat implementasi repository secara langsung.

Contoh implementasi:

```dart
// 1. Provider untuk TokenStore
final tokenStoreProvider = Provider<TokenStore>((ref) {
  return TokenStore();
});

// 2. Provider Repository
// Presentation bergantung pada kontrak AuthRepository,
// bukan langsung pada AuthRepositoryImpl.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final tokenStore = ref.watch(tokenStoreProvider);

  return AuthRepositoryImpl(
    tokenStore: tokenStore,
  );
});

// 3. Provider untuk AuthNotifier
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);

  return AuthNotifier(authRepository);
});
```

**Penjelasan:**

- `tokenStoreProvider` menyediakan objek `TokenStore`.
- `authRepositoryProvider` menyediakan implementasi `AuthRepositoryImpl` melalui kontrak abstrak `AuthRepository`.
- `authNotifierProvider` menyediakan `AuthNotifier` beserta state autentikasinya.
- Widget cukup menggunakan provider melalui `ref.watch` atau `ref.read`, tanpa menginstansiasi repository secara langsung.

**Catatan:** Contoh tersebut mengasumsikan class `TokenStore`, `AuthRepository`, `AuthRepositoryImpl`, `AuthNotifier`, dan `AuthState` telah dibuat sesuai kebutuhan proyek. Jika menggunakan Riverpod versi terbaru, API notifier yang tersedia perlu disesuaikan dengan versi dependensi yang digunakan.

## 5. AI Verification Checklist dan Hasil Verifikasi Kode

Tabel berikut berisi hasil verifikasi mandiri berdasarkan kriteria kelayakan arsitektur.

| Kriteria Verifikasi | Status | Catatan Temuan / Hasil Verifikasi |
|---|---|---|
| Interface repository berada di `domain`, sedangkan implementasinya berada di `data`? | ✅ PASSED | Interface `AuthRepository` berada di layer domain, sedangkan `AuthRepositoryImpl` berada di layer data. |
| Layer `domain` bebas dari import Flutter, Dio, SQFlite, dan Firebase? | ✅ PASSED | Berdasarkan hasil pemeriksaan menggunakan perintah `grep` atau `findstr`, tidak ditemukan import framework pada folder `domain/`. |
| Tidak ada use case redundan untuk CRUD sederhana? | ✅ PASSED | Operasi baca sederhana langsung dipanggil dari repository oleh notifier untuk menghindari over-engineering. |
| Entity bebas dari mapping seperti `toMap` dan `fromJson`? | ✅ PASSED | Fungsi pemetaan JSON/Map ditempatkan pada model di layer data, misalnya `NoteModel` atau `AuthModel`. |
| Wiring DI terpusat melalui provider tanpa instansiasi repository langsung di widget? | ✅ PASSED | Instansiasi dependensi dikelola melalui provider Riverpod. Widget mengakses dependensi melalui `ref.watch` atau `ref.read`. |

---

## 6. Kesimpulan

Penerapan Feature-First Clean Architecture pada proyek **Campus Notify** bertujuan untuk memisahkan tanggung jawab setiap layer, meningkatkan kemudahan pemeliharaan kode, dan mengurangi ketergantungan antarbagian aplikasi.

Pemisahan `domain` dan `data` membantu menjaga logika bisnis agar tidak bergantung langsung pada implementasi teknis seperti Dio atau Firebase. Sementara itu, Riverpod digunakan untuk mengelola dependensi dan menghubungkan repository dengan presentation layer.

Penggunaan use case disesuaikan dengan kebutuhan. Operasi sederhana dapat langsung menggunakan repository, sedangkan alur bisnis yang kompleks dapat dipisahkan ke dalam use case agar lebih mudah diuji dan dipelihara.

Dengan demikian, arsitektur yang diterapkan tetap terstruktur tanpa menambahkan abstraksi yang tidak diperlukan.