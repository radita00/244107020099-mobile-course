# AI Log — Week 9: AI-Assisted Development

> **Status pengerjaan:** Praktikum 1 (Prompt & Context Engineering) ✅ · Praktikum 2 (Generate & Verifikasi) ✅ · Praktikum 3 (Debug & Refactor) ✅ · AI Challenge ✅
> Hasil: 3 bug AI ditemukan & diperbaiki, `home_page.dart` 226 → 145 baris (semua method < 40 baris), `flutter analyze` bersih, 31/31 test hijau, 3 screenshot uji manual.
> Rincian AI Challenge (review AI, 3 temuan, keputusan per file) ada di [`ai-challenge.md`](ai-challenge.md). README **belum dikerjakan**.

---

# Praktikum 1 — Prompt & Context Engineering

## 1.1 Fitur yang dipilih

**Search judul pengumuman (case-insensitive) + empty state** di halaman Home `campus_notify`.

### Kenapa bukan "search notes" (contoh di jobsheet)?

Karena fitur `notes` di project ini **belum punya vertical slice lengkap**:

| Lapisan | Status di `campus_notify` week 7 |
|---|---|
| `Note` entity | ✅ ada |
| `NoteRepository` (interface) | ✅ ada |
| `GetNotes` use case | ✅ ada (pass-through 7 baris) |
| `NoteModel` | ✅ ada |
| Implementasi repository | ❌ tidak ada |
| Provider | ❌ tidak ada |
| Halaman / UI | ❌ tidak ada |
| Route | ❌ tidak ada |
| `sqflite` di `pubspec.yaml` | ❌ tidak ada |

Test `get_notes_test.dart` memakai `FakeNoteRepository` — jadi `GetNotes` belum bisa dijalankan beneran.

Kalau dipaksa "search notes", pekerjaannya jadi **membangun fitur notes dari nol** (tambah dependency DB + implementasi repository + provider + UI + route + test). Itu melanggar aturan jobsheet: *"menambah satu fitur kecil dengan AI, bukan membuat project baru."*

Sebaliknya `announcements` sudah punya vertical slice lengkap, jadi menambah search benar-benar "satu fitur kecil".

### Rencana file yang akan disentuh (belum dikerjakan)

| File | Jenis | Perkiraan baris |
|---|---|---|
| `lib/features/announcements/domain/usecases/search_announcements.dart` | baru | ~25 |
| `lib/features/announcements/presentation/providers/announcements_providers.dart` | ubah (tambah provider) | ~15 |
| `lib/features/announcements/presentation/pages/home_page.dart` | ubah (SearchBar + empty state) | ~40 |
| `test/search_announcements_test.dart` | baru | ~50 |

---

## 1.2 Prompt versi 1 — contoh BURUK (pembanding)

```
buatkan search pengumuman yang keren
```

**Kenapa buruk** — kelima slot kosong:

| Slot | Isi |
|---|---|
| Peran | ❌ tidak disebut |
| Konteks | ❌ tidak ada (AI tidak tahu ini project apa, pakai Riverpod atau tidak) |
| Tugas | ⚠️ ada tapi kabur: "yang keren" itu kriteria apa? |
| Batas | ❌ tidak ada (AI bebas ubah arsitektur, bebas panggil Dio dari widget) |
| Output | ❌ tidak ada (tidak minta test, tidak minta cara uji) |

Akibat yang bisa ditebak: AI akan menulis `StatefulWidget` dengan `setState`, memanggil repository langsung dari widget, dan **tidak** membuat test — semuanya melanggar dependency rule week 7.

---

## 1.3 Prompt versi 2 — formula 5 slot

```
Peran: senior Flutter developer yang disiplin Clean Architecture.

Konteks: project campus_notify, arsitektur feature-first dengan alur
presentation -> domain <- data. State management flutter_riverpod ^3.4.3.
Fitur announcements sudah punya entity, repository, use case, dan provider.

Tugas: tambah search judul pengumuman (case-insensitive, trim) + empty state
saat tidak ada hasil.

Batas: jangan ubah arsitektur, logika filter wajib di domain layer sebagai
use case (pure Dart), maksimal 80 baris, jangan sentuh fitur auth dan FCM.

Output: kode + 3 test case + cara uji manual.
```

Sudah mengisi 5 slot, tapi **konteksnya masih abstrak** — AI belum tahu nama class, signature repository, dan bentuk entity yang nyata. Jadi masih berpotensi mengarang API.

---

## 1.4 Prompt FINAL — 5 slot + konteks nyata (yang dipakai)

```text
Peran: senior Flutter developer yang disiplin Clean Architecture.

Konteks:
- Project: campus_notify — Flutter 3.47.7 / Dart 3.13.5
- Arsitektur: feature-first, alur dependency presentation -> domain <- data
- State management: flutter_riverpod ^3.4.3, routing: go_router ^18.0.2
- Fitur yang SUDAH ada: auth (login/logout), announcements (list + detail), FCM push
- Entity Announcement: id (String), title (String), body (String),
  author (String?), createdAt (DateTime?)
- announcementsProvider = FutureProvider<List<Announcement>> yang memanggil
  use case GetAnnouncements
- Struktur folder relevan:
  lib/core/failures.dart
  lib/features/announcements/domain/entities/announcement.dart
  lib/features/announcements/domain/repositories/announcement_repository.dart
  lib/features/announcements/domain/usecases/get_announcements.dart
  lib/features/announcements/domain/usecases/get_announcement_detail.dart
  lib/features/announcements/data/models/announcement_model.dart
  lib/features/announcements/data/repositories/announcement_repository_impl.dart
  lib/features/announcements/presentation/providers/announcements_providers.dart
  lib/features/announcements/presentation/pages/home_page.dart

Kontrak yang TIDAK boleh diubah — get_announcements.dart:

  import '../../../../core/failures.dart';
  import '../entities/announcement.dart';
  import '../repositories/announcement_repository.dart';

  /// Use case: Mengambil daftar pengumuman kampus.
  class GetAnnouncements {
    const GetAnnouncements(this._repository);
    final AnnouncementRepository _repository;

    Future<({List<Announcement> items, Failure? failure})> call() {
      return _repository.getAnnouncements();
    }
  }

Kontrak yang TIDAK boleh diubah — announcement_repository.dart:

  abstract interface class AnnouncementRepository {
    Future<({List<Announcement> items, Failure? failure})> getAnnouncements();
    Future<({Announcement? item, Failure? failure})> getAnnouncementById(String id);
  }

Potongan home_page.dart yang relevan (bagian render daftar):

  final announcementsState = ref.watch(announcementsProvider);
  ...
  announcementsState.when(
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (err, _) => Text('Gagal memuat pengumuman: $err'),
    data: (items) {
      if (items.isEmpty) {
        return const Center(child: Text('Belum ada pengumuman.'));
      }
      return Column(children: items.map((announcement) {
        return ListTile(
          leading: const Icon(Icons.campaign),
          title: Text(announcement.title),
          subtitle: Text(announcement.body),
          onTap: () => context.go(AppRoutes.announcement(announcement.id)),
        );
      }).toList());
    },
  )

Tugas:
Tambahkan fitur pencarian judul pengumuman di halaman Home:
1. Search bar di atas daftar pengumuman.
2. Filter judul secara CASE-INSENSITIVE dan tahan spasi depan/belakang (trim).
3. Query kosong (atau hanya spasi) = tampilkan SEMUA pengumuman.
4. Empty state KHUSUS saat tidak ada hasil:
   "Tidak ada pengumuman yang cocok dengan '<query>'"
   — bedakan dari empty state lama "Belum ada pengumuman." yang berarti
   datanya memang kosong dari server.

Batas:
- JANGAN ubah arsitektur, entity Announcement, maupun AnnouncementRepository.
- Logika filter WAJIB di domain layer sebagai use case baru, pure Dart,
  tanpa import Flutter/Dio.
- Widget TIDAK boleh memanggil repository langsung — lewat provider Riverpod.
- Maksimal 80 baris kode baru.
- JANGAN sentuh fitur auth dan FCM.
- JANGAN menambah dependency baru di pubspec.yaml.

Output yang saya mau:
1. Kode lengkap file baru + bagian home_page.dart yang berubah.
2. 3 test case: (a) query cocok, (b) query tidak cocok -> empty state,
   (c) query kosong -> semua tampil.
3. Cara uji manual langkah demi langkah.
4. Sebutkan SETIAP API Riverpod/Dart yang kamu pakai beserta nama class dan
   versinya, supaya saya bisa verifikasi ke pub.dev dan pubspec.lock.
```

### Kenapa poin 4 di "Output" penting

Meminta AI **mendeklarasikan sendiri** API yang dipakai membuat halusinasi lebih mudah dibuktikan. Kalau AI menulis `ref.watch(searchProvider.notifier).updateQuery()` tapi di Riverpod 3.4.3 method itu tidak ada, kita punya daftar klaim tertulis untuk dicek satu per satu — bukan menebak dari kode jadi.

---

## 1.5 Konteks: apa yang ditempel dan apa yang TIDAK

| Disertakan | Alasan |
|---|---|
| Struktur folder `features/announcements/` | AI perlu tahu batas layer, bukan menebak |
| `get_announcements.dart` + `announcement_repository.dart` | Kontrak nyata → signature tidak dikarang |
| Entity `Announcement` (field + tipe) | Supaya filter menyasar field `title` yang benar |
| Potongan `home_page.dart` bagian `data:` | Titik sisip search + empty state |
| Versi package dari `pubspec.yaml` | Mencegah AI memakai API versi lama |

| TIDAK disertakan | Alasan |
|---|---|
| Token FCM / JWT / `Authorization` header | Secret — dilarang jobsheet |
| `flutter_secure_storage`, `token_store.dart` | Tidak relevan untuk search, hanya menambah risiko |
| Seluruh isi `home_page.dart` (175 baris) | Bagian `_initPush()`, `_mask(_token!)`, dan status FCM **dipotong** karena memuat token FCM |
| `google-services.json`, `GoogleService-Info.plist` | Kredensial Firebase |
| Seluruh repo (~42 file Dart) | Melanggar prinsip "tempel potongan relevan, bukan seluruh repo" |
| Screenshot kode | Jobsheet: tempel teks, bukan gambar kabur |

### Sanitasi yang dilakukan sebelum prompting

1. `home_page.dart` dipotong: hanya bagian `build()` + cabang `data:` yang ditempel. Baris `_mask(_token!)`, `_status`, dan `_initPush()` dibuang karena menampilkan/mengolah token FCM.
2. `pubspec.yaml` hanya diambil nama package + versi — bukan seluruh file.
3. Tidak ada nilai token nyata di dokumen ini. Kalau suatu saat perlu menyebut token, gunakan placeholder `TOKEN_PLACEHOLDER`.

---

## 1.6 Verifikasi 5 slot

| Slot | Terisi di prompt final? | Bukti |
|---|---|---|
| **Peran** | ✅ | "senior Flutter developer yang disiplin Clean Architecture" |
| **Konteks** | ✅ | versi Flutter/Dart, arsitektur, Riverpod, entity, struktur folder, 2 file kontrak, snippet `home_page` |
| **Tugas** | ✅ | 4 poin bernomor (search bar, case-insensitive + trim, query kosong, empty state khusus) |
| **Batas** | ✅ | 6 larangan eksplisit (arsitektur, entity, repository, widget→repo, dependency baru, fitur auth/FCM) + batas 80 baris |
| **Output** | ✅ | 4 item (kode, 3 test case, cara uji, deklarasi API + versi) |

---

## 1.7 Checklist Praktikum 1

- [x] Fitur kecil dipilih dan dibatasi (search judul + empty state)
- [x] Alasan memilih `announcements` (bukan `notes`) terdokumentasi
- [x] Prompt buruk vs prompt baik dibandingkan per slot
- [x] Prompt final mengisi 5 slot (Peran, Konteks, Tugas, Batas, Output)
- [x] Konteks nyata ditempel: struktur folder, 2 file kontrak, entity, versi package
- [x] Tidak ada secret/token/JWT di prompt
- [x] Menyebutkan bagian yang TIDAK boleh diubah
- [x] Rencana verifikasi disebut (deklarasi API + versi untuk dicek ke pub.dev)

**Belum dikerjakan (menunggu perintah):** Praktikum 3 (debug + refactor), AI Challenge, README, screenshots.

---

# Praktikum 2 — Generate & Verifikasi

## 2.1 Prompt yang dipakai

Prompt final dari [§1.4](#14-prompt-final-yang-dipakai) dipakai **apa adanya**, tanpa tambahan `"fix dong"` atau prompt susulan. Output awal AI diterima utuh dulu, baru diverifikasi.

## 2.2 Output awal AI (v1) — yang diklaim

AI menghasilkan 3 file:

| File | Isi | Klaim AI |
|---|---|---|
| `domain/usecases/search_announcements.dart` | Use case filter judul | "case-insensitive + trim" |
| `presentation/providers/announcements_providers.dart` | `searchQueryProvider` + `filteredAnnouncementsProvider` | "Riverpod 3 siap pakai" |
| `presentation/pages/home_page.dart` | Search bar + empty state | "empty state untuk query kosong dan tak cocok" |

Potongan v1 yang bermasalah:

```dart
// v1 — providers
final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredAnnouncementsProvider = FutureProvider<List<Announcement>>((ref) async {
  final items = await ref.watch(announcementsProvider.notifier).future;
  final query = ref.watch(searchQueryProvider);
  return ref.watch(searchAnnouncementsProvider)(items, query);
});

// v1 — use case
final keyword = query.trim();
return items.where((item) => item.title.contains(keyword)).toList();
```

## 2.3 Verifikasi 6 langkah (sesuai jobsheet)

| # | Langkah | Hasil |
|---|---|---|
| 1 | Baca tiap baris, tandai yang belum dipahami | 3 baris ditandai: `StateProvider`, `.notifier`, `contains` tanpa `toLowerCase()` |
| 2 | Cek import — `domain/` bebas Flutter/Dio/SQLite | ✅ 0 hasil (lihat `evidence/07-grep-steril.txt`) |
| 3 | Cek API nyata (autocomplete + source package) | ❌ 2 API tidak ada → lihat §2.4 & §2.5 |
| 4 | `flutter analyze` sampai nol warning | ❌ 2 error dulu → ✅ `No issues found!` |
| 5 | Minimal 1 test sukses + 1 test gagal | ✅ 4 test; 2 merah dulu → hijau |
| 6 | Uji manual 3 query (kosong / cocok / tak cocok) | ✅ 3 screenshot di `screenshots/` → lihat §3.2 |

## 2.4 Halusinasi #1 — `StateProvider` (method fiktif untuk versi ini)

Output `flutter analyze` apa adanya:

```
error - The function 'StateProvider' isn't defined. Try importing the library that
defines 'StateProvider', correcting the name to the name of an existing function,
or defining a function named 'StateProvider' - lib\features\announcements\presentation\
providers\announcements_providers.dart:54:29 - undefined_function
```

**Bukti dari source package** (`riverpod-3.4.3`):

| Fakta | Bukti |
|---|---|
| `StateProvider` **ada**, tapi di folder `legacy` | `lib/src/providers/legacy/state_provider.dart:39` → `final class StateProvider<ValueT>` |
| Tidak diekspor lewat import utama | `flutter_riverpod.dart` dan `riverpod.dart` **tidak** punya baris export `legacy` → grep 0 hasil |
| Pengganti resmi | `lib/src/providers/notifier/orphan.dart:78` → `NotifierProvider<NotifierT, ValueT>` |

Jadi AI menulis API yang **sudah dipindah ke `legacy.dart`** dan tidak tersedia dari `import 'package:flutter_riverpod/flutter_riverpod.dart';`. Ini persis kategori *"Package kadaluarsa — AI memakai API v1 padahal pubspec memakai v3"*.

## 2.5 Halusinasi #2 — `FutureProvider.notifier`

```
error - The getter 'notifier' isn't defined for the type
'FutureProvider<List<Announcement>>'. Try importing the library that defines
'notifier', ... - lib\features\announcements\presentation\providers\
announcements_providers.dart:60:55 - undefined_getter
```

`.notifier` hanya dimiliki provider ber-*state* (`NotifierProvider`, `StateProvider`), bukan `FutureProvider`. AI mencampur dua konsep.

**Perbaikan:** `AsyncValue.whenData` — terverifikasi ada di `lib/src/core/async_value.dart:168`:

```dart
AsyncValue<NewT> whenData<NewT>(NewT Function(ValueT value) cb)
```

## 2.6 Bug logika #3 — filter case-sensitive

Kode v1 **lolos analyze** setelah 2 error di atas diperbaiki, tapi tetap salah. Test membuktikannya:

```
00:00 +1 -1: SearchAnnouncements query yang cocok mengembalikan pengumuman yang sesuai [E]
  Expected: an object with length of <1>
    Actual: []
     Which: has length of <0>
  test\search_announcements_test.dart 26:7

00:00 +1 -2: SearchAnnouncements pencarian tidak membedakan huruf besar dan kecil [E]
  Expected: an object with length of <1>
    Actual: []
     Which: has length of <0>
  test\search_announcements_test.dart 31:7
```

Penyebab: `query` di-`trim()` tapi **tidak** di-`toLowerCase()`, dan `item.title` juga tidak. Query `'beasiswa'` gagal menemukan `'Beasiswa Unggulan 2026'`.

Ini kategori *"Logika yakin tapi salah — filter case-sensitive yang meloloskan bug"* di jobsheet. Yang menarik: AI **mengklaim** case-insensitive di komentar kodenya, tapi implementasinya tidak.

## 2.7 Perbaikan final (v3)

```dart
// domain/usecases/search_announcements.dart
List<Announcement> call(List<Announcement> items, String query) {
  final keyword = query.trim().toLowerCase();
  if (keyword.isEmpty) return List<Announcement>.unmodifiable(items);

  return items
      .where((item) => item.title.toLowerCase().contains(keyword))
      .toList(growable: false);
}
```

```dart
// presentation/providers/announcements_providers.dart
class SearchQuery extends Notifier<String> {
  @override
  String build() => '';
  void setQuery(String value) => state = value;
  void clear() => state = '';
}

final searchQueryProvider = NotifierProvider<SearchQuery, String>(SearchQuery.new);

final filteredAnnouncementsProvider =
    Provider<AsyncValue<List<Announcement>>>((ref) {
  final asyncItems = ref.watch(announcementsProvider);
  final query = ref.watch(searchQueryProvider);
  final search = ref.watch(searchAnnouncementsProvider);
  return asyncItems.whenData((items) => search(items, query));
});
```

Perbaikan tambahan di `home_page.dart`: empty state dipisah jadi dua pesan —
`"Belum ada pengumuman."` (data memang kosong) vs
`"Tidak ada pengumuman yang cocok dengan "<query>"."` (hasil filter kosong),
plus ikon `Icons.inbox` vs `Icons.search_off`. AI v1 memakai satu pesan untuk dua kondisi berbeda.

## 2.8 Hasil akhir (bukti mesin)

| Gate | Perintah | Hasil | Bukti |
|---|---|---|---|
| Analyze | `flutter analyze` | `No issues found! (ran in 9.2s)` | `evidence/05-analyze-final.txt` |
| Test | `flutter test` | `+24: All tests passed!` | `evidence/04-test-hijau.txt` |
| Format | `dart format --set-exit-if-changed lib test` | `Formatted 44 files (0 changed)` exit `0` | `evidence/06-format.txt` |

Test baru: `test/search_announcements_test.dart` (4 test — query kosong, query cocok, case-insensitive, tanpa hasil). Total suite naik dari 20 → **24 test**.

## 2.9 Tabel terima / tolak saran AI

| # | Saran / output AI | Keputusan | Alasan teknis | Bukti |
|---|---|---|---|---|
| 1 | Use case murni di `domain/` untuk aturan filter | ✅ **Terima** | Sesuai dependency rule: logika bisnis bisa diuji tanpa Flutter/DB | `search_announcements.dart` tidak mengimpor `package:flutter` |
| 2 | `AsyncValue.whenData` untuk mempertahankan status loading/error | ✅ **Terima + refactor** | Idempoten, tidak memicu fetch ulang; `announcementsProvider` tetap satu sumber data | `async_value.dart:168` |
| 3 | `StateProvider` untuk query | ❌ **Tolak** | Tidak diekspor `flutter_riverpod.dart` di v3.4.3 → `undefined_function` | `evidence/01-analyze-v1.txt` |
| 4 | `announcementsProvider.notifier.future` | ❌ **Tolak** | `FutureProvider` tidak punya `.notifier` → `undefined_getter` | `evidence/01-analyze-v1.txt` |
| 5 | `title.contains(keyword)` tanpa normalisasi huruf | ❌ **Tolak** | Case-sensitive → query `'beasiswa'` tidak menemukan `'Beasiswa ...'` | `evidence/03-test-gagal.txt` |
| 6 | Satu pesan empty state untuk dua kondisi | ❌ **Tolak** | Pengguna tidak bisa membedakan "data kosong" vs "filter tidak cocok" | `home_page.dart` §2.7 |

## 2.10 Akar masalah (5 langkah debugging jobsheet)

1. **Reproduksi** — `flutter analyze` menunjuk file:baris:kolom (`announcements_providers.dart:54:29` dan `:60:55`).
2. **Isolasi** — aturan filter dipindah ke `SearchAnnouncements` (pure Dart) supaya bisa diuji tanpa widget.
3. **Test merah** — `search_announcements_test.dart` dibuat **sebelum** fix; 2 test merah membuktikan bug case-sensitive.
4. **Perbaiki kecil** — hanya 2 baris (`toLowerCase()` di kedua sisi) + ganti 2 API salah. Tidak ada refactor besar.
5. **Catat akar masalah** — §2.4–§2.6 di dokumen ini.

## 2.11 Checklist Praktikum 2

- [x] Kode digenerate dari prompt Praktikum 1 (tanpa prompt susulan "fix dong")
- [x] Langkah 1 — tiap baris dibaca & ditandai
- [x] Langkah 2 — `domain/` terbukti bebas Flutter/Dio/SQLite (grep 0 hasil)
- [x] Langkah 3 — API dicek ke source package `riverpod-3.4.3`, bukan tebakan
- [x] Langkah 4 — `flutter analyze` nol warning
- [x] Langkah 5 — 4 test (sukses + gagal + case-insensitive + tanpa hasil)
- [x] Langkah 6 — uji manual 3 query + screenshot ✅ (`screenshots/search-kosong.jpg`, `search-cocok.jpg`, `search-tidak-cocok.jpg`)
- [x] Minimal 1 bug/halusinasi AI ditemukan **dengan bukti** → ditemukan **3**
- [x] Output awal AI & output error disimpan verbatim di `docs/evidence/`

**Belum dikerjakan (menunggu perintah):** AI Challenge, README.

---

# Praktikum 3 — Debug dan Refactor

## 3.1 Debug dengan test merah (5 langkah)

Debug yang diminta jobsheet sudah dijalankan saat Praktikum 2, bukan setelahnya. Urutannya sengaja dibalik: **test merah dulu, perbaikan belakangan**.

| # | Langkah jobsheet | Yang dilakukan | Bukti |
|---|---|---|---|
| 1 | **Reproduksi** — langkah + input pemicu bug | `flutter analyze` menunjuk lokasi persis: `announcements_providers.dart:54:29` (`StateProvider`) dan `:60:55` (`.notifier`). Untuk bug logika: input `beasiswa` pada judul `Beasiswa Unggulan 2026` | `evidence/01-analyze-v1.txt` |
| 2 | **Isolasi** — pindah filter ke use case murni | Aturan pencarian dipindah ke `SearchAnnouncements` (tanpa Flutter/Dio/SQLite) sehingga bisa diuji tanpa widget | `domain/usecases/search_announcements.dart` |
| 3 | **Test merah** — buat test gagal pembukti bug | 4 test ditulis **sebelum** perbaikan; 2 di antaranya merah | `evidence/03-test-gagal.txt` |
| 4 | **Perbaiki kecil**, jalankan test + analyze | Hanya 2 baris berubah (`toLowerCase()` di query dan di `title`) + 2 API diganti | `evidence/02`, `evidence/04`, `evidence/05` |
| 5 | **Catat akar masalah** | Ditulis di §2.4–§2.6 dokumen ini | §2.4, §2.5, §2.6 |

**Tidak ada prompt `"fix dong"`.** Setiap perbaikan punya pemicu tertulis: pesan error compiler atau test merah.

## 3.2 Uji manual 3 query + screenshot

Dijalankan di HP Android fisik (bukan emulator), mode `flutter run` (banner DEBUG terlihat).

| Kondisi | Input | Hasil yang terlihat | File |
|---|---|---|---|
| Query kosong | *(kosong)* | 4 pengumuman: Pengumuman perkuliahan, Pengumuman ujian, Jadwal kuliah berubah, Pendaftaran seminar dibuka | `screenshots/search-kosong.jpg` |
| Query cocok | `ujian` | 1 hasil: **Pengumuman ujian** | `screenshots/search-cocok.jpg` |
| Query tak cocok | `zzz` | Ikon `search_off` + teks **Tidak ada pengumuman yang cocok dengan "zzz"** | `screenshots/search-tidak-cocok.jpg` |

Ketiga screenshot diperiksa ulang satu per satu (bukan diasumsikan): isi kotak search, jumlah item, dan teks empty state sesuai harapan.

## 3.3 Refactor ke layer yang benar

Target jobsheet:

```
widget (UI saja) -> notifier (state saja) -> use case (aturan filter/search) -> repository (SQLite/Dio)
```

### Sebelum vs sesudah

| File | Sebelum | Sesudah |
|---|---|---|
| `pages/home_page.dart` | **226 baris**, `build()` **141 baris** | **145 baris**, `build()` **25 baris** |
| `widgets/search_field.dart` | menyatu di `home_page.dart` | **44 baris** |
| `widgets/announcement_list.dart` | menyatu di `home_page.dart` | **65 baris** |
| `widgets/empty_announcement_state.dart` | menyatu di `home_page.dart` | **40 baris** |
| `widgets/push_status_panel.dart` | menyatu di `home_page.dart` | **42 baris** |

### Panjang tiap method di `home_page.dart` (batas 40 baris)

| Method | Baris |
|---|---|
| `initState()` | 4 |
| `dispose()` | 4 |
| `_initPush()` | 36 |
| `_info()` | 4 |
| `_logout()` | 4 |
| `_sendTestNotification()` | 9 |
| `_buildAppBar()` | 17 |
| `build()` | 25 |

Semua di bawah 40 ✅

### Pembagian tanggung jawab per layer

| Layer | File | Tanggung jawab |
|---|---|---|
| **widget (UI saja)** | `widgets/search_field.dart` | Render kotak pencarian; kirim input ke notifier |
| | `widgets/announcement_list.dart` | Render loading/error/data; tidak tahu dari mana data datang |
| | `widgets/empty_announcement_state.dart` | Bedakan "data kosong" vs "filter tak cocok" |
| | `widgets/push_status_panel.dart` | Render status FCM; aksi lewat callback, bukan service langsung |
| **notifier (state saja)** | `SearchQuery extends Notifier<String>` | Simpan query + `setQuery()` / `clear()` |
| **use case (aturan search)** | `SearchAnnouncements` | Trim, `toLowerCase()`, filter `title.contains()` |
| **repository (data)** | `AnnouncementRepositoryImpl` | Sumber data pengumuman |

### Bukti tidak ada akses data dari widget

```
grep -rn "data/repositories|package:sqflite|package:dio" \
  lib/features/announcements/presentation/pages \
  lib/features/announcements/presentation/widgets
→ [jumlah: 0]
```

## 3.4 Verifikasi akhir

| Perintah (persis jobsheet) | Hasil | Bukti |
|---|---|---|
| `flutter analyze` | `No issues found! (ran in 51.7s)` | `evidence/08-praktikum3-verifikasi.txt` |
| `dart format --set-exit-if-changed .` | `Formatted 48 files (0 changed)` — exit `0` | idem |
| `flutter test` | `+24: All tests passed!` | idem |

### Catatan masalah saat verifikasi

`dart format --set-exit-if-changed .` awalnya **crash**:

```
PathNotFoundException: Directory listing failed, path = '.\build\app\intermediates\
desugar_graph\debug\dexBuilderDebug\out\currentProject\jar_..._bucket_0\*'
```

Penyebab: folder `build/` sisa Gradle (hasil `flutter run`) berisi path yang sudah tidak valid di Windows, dan `dart format .` menelusuri **seluruh** direktori tanpa menghiraukan `.gitignore`. Ini bukan masalah kode.

Solusi: hapus `build/` lalu ulangi perintah → `Formatted 48 files (0 changed)`.

## 3.5 Checklist Praktikum 3

- [x] 5 langkah debug dijalankan berurutan (reproduksi → isolasi → test merah → perbaiki → catat)
- [x] Tidak memakai prompt `"fix dong"`; tiap perbaikan punya bukti error/test merah
- [x] Fungsi di atas 40 baris dipecah (`build()` 141 → 25 baris)
- [x] Tidak ada panggilan database/repository dari widget (grep 0 hasil)
- [x] Alur layer benar: widget → notifier → use case → repository
- [x] `flutter analyze` bersih
- [x] `dart format --set-exit-if-changed .` lolos (exit 0)
- [x] `flutter test` hijau (24 test)
- [x] Uji manual 3 query + screenshot tersimpan

**Belum dikerjakan (menunggu perintah):** AI Challenge, README.
