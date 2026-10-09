# AI Challenge: Dokumentasi

## 1. Prompt yang digunakan

[Buatkan repository layer Flutter untuk endpoint GET /comments?postId={id}
dari JSONPlaceholder menggunakan Dio + flutter_riverpod.
Requirements:
- Model Comment dengan fromJson aman null (postId, id, name, email, body).
- CommentRepository dengan method fetchComments(postId) + timeout 10 detik.
- AsyncNotifierProvider dengan penanganan error otomatis (AsyncError)
  dan fungsi pesan error
  ramah pengguna untuk timeout, connection error, 404, dan 500.
- Satu unit test untuk fromJson dengan field yang hilang.
Jelaskan setiap bagian kode dalam komentar.]

## 2. Hasil AI

AI menghasilkan fitur komentar:
- `Comment` model dengan `fromJson` (guard `is num` / `is String`)
- `CommentRepository.fetchComments(postId)`
- `CommentListNotifier` (AsyncNotifier family per `postId`) dan `commentListProvider`
- 1 unit test: `fromJson(const {})` mengisi nilai default

## 3. Hasil verifikasi dan perbaikan

| Poin verifikasi | Temuan | Perbaikan |
|-----------------|--------|-----------|
| UI memanggil Dio langsung? | Tidak. Dio hanya di `api_client.dart` dan repository (constructor injection). | Tidak perlu. |
| `fromJson` aman null? | `Comment` aman. `Post` memakai `as String? ?? ''` yang crash (`TypeError`) bila tipe salah (misalnya `title: 123`). | `Post.fromJson` diganti guard `is`, sama seperti `Comment`. |
| Semua `DioExceptionType` dipetakan? | Timeout, connectionError, badResponse sudah. `cancel` dan `badCertificate` jatuh ke pesan generik. Fallback akhir menampilkan `$error` mentah. | Tambah `cancel` dan `badCertificate`. Fallback diganti pesan umum tanpa detail teknis. |
| `baseUrl`/timeout terpusat? | `CommentRepository` mengulang timeout 10 detik per-request (duplikasi). | `Options(...)` dihapus dari repository. Timeout hanya di `createDio()`. |
| Test menguji kasus field hilang? | Hanya 1 kasus (`{}`), tanpa happy path, null eksplisit, atau tipe salah. | Ditambah happy path dan 3 edge case sendiri (lihat di bawah). |
| Lain-lain | Ada komentar berbahasa Vietnam di `providers.dart`. Cabang `code == 500` redundan. | Komentar diganti bahasa Indonesia. Cabang 500 digabung ke `code >= 500`. |

## 4. Edge case tambahan buatan sendiri

1. Nilai `null` eksplisit pada semua field `Comment`.
2. Tipe data salah (string pada field angka, angka pada field string).
3. Angka desimal pada field `int` (`2.9` menjadi `2`).
4. Tipe salah pada `Post` (menemukan celah cast `as String?`).

## 5. Alasan keputusan teknis

| Keputusan | Alasan |
|-----------|--------|
| Dio, bukan package `http` | Timeout, interceptor (logging), dan `DioException` terstruktur tanpa boilerplate. |
| Repository pattern | Memisahkan akses data dari UI. Widget bisa diuji dengan repository palsu tanpa HTTP. |
| `AsyncNotifier` | Exception di `build()` otomatis menjadi `AsyncError`, tanpa try/catch di tiap widget. |
| `retry: (_, _) => null` | Retry otomatis Riverpod 3 membuat test menggantung dan error tidak langsung final. |
| Default `0` / `''` pada `fromJson` | Mencegah crash akibat respons API yang tidak sesuai dokumentasi. Trade-off: data rusak (misalnya `id: 0`) bisa tersembunyi. |
| Pagination 10 item + guard `isLoadingMore` / `hasMore` | Mencegah request ganda saat scroll listener terpanggil berkali-kali dan menghentikan request saat data habis. |
| Data lama dipertahankan saat error halaman berikutnya | Pengguna tidak kehilangan daftar yang sudah dimuat. |
| `friendlyErrorMessage` tanpa pesan teknis mentah | Pengguna tidak perlu melihat detail internal. |