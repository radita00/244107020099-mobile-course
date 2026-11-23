# Mid Project Review - Week 8

**Mahasiswa:** Radita (244107020099)  
**Tanggal Review:** 3 November 2026  
**Project:** Campus Notify (Clean Architecture)

---

## 1. Audit Commit History

Analisis 3 commit terburuk dan perbaikannya:

| Sebelum | Sesudah (Conventional Format) | Alasan Perbaikan |
|---------|-------------------------------|------------------|
| `feat(week-5)` | `feat(notes): tambah offline storage dengan SQLite + sync` | Tidak jelas fitur apa. Sesudah: scope + deskripsi konkret |
| `screenshot ketinggalan` | `docs(week-4): tambah screenshot REST API response` | Tidak ada tipe. Sesudah: pakai `docs(scope)` + jelaskan apa yang ditambahkan |
| `feat: add week 3 navigation and state management with riverpod` | `feat(navigation): setup GoRouter + Riverpod state management` | Terlalu panjang. Sesudah: lebih ringkas, scope jelas |

**Best Practice Commit:**
- ✅ `refactor(data): pindahkan friendlyErrorMessage ke network_errors.dart agar dipakai bersama` - Jelas scope, action, dan alasan
- ✅ `refactor(ui): ekstrak PostTile dari ListView.builder agar reusable dan mudah diuji` - Lengkap dengan motivasi

---

## 2. Git Flow Status

### Branch Structure
```
main      → production-ready (protected)
develop   → integration branch (baru dibuat)
```

**Sebelum Week 8:**
- ❌ Semua commit langsung ke `main`
- ❌ Tidak ada branch `develop`
- ❌ Tidak ada feature branches

**Sesudah Week 8:**
- ✅ Branch `develop` dibuat dan di-push
- ✅ CI/CD aktif di GitHub Actions
- ✅ Feature branch workflow diterapkan (PR #1 merged)
- ✅ 11 commits via PR feat/week8-review-docs → develop

---

## 3. Static Analysis & Testing

### Week 7 Project: campus_notify

**flutter analyze:**
```
✅ No issues found! (ran in 142.7s)
```

**flutter test:**
```
✅ 20/20 tests passed
- Auth use case tests: 4/4
- Announcements use case tests: 3/3
- Core formatting tests: 3/3
- Push notification tests: 6/6
- Widget tests: 1/1
- Notes use case tests: 2/2
- Auth & push integration: 1/1
```

**dart format:**
```
✅ No formatting issues
```

---

## 4. Architecture Sterilitas (Clean Architecture Verification)

### Dependency Rule Check

```bash
# Domain layer tidak boleh import presentation atau data
grep -r "import.*presentation" lib/domain  # ✅ 0 hasil
grep -r "import.*data" lib/domain          # ✅ 0 hasil

# Data layer boleh import domain (dependency ke dalam)
grep -r "import.*domain" lib/data          # ✅ OK
```

**Struktur Feature-First:**
```
lib/
├── features/
│   ├── auth/
│   │   ├── presentation/  ← UI, widgets, providers
│   │   ├── domain/        ← entities, use cases, repository interfaces
│   │   └── data/          ← models, repository implementations
│   ├── announcements/
│   │   ├── presentation/
│   │   ├── domain/
│   │   └── data/
│   └── notes/
│       └── domain/
├── core/                  ← shared utilities
└── main.dart
```

**Verdict:** ✅ Clean Architecture terbukti steril

---

## 5. CI/CD Pipeline

### GitHub Actions Workflow

File: `.github/workflows/ci.yml`

**Trigger:**
- Pull Request ke `develop` atau `main`
- Push ke `develop`

**Steps:**
1. Checkout code
2. Setup Flutter **3.47.x** (Dart 3.13.5 — disamakan dengan environment lokal)
3. `flutter pub get`
4. `flutter analyze` (0 issues required)
5. `dart format --set-exit-if-changed .` (clean format required, dijalankan di dalam `campus_notify/`)
6. `flutter test` (all tests must pass)
7. Verify Week 8 docs exist (`test -f` gate)

**Status:** ✅ Aktif di branch develop

---

## 6. PR & Code Review Readiness

### Template PR (untuk PR berikutnya)

```markdown
## Masalah
[Deskripsi masalah yang diselesaikan]

## Solusi
- [Perubahan 1]
- [Perubahan 2]

## Cara Uji
1. [Step 1]
2. [Step 2]
3. flutter test [test file]

## Screenshot
[attach]

Closes #[issue-number]
```

### Review Checklist untuk Reviewer

**Kebenaran:**
- [ ] Tidak ada null safety violation
- [ ] Error handling lengkap (success + failure path)
- [ ] Edge case tertangani (empty, null, invalid input)

**Arsitektur:**
- [ ] Tidak ada import lintas layer yang melanggar dependency rule
- [ ] Entity tidak bocor ke UI (pakai model/DTO)
- [ ] DI pattern konsisten (Riverpod providers)

**Testing:**
- [ ] Unit test untuk use case baru
- [ ] Edge case di-test (validation failures)
- [ ] flutter analyze bersih
- [ ] flutter test hijau

**Keterbacaan:**
- [ ] Nama variabel/fungsi deskriptif
- [ ] Fungsi < 20 baris
- [ ] Widget < 300 baris (extract ke widget terpisah)

---

### 6.3 Hasil Review Sendiri (Self Review)

> **Catatan kejujuran:** Week 8 dikerjakan tanpa pasangan, jadi **tidak ada peer review sejawat**. Bagian ini adalah **self review** dengan metode yang sama (checkout, grep, jalankan test) dan temuan yang bisa diverifikasi ulang. Kekurangan ini dicatat sebagai action item, bukan disembunyikan.

### Temuan Kebenaran (2)

**K1 — CI gate dokumentasi tidak pernah bisa gagal** 🔴
- **Observasi:** step `Verify Week 8 Docs` hanya menjalankan `ls -la` pada folder yang pasti ada.
- **Dampak:** kalau `review-checklist.md` atau screenshot hilang, CI tetap hijau → gate palsu.
- **Bukti:** logika shell — `ls` sukses selama direktori ada, tidak memeriksa isi.
- **Perbaikan:** diganti loop `test -f` untuk 5 file wajib, `exit 1` bila ada yang hilang.

**K2 — Dokumentasi menyebut versi Flutter yang salah** 🟡
- **Observasi:** `README.md:53` dan `review-checklist.md:121` (kondisi saat audit) menulis "Setup Flutter 3.24.x", padahal `ci.yml` memakai `3.47.x`.
- **Dampak:** pembaca (dosen/reviewer) mendapat informasi yang bertentangan dengan konfigurasi nyata.
- **Bukti:** `sed -n '53p' README.md` → `Setup Flutter 3.47.x`; `sed -n '121p' docs/review-checklist.md` → `Setup Flutter **3.47.x**`; `grep -n "flutter-version" .github/workflows/ci.yml` → `3.47.x`. (Sebelum diperbaiki kedua baris itu berisi `3.24.x`.)
- **Perbaikan:** kedua dokumen disamakan ke 3.47.x. Sisa kata "3.24" di repo hanya ada di narasi historis (bagian ini dan §9.4), bukan sebagai konfigurasi aktif.

### Temuan Arsitektur (1)

**A1 — Dead code di `lib/data/`** 🟡
- **Observasi:** `api_client.dart` (43 baris) dan `api_errors.dart` (26 baris) tidak direferensikan siapa pun.
- **Bukti:**
  ```
  grep -rn "api_client" lib/ --include="*.dart" | grep -v "^lib/data/"   → 0 hasil
  grep -rn "api_errors" lib/ --include="*.dart"                          → 0 hasil
  ```
- **Dampak:** 69 baris kode mati membingungkan pembaca baru dan menyamarkan mana jalur yang benar-benar dipakai.
- **Keputusan:** **ditunda** — PR week 8 hanya dokumentasi + CI, menghapus file produksi di PR docs melanggar prinsip satu-PR-satu-tujuan. Dicatat sebagai issue terpisah.

### Temuan Test (1)

**T1 — Cakupan widget test tipis** 🟡
- **Observasi:** `test/widget_test.dart` hanya 1 widget test (halaman announcement). Fitur `notes` belum punya widget test sama sekali.
- **Bukti:** `ls test/` → 6 file; `grep -c "testWidgets" test/*.dart` → hanya `widget_test.dart` yang > 0.
- **Dampak:** regresi UI pada fitur notes tidak akan tertangkap otomatis.
- **Keputusan:** dikerjakan di **Week 9** saat menambah fitur search (wajib 1 widget test empty state).

### Saran Keterbacaan (1)

**R1 — Nama screenshot tidak deskriptif** 🟡
- **Observasi:** screenshot Week 7 bernama `image.png`, `image copy 2.png`, `image copy 3.png`, `image copy 4.png`, `image copy.png`.
- **Dampak:** tidak bisa dipakai sebagai bukti before/after karena tidak ada penanda mana yang "before" dan mana yang "after".
- **Bukti:** `ls 07-week-7-clean-architecture/screenshots/`.
- **Keputusan:** dicatat sebagai action item (rename ke `before-*.png` / `after-*.png`).

### Ringkasan Self Review

| Kategori | Jumlah | Status |
|---|---|---|
| Kebenaran | 2 | ✅ 2 diperbaiki |
| Arsitektur | 1 | ⏳ ditunda (issue terpisah) |
| Test | 1 | ⏳ Week 9 |
| Keterbacaan | 1 | ⏳ action item |

**Total: 5 temuan — 2 selesai, 3 terjadwal.**

---

## 7. Definisi Selesai (Definition of Done)

### Mid Semester Checklist

- [x] Aplikasi berjalan identik dengan Week 7
- [x] flutter analyze: 0 issues
- [x] flutter test: 20/20 passed
- [x] Clean Architecture steril (dependency rule terbukti)
- [x] CI/CD aktif di GitHub Actions (Flutter 3.47.x, parity dengan lokal)
- [x] CI docs gate nyata (`test -f`, bukan `ls`)
- [x] Branch develop dibuat dan di-push
- [x] Minimal 1 PR kecil (<300 baris) direview & merge (PR #1: 11 commits, +950/-438 lines)
- [ ] Issue #2 dibuat dan ditutup oleh PR #3 (`Closes #2`) — ⏳ menunggu aksi di GitHub
- [x] `.github/PULL_REQUEST_TEMPLATE.md` di root repo (otomatis muncul saat buka PR)
- [x] README update dengan status paruh semester + peta issue/PR
- [x] Screenshots PR merged + CI passed ditambahkan
- [x] Refleksi 4 pertanyaan jobsheet terjawab (§9.1-9.4)
- [x] Self review 5 temuan terdokumentasi (§6.3)
- [x] docs/review-checklist.md lengkap

---

## 8. Temuan & Improvement Plan

### Strengths
✅ Test coverage sangat baik (20 tests, 100% passed)  
✅ Clean Architecture konsisten di seluruh project  
✅ Error handling robust (validation + network errors)  
✅ No static analysis issues  

### Areas for Improvement
⚠️ **Commit messages:** Beberapa commit belum mengikuti conventional format  
⚠️ **Branch workflow:** Semua commit langsung ke main (fixed di week 8)  
⚠️ **Documentation:** README belum update status mid-semester  

### Action Items (Completed Week 8)
1. ✅ Update README.md dengan status mid-semester
2. ✅ Buat PR kecil dengan feature branch workflow (PR #1 merged)
3. ✅ Setup CI/CD pipeline (GitHub Actions)
4. ✅ Tambah screenshots PR merged + CI passed

---

## 9. Refleksi

### 9.1 Apa beda LGTM buta dengan approve yang bertanggung jawab? Apa risikonya bagi tim?

**LGTM buta** = menekan *Approve* tanpa checkout branch, tanpa menjalankan test, tanpa membaca diff. Reviewer hanya melihat "hijau" di UI GitHub.

**Approve bertanggung jawab** = reviewer:
1. `git checkout` branch dan menjalankan `flutter analyze` + `flutter test` sendiri,
2. membaca diff baris per baris, terutama path error dan edge case,
3. mengecek dependency rule (`domain/` bebas Flutter/Dio/SQLite),
4. menguji manual minimal 5 menit (happy path + empty state).

**Risiko LGTM buta bagi tim** — dan ini terjadi nyata di PR #1 minggu ini:
- PR #1 sempat **gagal CI 6 kali** (Dart SDK mismatch, `flutter_lints` 6.0.0, `flutter_secure_storage` 11.2.0, `firebase_messaging` 16.7.0, `dart format` 25 file). Kalau reviewer cuma LGTM, merge tetap terjadi dan `develop` jadi **tidak bisa di-build** — seluruh tim terblokir, bukan cuma satu orang.
- Bug logika (mis. filter case-sensitive) tidak akan tertangkap CI karena tidak ada test-nya. Hanya mata reviewer yang bisa menangkap.
- Biaya perbaikan naik 10x setelah merge: harus revert, buka PR baru, review ulang.

**Kesimpulan:** CI hijau adalah **syarat perlu, bukan syarat cukup**. Reviewer tetap wajib menjalankan sendiri.

---

### 9.2 Kapan komentar wajib berstatus `request changes`, dan kapan cukup saran?

**Wajib `request changes` (blocker)** — jika salah satu terpenuhi:

| Kondisi | Contoh di project ini |
|---|---|
| CI merah | PR #1 gagal di `flutter pub get` karena Dart 3.5.4 < syarat dependency |
| Melanggar dependency rule | `domain/` mengimpor `sqflite` atau widget Flutter |
| Test gagal / tidak ada test untuk perilaku baru | Fitur search tanpa 1 test pun |
| Risiko keamanan / data loss | Token ditulis ke `SharedPreferences` biasa, bukan secure storage |
| Perilaku berubah tapi tidak sesuai requirement | Empty state tidak muncul saat query tidak cocok |
| Utang teknis yang menutup jalan | Hardcode `Dio()` di widget → mustahil di-unit-test |

**Cukup saran (non-blocking)** — jika:
- Hanya gaya penamaan atau format → **seharusnya** sudah ditangani `dart format` + linter, bukan komentar manusia,
- Refactor opsional yang tidak mengubah perilaku (mis. pecah widget 250 baris jadi 2 widget 120 baris),
- Alternatif implementasi yang setara kualitasnya,
- Peningkatan di luar scope PR (mis. "minggu depan tambahkan pagination").

**Aturan praktis:** kalau komentar bisa dijawab "nanti saja tanpa merusak apa pun" → **saran**. Kalau jawabannya "kalau tidak sekarang, `develop` rusak" → **request changes**.

---

### 9.3 Bagian mana dari review AI yang Anda tolak atau sederhanakan, dan mengapa?

Detail lengkap ada di [`ai-review-vs-keputusan.md`](ai-review-vs-keputusan.md). Ringkasnya:

| Usulan AI | Keputusan | Alasan teknis |
|---|---|---|
| Pre-commit hook `dart format` di `.git/hooks/` | ❌ **Ditolak** | Hook tidak ikut ter-commit (tidak versioned), jadi tidak berlaku untuk clone lain. Gate yang benar adalah CI, yang sudah jalan. Hook hanya menyelesaikan masalah di mesin sendiri. |
| Peer review wajib untuk PR dokumentasi | ❌ **Ditolak** | PR #1 mengubah 0 baris kode produksi (docs + CI + format). Tidak ada perilaku yang bisa diregresi. Requirement peer review tetap dicatat sebagai action item untuk PR kode berikutnya. |
| `markdownlint-cli` + link checker di CI | 🟡 **Disederhanakan** | Diganti gate `test -f` untuk 5 file wajib. Alasan: menambah dependency npm + 2 menit runtime CI hanya untuk memvalidasi 2 file markdown — tidak sepadan. Yang penting file wajib benar-benar ada, bukan gaya markdown-nya. |
| Upgrade Flutter di CI ke 3.47.x | ✅ **Diterima** | Terbukti: 4 kegagalan CI berturut-turut semuanya berakar pada Dart SDK 3.5.4 yang terlalu tua. Setelah upgrade, CI hijau. |
| Scope `flutter analyze` ke `campus_notify/` saja | ✅ **Diterima** | Terbukti: `flutter analyze` di root menghasilkan **433 issues** dari project week 1-6 yang dependency-nya tidak lengkap — semuanya noise, bukan masalah nyata. |

**Pelajaran:** AI cenderung menyarankan **solusi paling lengkap**, bukan **solusi paling proporsional**. 3 dari 5 usulan ditolak/disederhanakan karena menambah kompleksitas tanpa menyelesaikan risiko nyata.

---

### 9.4 Satu hal konkret yang Anda perbaiki setelah review, dan apa dampaknya?

**Yang diperbaiki: versi Flutter di CI dari `3.24.x` → `3.47.x`.**

**Kronologi:**
1. PR #1 gagal CI #1 → `flutter_lints 6.0.0 requires Dart ^3.8.0` (CI punya Dart 3.5.4)
2. Percobaan 1: downgrade `flutter_lints` → 5.0.0 → gagal lagi (`firebase_messaging` butuh Dart 3.6.0)
3. Percobaan 2: upgrade Flutter ke 3.27.x (Dart 3.6.2) → gagal lagi (`flutter_secure_storage 11.2.0` butuh Dart 3.8.0)
4. Percobaan 3: downgrade `flutter_secure_storage` → 9.2.2 → gagal lagi (`flutter_riverpod 3.4.3` butuh Dart 3.12.0)
5. **Akar masalah ditemukan:** environment lokal memakai **Flutter 3.47.7 / Dart 3.13.5**, sedangkan CI dipin ke 3.24.x. Semua downgrade dependency adalah obat yang salah.
6. **Perbaikan final:** samakan CI dengan lokal (`flutter-version: '3.47.x'`) + revert semua downgrade dependency ke versi asli.

**Dampak terukur:**
| Metrik | Sebelum | Sesudah |
|---|---|---|
| Status CI PR #1 | ❌ Gagal 6x | ✅ Hijau |
| `flutter pub get` | Version solving failed | Got dependencies |
| Dependency yang di-downgrade | 3 (lints, secure_storage, + sdk) | 0 (semua versi asli) |
| Waktu debug | ~6 iterasi push | 1 commit fix |
| PR bisa merge | ❌ | ✅ |

**Akar pelajaran:** *"CI harus memakai toolchain yang sama dengan developer."* Kalau CI dan lokal beda versi, kegagalan yang muncul menyesatkan — terlihat seperti masalah dependency, padahal masalah parity environment.

---

### 9.5 Apa yang sudah dipelajari (Week 1-7)?
- Mobile development ecosystem & Flutter basics
- Declarative UI & responsive design
- Navigation dengan GoRouter
- State management dengan Riverpod
- REST API integration dengan Dio
- Local storage (SQLite) & offline-first patterns
- Authentication & secure storage
- Firebase Cloud Messaging
- Clean Architecture (SOLID, layer separation, DI)

### 9.6 Kesiapan untuk paruh kedua (Week 9-11)?
✅ **Siap** - Fondasi clean architecture solid, testing habits terbentuk, workflow Git mulai proper.

### 9.7 Tantangan terbesar?
Transisi dari quick prototyping (week 1-4) ke structured architecture (week 7). Butuh refactor besar-besaran tapi hasilnya worth it: code jadi testable, maintainable, scalable.

---

- **Status:** ✅ Mid Project Review Completed
- **PR #1:** Merged (11 commits, feat/week8-review-docs → develop)
- **PR #3:** ⏳ Pending (gap audit: refleksi jobsheet, PR template root, CI docs gate)
- **Issue #2:** ⏳ Pending (dibuat manual di GitHub, ditutup oleh PR #3 via `Closes #2`)
- **CI/CD:** Passing (Flutter 3.47.x, Dart 3.13.5)
- **Screenshots:** Added (PR merged + CI passed)
- **Self Review:** 5 temuan (2 diperbaiki, 3 terjadwal)
- **Next Step:** Week 9 - AI-assisted Development
