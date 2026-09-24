## 1. Prompt Desain

**Prompt yang diajukan:**
> "Bandingkan dua tata letak dashboard akademik untuk Flutter: versi `GridView` dan versi `LayoutBuilder` + `Column`. Jelaskan trade-off responsif dan aksesibilitasnya."

**Ringkasan output AI**

| Aspek | `GridView.count`  | `LayoutBuilder` + `Column`/`Row` manual |
|---    |---                |---                                       |
| Kerapian kode | Ringkas, deklaratif | Verbose, perlu grouping manual per baris |
| Fleksibilitas tinggi kartu | Terkunci oleh `childAspectRatio` — konten tidak seragam berisiko overflow | Tinggi mengikuti konten (`Column` intrinsik) — lebih aman untuk konten variatif |
| Transisi breakpoint | Melompat tegas 1→2 kolom | Sama, tapi lebih mudah dikustomisasi bertahap |
| Struktur semantik | Ada role grid implisit dari Flutter | Tidak ada role otomatis, perlu `Semantics` eksplisit |
| Urutan baca screen reader | Mengikuti urutan grid (bisa terasa kurang natural saat reflow 1↔2 kolom) | Dapat dikontrol eksplisit sesuai urutan kode |

**Keputusan yang dipilih:** tetap menggunakan `GridView.count`, karena keempat kartu (Assignments, Attendance, GPA, Portfolio) seragam strukturnya dan risiko overflow rendah selama teks dijaga singkat.

**Alasan teknis:** kompleksitas `LayoutBuilder` + `Column` manual (grouping pasangan, penanganan item ganjil) tidak sepadan untuk kasus data yang homogen ini. `GridView` dipilih demi keterbacaan kode dan konsistensi tinggi antar kartu.

## 2. Prompt Penguatan Konsep

**Prompt yang diajukan:**
> "Jelaskan kapan penggunaan `Expanded` justru menyebabkan overflow di dalam `Row`, beri contoh kode yang gagal dan perbaikannya."

**Ringkasan output AI**

**Skenario A — `Row` di dalam konteks lebar tak terbatas** (mis. `SingleChildScrollView`/`ListView` horizontal). `Expanded` butuh constraint lebar *bounded*; tanpanya, muncul error:
```
RenderFlex children have non-zero flex but incoming width constraints are unbounded.
```
Perbaikan: ganti `Expanded` dengan lebar tetap (`SizedBox(width: ...)`).

**Skenario B — `Expanded` hanya mengatur main axis (horizontal), bukan cross axis (vertikal).** Jika `Row` dibatasi tinggi tetap sementara konten di dalam `Expanded` butuh ruang vertikal lebih, overflow vertikal tetap terjadi. Perbaikan: hapus tinggi tetap pada container pembungkus, atau gunakan `mainAxisSize: MainAxisSize.min` pada `Column` di dalamnya.

**Keputusan yang dipilih:** kartu di Academic Overview tidak menggunakan tinggi `Container` yang dikunci secara terpisah (tinggi diatur lewat `childAspectRatio` grid, bukan `Container.height` manual), sehingga skenario B tidak berlaku langsung. Skenario A dihindari karena tidak ada `Row` yang ditempatkan di dalam scroll horizontal pada implementasi ini.

**Alasan teknis:** memahami bahwa `Expanded` = pembagi ruang *main axis* saja (bukan solusi umum anti-overflow) penting agar penambahan fitur ke depan (mis. `Row` di dalam list horizontal) tidak mengulang kesalahan yang sama.

## 3. Verification Prompt

**Prompt yang diajukan:**
> "Periksa kembali rekomendasi layout di atas: apakah tetap responsif di bawah 600px, apakah mengurangi aksesibilitas, dan apakah ada widget yang tidak tersedia di Flutter stabil saat ini?"

**Hasil audit AI:**

1. **Responsif di bawah 600px:** Sebagian besar aman (1 kolom). **Risiko yang teridentifikasi:** `childAspectRatio: 2.6` mengunci rasio kartu — pada layar sangat sempit (<320dp) atau skala teks sistem tinggi (accessibility text scaling), tinggi kartu yang terkunci berpotensi memicu overflow teks. **Belum diverifikasi** dengan pengujian `textScaleFactor` tinggi — dicatat sebagai item tindak lanjut.
2. **Aksesibilitas:** Tidak berkurang — penambahan `Semantics` pada header profil, tiap kartu, dan toggle tema (`toggled: isDark`) menambah konteks bagi screen reader. Catatan: urutan baca grid 2 kolom (kiri-atas → kanan-atas → kiri-bawah → kanan-bawah) perlu diuji langsung dengan TalkBack/VoiceOver untuk memastikan tidak membingungkan.
3. **Widget non-stabil:** Tidak ditemukan. `LayoutBuilder`, `GridView.count`, `CupertinoSwitch`, `Semantics`, `useMaterial3`, `colorSchemeSeed` — semuanya API stabil Flutter saat ini.

## 4. Bukti Verifikasi

- `screenshots/panjang.png` — tampilan 1 kolom (lebar layar < 600dp)
- `screenshots/lebar.png` — tampilan 2 kolom (lebar layar ≥ 600dp)
