# Pull Request Template

## 📝 Masalah
Project week 1-7 belum memiliki dokumentasi review formal dan Git workflow yang proper. Semua commit langsung ke `main` tanpa branching strategy.

## ✅ Solusi
- Tambah `docs/review-checklist.md` dengan audit lengkap:
  - Analisis 3 commit terburuk + perbaikan conventional format
  - Static analysis results (flutter analyze, dart format, flutter test)
  - Clean Architecture dependency rule verification
  - Template PR + review checklist untuk reviewer
  - Definition of Done mid-semester
  - Refleksi week 1-7
- Tambah `README.md` week 8 dengan overview Git Flow + CI/CD setup
- Branch `develop` sudah dibuat dan CI/CD aktif

## 🧪 Cara Uji
1. Baca `08-week-8-mid-project-review/docs/review-checklist.md`
2. Verifikasi semua checklist item tercantum (commit audit, static analysis, architecture verification)
3. Cek apakah action items jelas untuk next PR
4. Review format markdown (heading, table, code block)

**Dokumentasi only - tidak ada code changes**

## 📊 Checklist

- [x] Audit commit history dengan tabel sebelum/sesudah
- [x] Static analysis results documented (0 issues, 20/20 tests)
- [x] Architecture sterilitas verified dengan grep commands
- [x] PR template + review checklist untuk peer review
- [x] Definition of Done lengkap
- [x] Refleksi mid-semester + improvement plan
- [x] README.md week 8 overview

## 📸 Screenshot
N/A - documentation only

## 🔗 References
- Jobsheet Minggu 8: Praktikum 1-3 (Git hygiene, PR, static analysis)
- Conventional Commits: https://www.conventionalcommits.org/

---

Closes #[issue-number-jika-ada]
