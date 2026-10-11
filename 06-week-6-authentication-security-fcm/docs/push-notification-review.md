# Push Notification Review

Catatan ini menyimpan prompt, ringkasan output AI awal, perbaikan manual, dan
bukti validasi untuk implementasi FCM Campus Notify.

## Prompt

> Aplikasi Flutter Campus Notification App.  
> Stack: firebase_messaging, flutter_local_notifications, flutter_secure_storage,
> go_router, Riverpod.  
> Buatkan PushService dengan:
> - requestPermission + getToken + onTokenRefresh (kirim ke POST /devices)
> - onMessage (tampilkan local notification manual)
> - onMessageOpenedApp + getInitialMessage (navigasi ke data.route)
> - subscribe/unsubscribe topic pengumuman-kampus
> - background handler top-level dengan @pragma('vm:entry-point')
> Tandai bagian yang BERBEDA untuk Android 13+ vs iOS,
> dan bagian yang tidak boleh mengakses BuildContext.

## Output awal AI

Output awal menyatakan bahwa implementasi PushService dan integrasi HomePage
sudah tersedia, lalu melaporkan perapian lifecycle izin/token, deep link, dan
catatan platform. Perubahan yang awalnya dilakukan meliputi:

- Memasang listener `onTokenRefresh` sebelum mengambil token awal, lalu mengirim
  token awal dan token refresh melalui `POST /devices`.
- Menjaga deep link tap local notification saat router belum siap.
- Menangani error setup push di HomePage dan menambahkan dokumentasi perbedaan
  Android 13+/iOS serta larangan memakai `BuildContext` pada callback background.

Validasi awal yang dilaporkan: analisis statis tidak menemukan error. Pada audit
berikutnya, `flutter test` gagal dikompilasi karena `test/widget_test.dart`
memanggil constructor `MyApp` yang tidak didefinisikan dalam `lib/main.dart`.

## Daftar perbaikan manual dan tindak lanjut

| # | Perbaikan | File/area | Alasan dan hasil |
|---|---|---|---|
| 1 | Listener token refresh dipasang sebelum `getToken()`; token hasil `getToken()` dan refresh dikirim ke `/devices`. | `lib/messaging/push_service.dart` | Mengurangi kemungkinan melewatkan refresh saat startup serta memastikan refresh dikirim ke backend, bukan sekadar dicatat. |
| 2 | Callback tap local notification menyimpan route jika handler navigasi belum siap. | `lib/messaging/push_service.dart` | Mempertahankan deep link saat aplikasi baru diluncurkan. |
| 3 | Setup permission, token, subscribe, dan listen diletakkan di jalur error handling HomePage; log error tidak lagi mencetak rincian exception. | `lib/pages/home_page.dart` | Menampilkan status gagal tanpa membocorkan rincian request/token melalui exception. |
| 4 | Error callback refresh/listener hanya mencatat jenis exception, bukan objek error atau stack trace. | `lib/messaging/push_service.dart` | Mencegah detail request yang mungkin sensitif masuk ke log. |
| 5 | Kode autentikasi memasang Authorization dari access token yang dibaca dari secure storage, dan menggunakan token hasil refresh pada retry. | `lib/data/api_client.dart` | Pemeriksaan lokal memastikan nilai header berasal dari variabel token, bukan kredensial hard-coded; nilainya tidak dicetak saat pemeriksaan. |
| 6 | Hasil pengujian tiga state diperjelas sebagai jalur kode terverifikasi, bukan runtime pass. | `README.md`, dokumen ini | Tidak ada bukti tap notifikasi di perangkat/emulator pada saat validasi. |
| 7 | Repository auth masih berupa simulasi `mock-*`; tidak ada kredensial produksi yang boleh diambil dari implementasi tersebut. | `lib/data/auth_repository.dart` | Harus diganti dengan integrasi backend autentikasi sebelum rilis. |

## Hasil uji tiga app state

Payload yang digunakan adalah pesan topic `pengumuman-kampus` dengan
`data.route` bernilai `/pengumuman/3`.

| App state | Jalur yang diperiksa | Prosedur uji manual | Hasil |
|---|---|---|---|
| Foreground | `onMessage` → `_showForegroundNotification` → local notification. Tap membawa payload route ke callback `onDidReceiveNotificationResponse`, lalu GoRouter. | Login, biarkan aplikasi terbuka, kirim payload, tap banner, pastikan halaman Pengumuman #3 terbuka. | Jalur kode diverifikasi; uji perangkat/emulator belum dijalankan. |
| Background | `onMessageOpenedApp` mengambil `message.data['route']` dan meneruskannya ke GoRouter. | Login, pindahkan aplikasi ke background, kirim payload, tap banner sistem, pastikan halaman Pengumuman #3 terbuka. | Jalur kode diverifikasi; uji perangkat/emulator belum dijalankan. |
| Terminated | `getInitialMessage()` mengambil pesan peluncuran, lalu route diteruskan ke GoRouter saat HomePage disiapkan. | Login, force-close aplikasi, kirim payload, tap banner sistem, pastikan halaman Pengumuman #3 terbuka. | Jalur kode diverifikasi; uji perangkat/emulator belum dijalankan. |

Ketiga hasil di atas bukan bukti runtime. Jalankan setiap skenario pada Android
dan iOS; pastikan Firebase/APNs terkonfigurasi dan pengguna sudah login. Route
pengumuman dilindungi route guard login.

## Validasi otomatis

| Pemeriksaan | Hasil | Detail |
|---|---|---|
| Analisis statis file Dart yang disentuh | Lulus | Tidak ditemukan error analyzer pada PushService, HomePage, dan API client. |
| `flutter test` | Gagal, exit code 1 | Test gagal dikompilasi: `test/widget_test.dart` memanggil `const MyApp()`, tetapi constructor tersebut tidak ada pada `lib/main.dart`. |
| Tap notifikasi di device/emulator | Belum dijalankan | Tidak ada bukti runtime Android/iOS yang tersedia. |

## Catatan keamanan

- FCM token tidak ditulis ke log penuh; layar debug hanya menampilkan 12 karakter
  awal. Jangan aktifkan logging Dio request/response yang merekam header atau
  body `POST /devices`.
- Access dan refresh token autentikasi disimpan melalui `flutter_secure_storage`;
  request API memakai access token dari storage. Jangan hard-code token, API key,
  atau secret.
- `mock-*` pada auth repository adalah data simulasi, bukan token aman atau
  autentikasi produksi. Ganti sebelum deployment.
- Konfigurasi base URL saat ini adalah alamat contoh
  `https://example-campus-api.test`; sesuaikan melalui konfigurasi per-environment
  dan jangan menyimpan secret di repository.
