//+------------------------------------------------------------------+
//|                                   XAU_Cent_Scalper_M5.mq5        |
//|  ADAPTASI untuk Valetax MT5 Cent, modal $10, leverage 1:1000      |
//|                                                                    |
//|  BERDASARKAN: n30dyn4m1c/gold-pro-scalper                          |
//|  (XAU_Quant_Reversion_TickRobust.mq5, MIT, (c) 2026 n30dyn4m1c)    |
//|  File ini DITULIS ULANG dari dokumentasi/kode asli yang dibaca    |
//|  (read-only). BUKAN copy-paste penuh file asli.                    |
//|                                                                    |
//|  ⚠️  BELUM DIKOMPILASI, BELUM DI-BACKTEST, BELUM DIUJI DEMO.      |
//|  JANGAN PASANG DI AKUN REAL. Ikuti PANDUAN_BACKTEST.md dulu.       |
//|  Logika inti dipertahankan (Z-Score mean reversion, cost gate,     |
//|  filter berita/sesi, 1 posisi, tanpa martingale/grid).             |
//|  Yang diubah: timeframe M1 -> M5, SL $8 -> $2, TP -> $4,            |
//|  risiko 10% -> 1%, batas rugi harian 25% -> 3%, lot tetap 0,05.    |
//|                                                                    |
//|  PERINGATAN KONSEP: EA ini mean-reversion (beli saat harga jatuh    |
//|  terlalu jauh). Strategi manual di repo ini trend-following.       |
//|  Jangan jalankan keduanya di akun/chart yang sama.                 |
//+------------------------------------------------------------------+
#property strict
#property copyright "Original (c) 2026 n30dyn4m1c (MIT). Adaptation (c) 2026 alkiz (MIT)."
#property link      "https://github.com/n30dyn4m1c/gold-pro-scalper"
#property version   "1.00-cent-adapted"
#property description "N30 TickRobust diadaptasi untuk Valetax Cent $10 - M5, lot 0.05, SL $2, TP $4. DEMO DULU."

//--- Inputs: Strategy (adaptasi Cent $10)
input string InpTradeSymbol     = "XAUUSD"; // Simbol di Valetax (XAUUSD / GOLD / XAUUSD.c)
input double InpEntryZ          = 2.2;      // Z-Score entry (bar tertutup) - dipertahankan dari asli
input bool   InpRequireTurn     = true;     // Wajib ada bar putar arah sebelum entry
input double InpExitZ           = 0.2;      // Backup exit: tutup saat Z kembali ke dalam ini
input int    InpMaxHoldBars     = 12;       // Max tahan posisi, dalam bar M5 (12 bar = 60 menit)
input double InpSLPoints        = 200;      // SL tetap $2,00 (point 0,01 -> 200 poin). UBAH kalau digit beda!
input double InpTPPoints        = 400;      // TP tetap $4,00 (point 0,01 -> 400 poin)
input double InpSLMaxPoints     = 250;      // SL tidak boleh lebih dari $2,50 walau ATR besar
input double InpBreakevenPts    = 200;      // Pindah SL ke breakeven setelah profit $2,00 (0 = mati)
input int    InpStartHour       = 10;       // Jam mulai sesi (JAM SERVER broker, ~15:00 WIB)
input int    InpEndHour         = 18;       // Jam selesai sesi (JAM SERVER, ~23:00 WIB)
input int    InpFridayCloseHour = 18;       // Jumat: tutup posisi & berhenti di jam ini
input int    InpCooldownMins    = 60;       // Jeda setelah trade rugi, menit (asli 15 -> adaptasi 60)
input int    InpMagic           = 777510;   // Magic number adaptasi (asli 777555)

//--- Inputs: Cost gates (inti pertahanan TickRobust)
input double InpExtraCostPts    = 0.0;      // Komisi round-trip dalam poin (Cent = 0, tanpa komisi)
input double InpMinSDCostMult   = 3.0;      // StdDev harus >= 3x biaya round-trip
input double InpMinTPCostMult   = 4.0;      // Jarak TP harus >= 4x biaya round-trip
input double InpMaxSpreadPts    = 35.0;     // Spread maks (poin). Asli 50 -> adaptasi 35 (spread Cent lebar)

//--- Inputs: Indikator & filter regime
input int    InpMAPeriod        = 20;       // Periode SMA / StdDev
input int    InpATRPeriod       = 14;       // Periode ATR
input int    InpADXPeriod       = 14;       // Periode ADX
input double InpADXMax          = 22.0;     // Skip entry kalau ADX di atas ini (0 = mati)
input int    InpFilterPeriodH1  = 50;       // Periode SMA H1 untuk filter tren (0 = mati)
input int    InpATRAvgPeriod    = 50;       // Periode rata-rata ATR
input double InpMaxATRRatio     = 2.0;      // Skip kalau ATR > 2x rata-rata (pasar meledak)
input double InpMinATRRatio     = 0.4;      // Skip kalau ATR < 0,4x rata-rata (pasar mati)

//--- Inputs: Risiko - ADAPTASI CENT $10 (dinamis DIMATIKAN)
input bool   InpUseDynamicRisk  = false;    // HARUS false untuk $10. Jangan nyalakan!
input double InpRiskPct         = 1.0;      // Risiko 1% per trade (asli dinamis <$500 = 10% - BERBAHAYA)
input double InpFixedLot        = 0.05;     // Lot TETAP Cent. EA tidak boleh melebihi ini.
input int    InpSlippage        = 30;       // Slippage maks (poin)

//--- Inputs: Filter berita (red folder USD saja)
input bool   InpUseNewsFilter   = true;     // Filter berita aktif
input int    InpNewsMinsBefore  = 60;       // Jeda SEBELUM berita berdampak tinggi
input int    InpNewsMinsAfter   = 120;      // Jeda SESUDAH berita
input bool   InpCloseBeforeNews = true;     // Tutup posisi sebelum berita

//--- Inputs: Batas rugi harian - ADAPTASI CENT $10
input bool   InpUseDailyLossLimit = true;   // Batas rugi harian aktif
input double InpMaxDailyLossPct   = 3.0;    // 3% = $0,30 di modal $10 (asli 25% - BERBAHAYA)

//--- Global handles & state
int      handleMA, handleSD, handleATR, handleADX, handleMA_H1;
string   TradeSymbol;
ulong    glTicket            = 0;
double   glEntryPrice        = 0;
datetime glOpenTime          = 0;
datetime glLossCooldownUntil = 0;
datetime lastBarTime         = 0;

#define MAX_NEWS 40
datetime newsRed[MAX_NEWS];
int      newsRedCount = 0;
datetime lastNewsLoad = 0;

double   dailyStartBalance = 0;
int      dailyStartDay = -1;
bool     dailyLossHit = false;

//+------------------------------------------------------------------+
//| OnInit                                                           |
//+------------------------------------------------------------------+
int OnInit()
{
   TradeSymbol = InpTradeSymbol;
   if(!SymbolInfoInteger(TradeSymbol, SYMBOL_EXIST))
   {
      Print("Simbol ", TradeSymbol, " tidak ditemukan - mencoba XAUUSD");
      TradeSymbol = "XAUUSD";
      if(!SymbolInfoInteger(TradeSymbol, SYMBOL_EXIST))
      {
         Print("GOLD maupun XAUUSD tidak ditemukan. Isi InpTradeSymbol manual.");
         return(INIT_FAILED);
      }
   }
   if(!SymbolSelect(TradeSymbol, true))
   {
      Print("Gagal menambahkan ", TradeSymbol, " ke Market Watch");
      return(INIT_FAILED);
   }

   // PERINGATAN KEAMANAN: file ini belum pernah dikompilasi/di-backtest.
   Print("XAU_Cent_Scalper_M5 (ADAPTASI, BELUM DITES) - simbol=", TradeSymbol,
         " lot tetap=", DoubleToString(InpFixedLot, 2),
         " SL=", DoubleToString(InpSLPoints, 0), " poin TP=", DoubleToString(InpTPPoints, 0), " poin");

   handleMA  = iMA(TradeSymbol, _Period, InpMAPeriod, 0, MODE_SMA, PRICE_CLOSE);
   handleSD  = iStdDev(TradeSymbol, _Period, InpMAPeriod, 0, MODE_SMA, PRICE_CLOSE);
   handleATR = iATR(TradeSymbol, _Period, InpATRPeriod);
   handleADX   = (InpADXMax > 0) ? iADX(TradeSymbol, _Period, InpADXPeriod) : INVALID_HANDLE;
   handleMA_H1 = (InpFilterPeriodH1 > 0) ? iMA(TradeSymbol, PERIOD_H1, InpFilterPeriodH1, 0, MODE_SMA, PRICE_CLOSE) : INVALID_HANDLE;

   if(handleMA == INVALID_HANDLE || handleSD == INVALID_HANDLE || handleATR == INVALID_HANDLE)
   {
      Print("Gagal membuat indicator handle");
      return(INIT_FAILED);
   }
   if(InpUseNewsFilter) LoadNewsEvents();

   dailyStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   MqlDateTime dt; TimeToStruct(TimeCurrent(), dt);
   dailyStartDay = dt.day_of_year;
   dailyLossHit = false;
   lastBarTime = iTime(TradeSymbol, _Period, 0);

   // Pulihkan posisi terbuka setelah restart
   glTicket = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != TradeSymbol) continue;
      if(PositionGetInteger(POSITION_MAGIC) != (long)InpMagic) continue;
      glTicket = ticket;
      glEntryPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      glOpenTime = (datetime)PositionGetInteger(POSITION_TIME);
      Print("Posisi terbuka dipulihkan setelah restart: ticket=", ticket);
      break;
   }
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| OnDeinit                                                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(handleMA    != INVALID_HANDLE) IndicatorRelease(handleMA);
   if(handleSD    != INVALID_HANDLE) IndicatorRelease(handleSD);
   if(handleATR   != INVALID_HANDLE) IndicatorRelease(handleATR);
   if(handleADX   != INVALID_HANDLE) IndicatorRelease(handleADX);
   if(handleMA_H1 != INVALID_HANDLE) IndicatorRelease(handleMA_H1);
}

//+------------------------------------------------------------------+
//| Batas rugi harian (3% = $0,30 di modal $10)                      |
//+------------------------------------------------------------------+
void CheckDailyReset()
{
   MqlDateTime dt; TimeToStruct(TimeCurrent(), dt);
   if(dt.day_of_year != dailyStartDay)
   {
      dailyStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
      dailyStartDay = dt.day_of_year;
      dailyLossHit = false;
      Print("Reset tracker harian. Saldo awal: ", DoubleToString(dailyStartBalance, 2));
   }
}

bool IsDailyLossLimitHit()
{
   if(!InpUseDailyLossLimit) return false;
   if(dailyLossHit) return true;
   if(dailyStartBalance <= 0) return false;
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   double lossPercent = ((dailyStartBalance - equity) / dailyStartBalance) * 100.0;
   if(lossPercent >= InpMaxDailyLossPct)
   {
      dailyLossHit = true;
      Print("BATAS RUGI HARIAN KENA: ", DoubleToString(lossPercent, 2),
            "% (batas ", DoubleToString(InpMaxDailyLossPct, 1), "%). Berhenti trading hari ini.");
      return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| Filter berita: hanya USD berdampak tinggi (red folder)           |
//+------------------------------------------------------------------+
void LoadNewsEvents()
{
   newsRedCount = 0;
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   datetime dayStart = TimeCurrent() - (dt.hour * 3600 + dt.min * 60 + dt.sec);
   datetime dayEnd   = dayStart + 86400 + InpNewsMinsBefore * 60;
   MqlCalendarValue values[];
   if(!CalendarValueHistory(values, dayStart, dayEnd)) return;
   int total = ArraySize(values);
   for(int i = 0; i < total; i++)
   {
      MqlCalendarEvent event;
      if(!CalendarEventById(values[i].event_id, event)) continue;
      if(event.importance != CALENDAR_IMPORTANCE_HIGH) continue;
      MqlCalendarCountry country;
      if(!CalendarCountryById(event.country_id, country)) continue;
      if(country.currency != "USD") continue;
      if(newsRedCount < MAX_NEWS)
         newsRed[newsRedCount++] = values[i].time;
   }
   lastNewsLoad = TimeCurrent();
   Print("Berita dimuat: ", newsRedCount, " event USD berdampak tinggi hari ini");
}

bool IsNearNews()
{
   if(!InpUseNewsFilter) return false;
   MqlDateTime dtNow, dtLast;
   TimeToStruct(TimeCurrent(), dtNow);
   TimeToStruct(lastNewsLoad, dtLast);
   if(dtNow.day_of_year != dtLast.day_of_year) LoadNewsEvents();
   datetime now = TimeCurrent();
   for(int i = 0; i < newsRedCount; i++)
   {
      long diff = (long)(newsRed[i] - now);
      if(diff > -(InpNewsMinsAfter * 60) && diff < (InpNewsMinsBefore * 60))
         return true;
   }
   return false;
}

bool IsRedNewsImminent()
{
   if(!InpUseNewsFilter || !InpCloseBeforeNews) return false;
   datetime now = TimeCurrent();
   for(int i = 0; i < newsRedCount; i++)
   {
      long diff = (long)(newsRed[i] - now);
      if(diff > 0 && diff < (InpNewsMinsBefore * 60))
         return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| Utilitas: hitung posisi sendiri, normalisasi lot, tutup posisi   |
//+------------------------------------------------------------------+
int CountOwnPositions()
{
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) == TradeSymbol &&
         PositionGetInteger(POSITION_MAGIC) == (long)InpMagic)
         count++;
   }
   return count;
}

double NormalizeLot(double lot)
{
   double minLot  = SymbolInfoDouble(TradeSymbol, SYMBOL_VOLUME_MIN);
   double maxLot  = SymbolInfoDouble(TradeSymbol, SYMBOL_VOLUME_MAX);
   double stepLot = SymbolInfoDouble(TradeSymbol, SYMBOL_VOLUME_STEP);
   lot = MathMax(minLot, lot);
   lot = MathMin(maxLot, lot);
   lot = MathFloor(lot / stepLot) * stepLot;
   int digits = (int)MathRound(-MathLog10(stepLot + 1e-10));
   if(digits < 0) digits = 0;
   return NormalizeDouble(lot, digits);
}

void SetFillMode(MqlTradeRequest &req)
{
   uint fill = (uint)SymbolInfoInteger(TradeSymbol, SYMBOL_FILLING_MODE);
   if(fill & SYMBOL_FILLING_FOK)      req.type_filling = ORDER_FILLING_FOK;
   else if(fill & SYMBOL_FILLING_IOC) req.type_filling = ORDER_FILLING_IOC;
   else                               req.type_filling = ORDER_FILLING_RETURN;
}

void CloseAllOwnPositions(string reason)
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != TradeSymbol) continue;
      if(PositionGetInteger(POSITION_MAGIC) != (long)InpMagic) continue;
      MqlTradeRequest req = {}; MqlTradeResult res = {};
      req.action   = TRADE_ACTION_DEAL;
      req.position = ticket;
      req.symbol   = TradeSymbol;
      req.volume   = PositionGetDouble(POSITION_VOLUME);
      long posType = PositionGetInteger(POSITION_TYPE);
      req.type     = (posType == POSITION_TYPE_BUY) ? ORDER_TYPE_SELL : ORDER_TYPE_BUY;
      double price = (req.type == ORDER_TYPE_SELL) ? SymbolInfoDouble(TradeSymbol, SYMBOL_BID)
                                                   : SymbolInfoDouble(TradeSymbol, SYMBOL_ASK);
      req.price     = NormalizeDouble(price, _Digits);
      req.deviation = InpSlippage;
      req.comment   = "CENT " + reason;
      SetFillMode(req);
      if(!OrderSend(req, res) || res.retcode != TRADE_RETCODE_DONE)
         Print("Gagal tutup posisi (", reason, "): ticket=", ticket, " retcode=", res.retcode);
      else
         Print("Posisi ditutup (", reason, "): ticket=", ticket);
   }
}

bool IsWeekendRisk()
{
   MqlDateTime dt;
   TimeCurrent(dt);
   if((dt.day_of_week == 5 && dt.hour >= InpFridayCloseHour) || dt.day_of_week == 6 || dt.day_of_week == 0)
      return true;
   return false;
}

bool IsAlignedWithH1Trend(bool isBuy)
{
   if(InpFilterPeriodH1 <= 0 || handleMA_H1 == INVALID_HANDLE) return true;
   double h1ma[1];
   if(CopyBuffer(handleMA_H1, 0, 1, 1, h1ma) < 1) return true;
   double bid = SymbolInfoDouble(TradeSymbol, SYMBOL_BID);
   if(isBuy) return bid > h1ma[0];
   return bid < h1ma[0];
}

void DetectPositionClosed()
{
   if(glTicket == 0 || PositionSelectByTicket(glTicket)) return;
   double netPnL = 0;
   bool   found  = false;
   datetime from = (glOpenTime > 0) ? glOpenTime - 60 : TimeCurrent() - 86400;
   if(HistorySelect(from, TimeCurrent() + 1))
   {
      int total = HistoryDealsTotal();
      for(int i = total - 1; i >= 0; i--)
      {
         ulong deal = HistoryDealGetTicket(i);
         if(deal == 0) continue;
         if(HistoryDealGetInteger(deal, DEAL_ENTRY) != DEAL_ENTRY_OUT) continue;
         if((ulong)HistoryDealGetInteger(deal, DEAL_POSITION_ID) != glTicket) continue;
         netPnL = HistoryDealGetDouble(deal, DEAL_PROFIT)
                + HistoryDealGetDouble(deal, DEAL_SWAP)
                + HistoryDealGetDouble(deal, DEAL_COMMISSION);
         found = true;
         break;
      }
   }
   if(found && netPnL < 0 && InpCooldownMins > 0)
   {
      glLossCooldownUntil = TimeCurrent() + (long)InpCooldownMins * 60;
      Print("Trade rugi (", DoubleToString(netPnL, 2), ") - jeda entry sampai ",
            TimeToString(glLossCooldownUntil, TIME_DATE|TIME_MINUTES));
   }
   if(found)
      Print("Trade ditutup: ticket=", glTicket, " NetPnL=", DoubleToString(netPnL, 2));
   glTicket     = 0;
   glEntryPrice = 0;
   glOpenTime   = 0;
}

//+------------------------------------------------------------------+
//| OnTick: safety tiap tick, keputusan sekali per bar               |
//+------------------------------------------------------------------+
void OnTick()
{
   CheckDailyReset();
   DetectPositionClosed();

   if(IsDailyLossLimitHit())
   {
      if(glTicket != 0) CloseAllOwnPositions("batas rugi harian");
      return;
   }
   if(IsWeekendRisk())
   {
      if(glTicket != 0) CloseAllOwnPositions("tutup Jumat");
      return;
   }
   if(IsRedNewsImminent() && glTicket != 0)
      CloseAllOwnPositions("berita USD dekat");

   datetime curBar = iTime(TradeSymbol, _Period, 0);
   if(curBar == lastBarTime) return;
   lastBarTime = curBar;

   if(glTicket != 0 && PositionSelectByTicket(glTicket))
      ManageOnBar(curBar);
   else
      TryEnterOnBar();
}

//+------------------------------------------------------------------+
//| ManageOnBar: kelola posisi sekali per bar                        |
//+------------------------------------------------------------------+
void ManageOnBar(datetime curBar)
{
   double ma1[1], sd1[1], atr1[1];
   if(CopyBuffer(handleMA, 0, 1, 1, ma1) < 1 ||
      CopyBuffer(handleSD, 0, 1, 1, sd1) < 1 ||
      CopyBuffer(handleATR, 0, 1, 1, atr1) < 1) return;
   if(sd1[0] <= 0.0) return;

   double close1 = iClose(TradeSymbol, _Period, 1);
   double z1     = (close1 - ma1[0]) / sd1[0];
   long   posType = PositionGetInteger(POSITION_TYPE);
   double point   = SymbolInfoDouble(TradeSymbol, SYMBOL_POINT);
   double bid     = SymbolInfoDouble(TradeSymbol, SYMBOL_BID);
   double ask     = SymbolInfoDouble(TradeSymbol, SYMBOL_ASK);
   int    barsHeld = (glOpenTime > 0) ? (int)((curBar - glOpenTime) / PeriodSeconds()) : 0;

   // 1) Backup exit: harga sudah kembali ke rata-rata
   bool zReverted = (posType == POSITION_TYPE_BUY  && z1 >= -InpExitZ) ||
                    (posType == POSITION_TYPE_SELL && z1 <=  InpExitZ);
   if(zReverted)
   {
      CloseAllOwnPositions("Mean tercapai (Z=" + DoubleToString(z1, 2) + ")");
      return;
   }
   // 2) Time exit: 12 bar M5 = 60 menit
   if(barsHeld >= InpMaxHoldBars)
   {
      CloseAllOwnPositions("Time Exit (" + IntegerToString(barsHeld) + " bar)");
      return;
   }

   double currentSL = PositionGetDouble(POSITION_SL);
   double currentTP = PositionGetDouble(POSITION_TP);
   int    stopLevel = (int)SymbolInfoInteger(TradeSymbol, SYMBOL_TRADE_STOPS_LEVEL);
   double spreadPts = (ask - bid) / point;
   double costPts   = spreadPts + InpExtraCostPts;
   double newSL = currentSL;
   double newTP = currentTP;

   // 3) Breakeven setelah profit InpBreakevenPts
   if(InpBreakevenPts > 0)
   {
      double bePrice = 0;
      if(posType == POSITION_TYPE_BUY && bid - glEntryPrice >= InpBreakevenPts * point)
      {
         bePrice = glEntryPrice + (spreadPts + 2) * point;
         if(bid - bePrice < stopLevel * point) bePrice = 0;
         if(bePrice > 0 && bePrice > newSL + 10 * point) newSL = bePrice;
      }
      if(posType == POSITION_TYPE_SELL && glEntryPrice - ask >= InpBreakevenPts * point)
      {
         bePrice = glEntryPrice - (spreadPts + 2) * point;
         if(bePrice - ask < stopLevel * point) bePrice = 0;
         if(bePrice > 0 && (newSL == 0 || bePrice < newSL - 10 * point)) newSL = bePrice;
      }
   }

   // 4) Gravity TP: ikuti SMA, tapi tidak di bawah lantai biaya.
   //    TP utama tetap InpTPPoints ($4); SMA hanya sebagai backup yang lebih dekat.
   if(posType == POSITION_TYPE_BUY)
   {
      double floorTP = glEntryPrice + (costPts + 5) * point;
      double target  = MathMax(ma1[0], floorTP);
      if(target < currentTP - 20 * point && target - bid > stopLevel * point)
         newTP = NormalizeDouble(target, _Digits);
   }
   else
   {
      double floorTP = glEntryPrice - (costPts + 5) * point;
      double target  = MathMin(ma1[0], floorTP);
      if(target > currentTP + 20 * point && ask - target > stopLevel * point)
         newTP = NormalizeDouble(target, _Digits);
   }

   if(newSL != currentSL || newTP != currentTP)
   {
      MqlTradeRequest r = {}; MqlTradeResult rs = {};
      r.action   = TRADE_ACTION_SLTP;
      r.position = glTicket;
      r.symbol   = TradeSymbol;
      r.sl       = NormalizeDouble(newSL, _Digits);
      r.tp       = NormalizeDouble(newTP, _Digits);
      if(!OrderSend(r, rs) || rs.retcode != TRADE_RETCODE_DONE)
         Print("Gagal ubah SL/TP: retcode=", rs.retcode);
   }
}

//+------------------------------------------------------------------+
//| TryEnterOnBar: evaluasi entry sekali per bar, data bar tertutup  |
//+------------------------------------------------------------------+
void TryEnterOnBar()
{
   if(CountOwnPositions() > 0) return;
   if(TimeCurrent() < glLossCooldownUntil) return;
   if(IsNearNews()) return;

   MqlDateTime dt; TimeToStruct(TimeCurrent(), dt);
   if(dt.hour < InpStartHour || dt.hour >= InpEndHour) return;

   double ma1[1], sd1[1], atr1[1];
   if(CopyBuffer(handleMA, 0, 1, 1, ma1) < 1 ||
      CopyBuffer(handleSD, 0, 1, 1, sd1) < 1 ||
      CopyBuffer(handleATR, 0, 1, 1, atr1) < 1) return;
   if(sd1[0] <= 0.0 || atr1[0] <= 0.0) return;

   double close1 = iClose(TradeSymbol, _Period, 1);
   double close2 = iClose(TradeSymbol, _Period, 2);
   double z1     = (close1 - ma1[0]) / sd1[0];

   int dir = 0;
   if(z1 <= -InpEntryZ) dir = 1;        // jauh di bawah rata-rata -> Buy snap-back
   else if(z1 >= InpEntryZ) dir = -1;   // jauh di atas rata-rata -> Sell
   if(dir == 0) return;

   // Konfirmasi putar arah: jangan tangkap pisau jatuh
   if(InpRequireTurn)
   {
      if(dir == 1  && close1 < close2) return;
      if(dir == -1 && close1 > close2) return;
   }

   // ADX: hanya saat ranging
   if(InpADXMax > 0 && handleADX != INVALID_HANDLE)
   {
      double adx1[1];
      if(CopyBuffer(handleADX, 0, 1, 1, adx1) >= 1 && adx1[0] > InpADXMax) return;
   }

   // ATR: lewati pasar meledak / mati
   if(InpATRAvgPeriod > 1)
   {
      double atrAvgBuf[];
      ArrayResize(atrAvgBuf, InpATRAvgPeriod);
      if(CopyBuffer(handleATR, 0, 1, InpATRAvgPeriod, atrAvgBuf) >= InpATRAvgPeriod)
      {
         double sum = 0;
         for(int i = 0; i < InpATRAvgPeriod; i++) sum += atrAvgBuf[i];
         double atrAvg = sum / InpATRAvgPeriod;
         if(atrAvg > 0)
         {
            double ratio = atr1[0] / atrAvg;
            if(ratio > InpMaxATRRatio || ratio < InpMinATRRatio) return;
         }
      }
   }

   double bid   = SymbolInfoDouble(TradeSymbol, SYMBOL_BID);
   double ask   = SymbolInfoDouble(TradeSymbol, SYMBOL_ASK);
   double point = SymbolInfoDouble(TradeSymbol, SYMBOL_POINT);

   // COST GATE: StdDev dan jarak TP harus berkali-kali lipat biaya
   double spreadPts = (ask - bid) / point;
   double costPts   = spreadPts + InpExtraCostPts;
   if(spreadPts > InpMaxSpreadPts) return;
   double sdPts = sd1[0] / point;
   if(sdPts < InpMinSDCostMult * costPts) return;

   double entryPrice = (dir == 1) ? ask : bid;
   double tpDistPts  = (dir == 1) ? (ma1[0] - entryPrice) / point
                                  : (entryPrice - ma1[0]) / point;
   if(tpDistPts < InpMinTPCostMult * costPts) return;

   if(!IsAlignedWithH1Trend(dir == 1)) return;

   ExecuteTrade((dir == 1) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL,
                entryPrice, ma1[0], atr1[0], z1);
}

//+------------------------------------------------------------------+
//| ExecuteTrade: entry market, SL $2 / TP $4, lot tetap 0,05        |
//+------------------------------------------------------------------+
void ExecuteTrade(ENUM_ORDER_TYPE type, double price, double meanPrice, double atrVal, double zScore)
{
   double point     = SymbolInfoDouble(TradeSymbol, SYMBOL_POINT);
   int    stopLevel = (int)SymbolInfoInteger(TradeSymbol, SYMBOL_TRADE_STOPS_LEVEL);

   // SL: tetap $2,00, dibatasi maks $2,50 walau ATR besar.
   // (Asli: max(800 poin, 2,5xATR) = $8+ -> TIDAK dipakai di sini.)
   double slDist = InpSLPoints * point;
   if(slDist > InpSLMaxPoints * point) slDist = InpSLMaxPoints * point;
   if(slDist < (stopLevel + 5) * point) slDist = (stopLevel + 5) * point;

   double sl = (type == ORDER_TYPE_BUY) ? price - slDist : price + slDist;
   // TP utama $4,00; kalau SMA lebih dekat tapi masih menutup biaya, pakai SMA.
   double tp = (type == ORDER_TYPE_BUY) ? price + InpTPPoints * point : price - InpTPPoints * point;
   double tpMean = meanPrice;
   if(type == ORDER_TYPE_BUY  && tpMean > price && tpMean < tp) tp = tpMean;
   if(type == ORDER_TYPE_SELL && tpMean < price && tpMean > tp) tp = tpMean;

   if(type == ORDER_TYPE_BUY  && tp - price < stopLevel * point) tp = price + stopLevel * point;
   if(type == ORDER_TYPE_SELL && price - tp < stopLevel * point) tp = price - stopLevel * point;

   // LOT TETAP 0,05 - tidak dihitung dari risiko dinamis (yang asli 10%).
   // Risiko 1% ($0,10) sudah dijamin oleh kombinasi lot 0,05 + SL $2.
   double lot = NormalizeLot(InpFixedLot);
   double minLot = SymbolInfoDouble(TradeSymbol, SYMBOL_VOLUME_MIN);
   if(lot < minLot)
   {
      Print("Lot tetap di bawah lot minimum broker - periksa InpFixedLot.");
      return;
   }

   double marginRequired;
   if(!OrderCalcMargin(type, TradeSymbol, lot, price, marginRequired))
   {
      Print("Gagal hitung margin, trade dibatalkan");
      return;
   }
   if(marginRequired > AccountInfoDouble(ACCOUNT_MARGIN_FREE))
   {
      Print("Margin tidak cukup: butuh=", DoubleToString(marginRequired, 2),
            " bebas=", DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_FREE), 2));
      return;
   }

   string dir = (type == ORDER_TYPE_BUY) ? "B" : "S";
   string comment = "CENT " + dir + "|Z" + DoubleToString(zScore, 2);
   if(StringLen(comment) > 31) comment = StringSubstr(comment, 0, 31);

   MqlTradeRequest req = {}; MqlTradeResult res = {};
   req.action    = TRADE_ACTION_DEAL;
   req.symbol    = TradeSymbol;
   req.volume    = lot;
   req.type      = type;
   req.price     = NormalizeDouble(price, _Digits);
   req.magic     = InpMagic;
   req.sl        = NormalizeDouble(sl, _Digits);
   req.tp        = NormalizeDouble(tp, _Digits);
   req.deviation = InpSlippage;
   req.comment   = comment;
   SetFillMode(req);

   if(!OrderSend(req, res) || res.retcode != TRADE_RETCODE_DONE)
   {
      Print("Entry gagal: retcode=", res.retcode, " comment=", res.comment);
      return;
   }

   glTicket = 0;
   if(res.deal > 0 && HistoryDealSelect(res.deal))
      glTicket = (ulong)HistoryDealGetInteger(res.deal, DEAL_POSITION_ID);
   if(glTicket == 0 || !PositionSelectByTicket(glTicket)) glTicket = res.order;
   if(!PositionSelectByTicket(glTicket)) glTicket = res.deal;

   glEntryPrice = (res.price > 0) ? res.price : price;
   glOpenTime   = TimeCurrent();

   Print("Trade dibuka: ticket=", glTicket, " ", EnumToString(type), " ", DoubleToString(lot, 2),
         " lot @ ", DoubleToString(glEntryPrice, _Digits),
         " SL=", DoubleToString(req.sl, _Digits),
         " TP=", DoubleToString(req.tp, _Digits),
         " Z=", DoubleToString(zScore, 2));
}
//+------------------------------------------------------------------+
//| Akhir file. Ingat: file ini BELUM dikompilasi / di-backtest.     |
//| Lisensi MIT asli (n30dyn4m1c) tetap berlaku untuk logika dasar.   |
//+------------------------------------------------------------------+
