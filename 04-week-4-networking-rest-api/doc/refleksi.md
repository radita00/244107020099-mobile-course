# Refleksi

## 1. Mengapa UI dilarang memanggil Dio langsung? Apa yang rusak jika dilanggar?

UI seharusnya hanya menampilkan state. Jika widget memanggil Dio langsung:
- **Tidak bisa diuji tanpa jaringan.** Widget test jadi bergantung pada HTTP sungguhan, lambat dan tidak stabil.
- **Konfigurasi tersebar.** Mengubah `baseUrl`, timeout, atau header berarti mengedit banyak widget.
- **Request bisa berulang tak terkendali.** Pemanggilan di `build()` ikut terpicu setiap rebuild.
- **Parsing dan error mapping bercampur dengan tampilan**, sehingga pesan teknis mudah bocor ke pengguna.
- **Sulit mengganti sumber data** (cache, mock, API lain) karena UI terikat langsung ke Dio.

Dengan repository, UI hanya tahu "minta daftar post", dan detail jaringan terisolasi di satu tempat.

## 2. Kapan pagination client-side cukup, kapan harus pagination server?

- **Client-side cukup** bila datanya kecil (puluhan sampai ratusan item), sudah terunduh sekali, jarang berubah, dan API tidak menyediakan paging. Contoh: 100 post JSONPlaceholder sebenarnya masih nyaman dimuat sekaligus.
- **Pagination server (`_page` / `_limit`) wajib** bila data besar atau tak terbatas, payload berat, atau data sering berubah. Server hanya mengirim yang diperlukan sehingga hemat bandwidth, memori, dan baterai, dan waktu tampil awal lebih cepat.
- Catatan: pagination berbasis halaman bisa menghasilkan item ganda atau terlewat bila data bergeser di server. Untuk data yang sangat dinamis, pagination berbasis cursor lebih aman.

## 3. Bagaimana exception repository menjadi `AsyncError` tanpa try/catch di setiap widget? Kapan try/catch tetap dibutuhkan?

`AsyncNotifier.build()` mengembalikan `Future`. Riverpod membungkus Future itu secara internal: bila repository melempar exception, state otomatis menjadi `AsyncError(error, stackTrace)`, dan UI cukup menangani cabang `error:` pada `.when()`. Karena repository membiarkan exception naik (tidak ditelan), alurnya otomatis.

try/catch eksplisit tetap dibutuhkan ketika:
- Mengubah state secara **imperatif di luar `build()`**, misalnya `refresh()` pada `PostListNotifier`.
- State **bukan `AsyncValue`**, seperti `PagedPostsNotifier`: error harus disimpan ke field `error`, dan data lama dipertahankan.
- Ingin **menerjemahkan** exception ke tipe domain, atau memberi fallback (misalnya cache).
- Perlu **membersihkan sumber daya** (`finally`).
