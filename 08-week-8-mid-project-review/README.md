# Week 8: Mid Project Review & Code Review

**Tanggal:** 3 November 2026  
**Mahasiswa:** Radita (244107020099)  
**Project:** Campus Notify Clean Architecture Review

---

## 📋 Tujuan Pembelajaran

Setelah menyelesaikan week 8, saya mampu:

- ✅ Menggunakan Git Flow dengan branch `develop` dan `feature/*`
- ✅ Menulis commit berkualitas dengan conventional commits format
- ✅ Setup CI/CD dengan GitHub Actions
- ✅ Melakukan static analysis (`flutter analyze`, `dart format`, `flutter test`)
- ✅ Mendokumentasikan code review checklist
- ✅ Memverifikasi Clean Architecture dependency rules

---

## 🛠️ Yang Dikerjakan

### 1. Git Flow Setup

**Branch Structure:**
```
main      → production-ready (protected)
develop   → integration branch (newly created)
feat/*    → feature branches (akan dipakai di PR berikutnya)
```

**Sebelum Week 8:**
- Semua commit langsung ke `main`
- Tidak ada branching strategy

**Sesudah Week 8:**
- Branch `develop` dibuat dan di-push
- CI/CD aktif di GitHub Actions
- Conventional commits mulai diterapkan

---

### 2. CI/CD Pipeline

**File:** `.github/workflows/ci.yml`

**Workflow:**
```yaml
trigger: pull_request → [develop, main]
steps:
  1. Checkout code
  2. Setup Flutter 3.24.x
  3. flutter pub get
  4. flutter analyze    ← 0 issues required
  5. dart format check  ← clean format required
  6. flutter test       ← all tests must pass
```

**Status:** ✅ Aktif di develop branch

---

### 3. Code Quality Audit

**Project:** `07-week-7-clean-architecture/campus_notify`

**Static Analysis:**
```bash
flutter analyze  # ✅ No issues found!
dart format .    # ✅ No formatting issues
flutter test     # ✅ 20/20 tests passed
```

**Architecture Verification:**
```bash
# Dependency rule sterilitas check
grep -r "import.*presentation" lib/domain  # ✅ 0 violations
grep -r "import.*data" lib/domain          # ✅ 0 violations
```

---

### 4. Commit History Improvement

**Audit 3 Commit Terburuk:**

| Sebelum | Sesudah (Conventional) | Improvement |
|---------|------------------------|-------------|
| `feat(week-5)` | `feat(notes): tambah offline storage dengan SQLite + sync` | Scope & deskripsi jelas |
| `screenshot ketinggalan` | `docs(week-4): tambah screenshot REST API response` | Tipe commit proper |
| Long message | `feat(navigation): setup GoRouter + Riverpod state` | Ringkas & fokus |

**Best Commits (sudah baik):**
- ✅ `refactor(data): pindahkan friendlyErrorMessage ke network_errors.dart agar dipakai bersama`
- ✅ `refactor(ui): ekstrak PostTile dari ListView.builder agar reusable dan mudah diuji`

---

## 📊 Test Coverage

**Total:** 20 tests, 100% passed

**Breakdown:**
- Auth use cases: 4 tests
- Announcements use cases: 3 tests
- Core formatting: 3 tests
- Push notifications: 6 tests
- Notes use cases: 2 tests
- Widget tests: 1 test
- Integration tests: 1 test

---

## 📁 Struktur Dokumentasi

```
08-week-8-mid-project-review/
├── docs/
│   └── review-checklist.md  ← Audit lengkap + checklist review
├── README.md                 ← Overview week 8
└── screenshots/              ← (akan ditambahkan di PR)
```

---

## 🎯 Deliverables

- [x] Branch `develop` dibuat dan di-push
- [x] CI/CD GitHub Actions setup
- [x] `docs/review-checklist.md` lengkap dengan:
  - Audit commit history (sebelum/sesudah)
  - Static analysis results
  - Architecture sterilitas verification
  - PR template & review checklist
  - Definition of Done
  - Refleksi mid-semester
- [ ] **Next:** 1 PR kecil dengan feature branch workflow + peer review

---

## 🔍 Hasil Review

### Strengths
✅ Test coverage excellent (20/20 passed)  
✅ Clean Architecture konsisten  
✅ Error handling robust  
✅ Zero static analysis issues  

### Improvements
⚠️ Commit messages perlu konsisten conventional format  
⚠️ Branch workflow baru diterapkan (sebelumnya langsung ke main)  
⚠️ Documentation perlu update untuk mid-semester  

---

## 🚀 Next Steps (Week 9+)

1. Buat feature branch untuk improvement kecil
2. Open PR dengan template lengkap
3. Peer review dengan checklist
4. Merge ke develop setelah approve
5. Lanjut ke **Week 9: AI-Assisted Development**

---

## 📚 Referensi

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Git Flow](https://nvie.com/posts/a-successful-git-branching-model/)
- [GitHub Actions for Flutter](https://docs.github.com/en/actions)
- [Flutter Static Analysis](https://docs.flutter.dev/testing/static-analysis)

---

**Status:** ✅ Week 8 Foundation Complete  
**Project Quality:** Production-Ready  
**Ready for:** AI-Assisted Development (Week 9)
