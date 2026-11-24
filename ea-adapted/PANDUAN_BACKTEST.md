# Panduan Backtest EA Adaptasi — MT5 Strategy Tester

> ⚠️ **Jangan pasang EA ini di akun real sebelum semua langkah di bawah lolos.**
> Backtest yang bagus pun tidak menjamin profit live. Backtest yang jelek
> adalah alasan yang cukup untuk **tidak** memakai EA ini.

## 0. Yang kamu butuhkan

- MT5 desktop (Windows/Mac) — Strategy Tester di MT5 mobile tidak ada.
- Akun **demo Valetax Cent** (bukan real). Kalau belum ada, buat demo Cent
  $10 di client area Valetax, leverage 1:1000.
- File `XAU_Cent_Scalper_M5.mq5` dari folder ini.
- Data harga XAUUSD yang cukup: minimal 3 bulan M5.

## 1. Instalasi file EA

1. Di MT5, klik **File → Open Data Folder**.
2. Masuk ke folder `MQL5 → Experts`.
3. Copy file `XAU_Cent_Scalper_M5.mq5` ke folder itu.
4. Buka file di **MetaEditor** (klik kanan file → Edit, atau tekan F4 di MT5).
5. Tekan **Compile (F7)**.
6. **Harus 0 errors.** Kalau ada error/warning, JANGAN lanjut — catat pesan
   errornya dan kirim ke Momo. File ini belum pernah dikompilasi sebelumnya,
   jadi error sangat mungkin terjadi dan itu normal.
7. Kalau compile berhasil, file `.ex5` akan muncul di folder Experts yang sama.

## 2. Cek Tick Value & jam server dulu (5 menit, jangan dilewati)

1. Di Market Watch, klik kanan **XAUUSD → Specification**.
   Catat: **Contract Size, Tick Value, Tick Size, Digits, Stop Level**.
   - Kalau Digits = 2 (point 0,01): SL $2 = 200 poin, TP $4 = 400 poin ✅
   - Kalau Digits = 3 (point 0,001): SL $2 = 2.000 poin — ubah input
     `InpSLPoints` dan `InpTPPoints` di EA sebelum backtest.
2. Lihat jam di Market Watch (jam server). Bandingkan dengan jam WIB.
   Sesi EA 10:00–18:00 jam server ≈ 15:00–23:00 WIB kalau server GMT+2.
   Kalau selisihnya beda, sesuaikan `InpStartHour` / `InpEndHour`.

## 3. Backtest di Strategy Tester

1. Di MT5, tekan **Ctrl+R** (Strategy Tester) atau View → Strategy Tester.
2. Pilih:
   - **Expert:** `XAU_Cent_Scalper_M5`
   - **Symbol:** XAUUSD (nama persis di Market Watch kamu)
   - **Period:** **M5**
   - **Date:** pilih 3 bulan terakhir, misal 24 Agu – 24 Nov 2026.
     Jangan backtest cuma 1 minggu — terlalu sedikit trade untuk dinilai.
   - **Model:** **Every tick based on real ticks** (paling jujur untuk scalping).
     Jangan pakai "OHLC on M1" saja — EA TickRobust dibuat justru karena
     hasil OHLC dan Every Tick bisa jauh berbeda.
   - **Deposit:** **10 USD** (Cent: isi 10, pilih mata uang akun demo kamu)
   - **Leverage:** 1:1000
3. Klik tab **Inputs** dan periksa:
   - `InpTradeSymbol` = XAUUSD (sesuai simbol kamu)
   - `InpFixedLot` = 0,05
   - `InpRiskPct` = 1,0 — dan `InpUseDynamicRisk` = false
   - `InpSLPoints` = 200, `InpTPPoints` = 400
   - `InpMaxDailyLossPct` = 3,0
   - `InpStartHour` = 10, `InpEndHour` = 18
   - `InpMaxSpreadPts` = 35
4. Klik **Start**. Tunggu sampai selesai.
5. Lihat tab **Backtest** / **Graph** / **Report**:
   - Total trades: minimal 30 trade baru bisa dinilai. Kurang dari itu,
     perpanjang periode backtest.
   - Profit factor: harus > 1,2. Di bawah 1,0 = rugi, jangan pakai.
   - Max drawdown: harus < 10% dari $10 (yaitu < $1,00). Lebih dari itu,
     EA terlalu berisiko untuk akun ini.
   - Win rate saja tidak cukup — EA mean-reversion bisa win rate tinggi
     tapi sekali loss besar menghabiskan semuanya. Cek **largest loss**.
   - Cek juga: apakah ada trade yang loss lebih dari $0,10 (1%)?
     Kalau ada, SL / lot-nya tidak bekerja seperti yang diharapkan.

### Kriteria LOLOS backtest (semua harus terpenuhi)

- [ ] 0 errors saat compile
- [ ] ≥ 30 trade dalam 3 bulan
- [ ] Profit factor > 1,2
- [ ] Max drawdown < $1,00 (10%)
- [ ] Tidak ada satu trade pun yang loss > $0,15
- [ ] Hasil Every Tick dan OHLC tidak jauh berbeda (kalau jauh berbeda,
      ada masalah spread/simbol — jangan pakai)

Kalau satu saja gagal → **EA tidak dipakai.** Kembali ke trading manual
di `README.md`. Itu bukan kegagalan — itu backtest yang bekerja dengan benar.

## 4. Uji demo (forward test)

Kalau backtest lolos:

1. Pasang EA di chart **XAUUSD M5 demo Cent**, AutoTrading ON.
2. Biarkan jalan **minimal 2 minggu**, atau sampai 20 trade.
3. Isi jurnal di `JOURNAL.md` (atau export dari MT5 → History).
4. Bandingkan hasil demo dengan backtest. Kalau demo jauh lebih jelek
   (spread/slippage live lebih besar), jangan naik ke real.

## 5. Baru pertimbangkan live — dengan syarat ketat

- Backtest lolos DAN demo 20 trade tidak melanggar batas rugi harian.
- Lot tetap **0,05**, jangan naik.
- Pantau 3 hari pertama secara manual, jangan ditinggal.
- Kalau dalam 1 minggu rugi harian $0,30 kena 2x, **matikan EA** dan evaluasi.

## Yang tidak boleh dilakukan

- ❌ Optimasi parameter sampai backtest "sempurna" (overfitting — hasil
  bagus di masa lalu, hancur di live).
- ❌ Menjalankan EA asli (risiko 10%) dan EA adaptasi di akun yang sama.
- ❌ Menjalankan EA + trading manual di chart/akun yang sama.
- ❌ Menambah martingale / grid / "tambah lot kalau loss" ke EA ini.
- ❌ Memakai EA ini di akun Standard/ECN $10 — lot dan SL-nya dihitung
  untuk Cent.
