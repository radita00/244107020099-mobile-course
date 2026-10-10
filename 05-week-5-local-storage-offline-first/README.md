# Week 5: Offline Notes

Aplikasi catatan sederhana yang tetap bisa dipakai tanpa internet. Dibuat untuk
Codelab Flutter Minggu 5 (penyimpanan lokal dan offline-first).

## Tujuan

Latihan ini bertujuan untuk:

- memakai **SharedPreferences** untuk menyimpan pengaturan kecil (mode gelap dan waktu terakhir dibuka),
- memakai **SQLite (sqflite)** untuk menyimpan data yang lebih besar, yaitu catatan dan cache post,
- menerapkan pola **cache-first**: data lokal tampil dulu, lalu diperbarui dari jaringan di belakang layar,
- membuat **antrean sync** sederhana memakai penanda `dirty` pada catatan yang belum terkirim,
- memisahkan akses data dari UI lewat **repository** dan **Riverpod**.

## Fitur Utama

- **Pengaturan**
  - Mode gelap, tetap tersimpan setelah aplikasi ditutup.
  - Info waktu aplikasi terakhir dibuka.
  - Toggle *Force offline* untuk simulasi offline yang konsisten saat demo dan testing.
- **Catatan offline**
  - Tambah dan hapus catatan (geser ke kiri untuk menghapus).
  - Semua catatan tersimpan di SQLite, jadi tetap muncul walau tanpa internet.
  - Badge di ikon sync menunjukkan jumlah catatan yang belum tersinkron (`dirty`).
- **Sinkronisasi catatan**
  - Tombol sync menandai catatan `dirty` menjadi bersih.
  - Saat offline, sync ditunda dan muncul pemberitahuan.
- **Posts dengan cache-first**
  - Data dari `GET /posts` (JSONPlaceholder) disimpan di tabel `cached_posts`.
  - Saat dibuka, cache tampil seketika, lalu data terbaru diambil di belakang layar.
  - Saat offline atau jaringan gagal, daftar tetap tampil dari cache.

## Stack Teknologi

| Bagian | Teknologi |
|---|---|
| Framework | Flutter (Dart) |
| State management | flutter_riverpod |
| Preferensi | shared_preferences |
| Database lokal | sqflite + path |
| HTTP client | dio |
| API | JSONPlaceholder (`GET /posts`) |

## Struktur Folder

```
lib/
├── main.dart
├── providers.dart
├── data/
│   ├── local/
│   │   ├── db.dart
│   │   └── note.dart
│   ├── post.dart
│   ├── prefs.dart
│   ├── sync.dart
│   └── repositories/
│       ├── note_repository.dart
│       └── post_repository.dart
└── pages/
    ├── notes_page.dart
    ├── posts_page.dart
    └── settings_page.dart
screenshots/
```

## Cara Menjalankan

### Prasyarat

- Flutter SDK terpasang (cek dengan `flutter doctor`).
- Emulator Android atau HP Android dengan USB debugging aktif.

> **Penting:** jalankan di **Android**, bukan di Chrome/web. Package `sqflite`
> tidak mendukung web, sehingga di browser akan muncul error
> `databaseFactory not initialized`.

### Langkah

```bash
git clone <url-repository-anda>
cd week5_offline_notes
flutter pub get
flutter devices
flutter run -d <id-perangkat-android>
```

### Jika build Android gagal (error Gradle/Kotlin)

Kalau muncul error `Could not close incremental caches` saat build:

```bash
flutter clean
cd android
./gradlew --stop
cd ..
flutter pub get
flutter run
```

Jika masih gagal, tambahkan baris ini di `android/gradle.properties`:

```
kotlin.incremental=false
```

## Aturan Konflik

Saya memakai aturan **last-write-wins berdasarkan `updated_at`**. Kalau satu catatan
berbeda antara perangkat dan server, versi dengan `updated_at` paling baru yang dipakai.
Catatan lokal ditandai `dirty = 1` sampai server menjawab sukses (2xx), baru kemudian
ditandai bersih. Aturan ini ditetapkan secara eksplisit supaya sinkronisasi tidak
menimpa data secara diam-diam.

## Hasil yang Dicapai

### Pengujian

- [v] Mode gelap bertahan setelah aplikasi ditutup total.
- [v] Catatan bertahan setelah aplikasi ditutup dan dibuka lagi.
- [v] Badge `dirty` menunjukkan jumlah yang benar setelah tambah dan hapus catatan.
- [v] Posts tetap tampil dari cache saat mode pesawat aktif.
- [v] Setelah sync, badge kembali ke 0.
- [v] Toggle *Force offline* memberi hasil yang sama dengan mode pesawat sungguhan.

### Observasi

| Skenario | Sebelum | Sesudah | Screenshot |
|---|---|---|---|
| Posts saat online | Daftar kosong / belum ada cache | Daftar tampil, status "Diperbarui dari jaringan" | `screenshots/p3_01_posts_online.png` |
| Posts saat offline | ... | Daftar tetap tampil dari cache | `screenshots/p3_02_posts_offline.png` |
| Tambah catatan saat offline | Badge 0 | Badge 2 | `screenshots/p3_03_notes_offline.png` |
| Sync setelah online | Badge 2 | Badge 0 | `screenshots/p3_05_after_sync.png` |

### Keterbatasan

- Sinkronisasi masih **simulasi**: server digantikan `Future.delayed` 1 detik, lalu semua
  catatan `dirty` ditandai bersih. Yang dinilai di latihan ini adalah mekanismenya, bukan
  servernya.
- Penghapusan catatan langsung menghapus baris di database, belum ada *tombstone*, jadi
  penghapusan belum bisa diantrekan untuk dikirim ke server.
- Setelah data post diperbarui dari jaringan, state langsung diganti dengan data baru
  (tidak memakai `invalidate`, supaya tidak terjadi loop refresh).
- Aplikasi hanya diuji di Android, belum di web atau iOS.

## Hal yang Dipelajari

- Perbedaan kapan memakai SharedPreferences dan kapan memakai SQLite.
- Alasan akses data dibungkus repository dan provider, bukan dipanggil langsung di widget.
- Cara kerja cache-first dan kenapa UI tidak kosong saat offline.
- Kenapa sinkronisasi butuh aturan konflik yang jelas.