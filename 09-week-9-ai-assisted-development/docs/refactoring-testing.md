# Refactoring, Testing, dan Error Umum (Week 9 — bagian 7)

Semua perintah dijalankan di `09-week-9-ai-assisted-development/campus_notify`.
Bukti mentah: `docs/evidence/11-refactoring-verifikasi.txt`.

## 7.1 Refactoring Challenge

### a. Hasil AI di atas 80 baris dipecah jadi bagian kecil yang bisa diuji

| Sebelum (hasil AI) | Sesudah | Keterangan |
|---|---|---|
| `pages/home_page.dart` **226 baris** | **145 baris** | isinya tinggal lifecycle + 5 handler |
| `providers/announcements_providers.dart` **80 baris** (DI + state pencarian) | **45 baris** (DI + state data) | pencarian pindah ke `search_providers.dart` (**39 baris**) |
| `build()` **141 baris** | **25 baris** | dipecah ke 4 widget |

Widget hasil pemecahan:

| Widget | Baris | Isi |
|---|---|---|
| `widgets/search_field.dart` | 44 | `TextField` + tombol clear |
| `widgets/announcement_list.dart` | 65 | `state.when` loading / error / data |
| `widgets/empty_announcement_state.dart` | 40 | dua kondisi kosong (belum ada data vs tidak cocok) |
| `widgets/push_status_panel.dart` | 42 | status izin + token ter-mask |

Panjang method di `home_page.dart` (batas yang saya pakai: 40 baris):

```
 36 baris  Future<void> _initPush
 25 baris  Widget build
 17 baris  PreferredSizeWidget _buildAppBar
  9 baris  Future<void> _sendTestNotification
  4 baris  initState / dispose / _info / _logout
```

**Catatan jujur:** `home_page.dart` tetap 145 baris dan tidak saya paksa di bawah
80. Isinya sekarang satu `build()` 25 baris + handler yang semuanya ≤ 36 baris.
Memindahkan `_initPush` ke berkas lain tanpa memecah logikanya cuma
memindahkan masalah, bukan menyelesaikannya. Yang saya kecilkan adalah
**method dan tanggung jawab** — dan itu yang membuat kodenya bisa diuji
(`empty_state_widget_test.dart`, `search_provider_test.dart`).

### b. Filter/search dipindah ke use case domain yang murni

`domain/usecases/search_announcements.dart` (23 baris), **0 import Flutter**:

```dart
class SearchAnnouncements {
  const SearchAnnouncements();

  List<Announcement> call(List<Announcement> items, String query) {
    final keyword = query.trim().toLowerCase();
    if (keyword.isEmpty) return List<Announcement>.unmodifiable(items);
    return items
        .where((item) => item.title.toLowerCase().contains(keyword))
        .toList(growable: false);
  }
}
```

Widget tidak lagi menyimpan logika filter:

| Komponen | Tanggung jawab |
|---|---|
| `SearchField` | menulis teks ke `searchQueryProvider` |
| `SearchQuery` (Notifier) | menyimpan query, `setQuery` / `clear` |
| `filteredAnnouncementsProvider` | memanggil `SearchAnnouncements` + meneruskan status loading/error |
| `AnnouncementList` | render hasil, tidak tahu cara memfilter |

Bukti domain steril: `grep -rn "package:flutter\|package:flutter_riverpod"
lib/features/*/domain/` → **0 hasil**.

### c. Import lintas layer dihapus

Sebelum: dua berkas di `presentation/` mengimpor `data/` secara langsung.

| Berkas | Import yang dihapus |
|---|---|
| `announcements/presentation/providers/announcements_providers.dart` | `../../data/repositories/announcement_repository_impl.dart` |
| `auth/presentation/providers/auth_providers.dart` | `../../data/repositories/auth_repository_impl.dart` |

Sesudah: implementasi konkret pindah ke composition root per fitur —
`features/announcements/di.dart` dan `features/auth/di.dart`. Berkas provider di
`presentation/` sekarang hanya bergantung pada `AnnouncementRepository` /
`AuthRepository` (domain).

```
$ grep -rn "data/" lib/features/*/presentation/
[jumlah: 0]

$ grep -rn "import '.*data/" lib/features/
announcements/di.dart:3:import 'data/repositories/announcement_repository_impl.dart';
auth/di.dart:3:import 'data/repositories/auth_repository_impl.dart';
```

`flutter analyze` setelah perubahan: **No issues found!**

## 7.2 Testing

```
$ flutter test
+31: All tests passed!
```

| Item di jobsheet | Status | Bukti |
|---|---|---|
| `flutter test test/search_filter_test.dart` | ✅ — nama berkas saya `search_announcements_test.dart`, isinya sama: 4 test filter | `test/search_announcements_test.dart` |
| \+ 1 widget test untuk empty state | ✅ malah 3 test | `test/empty_state_widget_test.dart` |
| \+ uji manual 3 query + screenshot | ✅ | `screenshots/` |
| Test wiring provider (tambahan) | ✅ 4 test | `test/search_provider_test.dart` |

Uji manual yang saya lakukan di HP fisik:

| Query | Hasil | Screenshot |
|---|---|---|
| (kosong) | 4 pengumuman tampil | `screenshots/search-kosong.jpg` |
| `ujian` | 1 hasil: "Pengumuman ujian" | `screenshots/search-cocok.jpg` |
| `zzz` | empty state "tidak ada yang cocok" | `screenshots/search-tidak-cocok.jpg` |

## 7.3 Error umum dan solusinya

| Gejala | Terjadi? | Bukti | Yang saya lakukan |
|---|---|---|---|
| Method tidak ada (halusinasi API) | ✅ | `evidence/01-analyze-v1.txt`: `The function 'StateProvider' isn't defined`, `The getter 'notifier' isn't defined` | Cek sumber `riverpod-3.4.3` di pub cache, ganti ke `Notifier` + `AsyncValue.whenData` |
| Import lintas layer | ✅ | `grep presentation -> data` = 2 | Pindah implementasi ke `di.dart` per fitur (§7.1c) |
| Semua test merah | ⚠️ sebagian | `evidence/03-test-gagal.txt`: **2 dari 4** test merah — query `Ujian` (huruf besar) dan `BEASISWA` menghasilkan `[]` | Perbaiki use case (`toLowerCase()` pada query **dan** judul), **bukan** mengubah test |
| Prompt diulang terus | ❌ | — | Prompt v1 sudah cukup; yang salah output-nya, bukan prompt-nya. Saya verifikasi manual lalu perbaiki (`ai-log.md` §2.3) |
| Tak bisa menjelaskan | ❌ | — | Tiap perubahan dibaca ulang; alasan tiap keputusan ditulis di `ai-challenge.md` §7 |

## 7.4 Checklist verifikasi mandiri

- [x] Prompt 5 slot + konteks ada di `docs/ai-log.md` (§1.4 prompt final, §1.5 daftar konteks).
- [x] `flutter analyze` bersih (`No issues found!`) dan `flutter test` hijau (31 test).
- [x] 1 temuan AI dibuktikan benar + 1 ditolak beralasan — `docs/ai-challenge.md` §4 dan §5.
- [x] Mampu menjelaskan tiap keputusan tanpa membuka AI — `docs/ai-challenge.md` §7.
