# Campus Notify

Aplikasi Campus Notification: login dengan penyimpanan token aman,
refresh token otomatis, dan notifikasi push FCM.

Catatan prompt, output AI awal, perbaikan manual, serta tabel hasil uji push
notification tersimpan di [docs/push-notification-review.md](docs/push-notification-review.md).

## Refactoring routes dan API errors

- `lib/routes.dart` menjadi sumber konstanta path GoRouter dan parser murni
  `routeFromMessage(Map<String, dynamic>)` untuk payload FCM.
- `lib/data/api_errors.dart` memetakan Dio 401, timeout, dan koneksi offline
  menjadi pesan yang aman ditampilkan. `AuthNotifier` hanya menyimpan pesan ini
  ke state error; UI tidak menampilkan exception mentah.
- Unit test parser route dan pemetaan error berada di `test/auth_push_test.dart`.

## Praktikum 1 - Login, secure storage, token refresh
- Token disimpan lewat `TokenStore` (flutter_secure_storage).
- Dio interceptor mencoba refresh satu kali saat menerima 401, lalu mengulang request.
- Route guard GoRouter: belum login diarahkan ke `/login`.

## Praktikum 2 - FCM, izin, token lifecycle
- Izin notifikasi diminta saat beranda terbuka.
- Token FCM dikirim ke backend (`POST /devices`) dan dipantau lewat `onTokenRefresh`.
- Token ditampilkan terpotong (12 karakter pertama + `...`) di bagian Debug.
- Bukti: `screenshots/fcm-console-test.png`

## Praktikum 3 - Payload, tiga state, klik, topik

Payload uji:

    {
      "message": {
        "topic": "pengumuman-kampus",
        "notification": {
          "title": "Jadwal kuliah berubah",
          "body": "Kelas Mobile pindah ke Ruang A2 jam 13.00"
        },
        "data": { "route": "/pengumuman/3", "id": "3" }
      }
    }

### Matriks pengujian

| State | Jalur kode yang diverifikasi | Langkah uji perangkat | Hasil |
|---|---|---|---|
| Foreground | `FirebaseMessaging.onMessage` → `_showForegroundNotification` menampilkan local notification dengan payload `data.route`; tap ditangani `onDidReceiveNotificationResponse` → `GoRouter.go(route)` | Dengan pengguna sudah login, kirim payload uji di atas saat beranda terbuka, tap banner, pastikan halaman Pengumuman #3 tampil | Jalur kode terverifikasi; **belum diverifikasi di perangkat** |
| Background | `FirebaseMessaging.onMessageOpenedApp` → membaca `message.data['route']` → `GoRouter.go(route)` | Dengan pengguna sudah login, kirim saat aplikasi di background, tap banner sistem, pastikan halaman Pengumuman #3 tampil | Jalur kode terverifikasi; **belum diverifikasi di perangkat** |
| Terminated | `getInitialMessage()` → membaca `message.data['route']` → `GoRouter.go(route)` saat `HomePage` disiapkan | Dengan pengguna sudah login, force-close aplikasi, kirim pesan, tap banner sistem, pastikan halaman Pengumuman #3 tampil | Jalur kode terverifikasi; **belum diverifikasi di perangkat** |

`Belum diverifikasi di perangkat` berarti tidak ada bukti eksekusi di perangkat/emulator pada tugas ini; tabel di atas membuktikan jalur implementasi, bukan hasil runtime. Jalankan langkah uji di Android dan iOS untuk mengubah status tersebut menjadi lulus/gagal. Untuk pesan terminated, sistem harus dapat menerima push (misalnya konfigurasi Firebase/APNs benar); pengguna harus sudah login karena route pengumuman dijaga oleh autentikasi.

### Hasil validasi saat audit

| Validasi | Hasil | Keterangan |
|---|---|---|
| Analisis statis file PushService, HomePage, dan API client | Lulus | Tidak ditemukan error Dart. |
| `flutter test` | Lulus | 8 test lulus setelah smoke test widget usang yang merujuk `MyApp` diganti dengan pengujian halaman pengumuman. |
| Uji tap notifikasi di device/emulator Android/iOS | Belum dijalankan | Belum ada rekaman hasil runtime; ikuti matriks tiga state di atas. |

## Audit implementasi

| Pemeriksaan | Hasil | Bukti kode |
|---|---|---|
| Background handler top-level dengan `@pragma('vm:entry-point')`, bukan method kelas | Lulus | `firebaseMessagingBackgroundHandler` adalah fungsi top-level dan didaftarkan lewat `FirebaseMessaging.onBackgroundMessage` di `lib/messaging/push_service.dart`. |
| Refresh token dikirim ke backend | Lulus secara implementasi | Listener `onTokenRefresh` memanggil `_sendRefreshedToken`, yang memanggil `_sendToken` dan `POST /devices`; tidak hanya mencetak token. Pengiriman aktual perlu diverifikasi dengan backend yang tersedia. |
| Foreground menampilkan banner manual | Lulus secara implementasi | `onMessage` memanggil `_showForegroundNotification`, yang menjalankan `FlutterLocalNotificationsPlugin.show`. |
| Tap notifikasi di tiga state menuju route payload | Jalur kode diverifikasi; runtime belum dijalankan | Rincian prosedur/status ada di matriks pengujian di atas. |
| Token/secret tidak ditulis sebagai kredensial literal dan tidak dicetak penuh | Lulus untuk token FCM dan header API setelah perbaikan | FCM token dikirim ke backend tanpa logging; tampilan Debug hanya 12 karakter awal. Authorization memakai token tersimpan, bukan nilai kredensial literal. Error hanya mencetak jenis exception agar rincian request tidak ikut tercetak. |

### Batasan keamanan untuk demo

- `lib/data/auth_repository.dart` masih menghasilkan token `mock-*` dari data login sebagai **simulasi**, bukan kredensial/token produksi. Ganti repository simulasi dengan autentikasi backend sebelum rilis; jangan memasukkan token nyata ke source code.
- `https://example-campus-api.test` adalah alamat contoh. Atur base URL sesuai environment tanpa menyimpan secret di source code.
- Jangan aktifkan logging Dio yang merekam header atau body request di production; `POST /devices` membawa FCM token.

### Topic messaging
- Topik: `pengumuman-kampus` (broadcast ke semua mahasiswa).
- Pesan personal (nilai, tagihan) memakai token perangkat, bukan topik.
- Pesan berisi `notification` ditampilkan sistem otomatis saat background/terminated.
  Pesan hanya-data tidak ditampilkan otomatis, sehingga Campus Notification App
  memakai gabungan `notification` + `data`.

### Perbedaan platform
- **Android 13+ (API 33+)**: izin runtime `POST_NOTIFICATIONS` diminta saat
  `requestPermission()`; deklarasinya ada di `android/app/src/main/AndroidManifest.xml`.
  Android 8+ juga memerlukan notification channel, yang dibuat saat inisialisasi.
- **iOS**: `requestPermission()` meminta izin alert, badge, dan sound. Konfigurasikan
  Push Notifications capability, APNs key di Firebase, serta Background Modes
  (`Remote notifications`) di Xcode bila aplikasi perlu menerima data message
  saat background.
- Izin local notification iOS tidak diminta dua kali; permintaan dilakukan lewat
  Firebase Messaging.

### Batasan BuildContext
- Background handler berjalan di isolate terpisah: jangan akses `BuildContext`,
  widget, navigator/router UI, atau Riverpod state di sana.
- Listener FCM dan callback token juga jangan menangkap/menggunakan `BuildContext`.
  Beranda mengambil referensi `GoRouter` sebelum callback async dipasang, lalu
  callback hanya memakai referensi router tersebut.

## Catatan keamanan
- Token FCM penuh tidak ditampilkan di layar maupun screenshot laporan.