# XAUUSD Scalping Cent — Valetax MT5, Modal $10

Strategi scalping emas (XAUUSD) untuk akun **Valetax MT5 tipe Cent, leverage 1:1000, modal $10 (= 1.000 USC)**.
Gaya: scalping **M5–M15**, trend-following, risiko kecil, disiplin harian.

> ⚠️ **Bukan jaminan profit. Ini edukasi, bukan sinyal pasti.**
> Trading emas dengan leverage bisa menghabiskan seluruh modal. Jangan pakai uang
> kebutuhan pokok. Uji dulu di demo / akun Cent kecil sampai 20 trade pertama
> terbukti disiplin, baru pertimbangkan menambah modal.
>
> Harga contoh di dokumen ini: emas sekitar **$3.630 pada 24 Nov 2026**,
> support **$3.580**, resistance **$3.695**. Harga berubah tiap hari — selalu cek
> harga live sebelum trading, jangan pakai angka ini sebagai level abadi.

## Ringkasan strategi

| Item | Aturan |
|---|---|
| Broker / akun | Valetax, MT5, **Cent**, leverage 1:1000 |
| Modal | **$10 = 1.000 USC** |
| Pair | XAUUSD (GOLD) |
| Timeframe tren | **M15** |
| Timeframe entry | **M5** |
| Indikator | EMA 20 & EMA 50 (M15), RSI 14 (M5) |
| Lot | **0,05 lot Cent** (tetap, jangan naik dulu) |
| Stop Loss | **$2,00** dari entry |
| Take Profit | **$4,00** dari entry (RR 1:2) |
| Risiko / trade | **1% = $0,10** |
| Maks. trade / hari | **3 trade** |
| Batas rugi harian | **$0,30 (3%)** — kena, berhenti |
| Target untung harian | **$0,40–$0,60** — tercapai, berhenti |
| Jam trading | **15:00–18:00 WIB** (London) dan **20:00–23:00 WIB** (New York) |
| Jangan trading | 07:00–14:00 WIB (Asia sepi), 30 menit sebelum/sesudah berita besar USD |

## Kenapa Cent $10 bisa, tapi ECN $10 tidak

Di akun Cent Valetax, saldo tampil dalam sen (USC) dan 1 lot = 1.000 unit,
sedangkan Standard = 100.000 unit. Exposurenya kira-kira **100x lebih kecil**
dari Standard. Karena itu:

- 0,01 lot Cent ≈ $0,01 untung/rugi per $1 gerakan emas
- 0,05 lot Cent ≈ $0,05 per $1 gerakan emas
- SL $2 di 0,05 lot = rugi **$0,10 (1% modal)** — pas dengan aturan risiko
- Di akun Standard/ECN, 0,01 lot yang sama SL $2 = rugi $2,00 (20% modal $10)

> **Wajib verifikasi di MT5 kamu:** klik kanan XAUUSD → *Specification*,
> lihat **Contract Size** dan **Tick Value**. Kalau Tick Value 0,01 lot = $0,01,
> hitungan di repo ini benar. Kalau beda, jangan trading dulu — kirim
> screenshot Specification ke Momo, lot akan dihitung ulang.
> Lihat juga `LOT_CALCULATOR.md`.

## Setup chart MT5

1. Buka chart **XAUUSD, M15**.
2. Pasang **EMA 20** dan **EMA 50** (warna beda, misal EMA 20 biru, EMA 50 merah).
3. Buka chart kedua **XAUUSD, M5** (atau pakai multi-timeframe di chart yang sama).
4. Pasang **RSI 14** di M5.
5. Tandai di chart: High/Low sesi Asia (07:00–14:00 WIB), High/Low kemarin,
   support $3.580 dan resistance $3.695 (per 24 Nov 2026 — perbarui tiap hari).
6. Matikan One Click Trading kalau kamu belum terbiasa; pasang SL/TP **sebelum**
   entry, jangan sesudah.

## Cara baca arah (M15)

- Harga di atas EMA 20 **dan** EMA 50, EMA 20 di atas EMA 50 → **cari Buy saja**.
- Harga di bawah EMA 20 **dan** EMA 50, EMA 20 di bawah EMA 50 → **cari Sell saja**.
- EMA datar, harga bolak-balik di tengah-tengah EMA → **no trade**.
  Scalping paling rugi di pasar sideways.

## Aturan entry (M5)

### Buy — semua syarat harus terpenuhi

1. Tren M15 naik (lihat di atas).
2. Harga pullback ke dekat EMA 20 di M5.
3. RSI M5 naik dari bawah 40 ke atas 45.
4. Candle M5 penutup hijau dan menembus high candle sebelumnya.
5. Bukan jam berita besar USD, spread masih wajar (di Cent, waspada kalau
   spread melebar jauh di atas normal).

### Sell — kebalikannya

1. Tren M15 turun.
2. Harga pullback ke dekat EMA 20 di M5.
3. RSI M5 turun dari atas 60 ke bawah 55.
4. Candle M5 penutup merah dan menembus low candle sebelumnya.
5. Bukan jam berita besar USD.

**Jangan entry di tengah range, jangan lawan tren, jangan entry karena FOMO.**

## SL, TP, dan keluar posisi

- **SL: $2,00** dari entry, di luar swing M5 terakhir.
  Contoh Buy di $3.630 → SL $3.628. Sell di $3.630 → SL $3.632.
- **TP: $4,00** dari entry. Buy di $3.630 → TP $3.634. Sell → TP $3.626.
- Boleh tutup 50% posisi di TP $3,00 dan biarkan sisanya ke $4,00 — tapi
  jangan pindah SL ke entry terlalu cepat, spread Cent bisa menyentuhmu.
- Kalau sudah 2x loss berturut-turut hari itu, **berhenti**. Jangan balas dendam.
- Maksimal tahan posisi 60 menit (12 bar M5). Kalau belum kena SL/TP dan
  sudah 60 menit, tutup manual dan evaluasi.

## Manajemen risiko (angka $10)

| | Nilai |
|---|---|
| Modal | $10,00 (1.000 USC) |
| Risiko / trade (1%) | $0,10 |
| Lot | 0,05 Cent |
| Rugi kalau SL kena | $0,10 |
| Untung kalau TP kena | $0,20 |
| Batas rugi harian (3%) | $0,30 = 3x SL |
| Target untung harian | $0,40–$0,60 = 2–3x TP |
| Biaya spread per trade (kira-kira) | ~$0,015 di 0,05 lot — kecil, tapi TP jangan di bawah $3 |

Rumus lot (Cent, patokan 0,01 lot = $0,01 per $1 gerakan):

```
Lot = (Risiko $ / SL $) x 0,01 / 0,01
    = Risiko $ / SL $ x 0,01 lot per $0,01-per-$1
Contoh: $0,10 / $2,00 = 0,05 lot
```

Tabel lengkap untuk modal $10 / $20 / $50 ada di `LOT_CALCULATOR.md`.

## Checklist sebelum klik Buy/Sell

Lihat `CHECKLIST.md` — cetak / salin ke HP. Kalau satu saja jawabannya
"TIDAK", skip trade itu.

## Jurnal

Isi `JOURNAL.md` untuk 20 trade pertama. Tanpa jurnal, kamu tidak akan tahu
apakah strategi ini jalan atau cuma hoki. Setelah 20 trade, hitung:
win rate, rata-rata untung/rugi, dan apakah kamu melanggar aturan.

## EA (opsional, bukan wajib)

Folder `ea-adapted/` berisi adaptasi EA publik **Gold Pro Scalper**
(MIT, oleh n30dyn4m1c) untuk Cent $10, plus panduan backtest.

**Baca dulu `ea-adapted/ADAPTASI.md` sebelum menyentuh EA apa pun.**
Poin terpenting:

- EA aslinya adalah **mean-reversion M1** (beli saat harga terlalu jatuh,
  jual saat terlalu naik, hanya saat pasar ranging / ADX < 22). Itu
  **berlawanan** dengan strategi manual di repo ini (trend-following M5–M15).
- Jangan jalankan EA dan trading manual di akun/chart yang sama.
- EA **wajib** backtest di Strategy Tester lalu demo dulu. **Jangan langsung live.**
- File adaptasi di repo ini ditulis ulang dari dokumentasi aslinya,
  **belum dikompilasi dan belum di-backtest**. Anggap sebagai bahan belajar,
  bukan robot siap profit.

## Tentang Valetax (catatan jujur)

- Valetax support MT4/MT5, regulasi FSC Mauritius lisensi GB21026312 —
  regulator Tier 3, bukan Tier 1 (FCA/ASIC/CySEC), tanpa skema kompensasi
  investor seperti broker besar.
- Akun Cent: deposit minimal $8, spread mulai 1,2 pip, tanpa komisi,
  leverage maks 1:1000, margin call 60% / stop out 30%.
- Leverage 1:1000 tidak mengubah untung/rugi per pip — hanya mengubah
  margin yang ditahan. Yang menghabiskan akun adalah lot kebesaran dan
  tanpa SL, bukan leverage itu sendiri. Tetap: lot kecil, SL selalu dipasang.
- Verifikasi lisensi dan entitas yang melayani akunmu di situs resmi
  regulator sebelum menambah deposit besar.

## Isi repo ini

```
xauusd-scalping-cent/
├── README.md            # strategi lengkap (file ini)
├── LOT_CALCULATOR.md    # tabel lot $10 / $20 / $50 + rumus
├── CHECKLIST.md         # checklist sebelum entry
├── JOURNAL.md           # template jurnal 20 trade pertama
└── ea-adapted/
    ├── ADAPTASI.md              # ringkasan adaptasi EA Gold Pro Scalper
    ├── XAU_Cent_Scalper_M5.mq5 # EA adaptasi (ditulis ulang, BELUM dites)
    └── PANDUAN_BACKTEST.md     # cara backtest di MT5 Strategy Tester + demo
```

## Lisensi

Dokumen strategi di repo ini bebas dipakai untuk belajar pribadi.
Bagian EA: kode asli © 2026 n30dyn4m1c, lisensi MIT — lihat `ea-adapted/ADAPTASI.md`.
