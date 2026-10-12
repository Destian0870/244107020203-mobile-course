# AI Challenge Report - Campus Notify FCM

## 1. AI Prompt
Prompt yang digunakan untuk meminta draf awal layanan FCM kepada asisten AI:

\`\`\`text
Aplikasi Flutter Campus Notification App.
Stack: firebase_messaging, flutter_local_notifications, flutter_secure_storage, go_router, Riverpod.
Buatkan PushService dengan:
- requestPermission + getToken + onTokenRefresh (kirim ke POST /devices)
- onMessage (tampilkan local notification manual)
- onMessageOpenedApp + getInitialMessage (navigasi ke data.route)
- subscribe/unsubscribe topik pengumuman-kampus
- background handler top-level dengan @pragma('vm:entry-point')
Tandai bagian yang BERBEDA untuk Android 13+ vs iOS, dan bagian yang tidak boleh mengakses BuildContext.
\`\`\`

---

## 2. AI Verification Checklist
Hasil verifikasi dan audit terhadap kode yang dihasilkan oleh AI:

- [x] **Background Handler**: Fungsi background handler telah didefinisikan sebagai fungsi *top-level* di luar kelas dan diberi anotasi `@pragma('vm:entry-point')`.
- [x] **Token Refresh**: Listener `onTokenRefresh` tidak hanya mencetak ke log, melainkan memanggil fungsi callback untuk mengirim token baru ke backend.
- [x] **Foreground Notification**: Memakai local notification manual (`flutter_local_notifications`) agar banner tetap tampil saat aplikasi aktif di foreground.
- [x] **Deep Link / Routing**: Klik dari ketiga state aplikasi berhasil meneruskan payload rute dengan benar.
- [x] **Keamanan**: Tidak ada kunci atau secret yang di-hardcode di dalam file kode sumber.

---

## 3. Tabel Pengujian Lifecycle 3 App State

| App State | Kondisi Aplikasi Saat Notifikasi Masuk | Aksi Pengguna | Hasil / Rute Tujuan | Status Pengujian |
| :--- | :--- | :--- | :--- | :--- |
| **Foreground** | Aplikasi sedang dibuka dan aktif di layar | Mengetuk banner notifikasi lokal | Berhasil navigasi ke rute data (cth: `/pengumuman/3`) | Berhasil |
| **Background** | Aplikasi diminimalkan (ke *recent apps*) | Mengetuk notifikasi sistem | Berhasil membuka aplikasi dan mengarah ke rute tujuan | Berhasil |
| **Terminated** | Aplikasi dimatikan total (*swiped away*) | Mengetuk notifikasi sistem | Membuka aplikasi dari awal lalu mengarah ke rute target | Berhasil |

---

## 4. Catatan Teknis & Perbaikan Manual
- **Penyesuaian Versi**: Melakukan penyesuaian parameter method `initialize` pada `flutter_local_notifications` agar kompatibel dengan versi terbaru yang digunakan pada project praktikum.
- **Manajemen Token**: Memastikan penanganan token kosong atau saat terjadi *token refresh* ditangani dengan aman sebelum dikirim ke endpoint backend.