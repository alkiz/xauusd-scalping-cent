# Adaptasi EA Gold Pro Scalper untuk Cent $10

> ⚠️ **BACA DULU — PENTING**
>
> 1. File adaptasi di folder ini **ditulis ulang dari dokumentasi dan kode
>    yang dibaca (read-only)**, bukan hasil compile dan bukan hasil backtest.
>    File ini **BELUM dikompilasi, BELUM di-backtest, dan BELUM pernah jalan
>    di demo maupun live**.
> 2. **JANGAN langsung pasang di akun real $10.** Ikuti `PANDUAN_BACKTEST.md`:
>    Strategy Tester → demo Cent → baru pertimbangkan live, dan itupun
>    dengan lot 0,05.
> 3. EA aslinya **mean-reversion M1**, sedangkan strategi manual di repo ini
>    **trend-following M5–M15**. Keduanya berlawanan arah dalam banyak kondisi.
>    Jangan jalankan EA dan trading manual di akun/chart yang sama.

## Sumber asli (yang dibaca, bukan di-clone)

- Repo: **n30dyn4m1c/gold-pro-scalper**
- URL: https://github.com/n30dyn4m1c/gold-pro-scalper
- Lisensi: **MIT** (boleh dipakai, diubah, dan dibagikan dengan mencantumkan
  lisensi + copyright asli)
- Commit yang dibaca: `7794c91e6803d8ede4bec5ee36001dd46c5dade3` (24 Nov 2026)
- File yang dibaca penuh: `XAU_Quant_Reversion_TickRobust.mq5` (1.331 baris)
  dan `README.md` repo tersebut
- Penulis asli: **Neo Malesa (n30dyn4m1c)**, © 2026
- Repo **xauusd-scalper-research TIDAK dipakai** — lisensinya Proprietary,
  dilarang dipakai/dimodifikasi tanpa izin tertulis.
- Repo ini **tidak di-clone dengan git** — kode dibaca sebagai teks (read-only)
  lewat GitHub web, sesuai batasan keamanan saat pengerjaan.

## Ringkasan cara kerja EA asli (TickRobust) — Bahasa Indonesia

### Ide dasar: mean reversion, bukan trend-following

EA ini menganggap harga emas sering "terlalu jauh" dari rata-ratanya lalu
kembali (snap-back). Ia **membeli saat harga jatuh terlalu jauh** dan
**menjual saat harga naik terlalu jauh** — kebalikan dari "beli saat tren naik".

### Logika entry (sekali per bar, data bar tertutup saja)

1. Hitung **Z-Score** = (Close − SMA 20) / StdDev 20, dari bar M1 yang sudah tutup.
2. **Buy** kalau Z ≤ −2,2 (harga jauh di bawah rata-rata).
   **Sell** kalau Z ≥ +2,2 (harga jauh di atas rata-rata).
3. **Konfirmasi putar arah (turn confirmation):** bar terakhir harus sudah
   berhenti membuat harga ekstrem baru. Jangan tangkap pisau jatuh.
4. **ADX ≤ 22:** hanya entry saat pasar ranging, bukan saat tren kuat.
5. **ATR wajar:** ATR sekarang 0,4x–2,0x dari rata-rata ATR 50 bar.
   Lewati pasar yang terlalu sepi atau terlalu meledak.
6. **Cost gate (pertahanan utama TickRobust):** StdDev harus ≥ 3x biaya
   round-trip (spread + komisi), dan jarak ke target TP (SMA) harus
   ≥ 4x biaya. Kalau tidak, skip — profitnya akan habis dimakan spread.
7. **Spread ≤ 50 poin.** Kalau spread melebar, skip.
8. **Filter tren H1:** Buy hanya kalau harga di atas SMA 50 H1,
   Sell hanya kalau di bawahnya (filter ini longgar, bukan penentu utama).
9. **Sesi 10:00–20:00** waktu server broker, **tanpa berita USD berdampak tinggi**.

### Logika exit (urutan prioritas)

1. **TP server-side di SMA (mean):** TP dipasang sebagai limit order di
   harga rata-rata. Limit tidak membayar spread saat keluar.
   TP ini di-update tiap bar mengikuti SMA yang bergerak ("gravity TP"),
   tapi tidak boleh turun di bawah lantai yang masih menutup biaya.
2. **Backup exit:** tutup kalau Z kembali ke dalam ±0,2 (harga sudah kembali
   ke rata-rata).
3. **Time exit:** tutup setelah **40 bar** (di M1 = 40 menit) kalau belum kembali.
4. **Breakeven:** setelah profit 1x ATR, SL dipindah ke breakeven (+ biaya).
5. **SL server-side:** `max(800 poin, 2,5 × ATR)`.

### Filter berita & sesi

- Kalender ekonomi MQL5, **hanya berita USD berdampak tinggi** (red folder).
- Blokir entry **60 menit sebelum** dan **120 menit sesudah** berita.
- Tutup posisi terbuka sebelum berita (opsional, default aktif).
- Tutup semua posisi Jumat jam 20:00 waktu server, jangan bawa posisi weekend.

### Manajemen risiko asli — INI YANG PALING BERBAHAYA UNTUK $10

| Ekuitas | Risiko / trade | Batas rugi harian |
|---|---:|---:|
| < $500 | **10%** | **25%** |
| $500–$2.000 | 7% | 20% |
| $2.000–$5.000 | 5% | 15% |
| $5.000–$20.000 | 3% | 10% |
| > $20.000 | 1,5% | 7% |

- Lot dihitung dari risiko % dan jarak SL, lalu dinormalisasi ke lot minimum broker.
- Kalau lot hitungan di bawah lot minimum, EA **tidak entry** (skip).
- Cooldown **15 menit** setelah trade rugi.
- **Satu posisi saja** dalam satu waktu (per magic number).
- **Tidak ada martingale, grid, atau hedging** di kode yang dibaca — ini bagus.
- Magic number TickRobust: **777555**.

### Kenapa EA asli TIDAK BISA langsung dipakai di Cent $10

1. **SL 800 poin = $8,00.** Itu 80% dari modal $10 (Standard) — dan dengan
   risiko 10% (tier <$500), lot hitungannya akan di bawah lot minimum atau
   risikonya tidak masuk akal. Di Cent, perhitungan risiko memakai saldo
   1.000 USC dan tick value sen, jadi SL $8 tetap terlalu lebar untuk
   target SL $2 kita.
2. **Risiko 10% per trade dan batas rugi harian 25%** — 3x loss beruntun
   sudah menghabiskan seperempat akun. Untuk $10, itu bukan manajemen risiko.
3. **Timeframe M1** — noise dan biaya spread jauh lebih besar daripada M5,
   apalagi spread Cent yang mulai 1,2 pip.
4. **Mean reversion vs tren:** saat emas trending kuat (misal 24 Nov 2026
   range harian $3.607–$3.678, volatil), EA ini justru akan melawan tren
   dan bisa kena SL beruntun. Filter ADX ≤ 22 seharusnya mencegahnya,
   tapi tidak ada jaminan.

## Yang diubah di versi adaptasi (`XAU_Cent_Scalper_M5.mq5`)

File adaptasi ditulis ulang (bukan copy-paste penuh file asli) dengan
logika inti yang sama, tapi parameternya disesuaikan untuk Cent $10.
Perubahan utama:

| Parameter | Asli (TickRobust) | Adaptasi Cent $10 | Alasan |
|---|---:|---:|---|
| Timeframe yang disarankan | M1 | **M5** | Kurangi noise & biaya spread |
| Simbol | GOLD | **XAUUSD** (fallback GOLD) | Nama simbol di Valetax |
| Entry Z | 2,2 | **2,2 (tetap)** | Inti strategi dipertahankan |
| ADX maks | 22 | **22 (tetap)** | Hanya ranging |
| SL | max(800 poin, 2,5×ATR) = $8+ | **tetap $2,00 (200 poin), maks $2,50** | Sesuai strategi manual repo ini |
| TP | limit di SMA (mean) | **tetap $4,00 (400 poin) + TP di SMA sebagai backup** | RR 1:2, sesuai strategi manual |
| Risiko / trade | dinamis, <$500 = **10%** | **tetap 1,0%, dinamis DIMATIKAN** | $10 × 1% = $0,10 |
| Batas rugi harian | dinamis, <$500 = **25%** | **tetap 3,0% = $0,30** | Sesuai README repo ini |
| Lot | dihitung dari risiko % | **tetap 0,05 lot, maks 0,05** | Sesuai LOT_CALCULATOR.md |
| Sesi (waktu server) | 10:00–20:00 | **10:00–18:00** | ≈ 15:00–23:00 WIB (server GMT+2; cek jam server Valetax kamu, bisa geser ±1 jam saat DST) |
| Max hold | 40 bar (M1 = 40 mnt) | **12 bar (M5 = 60 mnt)** | Sesuai batas tahan manual |
| Cooldown setelah loss | 15 menit | **60 menit** | Lebih disiplin untuk akun kecil |
| Spread maks | 50 poin | **35 poin** | Spread Cent lebih lebar; 35 poin ≈ $0,35 |
| Berita USD | blokir 60 mnt sebelum / 120 sesudah | **tetap** | Dipertahankan |
| Magic number | 777555 | **777510** | Bedakan dari EA asli, hindari bentrok |
| Martingale / grid | tidak ada | **tetap tidak ada** | Dilarang ditambahkan |
| Max posisi | 1 | **1 (tetap)** | — |
| Breakeven | setelah 1×ATR | **setelah $2,00 profit (1× SL)** | Sederhana, sesuai SL $2 |

### Yang TIDAK diubah (sengaja)

- Z-Score, turn confirmation, filter ADX/ATR, cost gate, filter H1, dan
  filter berita dipertahankan — itu inti keunggulan TickRobust.
- TP limit di SMA dipertahankan sebagai **backup exit**, tapi TP utama
  adalah $4,00 tetap. Kalau SMA lebih dekat dari $4,00, TP SMA yang dipakai
  selama masih menutup biaya (lihat kode).

### Yang masih harus diverifikasi pengguna (jangan ditebak)

1. **Tick Value XAUUSD di akun Cent Valetax** — klik kanan XAUUSD →
   Specification. Adaptasi ini mengasumsikan 0,01 lot = $0,01 per $1 gerakan.
2. **Jam server Valetax vs WIB** — sesi 10:00–18:00 di kode adalah jam server.
   Cocokkan dengan jam di Market Watch MT5 kamu.
3. **Nama simbol** — di Valetax bisa `XAUUSD`, `GOLD`, atau `XAUUSD.c`.
   Ubah `InpTradeSymbol` kalau perlu.
4. **Point / digit** — XAUUSD Valetax umumnya 2 digit (point 0,01),
   jadi $2,00 = 200 poin. Kalau di akunmu 3 digit, ubah `InpSLPoints` /
   `InpTPPoints` sesuai perhitungan di `PANDUAN_BACKTEST.md`.

## Status

- [x] Kode asli dibaca penuh (1.331 baris, TickRobust)
- [x] Ringkasan & tabel perubahan dibuat (file ini)
- [x] File adaptasi ditulis ulang (`XAU_Cent_Scalper_M5.mq5`)
- [ ] File adaptasi dikompilasi di MetaEditor — **BELUM, harus dilakukan pengguna**
- [ ] Backtest Strategy Tester (Every Tick, real ticks) — **BELUM**
- [ ] Uji demo Cent minimal 2 minggu / 20 trade — **BELUM**
- [ ] Live — **DILARANG sebelum semua di atas lolos**

## Atribusi & lisensi

- Kode asli: © 2026 n30dyn4m1c, lisensi **MIT**.
  https://github.com/n30dyn4m1c/gold-pro-scalper
- Adaptasi di repo ini: turunan MIT, © 2026 alkiz.
  Sertakan lisensi MIT asli saat membagikan file adaptasi.
- Repo xauusd-scalper-research **tidak** dipakai di sini karena lisensi Proprietary.
