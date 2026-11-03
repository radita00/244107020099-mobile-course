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
- ⏳ Feature branch workflow akan diterapkan di PR berikutnya

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
2. Setup Flutter 3.24.x
3. `flutter pub get`
4. `flutter analyze` (0 issues required)
5. `dart format --set-exit-if-changed .` (clean format required)
6. `flutter test` (all tests must pass)

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

## 7. Definisi Selesai (Definition of Done)

### Mid Semester Checklist

- [x] Aplikasi berjalan identik dengan Week 7
- [x] flutter analyze: 0 issues
- [x] flutter test: 20/20 passed
- [x] Clean Architecture steril (dependency rule terbukti)
- [x] CI/CD aktif di GitHub Actions
- [x] Branch develop dibuat dan di-push
- [ ] Minimal 1 PR kecil (<300 baris) direview & merge (**Next Step**)
- [ ] README update dengan status paruh semester
- [ ] docs/review-checklist.md lengkap (**Done**)

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

### Action Items (Next PR)
1. Update README.md dengan:
   - Status paruh semester
   - Peta fitur completed (week 1-7)
   - Setup instructions lengkap
   - Screenshot aplikasi
2. Buat 1 PR kecil dengan feature branch workflow
3. Peer review dengan checklist di atas

---

## 9. Refleksi

### Apa yang sudah dipelajari (Week 1-7)?
- Mobile development ecosystem & Flutter basics
- Declarative UI & responsive design
- Navigation dengan GoRouter
- State management dengan Riverpod
- REST API integration dengan Dio
- Local storage (SQLite) & offline-first patterns
- Authentication & secure storage
- Firebase Cloud Messaging
- Clean Architecture (SOLID, layer separation, DI)

### Kesiapan untuk paruh kedua (Week 9-11)?
✅ **Siap** - Fondasi clean architecture solid, testing habits terbentuk, workflow Git mulai proper.

### Tantangan terbesar?
Transisi dari quick prototyping (week 1-4) ke structured architecture (week 7). Butuh refactor besar-besaran tapi hasilnya worth it: code jadi testable, maintainable, scalable.

---

**Status:** ✅ Mid Project Review Completed  
**Next Step:** Buat feature branch → PR kecil → peer review → merge to develop
