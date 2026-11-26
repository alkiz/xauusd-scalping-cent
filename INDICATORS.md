# Rincian Indikator — Scalping XAUUSD M5-M15 (Cent $10)

Akun: Valetax MT5 Cent, leverage 1:1000, modal $10 = 1.000 USC
Lot: 0,05 Cent | SL $2 | TP $4 | Risiko 1% = $0,10 per trade
Sesi: 15:00-18:00 WIB (London) dan 20:00-23:00 WIB (New York)

## 1. EMA 20 dan EMA 50 — Penentu Tren

- Insert > Indicators > Trend > Moving Average
- EMA 20: Period 20, Method Exponential, Apply to Close, warna Biru
- EMA 50: Period 50, Method Exponential, Apply to Close, warna Merah / Oranye
- Pasang di M15 dan M5.

Cara baca:
- Buy only: harga di atas EMA 20 DAN EMA 50, EMA 20 di atas EMA 50, keduanya miring naik.
- Sell only: harga di bawah EMA 20 DAN EMA 50, EMA 20 di bawah EMA 50, keduanya miring turun.
- No Trade: EMA 20 dan EMA 50 saling silang bolak-balik, datar, harga bolak-balik di tengah.

Entry pullback:
- Buy: harga turun ke EMA 20 di M5, lalu mantul naik.
- Sell: harga naik ke EMA 20 di M5, lalu mantul turun.
- Jangan entry kalau harga sudah lebih dari $5 dari EMA 20.

## 2. RSI 14 — Konfirmasi Momentum

- Insert > Indicators > Oscillators > Relative Strength Index
- Period 14, Apply to Close
- Level: 30, 40, 60, 70
- Pasang di M5, jendela bawah chart.

Cara baca:
- Buy: RSI naik dari bawah 40 ke atas 45, posisi 45-60.
- Sell: RSI turun dari atas 60 ke bawah 55, posisi 40-55.
- Jangan Buy kalau RSI di atas 70. Jangan Sell kalau RSI di bawah 30.
- Divergence: harga bikin low baru tapi RSI bikin low lebih tinggi = potensi Buy. Sebaliknya untuk Sell.

Wajib searah dengan EMA. Kalau EMA bilang Sell tapi RSI masih di 65 naik, skip.

## 3. ATR 14 — Ukur Volatilitas dan SL/TP

- Insert > Indicators > Oscillators > Average True Range
- Period 14, pasang di M5, jendela bawah.

Cara baca untuk Cent $10:
- ATR M5 normal di London/New York: $1,00 - $2,00
- ATR di bawah $0,80: pasar pelan, TP $4 susah tercapai, jangan scalping.
- ATR di atas $2,50: pasar terlalu liar, SL $2 gampang kena, tunggu tenang.
- Rumus ideal: SL = 1x ATR, TP = 2x ATR. Kalau ATR $2, SL $2 dan TP $4.

## 4. Support & Resistance — Manual

Tandai dengan Horizontal Line di MT5. Update tiap pagi.
Per 26 Nov 2026, harga sekitar $3.573:

Resistance: 3585, 3598, 3612, 3645-3680, 3700-3716, 3841 (SMA 20 Daily)
Support: 3550-3560, 3532-3535, 3500, 3480-3490, 3425-3445 (low mayor)

## 5. Setting Per Timeframe

| Timeframe | Indikator | Fungsi |
|---|---|---|
| H4 | EMA 50 dan EMA 200 | Tren besar. Di atas keduanya = naik, di bawah = turun. Per 26 Nov harga jauh di bawah keduanya = bearish |
| M15 | EMA 20 dan EMA 50 | Tren utama scalping: Buy only atau Sell only |
| M5 | EMA 20, EMA 50, RSI 14, ATR 14 | Entry, konfirmasi momentum, ukur volatilitas |

## 6. Aturan Kombinasi — Harus 3-3-nya Setuju

BUY hanya kalau:
1. M15: harga di atas EMA 20/50
2. M5: harga pullback ke EMA 20 lalu mantul, RSI 40 naik ke 45+
3. Harga di dekat Support (3550-3560 atau 3531-3535), bukan di tengah

SELL hanya kalau:
1. M15: harga di bawah EMA 20/50
2. M5: harga pullback ke EMA 20 lalu mantul turun, RSI 60 turun ke 55-
3. Harga di dekat Resistance (3585-3598 atau 3605-3612), bukan di tengah

Kalau satu saja tidak setuju, skip. Harga 3573 pada 26 Nov 2026 adalah tengah range — WAIT.

## 7. Template MT5

File: `templates/XAU_Cent_Scalping.tpl`
Cara pakai (MT5 desktop, bukan HP):
1. Download file .tpl dari repo ini.
2. MT5 > File > Open Data Folder > MQL5 > Profiles > Templates, paste file di sana.
3. Restart MT5, buka chart XAUUSD M5, klik kanan chart > Templates > Load Template > pilih XAU_Cent_Scalping.
4. Cek: EMA 20 biru, EMA 50 merah, RSI 14 di bawah, ATR 14 di bawah.
5. Kalau template tidak ter-load sempurna di build MT5 kamu, pakai setting manual di atas — setting manual adalah acuan utama, template hanya jalan pintas.

Template ini hanya berisi indikator bawaan MT5 (Moving Average, RSI, ATR), tidak ada indikator custom, tidak ada EA.
