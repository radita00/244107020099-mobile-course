# Refleksi (Week 9 — bagian 8)

Berdasarkan bukti yang tersimpan di `docs/evidence/`.

## 1. Satu halusinasi AI apa yang saya temukan, dan bagaimana saya membuktikannya?

Ada dua halusinasi API dan satu bug logika.

**Halusinasi #1 — `StateProvider`.** AI menulis
`final searchQueryProvider = StateProvider<String>((ref) => '');` untuk
menyimpan query pencarian. Bukti salahnya bukan feeling, tapi mesin:
`flutter analyze` menolak dengan

```
error • The function 'StateProvider' isn't defined • lib/.../announcements_providers.dart
```

(`docs/evidence/01-analyze-v1.txt`). Saya lalu buka paket yang benar-benar
terpasang di `$LOCALAPPDATA/Pub/Cache/hosted/pub.dev/riverpod-3.4.3` dan
`grep` kelasnya: `StateProvider` hanya ada di `lib/src/legacy.dart` dan tidak
diekspor oleh `flutter_riverpod.dart`. Jadi di versi ini memang tidak tersedia
lewat import utama — AI menulis API dari versi lama.

**Halusinasi #2 — `FutureProvider.notifier`.** AI menulis
`ref.watch(announcementsProvider.notifier).future`. Analyzer menolak:
`The getter 'notifier' isn't defined`. `FutureProvider` tidak punya `notifier`;
yang benar `Provider<AsyncValue<...>>` + `AsyncValue.whenData`.

**Bug logika — filter case-sensitive.** Ini bukan halusinasi API, tapi salah
logika: `contains()` dipakai tanpa `toLowerCase()`. Buktinya test:
**2 dari 4** test merah (`docs/evidence/03-test-gagal.txt`), keduanya
`Expected: length 1, Actual: []`. Yang saya perbaiki kodenya, bukan test-nya.

## 2. Prompt mana yang paling membantu, dan apa yang saya ubah?

Yang paling membantu: **prompt final 5 slot** di `docs/ai-log.md` §1.4 —
terutama slot *Constraint* dan *Output*.

Yang saya ubah dari percobaan awal:

| Sebelum | Sesudah | Efeknya |
|---|---|---|
| "Buatkan fitur search pengumuman pakai Riverpod" | Menyebut versi: `flutter_riverpod 3.4.3` | AI berhenti mengarang `StateProvider` |
| Hanya deskripsi struktur folder | Isi `AnnouncementRepository` dan `Announcement` ditempel apa adanya | Nama method dan field cocok, tidak perlu diperbaiki manual |
| "Beri kode lengkap" | "Sebutkan file, alasan tiap perubahan, dan test yang membuktikannya" | Output langsung bisa saya verifikasi per file |

Perubahan terbesar bukan menambah kalimat sopan, tapi **menambahkan fakta yang
bisa diperiksa** (versi paket + isi interface). Dengan itu saya bisa membuktikan
output AI salah lewat `flutter analyze`, bukan menduga-duga.

## 3. Satu refactor apa yang saya lakukan pada kode AI?

`home_page.dart` hasil AI **226 baris** dengan satu `build()` **141 baris**.
Saya pecah jadi:

| Hasil | Baris |
|---|---|
| `pages/home_page.dart` (lifecycle + handler) | 145 |
| `widgets/search_field.dart` | 44 |
| `widgets/announcement_list.dart` | 65 |
| `widgets/empty_announcement_state.dart` | 40 |
| `widgets/push_status_panel.dart` | 42 |

`build()` turun 141 → 25 baris, method terpanjang 36 baris (`_initPush`).

Refactor kedua: `announcements_providers.dart` yang mencampur DI dan state
pencarian saya pecah jadi `announcements_providers.dart` (45 baris) +
`search_providers.dart` (39 baris), dan import `data/` dipindah ke `di.dart`.
Efeknya bukan kosmetik: setelah itu saya bisa menulis 7 test baru
(`empty_state_widget_test.dart`, `search_provider_test.dart`) tanpa emulator.

## 4. Keputusan terima/tolak mana yang paling sulit?

**Menolak debounce 300 ms** pada kolom pencarian.

Ini paling sulit karena secara umum debounce itu praktik yang benar — jadi
menolaknya terasa seperti melawan kebiasaan. Yang akhirnya meyakinkan saya:

1. Datanya 4 pengumuman di memori; filter `toLowerCase().contains()` atas
   seluruh daftar jauh lebih murah daripada satu frame render.
2. `Timer` menambah lifecycle yang wajib di-`cancel()` di `dispose`; kalau lupa,
   muncul error "setState after dispose".
3. Widget test jadi bergantung waktu (`pump(300ms)`) → rawan flaky.
4. Kalau nanti datanya dari API, solusinya pagination/query di data layer,
   bukan debounce di widget. Menaruhnya sekarang berarti salah tempat nanti.

Keputusan yang hampir sama sulitnya: **tidak** membuat `SearchAnnouncements`
memanggil repository sendiri. Terdengar "kurang Clean Architecture", tapi
memanggil repository di situ akan menduplikasi penanganan loading/error yang
sudah ada di `announcementsProvider`, dan membuat use case tidak lagi murni
(sekarang bisa diuji tanpa mock apa pun).

## Referensi pendukung

| Sumber | Tautan | Dipakai untuk |
|---|---|---|
| Slide Week 9: AI-Assisted Development / Vibe Coding | [00-slides/Week_09](https://jti-polinema.github.io/flutter-codelab/00-slides/Week_09_AI_Assisted_Development_Vibe_Coding.html) | Alur praktikum & checklist |
| Flutter: Using IDEs and static analysis | [docs.flutter.dev/tools/using-ide](https://docs.flutter.dev/tools/using-ide) | Membaca output `flutter analyze` |
| Dart: Linter rules | [dart.dev/tools/linter-rules](https://dart.dev/tools/linter-rules) | Aturan di `analysis_options.yaml` |
| Riverpod: Getting started | [riverpod.dev/docs/introduction/getting_started](https://riverpod.dev/docs/introduction/getting_started) | `Notifier`, `NotifierProvider`, `AsyncValue` |
| GitHub Copilot: Best practices | [docs.github.com/.../best-practices](https://docs.github.com/en/copilot/using-github-copilot/best-practices) | Menyusun prompt + konteks |
| Learn Dart in Y Minutes | [learnxinyminutes.com/dart](https://learnxinyminutes.com/dart/) | Sintaks Dart yang tidak familiar |
| Dart Language Tour | [dart.dev/guides/language/language-tour](https://dart.dev/guides/language/language-tour) | `List.unmodifiable`, collection |
