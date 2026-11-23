# Week 9 — AI-Assisted Development / Vibe Coding

Pengerjaan codelab [#09 AI-Assisted Development](https://jti-polinema.github.io/flutter-codelab/09-minggu-9-ai-assisted-development-vibe-coding/index.html)
pada project **`campus_notify`** (kelanjutan Week 7 — Clean Architecture).

**Fitur yang ditambahkan:** pencarian judul pengumuman (tidak membedakan huruf
besar/kecil) + empty state dua kondisi.

## Fitur

| Fitur | Perilaku |
|---|---|
| Search judul | Ketik di kolom pencarian → daftar tersaring saat itu juga |
| Case-insensitive | `ujian`, `Ujian`, `UJIAN` memberi hasil sama |
| Trim spasi | Query `"  ujian  "` diperlakukan sama seperti `"ujian"` |
| Empty state | Data kosong → "Belum ada pengumuman." (`Icons.inbox`); hasil pencarian kosong → "Tidak ada pengumuman yang cocok dengan ..." (`Icons.search_off`) |
| Tombol clear | Ikon ✕ muncul saat kolom terisi, mengembalikan seluruh daftar |

## Struktur folder

```
09-week-9-ai-assisted-development/
├── campus_notify/          # project Flutter (lib/, test/, pubspec.yaml)
├── docs/
│   ├── ai-log.md           # Praktikum 1-3: prompt, output AI, verifikasi
│   ├── ai-challenge.md     # review AI: 3 temuan + keputusan per file
│   ├── refactoring-testing.md  # bagian 7: refactor, testing, error umum
│   ├── refleksi.md         # bagian 8: refleksi + referensi
│   └── evidence/           # output mentah analyze/test/grep (01-12)
├── screenshots/            # uji manual di HP fisik
└── README.md
```

## Prompt inti

Prompt yang dipakai memakai formula 5 slot (lengkap di
[`docs/ai-log.md`](docs/ai-log.md) §1.4):

| Slot | Isi |
|---|---|
| Role | Senior Flutter developer, Clean Architecture + Riverpod |
| Task | Tambah pencarian judul pengumuman + empty state pada fitur announcements |
| Context | Struktur `presentation → domain ← data`, isi `Announcement`, `AnnouncementRepository`, `SearchAnnouncements`, `flutter_riverpod 3.4.3` |
| Constraint | Jangan ubah layer data, jangan pakai `StateProvider` (di 3.x pindah ke legacy), jangan tambah dependency, wajib ada test |
| Output | Daftar file yang berubah + alasan + test yang membuktikan |

## Stack

| Komponen | Versi |
|---|---|
| Dart SDK | `^3.13.5` |
| flutter_riverpod | `^3.4.3` |
| go_router | `^18.0.2` |
| dio | `^5.11.1` |
| flutter_secure_storage | `^11.2.0` |
| firebase_core / firebase_messaging | `^4.15.0` / `^16.7.0` |
| flutter_local_notifications | `^22.3.1` |

## Cara menjalankan

```bash
cd campus_notify
flutter pub get
flutter run
```

Login memakai mock (tanpa backend): email apa pun yang mengandung `@` dan
password minimal 6 karakter, misalnya `mhs@student.polinema.ac.id` / `123456`.

Uji pencarian:

1. Biarkan kolom kosong → 4 pengumuman tampil.
2. Ketik `ujian` → 1 hasil ("Pengumuman ujian").
3. Ketik `zzz` → empty state "tidak ada yang cocok".
4. Tekan ✕ → daftar kembali lengkap.

## Hasil verifikasi mesin

```bash
$ flutter analyze
Analyzing campus_notify...
No issues found!

$ dart format --set-exit-if-changed .
Formatted 53 files (0 changed)

$ flutter test
+31: All tests passed!
```

Rincian test:

| Berkas | Test |
|---|---|
| `test/search_announcements_test.dart` | 4 (use case filter) |
| `test/empty_state_widget_test.dart` | 3 (widget empty state) |
| `test/search_provider_test.dart` | 4 (wiring provider) |
| test lain dari Week 7 (auth, push, dll.) | 20 |
| **Total** | **31** |

Bukti mentah: [`docs/evidence/11-refactoring-verifikasi.txt`](docs/evidence/11-refactoring-verifikasi.txt).

## Uji manual (HP fisik)

| Kondisi | Screenshot |
|---|---|
| Kolom kosong → 4 pengumuman | [`screenshots/search-kosong.jpg`](screenshots/search-kosong.jpg) |
| Query `ujian` → 1 hasil | [`screenshots/search-cocok.jpg`](screenshots/search-cocok.jpg) |
| Query `zzz` → empty state | [`screenshots/search-tidak-cocok.jpg`](screenshots/search-tidak-cocok.jpg) |

## Keputusan atas saran AI

| Temuan AI | Level | Keputusan |
|---|---|---|
| Empty state belum punya widget test | blocker | diterima → 3 test |
| Provider mencampur DI + state UI dan wiring belum diuji | blocker | diterima + refactor → `search_providers.dart` + 4 test |
| Debounce 300 ms pada kolom pencarian | saran | ditolak (alasan teknis di [`docs/ai-challenge.md`](docs/ai-challenge.md) §5) |

## Batasan

- Repository pengumuman masih **in-memory** (4 item), belum tersambung backend.
- Login masih **mock**; tidak ada verifikasi ke server.
- Push notification berjalan dengan service mock — `lib/firebase_options.dart`
  belum ada, jadi FCM nyata belum aktif.
- `campus_notify` adalah salinan Week 7; folder Week 7 tidak diubah.

## Dokumentasi

| Berkas | Isi |
|---|---|
| [`docs/ai-log.md`](docs/ai-log.md) | Praktikum 1-3: prompt, output AI v1, 3 bug, perbaikan, screenshot |
| [`docs/ai-challenge.md`](docs/ai-challenge.md) | Review AI: prompt, 3 temuan, tabel keputusan per file, alasan penolakan |
| [`docs/refactoring-testing.md`](docs/refactoring-testing.md) | Bagian 7: refactoring challenge, testing, tabel error umum, checklist |
| [`docs/refleksi.md`](docs/refleksi.md) | Bagian 8: refleksi 4 pertanyaan + referensi |
| [`docs/evidence/`](docs/evidence/) | Output mentah `flutter analyze`, `flutter test`, `dart format`, `grep` |
