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

## 📊 Status Paruh Semester (Week 1-7)

### ✅ Fitur yang Sudah Diselesaikan

**Week 1-2:** Foundation
- Flutter environment setup + Dart basics
- Declarative UI & responsive design
- Material 3 components

**Week 3-4:** Core Features
- Navigation (GoRouter)
- State management (Riverpod)
- REST API integration (Dio)
- Error handling & loading states

**Week 5-6:** Data & Auth
- Local storage (SQLite)
- Offline-first architecture
- Authentication flow
- Secure storage (flutter_secure_storage)
- Firebase Cloud Messaging (FCM)

**Week 7:** Clean Architecture Refactor
- Feature-first structure (presentation → domain ← data)
- SOLID principles
- Dependency injection
- Repository pattern
- 20 unit tests (100% passed)

---

## 🏗️ Stack Teknologi

**Framework & Language:**
- Flutter 3.47.7
- Dart 3.13.5

**State Management:**
- Riverpod 3.4.3

**Navigation:**
- GoRouter 18.0.2

**Networking:**
- Dio 5.11.1 (HTTP client)
- REST API integration

**Storage:**
- SQLite (sqflite)
- flutter_secure_storage 11.2.0

**Firebase:**
- firebase_core 4.15.0
- firebase_messaging 16.7.0
- flutter_local_notifications 22.3.1

**Testing:**
- flutter_test (20 unit tests)

**CI/CD:**
- GitHub Actions
- Flutter analyze + dart format + flutter test

---

## 🗺️ Peta Issue & Pull Request

### Pull Requests
| # | Title | Status | Commits | Changes |
|---|-------|--------|---------|---------|
| #1 | feat/week8-review-docs → develop | ✅ Merged | 11 | +950/-438 |

### Issues
Belum ada issue tracking system (akan diimplementasikan di week 9+)

**Action Items:**
- [ ] Setup GitHub Issues untuk feature tracking
- [ ] Buat issue template
- [ ] Link PR ke issue dengan "Closes #N"

---

## 🚀 Cara Menjalankan Project

### Prerequisites
- Flutter SDK 3.47.x atau lebih baru
- Dart SDK 3.13.x atau lebih baru
- Android Studio / Xcode (untuk emulator)
- Git

### Setup & Run

```bash
# 1. Clone repository
git clone https://github.com/radita00/244107020099-mobile-course.git
cd 244107020099-mobile-course

# 2. Checkout develop branch
git checkout develop

# 3. Masuk ke project week 7 (production-ready)
cd 07-week-7-clean-architecture/campus_notify

# 4. Install dependencies
flutter pub get

# 5. Verifikasi setup
flutter doctor

# 6. Run tests
flutter test

# 7. Run app
flutter run
```

### Struktur Repository

```
244107020099-mobile-course/
├── 01-week-1-mobile-development-ecosystem-flutter-refresh/
├── 02-week-2-declarative-ui-responsive-design/
├── 03-week-3-navigation-state-management/
├── 04-week-4-networking-rest-api/
├── 05-week-5-local-storage-offline-first/
├── 06-week-6-authentication-security-fcm/
├── 07-week-7-clean-architecture/          ← Production-ready project
│   └── campus_notify/
├── 08-week-8-mid-project-review/          ← You are here
│   ├── docs/
│   │   ├── review-checklist.md
│   │   └── ai-review-vs-keputusan.md
│   ├── screenshots/
│   └── README.md
└── .github/workflows/ci.yml
```

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
