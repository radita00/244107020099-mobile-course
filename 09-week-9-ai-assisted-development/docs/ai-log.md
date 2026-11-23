# AI Log — Week 9: AI-Assisted Development

> **Status pengerjaan:** Praktikum 1 (Prompt & Context Engineering) ✅ selesai.
> Praktikum 2 (Generate & Verifikasi), Praktikum 3 (Debug & Refactor), dan AI Challenge **belum dikerjakan**.

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

**Belum dikerjakan (menunggu perintah):** Praktikum 2 (generate + verifikasi), Praktikum 3 (debug + refactor), AI Challenge, README, screenshots.
