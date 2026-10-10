## Verifikasi Rekomendasi AI

### 1. Apakah daftar catatan disimpan di SharedPreferences?

Tidak. AI hanya menyarankan SharedPreferences untuk pengaturan kecil, dan di aplikasi saya
isinya cuma `dark_mode` dan `last_opened_at` (`lib/data/prefs.dart`). Daftar catatan
disimpan di tabel SQLite `notes` (`lib/data/local/db.dart`).

Menyimpan banyak catatan di SharedPreferences kurang cocok, karena seluruh koleksi harus
diubah ke teks dan dimuat ulang setiap kali ada perubahan. Untuk kebutuhan seperti ini
lebih pas pakai query database.

### 2. Apakah skema AI mendukung antrean sync?

Belum lengkap. Skema dari AI punya `updated_at`, tapi tidak punya `dirty`. Padahal
timestamp saja tidak cukup untuk tahu apakah sebuah perubahan sudah terkirim atau belum.

Skema di aplikasi saya sudah punya `dirty` dan `updated_at`, dan catatan baru otomatis
diberi `dirty: true` (`note.dart`, `note_repository.dart`). Tapi masih ada dua kekurangan:

- Sinkronisasinya masih simulasi. Tidak ada data yang dikirim ke server, semua catatan
  langsung ditandai bersih (`sync.dart`).
- Saat catatan dihapus, barisnya langsung hilang. Belum ada tombstone, jadi penghapusan
  tidak bisa dimasukkan ke antrean untuk dikirim ke server.

### 3. Apakah klaim "real-time" didukung stream?

Untuk Drift, klaimnya benar. Di proyek percobaan saya pakai `select(...).watch()`, dan test
menunjukkan hasilnya berubah dari satu baris menjadi dua baris setelah insert.

Tapi untuk aplikasi saya sekarang, klaim itu belum berlaku. Daftar catatan masih dimuat
lewat `fetchNotes()`, lalu state Riverpod di-invalidate setelah tambah atau hapus
(`providers.dart`). Jadi aplikasi ini belum memakai stream database.

### 4. Apakah estimasi boilerplate masuk akal?

Estimasi "sedang" masuk akal untuk skema yang kecil, tapi tetap ada biayanya.

Saya coba di proyek terpisah:

```powershell
flutter pub add drift
flutter pub add --dev drift_dev build_runner sqlite3
dart run build_runner build
flutter test
```

Versi yang terpasang: `drift 2.35.2`, `drift_dev 2.35.1`, `build_runner 2.16.2`. Generator
berhasil menulis tujuh file output dan test lulus.

Untuk migrasinya, saya buat database versi 1 dengan bentuk tabel sqflite saya (`updated_at`
berupa teks ISO-8601 dan ada kolom `dirty`), lalu dibuka dengan Drift versi 2 yang menambah
kolom `archived`. Data lama, timestamp, dan status dirty tetap terbaca.

Yang dibutuhkan untuk migrasi: deklarasi tabel, `schemaVersion`, `MigrationStrategy`,
converter tanggal supaya format `updated_at` lama tetap terbaca, dan test migrasi. Package
`sqlite3` hanya dipakai untuk membuat database lama saat test, bukan dibutuhkan aplikasi
saat berjalan.

Percobaan ini hanya membuktikan alur dasarnya. Saya belum mengukur performa dengan 1000+
catatan, dan belum menghitung biaya memindahkan