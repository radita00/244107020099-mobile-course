# AI Challenge — Review Kode Search oleh AI

Dokumen ini berisi prompt yang saya kirim, output AI apa adanya, tabel keputusan
per file, dan bukti verifikasinya. Semua perintah dijalankan di dalam
`09-week-9-ai-assisted-development/campus_notify`.

## 1. Prompt yang dikirim

Template dari jobsheet:

```
Review kode search Flutter ini sebagai senior dev.
Konteks: feature-first (presentation->domain<-data),
Riverpod, SQLite + Dio.
Fokus: kebenaran, arsitektur, test. Abaikan style.
Beri 3 temuan + level blocker/saran + alasan.
```

Konteks yang saya lampirkan (kode, bukan secret):

| Yang dilampirkan | Baris |
|---|---|
| `domain/usecases/search_announcements.dart` | 23 |
| `presentation/providers/announcements_providers.dart` | 80 |
| `presentation/widgets/search_field.dart` | 44 |
| `presentation/widgets/announcement_list.dart` | 65 |
| `presentation/widgets/empty_announcement_state.dart` | 40 |
| Daftar `test/` (7 file, 24 test) + hasil `flutter analyze` bersih | — |

Catatan jujur: project saya memakai repository in-memory, bukan SQLite. Saya
tetap menulis "SQLite + Dio" sesuai template, tapi di kolom konteks saya sebut
jelas bahwa datanya in-memory supaya AI tidak mengarang soal query database.

## 2. Output AI (apa adanya)

> **Temuan 1 — blocker**
> `EmptyAnnouncementState` tidak punya widget test. Jobsheet meminta 1 widget
> test untuk empty state, tetapi `test/` hanya berisi unit test use case.
> Padahal widget ini punya dua cabang yang menghasilkan teks dan ikon berbeda
> (`Icons.inbox` vs `Icons.search_off`), dan tidak satu pun cabang diverifikasi.
> Alasan: regresi teks/ikon tidak akan tertangkap gate mana pun.
>
> **Temuan 2 — blocker**
> `announcements_providers.dart` mencampur dua tanggung jawab: composition root
> (`AnnouncementRepositoryImpl`, provider use case) dan state presentasi
> (`SearchQuery`, `filteredAnnouncementsProvider`). Efeknya
> `widgets/announcement_list.dart` mengimpor file yang juga mengimpor
> implementasi data layer, sehingga batas layer kabur dan file ini berubah
> karena dua alasan berbeda. Ditambah lagi tidak ada test yang menyentuh
> `filteredAnnouncementsProvider`, jadi kesalahan wiring (override repository,
> urutan `watch`, query tidak ter-propagate) tidak terdeteksi.
> Alasan: satu file = satu alasan berubah; wiring tanpa test = bug senyap.
>
> **Temuan 3 — saran**
> Tambahkan debounce 300 ms pada `TextField` pencarian memakai `Timer` di
> `initState`/`dispose`, supaya filter tidak dijalankan setiap ketikan.
> Alasan: mengurangi jumlah rebuild pada daftar yang besar.

## 3. Tabel usulan vs keputusan

| File | Usulan AI | Keputusan | Alasan singkat |
|---|---|---|---|
| `widgets/empty_announcement_state.dart` | tambah widget test | **terima** | Kode tidak diubah, hanya menambah 3 test |
| `providers/announcements_providers.dart` | pisahkan DI dari state presentasi | **terima + refactor** | 80 → 45 baris, isinya hanya DI + state data |
| `providers/search_providers.dart` (baru) | — | **terima + refactor** | 39 baris: state query + daftar terfilter |
| `widgets/announcement_list.dart` | — | **terima** (ganti import) | Tidak lagi menyentuh file yang mengimpor data layer |
| `widgets/search_field.dart` | debounce 300 ms | **tolak** | Alasan teknis di §5 |
| `domain/usecases/search_announcements.dart` | — | **terima** (tanpa perubahan) | Sudah murni, sudah diuji 4 test |
| `test/search_provider_test.dart` (baru) | tambah test wiring | **terima** | 4 test lewat `ProviderContainer.test` |

## 4. Bukti temuan AI benar

Sebelum dikerjakan, saya buktikan dulu dengan grep — bukan percaya begitu saja
(`docs/evidence/09-bukti-temuan.txt`):

```
$ grep -rn "EmptyAnnouncementState" test/
[jumlah: 0]

$ grep -rn "filteredAnnouncementsProvider" test/
[jumlah: 0]

$ grep -rn "ProviderContainer" test/
[ProviderContainer di test: 0]
```

Jadi temuan 1 dan 2 benar: **nol** test menyentuh empty state maupun wiring
provider. Yang ada hanya `search_announcements_test.dart` (4 test) yang menguji
fungsi murni.

Setelah diperbaiki:

| Test baru | Isi | Jumlah |
|---|---|---|
| `test/empty_state_widget_test.dart` | query kosong → `Belum ada pengumuman.` + `Icons.inbox`; query terisi → pesan "tidak cocok" + `Icons.search_off`; query spasi saja dianggap kosong | 3 |
| `test/search_provider_test.dart` | query kosong → semua item; `BEASISWA` → 1 item (case-insensitive); `zzz` → kosong; `clear()` → semua item | 4 |

`test/search_provider_test.dart` memakai `ProviderContainer.test()` dengan
`announcementRepositoryProvider.overrideWithValue(...)`, jadi tidak menyentuh
jaringan atau database — ini yang membuktikan wiring-nya, bukan cuma use case-nya.

## 5. Alasan menolak temuan 3 (debounce)

Alasan penolakan bersifat teknis:

1. **Beban kerjanya tidak nyata.** Data ada di memori, 4 pengumuman, filter
   `toLowerCase().contains()` atas seluruh daftar. Biayanya jauh di bawah satu
   frame; debounce tidak mengubah angka yang bisa diukur.
2. **Menambah lifecycle yang harus dijaga.** `Timer` wajib di-`cancel()` di
   `dispose`. Kalau lupa, muncul "setState after dispose" saat halaman ditutup.
3. **Membuat test tidak deterministik.** Widget test jadi butuh
   `pump(Duration(milliseconds: 300))`; kalau timer belum jalan, assertion gagal
   dan hasilnya flaky.
4. **Perilaku jadi terasa lambat.** Dengan 4 item, hasil filter yang tertinggal
   300 ms dari ketikan justru terasa seperti lag.
5. **Kalau daftar benar-benar membesar**, solusinya bukan debounce di widget,
   melainkan pagination / query di data layer — jadi menaruh debounce sekarang
   akan salah tempat saat skalanya berubah.

## 6. Hasil verifikasi akhir

`docs/evidence/10-ai-challenge-verifikasi.txt`:

```
flutter analyze
  No issues found! (ran in 4.8s)

dart format --set-exit-if-changed .
  exit=0
  Formatted 51 files (0 changed)

flutter test
  +31: All tests passed!
```

Test naik dari 24 → 31 (3 widget test + 4 provider test), tanpa mengubah
perilaku aplikasi. `announcements_providers.dart` turun 80 → 45 baris dan
`announcement_list.dart` tidak lagi mengimpor file yang menyentuh data layer:

```
pages/announcement_page.dart:7:  import '../providers/announcements_providers.dart';
pages/home_page.dart:8:         import '../providers/announcements_providers.dart';
widgets/announcement_list.dart:6: import '../providers/search_providers.dart';
widgets/search_field.dart:4:      import '../providers/search_providers.dart';
```

## 7. Penjelasan tiap keputusan (tanpa membuka AI)

- **Empty state saya beri test** karena widget itu satu-satunya tempat dua
  kondisi berbeda (data kosong vs hasil pencarian kosong) dipisahkan. Kalau
  salah kondisi, user melihat pesan "belum ada pengumuman" padahal datanya ada
  dan cuma tidak cocok — itu bug yang tidak akan tertangkap `flutter analyze`.
- **File provider saya pecah** karena satu file sebaiknya berubah karena satu
  alasan. DI berubah kalau implementasi repository berganti; state pencarian
  berubah kalau perilaku UI berubah. Dicampur, setiap perubahan UI menyeret
  import data layer ke widget.
- **Wiring saya test lewat `ProviderContainer`** karena unit test use case tidak
  membuktikan `searchQueryProvider` benar-benar mengalir ke
  `filteredAnnouncementsProvider`. Yang diuji di situ adalah sambungannya, bukan
  rumus filternya.
- **Debounce saya tolak** karena masalah yang diselesaikan (rebuild berlebih)
  tidak ada pada 4 item di memori, sementara biayanya nyata: lifecycle timer,
  test flaky, dan respons yang terasa lambat.
