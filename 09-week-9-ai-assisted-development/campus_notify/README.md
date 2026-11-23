# Campus Notify — Minggu 7: Clean Architecture Refactor

Refactoring aplikasi **Campus Notify** (autentikasi, push notifications FCM, dan daftar pengumuman kampus) ke dalam pola **Clean Architecture feature-first**.

---

## Daftar Isi
1. [Tujuan Refactoring](#tujuan-refactoring)
2. [Diagram Layer dan Arah Dependensi](#diagram-layer-dan-arah-dependensi)
3. [Praktikum 1: Audit Layer Project Lama](#praktikum-1-audit-layer-project-lama)
4. [Praktikum 2: Domain dan Data Per Fitur](#praktikum-2-domain-dan-data-per-fitur)
5. [Praktikum 3: Presentation, DI, dan Verifikasi](#praktikum-3-presentation-di-dan-verifikasi)
6. [Hasil Pengujian (Unit & Widget Testing)](#hasil-pengujian-unit--widget-testing)
7. [AI Challenge & Keputusan Arsitektur](#ai-challenge--keputusan-arsitektur)

---

## Tujuan Refactoring
- Memisahkan kode menjadi lapisan murni: **Domain**, **Data**, dan **Presentation** dengan struktur *feature-first*.
- Menerapkan prinsip **SOLID**, khususnya **Dependency Inversion Principle (DIP)**: Lapisan domain mendefinisikan abstraksi/antarmuka (interface), dan lapisan data mengimplementasikannya.
- Menjamin lapisan **Domain** steril dari dependensi framework (`flutter`, `dio`, `sqflite`, `firebase`).
- Menjamin lapisan **Presentation** steril dari pemanggilan data mentah (`Dio`, database, `FlutterSecureStorage`) dan instansiasi manual.

---

## Diagram Layer dan Arah Dependensi

```
              ┌────────────────────────┐
              │   PRESENTATION LAYER   │
              │ (Pages, Providers, DI) │
              └───────────┬────────────┘
                          │
                   (depends on)
                          │
                          ▼
              ┌────────────────────────┐
              │      DOMAIN LAYER      │◄────────── (implements)
              │ (Entities, Use Cases,  │                  │
              │  Repository Contract,  │                  │
              │       Failures)        │                  │
              └────────────────────────┘                  │
                                                   ┌──────┴───────┐
                                                   │  DATA LAYER  │
                                                   │   (Models,   │
                                                   │ Repository   │
                                                   │    Impl)     │
                                                   └──────────────┘
```

> **Aturan Dependensi:**
> Panah dependensi hanya mengarah ke dalam menuju **Domain Layer**. Lapisan domain tidak mengenal implementasi database, jaringan, maupun framework UI.

---

## Struktur Folder Project

```text
lib/
├── core/
│   ├── failures.dart                        # Failure domain (sealed class, murni Dart)
│   └── format.dart                          # Fungsi murni format tanggal & parsing rute
├── features/
│   ├── auth/
│   │   ├── domain/
│   │   │   ├── entities/auth_session_entity.dart
│   │   │   ├── repositories/auth_repository.dart       # Contract (interface)
│   │   │   └── usecases/
│   │   │       ├── login_usecase.dart
│   │   │       ├── logout_usecase.dart
│   │   │       └── get_saved_session_usecase.dart
│   │   ├── data/
│   │   │   ├── models/auth_session_model.dart          # Mapping JSON/Map toEntity
│   │   │   └── repositories/auth_repository_impl.dart  # Konkret + token store
│   │   └── presentation/
│   │       ├── providers/auth_providers.dart           # DI + AuthNotifier
│   │       └── pages/login_page.dart
│   ├── announcements/
│   │   ├── domain/
│   │   │   ├── entities/announcement.dart
│   │   │   ├── repositories/announcement_repository.dart # Contract
│   │   │   └── usecases/
│   │   │       ├── get_announcements.dart
│   │   │       └── get_announcement_detail.dart
│   │   ├── data/
│   │   │   ├── models/announcement_model.dart
│   │   │   └── repositories/announcement_repository_impl.dart
│   │   └── presentation/
│   │       ├── providers/announcements_providers.dart   # DI + FutureProvider
│   │       └── pages/
│   │           ├── home_page.dart
│   │           └── announcement_page.dart
│   └── notes/                               # Contoh jobsheet
│       ├── domain/
│       │   ├── entities/note.dart
│       │   ├── repositories/note_repository.dart
│       │   └── usecases/get_notes.dart
│       └── data/
│           └── models/note_model.dart
├── messaging/
│   └── push_service.dart                    # Infrastructure service FCM
├── routes.dart                              # Rute GoRouter
└── main.dart                                # Entry point aplikasi
```

---

## Praktikum 1: Audit Layer Project Lama

### 1. Pemetaan File ke Layer

| File Lama | Layer Lama | Masalah Sebelum Refactor | Status Setelah Refactor |
|---|---|---|---|
| `pages/home_page.dart` | presentation | Data pengumuman hardcoded di widget ListTile | Dipindah ke `features/announcements/presentation/pages/home_page.dart`, data dibaca via `announcementsProvider` |
| `pages/login_page.dart` | presentation | Instansiasi logic auth tercampur | Dipindah ke `features/auth/presentation/pages/login_page.dart`, komunikasi via `authStateProvider` |
| `pages/announcement_page.dart` | presentation | Berisi map statis `_data` langsung di widget | Dipindah ke `features/announcements/presentation/pages/announcement_page.dart`, data dibaca via use case |
| `data/auth_repository.dart` | data | Interface dan implementasi bercampur dalam satu kelas konkret | Dipecah menjadi interface `AuthRepository` (domain) dan `AuthRepositoryImpl` (data) |
| `providers/auth_provider.dart` | presentation | Instansiasi service konkret langsung tanpa abstraksi | Digantikan oleh `auth_providers.dart` dengan DI Riverpod |

---

## Praktikum 2: Domain dan Data Per Fitur

1. **Entity Murni (Domain)**:
   - Dibuat tanpa import `flutter`, tanpa mapping (`toMap`/`fromMap`/`toJson`).
   - Contoh: `AuthSessionEntity`, `Announcement`, `Note`.
2. **Failure dan Kontrak Repository (Domain)**:
   - Kelas `sealed class Failure` di `lib/core/failures.dart` (`LocalFailure`, `NetworkFailure`, `ServerFailure`, `AuthFailure`, `ValidationFailure`).
   - Repository mengembalikan Dart records `({T? result, Failure? failure})` sehingga sukses/gagal eksplisit tanpa melemparkan Exception mentah ke UI.
3. **Model dan Implementasi (Data)**:
   - Model mewarisi Entity dan menyediakan serialisasi (`fromJson`, `toJson`, `toEntity`).
   - Repository Impl menangani sumber data dan mengonversi exception menjadi `Failure`.
4. **Use Case**:
   - `LoginUseCase`: validasi email dan password di domain layer sebelum memanggil repository.
   - `LogoutUseCase`: membersihkan sesi login.
   - `GetAnnouncements` & `GetAnnouncementDetail`: mengambil data pengumuman.
   - `GetNotes`: contoh use case catatan sesuai jobsheet.

---

## Praktikum 3: Presentation, DI, dan Verifikasi

### 1. Dependency Injection (DI) Terpusat
Seluruh wiring ketergantungan diatur secara deklaratif melalui Riverpod Provider di folder presentation/providers:
- Data layer di-instansiasi via `Provider<Repository>`
- Use Case disuntikkan abstraksi repository via `ref.watch(repositoryProvider)`
- Notifier/FutureProvider dikonsumsi oleh widget menggunakan `ConsumerWidget` / `ConsumerStatefulWidget`

### 2. Tiga Pemeriksaan Grep Sterilitas (Verifikasi Dependency Rule)

| Pemeriksaan | Target Path | Pola Pencarian | Hasil |
|---|---|---|:---:|
| **1. Presentation steril dari data mentah** | `lib/features/*/presentation`, `lib/pages` | `Dio\(|openDatabase|getDatabasesPath|FlutterSecureStorage|SharedPreferences\.getInstance|jsonDecode` | **0 Pelanggaran (BERSIH)** |
| **2. Domain steril dari framework** | `lib/features/*/domain`, `lib/core` | `package:flutter/|package:dio|package:sqflite|package:firebase` | **0 Pelanggaran (BERSIH)** |
| **3. DI Leak di Presentation** | `lib/features/*/presentation`, `lib/pages` | `Repository\(|Dio\(BaseOptions` | **0 Pelanggaran (BERSIH)** |

---

## Hasil Pengujian (Unit & Widget Testing)

Perintah eksekusi:
```bash
flutter analyze
flutter test
```

### Hasil `flutter analyze`:
```text
Analyzing campus_notify...
No issues found! (ran in 5.2s)
```

### Hasil `flutter test` (20 Pengujian Lulus):
- `test/get_notes_test.dart`:
  - `GetNotes meneruskan daftar dari repository` (Lulus)
  - `GetNotes meneruskan failure tanpa melempar` (Lulus)
- `test/auth_usecase_test.dart`:
  - `LoginUseCase memvalidasi format email sebelum memanggil repository` (Lulus)
  - `LoginUseCase memvalidasi panjang minimal kata sandi` (Lulus)
  - `LoginUseCase berhasil dan mengembalikan AuthSessionEntity` (Lulus)
  - `LogoutUseCase berhasil membersihkan sesi` (Lulus)
- `test/announcements_usecase_test.dart`:
  - `GetAnnouncements mengembalikan daftar pengumuman` (Lulus)
  - `GetAnnouncementDetail mengembalikan item spesifik jika ditemukan` (Lulus)
  - `GetAnnouncementDetail menolak ID kosong dengan ValidationFailure` (Lulus)
- `test/format_test.dart`:
  - `formatDateTime memformat tanggal dan waktu dengan tepat` (Lulus)
  - `formatDateOnly memformat tanggal saja` (Lulus)
  - `parseAnnouncementId memvalidasi dan mem-parsing ID angka` (Lulus)
- `test/widget_test.dart`:
  - `announcement page renders the selected announcement` (Lulus)
- `test/auth_push_test.dart`:
  - Seluruh pengujian rute, token, dan penanganan error HTTP status 401/timeout (Lulus)

```text
00:02 +20: All tests passed!
```

---

## AI Challenge & Keputusan Arsitektur
Detail lengkap analisis prompt AI, perbandingan usulan AI vs keputusan teknis, dan alasan arsitektur terdokumentasi di [docs/ai_challenge.md](docs/ai_challenge.md).
