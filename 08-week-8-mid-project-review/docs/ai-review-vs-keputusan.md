# AI Review vs Keputusan Final - PR #1

**PR:** #1 feat/week8-review-docs → develop  
**Tanggal Review:** 3 November 2026  
**Reviewer:** AI (Hermes Agent) + Manual Verification

---

## 1. Prompt yang Digunakan

```
Review PR Flutter ini sebagai senior Flutter dev.
Konteks: feature-first Clean Architecture (presentation -> domain <- data),
Riverpod, GoRouter, SQLite + Dio.
Fokus: kebenaran, arsitektur, dan test. Abaikan style.
Berikan 5 temuan teratas + level (blocker/saran)
+ alasan + usulan potongan kode perbaikan.
```

---

## 2. Output AI (5 Temuan)

### Temuan 1: CI/CD Flutter Version Mismatch (BLOCKER)
**Level:** BLOCKER  
**Deskripsi:** CI workflow awalnya menggunakan Flutter 3.24.x yang menyediakan Dart 3.5.4, tetapi project `campus_notify` membutuhkan Dart 3.13.5 (dari pubspec.yaml). Dependency seperti `flutter_lints ^6.0.0`, `flutter_secure_storage ^11.2.0`, dan `firebase_messaging ^16.7.0` memerlukan Dart SDK versi lebih tinggi.

**Alasan:** Version mismatch menyebabkan `flutter pub get` gagal di CI dengan error "version solving failed", memblokir merge PR.

**Usulan:**
```yaml
# .github/workflows/ci.yml
- name: Setup Flutter
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.47.x'  # Match dengan local development
    channel: 'stable'
```

---

### Temuan 2: Dart Format Not Run Before First Commits (SARAN)
**Level:** SARAN  
**Deskripsi:** PR memiliki 2 commit format fix terpisah (`a3a942e` dan `c157f3a`) yang mem-format 25 files (3+22) setelah CI fail. Ini menunjukkan `dart format` tidak dijalankan sebelum commit awal.

**Alasan:** Format issues seharusnya dicegah dengan pre-commit hook atau developer habit, bukan ditemukan oleh CI.

**Usulan:**
```bash
# Setup pre-commit hook di .git/hooks/pre-commit
#!/bin/bash
cd 07-week-7-clean-architecture/campus_notify
dart format . --set-exit-if-changed
if [ $? -ne 0 ]; then
  echo "❌ Code not formatted. Run: dart format ."
  exit 1
fi
```

---

### Temuan 3: Documentation-Only PR Lacks Peer Review Evidence (SARAN)
**Level:** SARAN  
**Deskripsi:** PR berisi dokumentasi (review-checklist, README, PR template) tetapi tidak ada bukti peer review. Week 8 requirement menyebutkan "peer review 15 menit" dengan minimal 2 temuan kebenaran + 1 arsitektur + 1 test + 1 keterbacaan.

**Alasan:** Untuk PR documentation-only, peer review mungkin tidak applicable, tetapi jobsheet requirement tidak membedakan jenis PR.

**Usulan:**
- Dokumentasikan "Self-review only (no code changes, documentation PR)" di review-checklist.md
- Atau: buat 1 PR kecil dengan code changes untuk demonstrate peer review workflow

---

### Temuan 4: CI Analyze Scope Mismatch (BLOCKER → FIXED)
**Level:** BLOCKER (sudah diperbaiki di commit `b32ac2d`)  
**Deskripsi:** CI awalnya menjalankan `flutter analyze` di repo root, yang men-scan semua week 1-7 projects (433 issues found dari dependency incomplete). Commit fix mem-scope analyze hanya ke `07-week-7-clean-architecture/campus_notify/`.

**Alasan:** Week 1-6 adalah standalone projects dengan missing dependencies. CI seharusnya hanya verify production-ready code (week 7).

**Usulan:** (Sudah diterapkan)
```yaml
- name: Analyze Week 7 (Clean Architecture)
  working-directory: ./07-week-7-clean-architecture/campus_notify
  run: |
    flutter pub get
    flutter analyze
    dart format --set-exit-if-changed .
    flutter test
```

**Status:** ✅ Fixed dalam PR ini

---

### Temuan 5: Missing Test Coverage for Week 8 Docs (INFO)
**Level:** INFO  
**Deskripsi:** Week 8 folder tidak memiliki automated tests untuk markdown validation. Files seperti `review-checklist.md` dan `README.md` bisa memiliki broken links, incorrect code blocks, atau inconsistent formatting.

**Alasan:** Documentation quality bisa di-verify dengan tools seperti `markdownlint` atau link checkers, mengurangi manual review burden.

**Usulan:**
```yaml
# .github/workflows/ci.yml
- name: Verify Week 8 Docs
  run: |
    npm install -g markdownlint-cli
    markdownlint 08-week-8-mid-project-review/**/*.md
    # Check for broken internal links
    grep -r "\[.*\](.*\.md)" 08-week-8-mid-project-review/ | while read line; do
      # validate links exist
    done
```

---

## 3. Tabel Verifikasi

| # | Temuan AI | Level | Verifikasi (Bukti) | Keputusan | Alasan Keputusan |
|---|-----------|-------|-------------------|-----------|------------------|
| 1 | CI Flutter version mismatch | BLOCKER | ✅ **Terbukti**. Log CI job 125677261212 menunjukkan "Dart SDK 3.5.4 but flutter_lints ^6.0.0 requires ^3.8.0". Commit `94f81a5` upgrade ke Flutter 3.47.x fix issue ini. | ✅ **DITERIMA** | Temuan valid. Tanpa fix ini PR tidak bisa merge. Evidence: CI logs + commit history. |
| 2 | Dart format tidak dijalankan sebelum commit | SARAN | ✅ **Terbukti**. Commit `a3a942e` (3 test files) dan `c157f3a` (22 lib/test files) adalah format fixes setelah CI fail. | ❌ **DITOLAK** | Meski benar, pre-commit hook bukan requirement week 8. Format fixes via CI feedback adalah workflow acceptable. Setup pre-commit hook bisa jadi improvement week 9+. |
| 3 | Documentation PR lacks peer review | SARAN | ⚠️ **Partially true**. Tidak ada reviewer kedua listed di PR. Namun week 8 adalah **individual assignment** (review-checklist.md Section 9: "Kesiapan untuk paruh kedua"). | ❌ **DITOLAK** | Week 8 context: mid-semester **self-assessment**, bukan team collaboration PR. Peer review requirement berlaku untuk **future PRs** (action items), bukan PR dokumentasi week 8 ini. |
| 4 | CI analyze scope mismatch | BLOCKER | ✅ **Terbukti & Fixed**. Commit `b32ac2d` menambahkan `working-directory: ./07-week-7-clean-architecture/campus_notify`. Sebelumnya analyze scan 433 issues dari week 1-6. | ✅ **DITERIMA & FIXED** | Valid blocker, sudah di-fix dalam PR ini. Evidence: CI yml diff + local `flutter analyze` output (433→0 issues). |
| 5 | Missing markdown linting | INFO | ✅ **Terbukti**. Tidak ada markdownlint atau link checker di CI. Manual review satu-satunya validation untuk docs quality. | ⏳ **DEFER** | Valid improvement idea, tapi **out of scope** untuk week 8. Jobsheet tidak require markdown linting. Bisa ditambahkan sebagai stretch goal atau week 9+ improvement. |

---

## 4. Summary

### Temuan Diterima (2)
1. ✅ **CI Flutter version mismatch** - Fixed dengan upgrade Flutter 3.47.x
2. ✅ **CI analyze scope mismatch** - Fixed dengan working-directory scope

### Temuan Ditolak (2)
1. ❌ **Pre-commit hook untuk format** - Bukan requirement, format via CI acceptable
2. ❌ **Peer review untuk documentation PR** - Week 8 adalah self-assessment, peer review untuk future code PRs

### Temuan Defer (1)
1. ⏳ **Markdown linting** - Good idea tapi out of scope week 8

---

## 5. Bukti Verifikasi

### Bukti Temuan 1 (Flutter Version)
```bash
# CI Log sebelum fix
Error: Because flutter_lints 6.0.0 requires SDK version ^3.8.0 
and no versions of flutter_lints match >6.0.0 <7.0.0, 
flutter_lints ^6.0.0 is forbidden.

# Fix commit
git show 94f81a5 --stat
# modified: .github/workflows/ci.yml (flutter-version: 3.47.x)
# modified: pubspec.yaml (revert downgrades)
```

### Bukti Temuan 2 (Format Fixes)
```bash
git log --oneline --grep="format"
c157f3a style: dart format semua lib/ dan test/ files (22 files changed)
a3a942e style: dart format test files (auth_usecase_test, get_notes_test, widget_test)
```

### Bukti Temuan 4 (Analyze Scope)
```bash
# Sebelum fix: flutter analyze di root
flutter analyze  # 433 issues found (all weeks)

# Sesudah fix: analyze di campus_notify only
cd 07-week-7-clean-architecture/campus_notify
flutter analyze  # 0 issues found
```

---

## 6. Keputusan Teknis Final

**PR #1 Status:** ✅ **APPROVED**

**Rationale:**
- 2 blocker issues identified by AI were **valid and fixed** during PR iteration
- 2 rejected suggestions were **out of scope** for week 8 self-assessment context
- 1 deferred suggestion is **future improvement**, not blocking
- All CI checks passing after fixes
- Documentation complete per week 8 requirements

**Lessons Learned:**
1. AI review efektif untuk catch **environment mismatch** (Flutter version) yang tidak terdeteksi local development
2. AI suggestion perlu **context filtering** - pre-commit hooks & peer review valid untuk team setting, tapi bukan requirement individual assignment
3. **Verify first, apply later** - 50% AI suggestions ditolak/defer setelah verifikasi dengan jobsheet requirements

---

**Verified by:** Radita (244107020099)  
**Date:** 3 November 2026  
**Demo-ready:** ✅ Dapat explain setiap temuan tanpa membuka catatan AI
