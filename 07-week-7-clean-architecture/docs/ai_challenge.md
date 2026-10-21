# AI Challenge: Clean Architecture Feature-First Refactoring

## 1. Prompt yang Digunakan
```text
Project Flutter saya: campus_notify (auth + FCM + daftar pengumuman).
Kondisi kini: folder lib/{data, providers, pages, messaging},
repository tercampur dengan implementasi, widget memanggil Dio langsung.
Tugas:
1. Usulkan struktur feature-first Clean Architecture
   (presentation/domain/data) untuk fitur auth + announcements.
2. Untuk tiap file lama, sebutkan tujuan barunya (pindah/pecah/hapus).
3. Tandai bagian yang over-engineering bila diterapkan ke CRUD sederhana,
   dan kapan use case benar-benar dibutuhkan vs repository langsung.
4. Tunjukkan wiring DI dengan Riverpod (tanpa package DI tambahan).
Jelaskan trade-off setiap keputusan.
```

---

## 2. Output & Usulan Awal AI
AI mengusulkan:
- Memisahkan kode ke dalam modul fitur: `features/auth`, `features/announcements`, dan `features/notes`.
- Setiap fitur memiliki 3 layer: `domain`, `data`, dan `presentation`.
- Membuat kelas `UseCase` terpisah untuk setiap aksi individual (termasuk CRUD sederhana seperti `GetSession`, `Logout`, `GetAnnouncements`).
- Membuat abstraksi DataSource terpisah (`AuthRemoteDataSource`, `AuthLocalDataSource`) di dalam Data Layer.
- Menggunakan Riverpod `Provider` murni untuk Dependency Injection tanpa dependensi tambahan seperti `get_it` atau `injectable`.

---

## 3. Tabel Usulan AI vs Keputusan Final

| Komponen / Masalah | Usulan Awal AI | Keputusan Final | Alasan Teknis |
|---|---|---|---|
| **Pemisahan Interface vs Impl** | Interface di `domain/repositories`, Impl di `data/repositories`. | **Diterima** | Sesuai prinsip Dependency Inversion (DIP). Domain hanya tahu abstraksi; perubahan implementasi data/API tidak merusak domain/UI. |
| **Pemisahan Model vs Entity** | Entity murni di `domain/entities`, Model dengan mapping di `data/models`. | **Diterima** | Domain steril dari format serialisasi (JSON, Map, SQLite). Serialisasi hanya urusan data layer. |
| **Abstraksi DataSource terpisah** | Membuat `RemoteDataSource` & `LocalDataSource` untuk setiap fitur. | **Ditolak / Disederhanakan** | Pada skala aplikasi kampus ini, memecah DataSource menjadi interface terpisah untuk 1-2 endpoint menambah boilerplate berlebih (over-engineering). Repositori mengelola sumber data langsung via service storage/API client. |
| **Use Case untuk tiap operasi** | Wajib membuat use case kelas terpisah untuk semua aksi, termasuk CRUD 1 baris. | **Diterima secara selektif** | Use case dipertahankan untuk operasi yang memiliki validasi bisnis (seperti format email, panjang password pada `LoginUseCase`, validasi ID pada `GetAnnouncementDetail`), serta untuk memudahkan unit testing domain dengan FakeRepository. |
| **Error Handling (Records vs Either)** | Memakai package pihak ketiga `fpdart` (`Either<Failure, T>`). | **Ditolak, Gunakan Dart Records** | Menggunakan fitur bawaan Dart 3 `({T? data, Failure? failure})`. Lebih ringan, tidak menambah ketergantungan library luar, dan tipe aman (*type-safe*). |
| **Formatting Tanggal** | Dibiarkan di dalam widget `build()`. | **Ditolak, Diekstrak ke `core/format.dart`** | Formatting tanggal dan parsing rute diekstrak ke fungsi murni agar dapat diuji secara independen tanpa ketergantungan widget tree Flutter. |

---

## 4. Kapan Use Case Dibutuhkan vs Kapan Cukup Repository Langsung?

- **Use Case Benar-benar Dibutuhkan**:
  1. Operasi menggabungkan data dari lebih dari 1 repositori (misal: validasi user dari `AuthRepository` lalu update device token ke `PushRepository`).
  2. Terdapat aturan bisnis murni atau validasi input sebelum menyentuh data (contoh: validasi email, sanitasi input).
  3. Dibutuhkan logika caching, filtering, atau sorting khusus yang independen dari UI.
  4. Pengujian unit domain yang murni (*pure unit testing*) tanpa memuat mock repositori kompleks.

- **Cukup Repository Langsung ke Notifier**:
  1. Operasi CRUD sederhana satu-baris (misal: *pass-through* membaca daftar tanpa filtering atau transformasi tambahan).
  2. Tim kecil dengan kecepatan iterasi cepat di mana biaya memelihara kelas *boilerplate* melebihi manfaatnya.

---

## 5. Wiring Dependency Injection (Riverpod)

Wiring dependency injection dipusatkan di folder `presentation/providers/`:
```dart
// 1. Data Layer: Repository Impl
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

// 2. Domain Layer: Use Case menerima abstraksi
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

// 3. Presentation Layer: State Notifier untuk UI
final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, AuthSessionEntity?>(AuthNotifier.new);
```
Widget hanya mendengarkan `authStateProvider` via `ref.watch` atau `ref.read` tanpa pernah menginstansiasi repositori secara manual (`new AuthRepository()`).
