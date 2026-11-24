# Kalkulator Lot — Akun Cent Valetax, XAUUSD

Semua angka di sini memakai patokan yang **wajib kamu verifikasi dulu** di MT5:

> Klik kanan **XAUUSD → Specification**, lihat **Tick Value**.
> Patokan repo ini: **0,01 lot Cent = $0,01 untung/rugi per $1 gerakan emas**.
> Kalau Tick Value di akunmu beda, semua tabel di bawah harus dihitung ulang.

## Rumus

```
Nilai per $1 gerakan = Lot x $1,00   (karena 0,01 lot = $0,01 per $1)
Rugi kalau SL kena   = Nilai per $1 x SL ($)
Untung kalau TP kena = Nilai per $1 x TP ($)
Lot = Risiko $ / SL $ x 0,01 / 0,01
    = (Risiko $ / SL $) / 1 x 0,01 lot ... sederhananya:
Lot = Risiko $ / SL $ x 0,01 lot ÷ $0,01
Contoh $10: $0,10 / $2,00 = 0,05 lot
```

Aturan dasar yang dipakai di semua tabel: **SL $2,00, TP $4,00 (RR 1:2),
risiko 1% per trade**.

## Tabel 1 — Modal $10 (akun ALKiZ saat ini)

Modal $10 = 1.000 USC. Risiko 1% = **$0,10**.

| Lot Cent | Nilai / $1 gerakan | Rugi SL $2 | Untung TP $4 | % modal / trade |
|---|---:|---:|---:|---:|
| 0,01 | $0,01 | $0,02 | $0,04 | 0,2% |
| 0,03 | $0,03 | $0,06 | $0,12 | 0,6% |
| **0,05** | **$0,05** | **$0,10** | **$0,20** | **1,0% ✅ pakai ini** |
| 0,10 | $0,10 | $0,20 | $0,40 | 2,0% ⚠️ |
| 0,20 | $0,20 | $0,40 | $0,80 | 4,0% ❌ |

Batas harian $10: rugi maks **$0,30** (3x SL di 0,05 lot),
target untung **$0,40–$0,60** (2–3x TP di 0,05 lot).

## Tabel 2 — Modal $20

Modal $20 = 2.000 USC. Risiko 1% = **$0,20**.

| Lot Cent | Rugi SL $2 | Untung TP $4 | % modal |
|---|---:|---:|---:|
| 0,05 | $0,10 | $0,20 | 0,5% |
| **0,10** | **$0,20** | **$0,40** | **1,0% ✅** |
| 0,20 | $0,40 | $0,80 | 2,0% ⚠️ |

Batas harian $20: rugi maks **$0,60**, target untung **$0,80–$1,20**.

## Tabel 3 — Modal $50

Modal $50 = 5.000 USC. Risiko 1% = **$0,50**.

| Lot Cent | Rugi SL $2 | Untung TP $4 | % modal |
|---|---:|---:|---:|
| 0,10 | $0,20 | $0,40 | 0,4% |
| **0,25** | **$0,50** | **$1,00** | **1,0% ✅** |
| 0,50 | $1,00 | $2,00 | 2,0% ⚠️ |

Batas harian $50: rugi maks **$1,50**, target untung **$2,00–$3,00**.

## Kalau SL-nya bukan $2?

Pakai rumus, jangan kira-kira. Contoh modal $10 (risiko $0,10):

| SL | Lot yang pas (risiko $0,10) | TP (2x SL) | Untung TP |
|---:|---:|---:|---:|
| $1,00 | 0,10 | $2,00 | $0,20 |
| $1,50 | 0,07 | $3,00 | $0,21 |
| **$2,00** | **0,05** | **$4,00** | **$0,20** |
| $3,00 | 0,03 | $6,00 | $0,18 |
| $5,00 | 0,02 | $10,00 | $0,20 |

Perhatikan: untung TP-nya hampir sama ($0,20) karena risiko dan RR-nya sama.
SL yang lebih lebar bukan berarti profit lebih besar — hanya butuh waktu
lebih lama dan lebih tahan noise. Untuk scalping M5, SL $2 adalah kompromi
yang masuk akal; SL $1 terlalu mudah kena spread/noise.

## Biaya spread (perkiraan, Cent)

- Spread XAUUSD di Cent mulai 1,2 pip, rata-rata sekitar $0,30.
- Per trade 0,05 lot: biaya spread ≈ **$0,015**.
- Itu 7,5% dari TP $0,20 — masih oke, tapi alasan kenapa TP jangan
  di bawah $3,00. TP $1,00 akan habis dimakan spread.
- Akun Cent **tanpa komisi** (berbeda dengan ECN yang $4/lot).

## Margin (perkiraan — verifikasi di MT5)

Leverage 1:1000 hanya menentukan margin yang ditahan, bukan untung/rugi.
Perkiraan kasar di harga $3.630: margin 0,05 lot Cent hanya puluhan sen,
bukan $3,63 seperti 0,01 lot Standard/ECN. Angka pastinya tergantung
Contract Size XAUUSD di akun Cent Valetax — cek di Specification,
atau lihat kolom Margin saat pasang posisi demo. Jangan trading live
sebelum kamu melihat sendiri margin 0,05 lot di terminalmu.

## Contoh hitungan cepat sebelum entry

Contoh: Buy XAUUSD di $3.630, lot 0,05, modal $10.

- SL $3.628 → kalau kena, rugi $0,10
- TP $3.634 → kalau kena, untung $0,20
- Harga harus naik $4,00 untuk TP — di sesi London/New York itu gerakan
  yang wajar dalam 15–60 menit, tapi tidak dijamin terjadi tiap trade.
