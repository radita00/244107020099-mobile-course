# Week 4: Networking & REST API (Flutter)

## Tujuan
Membangun aplikasi daftar data dari REST API (JSONPlaceholder) dengan arsitektur
berlapis: model, repository, state (Riverpod), dan UI, lengkap dengan penanganan
error dan pagination.

## Fitur utama
- Daftar post dari `GET /posts` dengan 4 state: loading, error (+ tombol "Coba lagi"), empty, success
- Pesan error ramah pengguna untuk timeout, koneksi gagal, dan respons server (404, 401/403, 5xx)
- Infinite scroll 10 item per halaman dengan guard request ganda
- Model `fromJson` aman null dan aman tipe
- Dio terpusat (base URL, timeout, interceptor logging)
- Dokumentasi AI Challenge dan refleksi di `docs/`

## Stack teknologi
Flutter, Dart, Dio, flutter_riverpod (`AsyncNotifier`, `Notifier`), JSONPlaceholder API.

## Struktur
​```
lib/       kode aplikasi (data/, pages/)
test/      unit test, test provider, widget test
docs/      ai-challenge.md, refleksi.md
screenshots/  bukti tampilan dan hasil test
​```

## Cara menjalankan
​```bash
flutter pub get
flutter run
flutter test
​```

## Hasil yang dicapai
- Semua test lulus (unit model, provider dengan repository palsu, widget test)
- Pengujian 3 skenario error: internet normal, mode pesawat + retry, base URL salah
- Verifikasi 5 poin kode buatan AI beserta perbaikannya (lihat `docs/ai-challenge.md`)

## Screenshots
Lihat folder `screenshots/`.