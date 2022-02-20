struct HCandles  {   int RCN;      //RCN (Recent Candle Num)
                  double High;  // High
                  double Low;     // Low
                  double Open;       // Open
                  double Close;        // High
                  string CandleType;        // CandleType true = Bull, false = Bear
                  string Pattern;
                     double LiquidityLine;
                     int zn;
                     bool LiquidityBool;
                     bool JustHit_;
                     bool LiquidityActive;
                     int Hit_int;
                     string PsychoHits;
                  datetime Time; //Time Printed
                  bool PatternDisplay; //Is Boxing of the Pattern Displayed?
   };
/*Variables*/
/*<--General Vars*/
bool FirstCandleProcess_ = false;
extern string TimeFrame = "15M";
extern float LiquidityRange = 3;
extern int Window = 100;   // Number of candles to scan
HCandles HCandles_[100]; 
int i = 0;
bool CandleInfoProcess_ = false;
bool CandleInfoDisplay_ = false;
/*<----Liquidity Sorter---->*/
bool LiquidityInfoProcess_ = false;
/*<--Conditions-->*/
bool Conditions_Complete = false;
/*<--Clean Up-->*/
static int cc = 0;
bool CleanUp = false;
void CPS(){
   while(i < Window)
   {
   if(i == 0){
      if(!CandleInfoProcess_){
      HCandles_[0].Time = MQLR_Bars(0, "Time");
      }
   }
   if(i < Window - 3 && i > 0){
      if(!CandleInfoProcess_){
         HCandles_[i].RCN = i;
         HCandles_[i].Close = iClose(_Symbol, PERIOD_CURRENT, i);
         HCandles_[i].Open = iOpen(_Symbol, PERIOD_CURRENT, i);
         HCandles_[i].High = iHigh(_Symbol, PERIOD_CURRENT, i);
         HCandles_[i].Low = iLow(_Symbol, PERIOD_CURRENT, i);
         HCandles_[i].Time = MQLR_Bars(i, "Time");
         HCandles_[i].Pattern = "";
         //Bullish or Bearish?
            if(HCandles_[i].Open < HCandles_[i].Close){
               HCandles_[i].CandleType = "Bullish";
            }
            else {
               HCandles_[i].CandleType = "Bearish";
            }
      }
      else if((CandleInfoProcess_ && !CandleInfoDisplay_) && i < Window - 1){
         //Pattern?
         //Bullish Engulfing
            if((HCandles_[i].Open < HCandles_[i + 1].Close
               || HCandles_[i].Open > HCandles_[i + 1].Close
               || HCandles_[i].Open == HCandles_[i + 1].Close)
               
            && HCandles_[i].Open > HCandles_[i + 1].Low 
            && HCandles_[i].Close > HCandles_[i + 1].Open
            && HCandles_[i].CandleType == "Bullish"
            && HCandles_[i + 1].CandleType == "Bearish"){
               if(!HCandles_[i].PatternDisplay){
                  HCandles_[i].Pattern = "Bullish Engulfing";
                  CPS_LiquidityThenPatternCheck(i, "Bullish Engulfing");
                  ObjectCreate(
                        _Symbol,
                        "Bullish Engulfing: " + i,
                        OBJ_RECTANGLE,
                        0,
                        HCandles_[i + 2].Time,
                        HCandles_[i].High,
                        HCandles_[i - 1].Time,
                        MathMin(HCandles_[i].Low, HCandles_[i + 1].Low)
                     );
                     //ObjectSetInteger(0,"Rectangle",OBJPROP_COLOR,clrBlue);
                     ObjectSetInteger(0,"Bullish Engulfing: " + i,OBJPROP_BACK,false);
                     ObjectSetInteger(0,"Bullish Engulfing: " + i,OBJPROP_COLOR,clrPink);
                     HCandles_[i].PatternDisplay = true;
               }
            }
            //Bearish Engulfing
            else if((HCandles_[i].Open > HCandles_[i + 1].Close
               || HCandles_[i].Open < HCandles_[i + 1].Close
               || HCandles_[i].Open == HCandles_[i + 1].Close)
            && HCandles_[i].Open < HCandles_[i + 1].High
            && HCandles_[i].Close < HCandles_[i + 1].Open
            && HCandles_[i].CandleType == "Bearish"
            && HCandles_[i + 1].CandleType == "Bullish"){
                  HCandles_[i].Pattern = "Bearish Engulfing";
                  
                  if(!HCandles_[i].PatternDisplay){
                  
                  CPS_LiquidityThenPatternCheck(i, HCandles_[i].Pattern);
                  ObjectCreate(
                        _Symbol,
                        "Bearish Engulfing: " + i,
                        OBJ_RECTANGLE,
                        0,
                        HCandles_[i + 2].Time,
                        MathMax(HCandles_[i].High, HCandles_[i + 1].High),
                        HCandles_[i - 1].Time,
                        HCandles_[i].Low
                     );
                     //ObjectSetInteger(0,"Rectangle",OBJPROP_COLOR,clrBlue);
                     ObjectSetInteger(0,"Bearish Engulfing: " + i,OBJPROP_BACK,false);
                     ObjectSetInteger(0,"Bearish Engulfing: " + i,OBJPROP_COLOR,clrCyan);
                     HCandles_[i].PatternDisplay = true;
               }
            }
            //Evening Star
            else if(HCandles_[i].CandleType == "Bearish"
            && HCandles_[i + 2].CandleType == "Bullish"
            
            && ((HCandles_[i].High < HCandles_[i + 1].High
            && HCandles_[i].Close < HCandles_[i + 2].Open
            && HCandles_[i + 1].Close > HCandles_[i + 2].Close)
            || 
               (HCandles_[i].High < HCandles_[i + 1].High
            && HCandles_[i + 2].Open < HCandles_[i].Open))){
            if(!HCandles_[i].PatternDisplay){
            
            HCandles_[i].Pattern = "Evening Star";
            CPS_LiquidityThenPatternCheck(i, "Evening Star");
                  ObjectCreate(
                        _Symbol,
                        "Evening Star: " + i,
                        OBJ_RECTANGLE,
                        0,
                        HCandles_[i + 3].Time,
                        MathMax(MathMax(HCandles_[i].High, HCandles_[i + 1].High), HCandles_[i + 2].High),
                        HCandles_[i - 1].Time,
                        MathMin(MathMin(HCandles_[i].Low, HCandles_[i + 1].Low), HCandles_[i + 2].Low)
                     );
                     //ObjectSetInteger(0,"Rectangle",OBJPROP_COLOR,clrBlue);
                     ObjectSetInteger(0,"Evening Star: " + i,OBJPROP_BACK,false);
                     ObjectSetInteger(0,"Evening Star: " + i,OBJPROP_COLOR,clrCyan);
                     HCandles_[i].PatternDisplay = true;
               }
            }
         //Morning
         else if(HCandles_[i].CandleType == "Bullish"
            && HCandles_[i + 2].CandleType == "Bearish"
            
            && ((HCandles_[i].High > HCandles_[i + 1].High
            && HCandles_[i + 1].Close < HCandles_[i + 2].Close)
            ||
               (HCandles_[i].High > HCandles_[i + 1].High
            && HCandles_[i + 2].Open > HCandles_[i].Open))){
            
            if(!HCandles_[i].PatternDisplay){
            /*Add a component to where the first candles doesnt not have to be longer than the third*/
            HCandles_[i].Pattern = "Morning Star";
            CPS_LiquidityThenPatternCheck(i, "Morning Star");
                  ObjectCreate(
                        _Symbol,
                        "Morning Star: " + i,
                        OBJ_RECTANGLE,
                        0,
                        HCandles_[i + 3].Time,
                        MathMax(MathMax(HCandles_[i].High, HCandles_[i + 1].High), HCandles_[i + 2].High),
                        HCandles_[i - 1].Time,
                        MathMin(MathMin(HCandles_[i].Low, HCandles_[i + 1].Low), HCandles_[i + 2].Low)
                     );
                     //ObjectSetInteger(0,"Rectangle",OBJPROP_COLOR,clrBlue);
                     ObjectSetInteger(0,"Morning Star: " + i,OBJPROP_BACK,false);
                     ObjectSetInteger(0,"Morning Star: " + i,OBJPROP_COLOR,clrPink);
                     HCandles_[i].PatternDisplay = true;
               }  
            }
            else HCandles_[i].Pattern = "N|A";
         }
         
      //Print("First Candle Time: " + MQLR_Bars(i + 1, "Time") + " || " + "Second: " + MQLR_Bars(i + 1, "Time"));
      }
      ++i;
   }
   if(i == Window || i > Window){
      i = 0;
      if(!CandleInfoProcess_) {
         Print("Candle Data: Loaded");
         CandleInfoProcess_ = true;
         Print("Checking");
      }
      else if(CandleInfoProcess_ & !CandleInfoDisplay_) {
         Print("Candle Data: Displayed");
         CandleInfoDisplay_ = true;
      }
   }
}
//Function that access the bars through MQLRates, then returns what is requested
double MQLR_Bars(int i, string Request){
   //Data Processing
   int HighestCandle, LowestCandle;
   
   double High[], Low[];
   
   ArraySetAsSeries(High, true);
   
   ArraySetAsSeries(Low, true);
   
   CopyHigh(_Symbol,PERIOD_CURRENT,0,Window,High);
   
   CopyLow(_Symbol,PERIOD_CURRENT,0,Window,Low);
   
   HighestCandle = ArrayMaximum(High,Window,0);
   LowestCandle = ArrayMinimum(Low,Window,0);
   
   MqlRates PriceInformation[];
   
   ArraySetAsSeries(PriceInformation, true);
   
   int Data = CopyRates(_Symbol, PERIOD_CURRENT, 0, Bars(_Symbol,PERIOD_CURRENT), PriceInformation);
   //Reuqest
   double return_;
   if(Request == "Time"){
      return_ = PriceInformation[i].time;
   }
   return return_;
}

void Liquidity(){
   if(!LiquidityInfoProcess_ && CandleInfoProcess_ && CandleInfoDisplay_){
      while(i < Window)
      {
         if(HCandles_[i].Pattern != ""){
            LSorter(i);
         }
         ++i;
      }
      if(i == Window || i > Window){
         i = 0;
         
            Print("Liquidity Data: Loaded");
            LiquidityInfoProcess_ = true;
      }
   }
}
//Determines the Line of Liquidity
void LSorter(int z) {
   double LiquidityLine;
   if(HCandles_[z].Pattern == "Morning Star"
   || HCandles_[z].Pattern == "Bullish Engulfing") {
      LiquidityLine = MathMin(MathMin(HCandles_[z].Low, HCandles_[z + 1].Low), HCandles_[z + 2].Low);
   }
   else if(HCandles_[z].Pattern == "Evening Star"
   || HCandles_[z].Pattern == "Bearish Engulfing") {
      LiquidityLine = MathMax(MathMax(HCandles_[z].High, HCandles_[z + 1].High), HCandles_[z + 2].High);
   }
   HCandles_[z].LiquidityLine = LiquidityLine;
}
int h = 0;
void LiquidityHit_Update(){
   int Liquid_int;
   for(h;h<Window;h++) {
      if((h - HCandles_[h].zn) <= h){
         if(HCandles_[h].Pattern == "Bullish Engulfing"
            || HCandles_[h].Pattern == "Bearish Engulfing"
            || HCandles_[h].Pattern == "Evening Star"
            || HCandles_[h].Pattern == "Morning Star"){
            for(HCandles_[h].zn;HCandles_[h].zn < h;HCandles_[h].zn++){
                //Print("T" + h);
                if(HCandles_[h].LiquidityLine < HCandles_[h - HCandles_[h].zn].High
                  && HCandles_[h].LiquidityLine > HCandles_[h - HCandles_[h].zn].Low) {
                     
                     if(!HCandles_[h].LiquidityBool) {
                        HCandles_[i].Hit_int = (h - HCandles_[h].zn);
                        HCandles_[h].LiquidityBool = true;
                     }
                }
            }
               
            }
      }
   }
   if(h == Window-1 || h > Window-1){
         h = 0;
   }
}
int ld = 0;
void LiquidityDisplay(){
string LineName;
   for(ld;ld<Window;ld++) {
      if(HCandles_[ld].Pattern == "Bullish Engulfing"
      || HCandles_[ld].Pattern == "Bearish Engulfing"
      || HCandles_[ld].Pattern == "Evening Star"
      || HCandles_[ld].Pattern == "Morning Star"){
      LineName = "Liquidity: " + HCandles_[ld].RCN;
      ObjectDelete(_Symbol, LineName);
         if(!HCandles_[ld].LiquidityBool && !HCandles_[ld].JustHit_) {
            ObjectCreate(_Symbol, LineName,
            OBJ_RECTANGLE, 0,
            HCandles_[ld].Time,
            HCandles_[ld].LiquidityLine + LiquidityRange,
            HCandles_[HCandles_[ld].Hit_int].Time,
            HCandles_[ld].LiquidityLine - LiquidityRange);
            ObjectSetInteger(0,LineName,OBJPROP_COLOR,clrRed);
            ObjectSetInteger(0,LineName,OBJPROP_BACK,false);
            HCandles_[ld].LiquidityActive = true;
         }
      }
   }
   if(ld == Window || ld > Window){
      ld = 0;
   }
}

/*Check for New Candles*/
static int LastCandleNumber;
int OnInit()
  {
   Init_Panel();
   LastCandleNumber = iBars(_Symbol,PERIOD_CURRENT);
   Print(_Symbol + " " + TimeFrame + " Started: " + TimeToString(TimeCurrent(),TIME_MINUTES));
   Alert(_Symbol + " " + TimeFrame + " Started: " + TimeToString(TimeCurrent(),TIME_MINUTES));
   SendNotification(_Symbol + " " + TimeFrame + " Started: " + TimeToString(TimeCurrent(),TIME_MINUTES));
   return(INIT_SUCCEEDED);
  }
void CheckForNewCandle(int CandleNumber) {
   if(CandleNumber > LastCandleNumber){
      //CandleInfoProcess_ = false;
         Print("New Candle");
         Conditions_N_Exe();
         CleanUp = true;
         LastCandleNumber = CandleNumber;
   }
}
void OnDeinit(const int reason) {
   OMB_E.Destroy(reason);
}
bool LiquidityHit_Fr_UpSide = false;
bool LiquidityHit_Fr_DownSide = false;
int c = 0;
int TL = 1;
void LiquidityCheck(){
   for(c;c<Window;c++) {
      if(HCandles_[c].Pattern == "Bullish Engulfing"
      || HCandles_[c].Pattern == "Bearish Engulfing"
      || HCandles_[c].Pattern == "Evening Star"
      || HCandles_[c].Pattern == "Morning Star"){
         if(HCandles_[c].LiquidityActive && !HCandles_[c].LiquidityBool && !HCandles_[c].JustHit_ 
         && HCandles_[c].Hit_int == 0){
            if(HCandles_[c].LiquidityLine < iHigh(_Symbol, PERIOD_CURRENT, 0)
            && HCandles_[c].LiquidityLine > iLow(_Symbol, PERIOD_CURRENT, 0)) {
               ObjectDelete(_Symbol, "Liquidity: " + HCandles_[c].RCN);
               ObjectCreate(_Symbol, "Taken Liquidity: " + TL,
               OBJ_RECTANGLE, 0,
               HCandles_[c].Time,
               HCandles_[c].LiquidityLine + LiquidityRange,
               HCandles_[0].Time,
               HCandles_[c].LiquidityLine - LiquidityRange);
               ObjectSetInteger(0,"Taken Liquidity: " + TL,OBJPROP_COLOR,clrOrange);
               ObjectSetInteger(0,"Taken Liquidity: " + TL,OBJPROP_BACK,false);
               TL++;
               Print("Liquidity Hit");
               if((HCandles_[c].LiquidityLine > iOpen(_Symbol, PERIOD_CURRENT, 0))
               && !LiquidityHit_Fr_DownSide) {
                  Print("Liquidity Hit From Down Side");
                  LiquidityHit_Fr_DownSide = true;
               }
               if((HCandles_[c].LiquidityLine < iOpen(_Symbol, PERIOD_CURRENT, 0))
               && !LiquidityHit_Fr_UpSide) {
                  Print("Liquidity Hit From Up Side");
                  LiquidityHit_Fr_UpSide = true;
               }
               HCandles_[c].JustHit_ = true;
            }
         }
      }
   }
   if(c == Window || c > Window){
      c = 0;
   }
}

/*LiquidityThenPatternCheck under the CPS, so this is being checked twice to make sure.*/
void CPS_LiquidityThenPatternCheck(int RCN, string Pattern) {
   if(RCN == 1){
   Print("CPS Pattern Detected");
      //Both(Neutral)
      if(Direction == "Both") {
         if(LiquidityHit_Fr_DownSide) {
            if(Pattern == "Bearish Engulfing" || Pattern == "Evening Star"){
               SendNotification(_Symbol + " " + TimeFrame + " <--Bearish Pattern-->");
               Alert(_Symbol + " " + TimeFrame + " <--Bearish Pattern-->");
               LiquidityHit_Fr_DownSide = false;
            }
         }
         if(LiquidityHit_Fr_UpSide){
            if(Pattern == "Morning Star" || Pattern == "Bullish Engulfing"){
               SendNotification(_Symbol + " " + TimeFrame + " <--Bullish Pattern-->");
               Alert(_Symbol + " " + TimeFrame + " <--Bullish Pattern-->");
               LiquidityHit_Fr_UpSide = false;
            }
         }
      }
      //Sell
      if(Direction == "Sell") {
         if(LiquidityHit_Fr_DownSide) {
            if(Pattern == "Bearish Engulfing" || Pattern == "Evening Star"){
               SendNotification(_Symbol + " " + TimeFrame + " <--Bearish Pattern-->");
               Alert(_Symbol + " " + TimeFrame + " <--Bearish Pattern-->");
               LiquidityHit_Fr_DownSide = false;
            }
         }
         if(Continue_) {
            if(Pattern == "Bearish Engulfing" || Pattern == "Evening Star"){
               SendNotification(_Symbol + " " + TimeFrame + " <--Bearish Pattern-->");
               Alert(_Symbol + " " + TimeFrame + " <--Bearish Pattern-->");
            }
         }
      }
      //Buy
      if(Direction == "Buy") {
         if(LiquidityHit_Fr_UpSide){
            if(Pattern == "Morning Star" || Pattern == "Bullish Engulfing"){
               SendNotification(_Symbol + " " + TimeFrame + " <--Bullish Pattern-->");
               Alert(_Symbol + " " + TimeFrame + " <--Bullish Pattern-->");
               LiquidityHit_Fr_UpSide = false;
            }
         }
         if(Continue_) {
            if(Pattern == "Morning Star" || Pattern == "Bullish Engulfing"){
               SendNotification(_Symbol + " " + TimeFrame + " <--Bullish Pattern-->");
               Alert(_Symbol + " " + TimeFrame + " <--Bullish Pattern-->");
            }
         }
      }
   }
}
string Direction = "";
bool Continue_ = false;
/*Directive Alerts Set*/
void OnChartEvent(const int EventID,      //Event Event ID
                  const long& lparam,     //long Event Parameter
                  const double& dparam,   //double Event Parameter
                  const string& sparam    //string Parameter
                  ) {
   if(EventID == CHARTEVENT_KEYDOWN) {
      short KeyThatWasPressed =TranslateKey((int)lparam);
      //Sell Set
      if(ShortToString(KeyThatWasPressed) == "s") {
         Direction = "Sell";
         Continue_ = false;
         SendNotification(_Symbol + " " + Direction + " Direction Set");
         MessageBox(_Symbol + " " + Direction + " Direction Set");
      }
      else if(ShortToString(KeyThatWasPressed) == "b") {
         Direction = "Buy";
         Continue_ = false;
         SendNotification(_Symbol + " " + Direction + " Direction Set");
         MessageBox(_Symbol + " " + Direction + " Direction Set");
      }
      else if(ShortToString(KeyThatWasPressed) == "n") {
         Direction = "Both";
         Continue_ = false;
         SendNotification(_Symbol + " " + Direction + " Direction Set");
         MessageBox(_Symbol + " " + Direction + " Direction Set");
      }
      else if(ShortToString(KeyThatWasPressed) == "o") {
         Direction = "";
         Continue_ = false;
         SendNotification(_Symbol + " Direction Set Off"); 
         MessageBox(_Symbol + " Direction Set Off"); 
      }
      if(ShortToString(KeyThatWasPressed) == "c" && !Continue_) {
         
         MessageBox(_Symbol + " " + "Continue Alerts On");
         Continue_ = true;
      }
      else if(ShortToString(KeyThatWasPressed) == "c" && Continue_) {
         
         MessageBox(_Symbol + " " + "Continue Alerts Off");
         Continue_ = false;
      }
      if(ShortToString(KeyThatWasPressed) == "w") {
         Alert("Window Opened");
      }
   }
   NeoChartEvent(EventID, lparam, dparam, sparam);
}
/*<--Conditions-->*/
void Conditions_N_Exe() {
//Print("Checking");
   Conditions_Complete = true;
}
void CleanUpDisplay(){
   while(cc < Window){
   if(HCandles_[cc].PatternDisplay) {
      //Print("Works: " + ObjectsTotal("AUDUSD",0));
      ObjectDelete(_Symbol, HCandles_[cc].Pattern + ": " + cc);
      ObjectDelete(_Symbol, "Liquidity: " + HCandles_[cc].RCN);
      HCandles_[cc].LiquidityLine = NULL;
      HCandles_[cc].PatternDisplay = false;
      HCandles_[cc].RCN = NULL;
      HCandles_[cc].High = NULL;
      HCandles_[cc].Low = NULL;
      HCandles_[cc].Open = NULL;
      HCandles_[cc].Close = NULL;
      HCandles_[cc].CandleType = "";
      HCandles_[cc].Pattern = "";
      HCandles_[cc].zn = NULL;
      HCandles_[cc].LiquidityBool = false;
      HCandles_[cc].Hit_int = NULL;
      HCandles_[cc].Time = NULL;
      HCandles_[cc].LiquidityActive = false;
      HCandles_[cc].JustHit_ = false;
   }
   cc++;
   }
   if(cc == Window || cc > Window){
      Print("Clean Up");
      cc = 0;
      i = 0;
      Conditions_Complete = false;
      LiquidityInfoProcess_ = false;
      CandleInfoProcess_ = false;
      CandleInfoDisplay_ = false;
      CleanUp = false;
   }
}
//Pattern Pre Timer
struct TimeFractor {
   string TimeFrame;
   //00:11
   int PointInTimes_mm[];
   //11:00
   int PointInTimes_hh[];
};
TimeFractor TF_PIT[4];
void TimeSettings(){
//0 = 5M, 1 = 15M, 2 = 4H, 3
   //5M
      //Minute
      ArrayResize(TF_PIT[0].PointInTimes_mm, 4);
      TF_PIT[0].PointInTimes_mm[0] = 3;
      TF_PIT[0].PointInTimes_mm[1] = 4;
      TF_PIT[0].PointInTimes_mm[2] = 8;
      TF_PIT[0].PointInTimes_mm[3] = 9;
   //15M
      //Minute
      ArrayResize(TF_PIT[1].PointInTimes_mm, 8);
      TF_PIT[1].PointInTimes_mm[0] = 13;
      TF_PIT[1].PointInTimes_mm[1] = 14;
      TF_PIT[1].PointInTimes_mm[2] = 28;
      TF_PIT[1].PointInTimes_mm[3] = 29;
      TF_PIT[1].PointInTimes_mm[0] = 43;
      TF_PIT[1].PointInTimes_mm[1] = 44;
      TF_PIT[1].PointInTimes_mm[2] = 28;
      TF_PIT[1].PointInTimes_mm[3] = 29;
   //4H
      //Minute
      ArrayResize(TF_PIT[2].PointInTimes_mm, 4);
      TF_PIT[2].PointInTimes_mm[0] = 56;
      TF_PIT[2].PointInTimes_mm[1] = 57;
      TF_PIT[2].PointInTimes_mm[2] = 58;
      TF_PIT[2].PointInTimes_mm[3] = 59;
      //Hour
      ArrayResize(TF_PIT[2].PointInTimes_hh, 6);
      TF_PIT[2].PointInTimes_hh[0] = 03;
      TF_PIT[2].PointInTimes_hh[1] = 07;
      TF_PIT[2].PointInTimes_hh[2] = 11;
      TF_PIT[2].PointInTimes_hh[3] = 15;
      TF_PIT[2].PointInTimes_hh[4] = 19;
      TF_PIT[2].PointInTimes_hh[5] = 23;
   //30M
      //Minute
      ArrayResize(TF_PIT[3].PointInTimes_mm, 4);
      TF_PIT[3].PointInTimes_mm[0] = 28;
      TF_PIT[3].PointInTimes_mm[1] = 29;
      TF_PIT[3].PointInTimes_mm[2] = 58;
      TF_PIT[3].PointInTimes_mm[3] = 59;
}

bool timeLock = false;
int CurrentPIT;
void TimeCheck(){
   if(!timeLock){
      if(TimeFrame == "5M"){
         _5M();
      }
      else if(TimeFrame == "15M") {
         _15M();
      }
      else if(TimeFrame == "4H") {
         _4H();
      }
      else if(TimeFrame == "30M") {
         _30M();
      }
      timeLock = true;
   }
   if(timeLock){
      if(CurrentPIT != PointInTime_m()){
         timeLock = false;
      }
   } 
} 
//Seperate Functions that will Check PointInTimes Per TimeFrame
int TF5 = 0;
void _5M(){
   for(TF5;TF5<ArraySize(TF_PIT[0].PointInTimes_mm);TF5++) {
      if(PointInTime_mm() == TF_PIT[0].PointInTimes_mm[TF5]) {
         Print(TF_PIT[0].TimeFrame);
         Print(TF_PIT[0].PointInTimes_mm[TF5]);
         PlaySound ("alert2.wav");
         SendNotification("<!$$!> " + _Symbol + " " + TimeFrame + " Possible Pattern");
         CurrentPIT = PointInTime_m();
         timeLock = true;
      }
   }
   if(TF5 == ArraySize(TF_PIT[0].PointInTimes_mm)-1 || TF5 > ArraySize(TF_PIT[0].PointInTimes_mm)-1){
         TF5 = 0;
   }
}
int TF15 = 0;
void _15M(){
   for(TF15;TF15<ArraySize(TF_PIT[1].PointInTimes_mm);TF15++) {
      if(PointInTime_m() == TF_PIT[1].PointInTimes_mm[TF15]) {
         Print(TF_PIT[1].TimeFrame);
         Print(TF_PIT[1].PointInTimes_mm[TF15]);
         PlaySound ("alert2.wav");
         SendNotification("<!$$!> " + _Symbol + " " + TimeFrame + " Possible Pattern");
         CurrentPIT = PointInTime_m();
         timeLock = true;
      }
   }
   if(TF15 == ArraySize(TF_PIT[1].PointInTimes_mm)-1 || TF15 > ArraySize(TF_PIT[1].PointInTimes_mm)-1){
         TF15 = 0;
   }
}
int TF30 = 0;
void _30M(){
   for(TF30;TF30<ArraySize(TF_PIT[3].PointInTimes_mm);TF30++) {
      if(PointInTime_m() == TF_PIT[3].PointInTimes_mm[TF30]) {
         Print(TF_PIT[3].TimeFrame);
         Print(TF_PIT[3].PointInTimes_mm[TF30]);
         PlaySound ("alert2.wav");
         SendNotification("<!$$!> " + _Symbol + " " + TimeFrame + " Possible Pattern");
         CurrentPIT = PointInTime_m();
         timeLock = true;
      }
   }
   if(TF30 == ArraySize(TF_PIT[3].PointInTimes_mm)-1 || TF30 > ArraySize(TF_PIT[3].PointInTimes_mm)-1){
         TF30 = 0;
   }
} 
int TF4_hh = 0;
int TF4_mm = 0;
void _4H(){
   for(TF4_hh;TF4_hh<ArraySize(TF_PIT[2].PointInTimes_hh);TF4_hh++) {
      if(PointInTime_hh() == TF_PIT[2].PointInTimes_hh[TF4_hh]) {
         _4H_mm();
      }
   }
   if(TF4_hh == ArraySize(TF_PIT[2].PointInTimes_hh)-1 || TF4_hh > ArraySize(TF_PIT[2].PointInTimes_hh)-1){
         TF4_hh = 0;
   }
}
void _4H_mm(){
   for(TF4_mm;TF4_mm<ArraySize(TF_PIT[2].PointInTimes_mm);TF4_mm++) {
      if(PointInTime_m() == TF_PIT[2].PointInTimes_mm[TF4_mm]) {
            Print(TF_PIT[2].TimeFrame);
            Print(PointInTime_m());
            PlaySound ("alert2.wav");
            SendNotification("<!$$!> " + _Symbol + " " + TimeFrame + " Possible Pattern");
            CurrentPIT = PointInTime_m();
            timeLock = true;
      }
   }
   if(TF4_mm == ArraySize(TF_PIT[2].PointInTimes_mm)-1 || TF4_mm > ArraySize(TF_PIT[2].PointInTimes_mm)-1){
         TF4_mm = 0;
   }
}
//Functions that check specific parts of time
//00:01 (Mainly for 5M)
int PointInTime_mm(){
   string Time = "" + TimeToString(TimeCurrent(),TIME_MINUTES);
   string PointInTime_str = StringSubstr(Time,4,3);
   int PointInTime_int = StringToInteger(PointInTime_str);
   return PointInTime_int;
}
//00:11 (Mainly for 15M)
int PointInTime_m(){
   string Time = "" + TimeToString(TimeCurrent(),TIME_MINUTES);
   string PointInTime_str = StringSubstr(Time,3,2);
   int PointInTime_int = StringToInteger(PointInTime_str);
   return PointInTime_int;
}
//11:11 (Mainly for 4H)
int PointInTime_hh(){
   string Time = "" + TimeToString(TimeCurrent(),TIME_MINUTES);
   string PointInTime_str = StringSubstr(Time,0,2);
   int PointInTime_int = StringToInteger(PointInTime_str);
   return PointInTime_int;
}
//Pattern Preparer
HCandles AC_Candles[3]; 
void CandleInfo(int RCN){
//Get Open and Close Info
   AC_Candles[RCN].Close = iClose(_Symbol, PERIOD_CURRENT, RCN);
   AC_Candles[RCN].Open = iOpen(_Symbol, PERIOD_CURRENT, RCN);
   AC_Candles[RCN].High = iHigh(_Symbol, PERIOD_CURRENT, RCN);
   AC_Candles[RCN].Low = iLow(_Symbol, PERIOD_CURRENT, RCN);
//Determine Candle Type
//Bullish or Bearish?
            if(AC_Candles[RCN].Open < AC_Candles[RCN].Close){
               AC_Candles[RCN].CandleType = "Bullish";
            }
            else {
               AC_Candles[RCN].CandleType = "Bearish";
            }
}
static int cCalc = 0;
void CandleCalculations(){
   //Pattern? (PcCalced Patterned)
         if(LiquidityHit_Fr_UpSide) {
            if(Direction == "Buy" || Direction == "Both") {
            //Bullish Engulfing
               if((AC_Candles[cCalc].Open < AC_Candles[cCalc + 1].Close
                  || AC_Candles[cCalc].Open > AC_Candles[cCalc + 1].Close
                  || AC_Candles[cCalc].Open == AC_Candles[cCalc + 1].Close)
                  
               && AC_Candles[cCalc].Open > AC_Candles[cCalc + 1].Low 
               && AC_Candles[cCalc].Close > AC_Candles[cCalc + 1].Open
               && AC_Candles[cCalc].CandleType == "Bullish"
               && AC_Candles[cCalc + 1].CandleType == "Bearish"){
                  Pattern_OMB_E = "Bullish Engulfing";
                  TimeCheck();
               }
            //Morning
               else if(AC_Candles[cCalc].CandleType == "Bullish"
               && AC_Candles[cCalc + 2].CandleType == "Bearish"
               
               && ((AC_Candles[cCalc].High > AC_Candles[cCalc + 1].High
               && AC_Candles[cCalc + 1].Close < AC_Candles[cCalc + 2].Close)
               ||
                  (AC_Candles[cCalc].High > AC_Candles[cCalc + 1].High
               && AC_Candles[cCalc + 2].Open > AC_Candles[cCalc].Open))){
                  Pattern_OMB_E = "Morning Star";
                  TimeCheck();
               }
            }
         }
         if(LiquidityHit_Fr_DownSide) {
            if(Direction == "Sell" || Direction == "Both") {
            //Bearish Engulfing
               if((AC_Candles[cCalc].Open > AC_Candles[cCalc + 1].Close
                  || AC_Candles[cCalc].Open < AC_Candles[cCalc + 1].Close
                  || AC_Candles[cCalc].Open == AC_Candles[cCalc + 1].Close)
               && AC_Candles[cCalc].Open < AC_Candles[cCalc + 1].High
               && AC_Candles[cCalc].Close < AC_Candles[cCalc + 1].Open
               && AC_Candles[cCalc].CandleType == "Bearish"
               && AC_Candles[cCalc + 1].CandleType == "Bullish"){
                  Pattern_OMB_E = "Bearish Engulfing";
                  TimeCheck();
               }
            //Evening Star
               else if(AC_Candles[cCalc].CandleType == "Bearish"
               && AC_Candles[cCalc + 2].CandleType == "Bullish"
               
               && ((AC_Candles[cCalc].High < AC_Candles[cCalc + 1].High
               && AC_Candles[cCalc].Close < AC_Candles[cCalc + 2].Open
               && AC_Candles[cCalc + 1].Close > AC_Candles[cCalc + 2].Close)
               || 
                  (AC_Candles[cCalc].High < AC_Candles[cCalc + 1].High
               && AC_Candles[cCalc + 2].Open < AC_Candles[cCalc].Open))){
                  Pattern_OMB_E = "Evening Star";
                  TimeCheck();
               }
            }
         }
         
}
void ActivePreChecker(){
//Get Info of First 3 Candles
  CandleInfo(0);
  CandleInfo(1);
  CandleInfo(2);
  
//Use Calculations & Predict
CandleCalculations();
}
//Liquidity Hit & Pre Pattern Checker
void LH_PatternPreChecker(){
   if(LiquidityHit_Fr_DownSide || LiquidityHit_Fr_UpSide) {
      ActivePreChecker();
   }
}
void OnTick(){
   TimeSettings();
   LH_PatternPreChecker();
   CPS();
   Liquidity();
   if(LiquidityInfoProcess_ && CandleInfoProcess_ && CandleInfoDisplay_ && !CleanUp){
      int CandleNumber = iBars(_Symbol,PERIOD_CURRENT);
      CheckForNewCandle(CandleNumber);
      LiquidityHit_Update();
      LiquidityDisplay();
      LiquidityCheck();
   }
   else if(LiquidityInfoProcess_ && CandleInfoProcess_ && CandleInfoDisplay_ && CleanUp && Conditions_Complete){
      CleanUpDisplay();
    }
    PatternCheck();
    PanelDisplayUpdate();
    /* <<<!!! IMPORTANT !!!>>>
    Comment("Keyboard Buttons \n" + 
    "W = Open Alert Window \n" +
    "N = Neutral (Both Directions) \n" +
    "B = Buy (Bullish Direction) \n" +
    "S = Sell (Bearish Direction)\n" +
    "O = Off (Direction Alert Off)");*/
}
#include <Controls\Dialog.mqh>
#include <Controls\Button.mqh>
#include <Controls\Edit.mqh>
#include <Controls\Label.mqh>

#define INDENT_LEFT (11)
#define INDENT_TOP (1)
#define CONTROLS_GAPS_X (5)
#define BUTTON_WIDTH (100)
#define BUTTON_HEIGHT (20)

CAppDialog OMB_E;
CButton Bull_Button;
CButton Bear_Button;
CLabel Pervious30M_Swing;

CLabel ConsolidationRange_Label;
CEdit TopRange_Edit;
CEdit BottomRange_Edit;

CLabel Overprice_Label;
CEdit OverboughtP_Edit;
CEdit OversoldP_Edit;

CButton WorkReset_Button;

CLabel VPA_Label;
CButton VPA_Toggle;
CLabel ChoppyPattern_Label;
CButton ChoppyPattern_Button;

CLabel TCL_Label;

void Init_Panel() {
   if(!OMB_E.Create(0, "O(M).Brain Execution",0,20,20,360,424))
      return(INIT_FAILED);
   //Swing Button Toggle
   if(!CreateBull_Button())
      return(false);
   if(!CreateBear_Button())
      return(false);
   if(!OMB_E.Add(Bull_Button))
      return(false);
   if(!OMB_E.Add(Bear_Button))
      return(false);
   if(!Create_Pervious30M_Swing())
      return(false);
   if(!OMB_E.Add(Pervious30M_Swing))
      return(false);
   //Consolidation Range
   if(!Create_ConsolidationRange_Label())
      return(false);
   if(!OMB_E.Add(ConsolidationRange_Label))
      return(false);
   if(!Create_TopRange_Edit())
      return(false);
   if(!OMB_E.Add(TopRange_Edit))
      return(false);
   if(!Create_BottomRange_Edit())
      return(false);
   if(!OMB_E.Add(BottomRange_Edit))
      return(false);
   
   if(!Create_Overprice_Label())
      return(false);
   if(!OMB_E.Add(Overprice_Label))
      return(false);
   if(!Create_OverboughtP_Edit())
      return(false);
   if(!OMB_E.Add(OverboughtP_Edit))
      return(false);
   if(!Create_OversoldP_Edit())
      return(false);
   if(!OMB_E.Add(OversoldP_Edit))
      return(false);
   //Work Reset
   if(!CreateWorkReset_Button())
      return(false);
   if(!OMB_E.Add(WorkReset_Button))
      return(false);
   //VPA & Choppy Pattern
   if(!Create_VPA_Label())
      return(false);
   if(!OMB_E.Add(VPA_Label))
      return(false);
   if(!CreateVPA_Toggle())
      return(false);
   if(!OMB_E.Add(VPA_Toggle))
      return(false);
      
   if(!Create_ChoppyPattern_Label())
      return(false);
   if(!OMB_E.Add(ChoppyPattern_Label))
      return(false);
   if(!CreateChoppyPattern_Button())
      return(false);
   if(!OMB_E.Add(ChoppyPattern_Button))
      return(false);
      
   //TCL
   if(!Create_TCL_Label())
      return(false);
   if(!OMB_E.Add(TCL_Label))
      return(false);
}
bool CreateBull_Button(void) {
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP + 20;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
   
   if(!Bull_Button.Create(0, "Bull", 0,x1,y1,x2,y2))
      return(false);
   if(!Bull_Button.Text("Bull"))
      return(false);
   if(!Bull_Button.ColorBackground(clrLime))
      return(false);
   if(!OMB_E.Add(Bull_Button))
      return(false);
      
   return(true);
}
bool CreateBear_Button(void) {
   int x1=INDENT_LEFT+ 156;
   int y1=INDENT_TOP + 20;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
   
   if(!Bear_Button.Create(0, "Bear", 0,x1,y1,x2,y2))
      return(false);
   if(!Bear_Button.Text("Bear"))
      return(false);
   if(!Bear_Button.ColorBackground(clrRed))
      return(false);
   if(!Bear_Button.Color(clrWhite))
      return(false);
   if(!OMB_E.Add(Bear_Button))
      return(false);
   
      
   return(true);
}
bool Create_Pervious30M_Swing(void) {
   int x1=INDENT_LEFT + 60;
   int y1=INDENT_TOP;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
   
   if(!Pervious30M_Swing.Create(0, "Previous 30M Swing", 0,x1,y1,x2,y2))
      return(false);
   if(!Pervious30M_Swing.Text("<<Previous 30M Swing>>"))
      return(false);
   if(!OMB_E.Add(Pervious30M_Swing))
      return(false);
      
   return(true);
}
bool Create_ConsolidationRange_Label(void) {
   int x1=INDENT_LEFT + 60;
   int y1=INDENT_TOP + 40;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
   
   if(!ConsolidationRange_Label.Create(0, "Consolidation Range", 0,x1,y1,x2,y2))
      return(false);
   if(!ConsolidationRange_Label.Text("<<Consolidation Range>>"))
      return(false);
   if(!OMB_E.Add(ConsolidationRange_Label))
      return(false);
      
   return(true);
}
bool Create_TopRange_Edit(void) {
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP + 60;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
   if(!TopRange_Edit.Create(0, "Top Range", 0,x1,y1,x2,y2))
      return(false);
   if(!TopRange_Edit.Text("Top Range"))
      return(false);
   if(!TopRange_Edit.TextAlign(ALIGN_LEFT))
      return(false);
   if(!OMB_E.Add(TopRange_Edit))
      return(false);
      
   return(true);
}
bool Create_BottomRange_Edit(void) {
   int x1=INDENT_LEFT + 156;
   int y1=INDENT_TOP + 60;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
   if(!BottomRange_Edit.Create(0, "Bottom Range", 0,x1,y1,x2,y2))
      return(false);
   if(!BottomRange_Edit.Text("Bottom Range"))
      return(false);
   if(!BottomRange_Edit.TextAlign(ALIGN_LEFT))
      return(false);
   if(!OMB_E.Add(BottomRange_Edit))
      return(false);
      
   return(true);
}
bool Create_Overprice_Label(void) {
   int x1=INDENT_LEFT + 60;
   int y1=INDENT_TOP + 80;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
   
   if(!Overprice_Label.Create(0, "Overprice Point", 0,x1,y1,x2,y2))
      return(false);
   if(!Overprice_Label.Text("<<OverPrice Points>>"))
      return(false);
   if(!OMB_E.Add(Overprice_Label))
      return(false);
      
   return(true);
}
bool Create_OverboughtP_Edit(void) {
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP + 100;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
   if(!OverboughtP_Edit.Create(0, "Overbought Point", 0,x1,y1,x2,y2))
      return(false);
   if(!OverboughtP_Edit.Text("Overbought"))
      return(false);
   if(!OverboughtP_Edit.TextAlign(ALIGN_LEFT))
      return(false);
   if(!OMB_E.Add(OverboughtP_Edit))
      return(false);
      
   return(true);
}
bool Create_OversoldP_Edit(void) {
   int x1=INDENT_LEFT + 156;
   int y1=INDENT_TOP + 100;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
   if(!OversoldP_Edit.Create(0, "Oversold Point", 0,x1,y1,x2,y2))
      return(false);
   if(!OversoldP_Edit.Text("Oversold Point"))
      return(false);
   if(!OversoldP_Edit.TextAlign(ALIGN_LEFT))
      return(false);
   if(!OMB_E.Add(OversoldP_Edit))
      return(false);
      
   return(true);
}
bool CreateWorkReset_Button(void) {
   int x1=INDENT_LEFT + 80;
   int y1=INDENT_TOP + 130;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
   
   if(!WorkReset_Button.Create(0, "Work Reset", 0,x1,y1,x2,y2))
      return(false);
   if(!WorkReset_Button.Text("Work Reset"))
      return(false);
   if(!WorkReset_Button.ColorBackground(clrPurple))
      return(false);
   if(!WorkReset_Button.Color(clrWhite))
      return(false);
   if(!OMB_E.Add(WorkReset_Button))
      return(false);
      
   return(true);
}
bool Create_VPA_Label(void) {
   int x1=INDENT_LEFT + 100;
   int y1=INDENT_TOP + 150;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
   
   if(!VPA_Label.Create(0, "VPA", 0,x1,y1,x2,y2))
      return(false);
   if(!VPA_Label.Text("??VPA??"))
      return(false);
   if(!OMB_E.Add(VPA_Label))
      return(false);
      
   return(true);
}
bool CreateVPA_Toggle(void) {
   int x1=INDENT_LEFT + 80;
   int y1=INDENT_TOP + 170;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
   
   if(!VPA_Toggle.Create(0, "VPA Toggle", 0,x1,y1,x2,y2))
      return(false);
   if(!VPA_Toggle.Text("None"))
      return(false);
   if(!VPA_Toggle.ColorBackground(clrCoral))
      return(false);
   if(!VPA_Toggle.Color(clrWhite))
      return(false);
   if(!OMB_E.Add(VPA_Toggle))
      return(false);
      
   return(true);
}
bool Create_ChoppyPattern_Label(void) {
   int x1=INDENT_LEFT + 80;
   int y1=INDENT_TOP + 190;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
   
   if(!ChoppyPattern_Label.Create(0, "Choppy Pattern Label", 0,x1,y1,x2,y2))
      return(false);
   if(!ChoppyPattern_Label.Text("??Choppy Pattern??"))
      return(false);
   if(!OMB_E.Add(ChoppyPattern_Label))
      return(false);
      
   return(true);
}
bool CreateChoppyPattern_Button(void) {
   int x1=INDENT_LEFT + 80;
   int y1=INDENT_TOP + 210;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
   
   if(!ChoppyPattern_Button.Create(0, "Choppy Pattern Button", 0,x1,y1,x2,y2))
      return(false);
   if(!ChoppyPattern_Button.Text("None"))
      return(false);
   if(!ChoppyPattern_Button.ColorBackground(clrCoral))
      return(false);
   if(!ChoppyPattern_Button.Color(clrWhite))
      return(false);
   if(!OMB_E.Add(ChoppyPattern_Button))
      return(false);
      
   return(true);
}
bool Create_TCL_Label(void) {
   int x1=INDENT_LEFT + 35;
   int y1=INDENT_TOP + 250;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
   
   if(!TCL_Label.Create(0, "TCL_Label", 0,x1,y1,x2,y2))
      return(false);
   if(!TCL_Label.Text("[Pattern]: " + "??" + "[TCL]: " + "??"))
      return(false);
   if(!OMB_E.Add(TCL_Label))
      return(false);
      
   return(true);
}
double VPA = 0;
string Pre30Swing = "";
int VPA_Toggle_int = 0;

int ChoppyP_int = 0;
double ChoppyP = 0;

double TopRange_double;
double BottomRange_double;
double OversoldPoint;
double OverboughtPoint;

int LiquidityPoint = 0;

int SwingCorrelationPoint = 0;

string Pattern_OMB_E;

void NeoChartEvent(const int id,
                  const long& lparam,
                  const double& dparam,
                  const string& sparam) {
   OMB_E.ChartEvent(id,lparam,dparam,sparam);
   if(id==CHARTEVENT_OBJECT_CLICK){
      if(sparam=="Bull"){
         Pre30Swing = "Bullish";
         PanelDisplayUpdate();
         Print("Previous 30M Swing: Bull");
      }
      if(sparam=="Bear"){
         Pre30Swing = "Bearish";
         PanelDisplayUpdate();
         Print("Previous 30M Swing: Bear");
      }
      if(sparam=="Work Reset"){
         ConsolidationDisplay();
         PanelDisplayUpdate();
         Print("Swing and Consolidation Range Reset");
      }
      if(sparam=="VPA Toggle"){
         VPA_ToggleFunc(VPA_Toggle_int);
         PanelDisplayUpdate();
      }
      if(sparam=="Choppy Pattern Button"){
         ChoppyP_ToggleFunc(ChoppyP_int);
         PanelDisplayUpdate();
      }
   }
   if(id==CHARTEVENT_OBJECT_ENDEDIT){
      if(sparam=="Top Range") {
         TopRange_double = TopRange_Edit.Text();
         PanelDisplayUpdate();
      }
      if(sparam=="Bottom Range") {
         BottomRange_double = BottomRange_Edit.Text();
         PanelDisplayUpdate();
      }
      if(sparam=="Oversold Point") {
         OversoldPoint = OversoldP_Edit.Text();
         PanelDisplayUpdate();
      }
      if(sparam=="Overbought Point") {
         OverboughtPoint = OverboughtP_Edit.Text();
         PanelDisplayUpdate();
      }
   } 
}
void VPA_ToggleFunc(int i) {
/*
0 = Steady
1 = S-Volatile
2 = Volatile
3 = Exhuastion
*/
   if(i == 0) {
      VPA_Toggle.Text("Steady");
      VPA = 0;
   }
   else if(i == 1) {
      VPA_Toggle.Text("S-Volatile");
      VPA = 2;
   }
   else if(i == 2) {
      VPA_Toggle.Text("Volatile");
      VPA = 3;
   }
   else if(i == 3) {
      VPA_Toggle.Text("Exhuastion");
      VPA = -5;
      VPA_Toggle_int = -1;
   }
   VPA_Toggle_int++;
}
void ChoppyP_ToggleFunc(int i) {
/*
0 = Choppy
1 = Not
*/
   if(i == 0) {
      ChoppyPattern_Button.Text("Choppy");
      ChoppyP = 0;
   }
   else if(i == 1) {
      ChoppyPattern_Button.Text("Not");
      ChoppyP_int = -1;
      ChoppyP = 2;
   }
   ChoppyP_int++;
}
void ConsolidationDisplay() {
   //Top Consolidation
   string TopRange_LN = "Top Range";
   ObjectDelete(_Symbol, TopRange_LN);
   ObjectCreate(_Symbol, TopRange_LN, OBJ_HLINE,0,HCandles_[0].Time, TopRange_double);
   ObjectSetInteger(0,TopRange_LN,OBJPROP_COLOR,clrPurple);
   string OverboughtP_LN = "Overbought Point";
   ObjectDelete(_Symbol, OverboughtP_LN);
   ObjectCreate(_Symbol, OverboughtP_LN, OBJ_HLINE,0,NULL, OverboughtPoint);
   ObjectSetInteger(0,OverboughtP_LN,OBJPROP_COLOR,clrPurple);
   //Bottom Consolidation
   string BottomRange_LN = "Bottom Range";
   ObjectDelete(_Symbol, BottomRange_LN);
   ObjectCreate(_Symbol, BottomRange_LN, OBJ_HLINE,0,HCandles_[0].Time, BottomRange_double);
   ObjectSetInteger(0,BottomRange_LN,OBJPROP_COLOR,clrPurple);
   string OversoldP_LN = "Oversold Point";
   ObjectDelete(_Symbol, OversoldP_LN);
   ObjectCreate(_Symbol, OversoldP_LN, OBJ_HLINE,0,HCandles_[0].Time, OversoldPoint);
   ObjectSetInteger(0,OversoldP_LN,OBJPROP_COLOR,clrPurple);
   
}

string IsOverPrice(double Price_) {
   double Price = iClose(_Symbol, PERIOD_CURRENT, 0);
   string result = "";
   if(Price_ == NULL) {
      if(Price >= OverboughtP_Edit.Text()) {
         result = "Overbought";
      }
      else if(Price <= OversoldP_Edit.Text()) {
         result = "Oversold";
      }
   }
   else if(Price_ != NULL) {
       if(Price_ >= OverboughtP_Edit.Text()) {
         result = "Overbought";
      }
      else if(Price_ <= OversoldP_Edit.Text()) {
         result = "Oversold";
      }
   }
   return result;
}
int OverPrice_int;
void IFOverPriced(string PatternDir) {
      if(PatternDir == "Bullish") {
         if(MathMin(MathMin(iLow(_Symbol, PERIOD_CURRENT, 0), iLow(_Symbol, PERIOD_CURRENT, 1)), iLow(_Symbol, PERIOD_CURRENT, 2)) < OversoldPoint) {
            OverPrice_int = 1;
         }
         else {
            OverPrice_int = 0;
         }
      }
      else if(PatternDir == "Bearish") {
         if(MathMax(MathMax(iHigh(_Symbol, PERIOD_CURRENT, 0), iHigh(_Symbol, PERIOD_CURRENT, 1)), iHigh(_Symbol, PERIOD_CURRENT, 3)) > OverboughtPoint) {
            OverPrice_int = 1;
         }
         else {
            OverPrice_int = 0;
         }
      }
}

void LiquidityPointCheck(string PatternDir) {
   if(PatternDir == "Bearish") {
      if(LiquidityHit_Fr_DownSide) {
         LiquidityPoint = 1;
      }
      else if(!LiquidityHit_Fr_DownSide) {
         LiquidityPoint = 0;
      }
   }
   else if(PatternDir == "Bullish") {
      if(LiquidityHit_Fr_UpSide) {
         LiquidityPoint = 1;
      }
      else if(!LiquidityHit_Fr_UpSide) {
         LiquidityPoint = 0;
      }
   }
}

void SwingCorrelationCheck(string PatternDir) {
   if(PatternDir == Pre30Swing) {
      SwingCorrelationPoint = 1;
   }
   else if(PatternDir != Pre30Swing) {
      SwingCorrelationPoint = 0;
   }
}
void PatternCheck() {
            //Bullish Engulfing
               if((AC_Candles[cCalc].Open < AC_Candles[cCalc + 1].Close
                  || AC_Candles[cCalc].Open > AC_Candles[cCalc + 1].Close
                  || AC_Candles[cCalc].Open == AC_Candles[cCalc + 1].Close)
                  
               && AC_Candles[cCalc].Open > AC_Candles[cCalc + 1].Low 
               && AC_Candles[cCalc].Close > AC_Candles[cCalc + 1].Open
               && AC_Candles[cCalc].CandleType == "Bullish"
               && AC_Candles[cCalc + 1].CandleType == "Bearish"){
                  IFOverPriced("Bullish");
                  LiquidityPointCheck("Bullish");
                  SwingCorrelationCheck("Bullish");
               }
            //Morning
               else if(AC_Candles[cCalc].CandleType == "Bullish"
               && AC_Candles[cCalc + 2].CandleType == "Bearish"
               
               && ((AC_Candles[cCalc].High > AC_Candles[cCalc + 1].High
               && AC_Candles[cCalc + 1].Close < AC_Candles[cCalc + 2].Close)
               ||
                  (AC_Candles[cCalc].High > AC_Candles[cCalc + 1].High
               && AC_Candles[cCalc + 2].Open > AC_Candles[cCalc].Open))){
                  IFOverPriced("Bullish");
                  LiquidityPointCheck("Bullish");
                  SwingCorrelationCheck("Bullish");
               }
            //Bearish Engulfing
               if((AC_Candles[cCalc].Open > AC_Candles[cCalc + 1].Close
                  || AC_Candles[cCalc].Open < AC_Candles[cCalc + 1].Close
                  || AC_Candles[cCalc].Open == AC_Candles[cCalc + 1].Close)
               && AC_Candles[cCalc].Open < AC_Candles[cCalc + 1].High
               && AC_Candles[cCalc].Close < AC_Candles[cCalc + 1].Open
               && AC_Candles[cCalc].CandleType == "Bearish"
               && AC_Candles[cCalc + 1].CandleType == "Bullish"){
                  IFOverPriced("Bearish");
                  LiquidityPointCheck("Bearish");
                  SwingCorrelationCheck("Bearish");
               }
            //Evening Star
               else if(AC_Candles[cCalc].CandleType == "Bearish"
               && AC_Candles[cCalc + 2].CandleType == "Bullish"
               
               && ((AC_Candles[cCalc].High < AC_Candles[cCalc + 1].High
               && AC_Candles[cCalc].Close < AC_Candles[cCalc + 2].Open
               && AC_Candles[cCalc + 1].Close > AC_Candles[cCalc + 2].Close)
               || 
                  (AC_Candles[cCalc].High < AC_Candles[cCalc + 1].High
               && AC_Candles[cCalc + 2].Open < AC_Candles[cCalc].Open))){
                  IFOverPriced("Bearish");
                  LiquidityPointCheck("Bearish");
                  SwingCorrelationCheck("Bearish");
               }
}

double CalculateTCL() {
   double TCL;
   TCL = SwingCorrelationPoint + LiquidityPoint + OverPrice_int + ChoppyP + VPA;
   return TCL;
}
void PanelDisplayUpdate() {
   TCL_Label.Text("[Pattern]: " + Pattern_OMB_E + " [TCL]: " + CalculateTCL());
}