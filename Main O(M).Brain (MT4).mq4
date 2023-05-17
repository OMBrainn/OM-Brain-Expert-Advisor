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
extern string TimeFrame = "5M";
extern float LiquidityRange = 0.00001f;
extern int Window = 1000;   // Number of candles to scan
HCandles HCandles_[1000]; 
HCandles ECandles_[3]; 
HCandles MUCandles[1000];
float Highs_[1000];
float Lows_[1000];

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
   if(i >= 0 && !MarkUpCPS_bool){
         MUCandles[i].RCN = i;
         MUCandles[i].Close = iClose(_Symbol, PERIOD_CURRENT, i);
         MUCandles[i].Open = iOpen(_Symbol, PERIOD_CURRENT, i);
         MUCandles[i].High = iHigh(_Symbol, PERIOD_CURRENT, i);
         Highs_[i] = iHigh(_Symbol, PERIOD_CURRENT, i);
         MUCandles[i].Low = iLow(_Symbol, PERIOD_CURRENT, i);
         Lows_[i] = iLow(_Symbol, PERIOD_CURRENT, i);
         MUCandles[i].Time = MQLR_Bars(i, "Time");
         MUCandles[i].Pattern = "";
   }
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
                     if(!ADC_bool) {
                     ObjectSetInteger(0,"Bullish Engulfing: " + i,OBJPROP_COLOR,clrNONE);
                     }
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
                     if(!ADC_bool) {
                     ObjectSetInteger(0,"Bearish Engulfing: " + i,OBJPROP_COLOR,clrNONE);
                     }
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
                     if(!ADC_bool) {
                     ObjectSetInteger(0,"Evening Star: " + i,OBJPROP_COLOR,clrNONE);
                     }
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
                     if(!ADC_bool) {
                     ObjectSetInteger(0,"Morning Star: " + i,OBJPROP_COLOR,clrNONE);
                     }
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
      MarkUpCPS_bool = true;
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
            if(ADC_bool) {
            ObjectSetInteger(0,LineName,OBJPROP_COLOR,clrCrimson);
            }
            else if(!ADC_bool) {
            ObjectSetInteger(0,LineName,OBJPROP_COLOR,clrNONE);
            }
            ObjectSetInteger(0,LineName,OBJPROP_BACK,false);
            HCandles_[ld].LiquidityActive = true;
         }
      }
   }
   if(ld == Window || ld > Window){
      ld = 0;
   }
}
int zo = 0;
void PatternDisplay() {
   for(zo;zo<Window;zo++) {
      if(HCandles_[zo].Pattern == "Bullish Engulfing"){
         if(ADC_bool) {
                     ObjectSetInteger(0,"Bullish Engulfing: " + zo,OBJPROP_COLOR,clrPink);
                     }
                     else if(!ADC_bool) {
                     ObjectSetInteger(0,"Bullish Engulfing: " + zo,OBJPROP_COLOR,clrNONE);
                     }
      }
      if(HCandles_[zo].Pattern == "Bearish Engulfing"){
         if(ADC_bool) {
                     ObjectSetInteger(0,"Bearish Engulfing: " + zo,OBJPROP_COLOR,clrCyan);
                     }
                     else if(!ADC_bool) {
                     ObjectSetInteger(0,"Bearish Engulfing: " + zo,OBJPROP_COLOR,clrNONE);
                     }
      }
      if(HCandles_[zo].Pattern == "Evening Star"){
         if(ADC_bool) {
                     ObjectSetInteger(0,"Evening Star: " + zo,OBJPROP_COLOR,clrCyan);
                     }
                     else if(!ADC_bool) {
                     ObjectSetInteger(0,"Evening Star: " + zo,OBJPROP_COLOR,clrNONE);
                     }
      }
      if(HCandles_[zo].Pattern == "Morning Star"){
         if(ADC_bool) {
                     ObjectSetInteger(0,"Morning Star: " + zo,OBJPROP_COLOR,clrPink);
                     }
                     else if(!ADC_bool) {
                     ObjectSetInteger(0,"Morning Star: " + zo,OBJPROP_COLOR,clrNONE);
                     }
      }
      }
      if(zo == Window || zo > Window){
      zo = 0;
   }
}
/*Check for New Candles*/
static int LastCandleNumber;
int OnInit()
  {
   CandleType();
   StopLoss_d = CurrentPrice() - 0.0005;
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
string Direction = "Off";
bool Continue_ = false;

string OrderType_ = "Buy";
double StopLoss_d = 0.0;
double TakeProfit_d = 0.0;
double AccountSize = 200000;
float RiskPercentage = 0.01;
float LotSize = 0.0;
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
         ContinuationAlertAdd = "";
         Continue_Button.Text("Continue: Off");
         Direction = "Sell";
         Continue_ = false;
         PanelDisplayUpdate();
         SendNotification(_Symbol + " " + Direction + " Direction Set");
         MessageBox(_Symbol + " " + Direction + " Direction Set");
      }
      else if(ShortToString(KeyThatWasPressed) == "b") {
         ContinuationAlertAdd = "";
         Continue_Button.Text("Continue: Off");
         Direction = "Buy";
         Continue_ = false;
         PanelDisplayUpdate();
         SendNotification(_Symbol + " " + Direction + " Direction Set");
         MessageBox(_Symbol + " " + Direction + " Direction Set");
      }
      else if(ShortToString(KeyThatWasPressed) == "n") {
         ContinuationAlertAdd = "";
         Continue_Button.Text("Continue: Off");
         Direction = "Both";
         Continue_ = false;
         PanelDisplayUpdate();
         SendNotification(_Symbol + " " + Direction + " Direction Set");
         MessageBox(_Symbol + " " + Direction + " Direction Set");
      }
      else if(ShortToString(KeyThatWasPressed) == "o") {
         ContinuationAlertAdd = "";
         Continue_Button.Text("Continue: Off");
         Direction = "Off";
         Continue_ = false;
         PanelDisplayUpdate();
         SendNotification(_Symbol + " Direction Set Off"); 
         MessageBox(_Symbol + " Direction Set Off"); 
      }
      if(ShortToString(KeyThatWasPressed) == "c" && !Continue_) {
         ContinuationAlertAdd = "Continuation";
         Continue_Button.Text("Continue: On");
         PanelDisplayUpdate();
         MessageBox(_Symbol + " " + "Continue Alerts On");
         Continue_ = true;
      }
      else if(ShortToString(KeyThatWasPressed) == "c" && Continue_) {
         ContinuationAlertAdd = "";
         Continue_Button.Text("Continue: Off");
         PanelDisplayUpdate();
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
      MarkUpCPS_bool = false;
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
bool MEX_Lock = false;
void OMB_Mex() {
   CandleType();
   if(OrderType_ == "Buy") {
      TakeProfit_d = CurrentPrice() + ((CurrentPrice() - StopLoss_d) * 2);
   }
   else if(OrderType_ == "Sell") {
      TakeProfit_d = CurrentPrice() - ((StopLoss_d - CurrentPrice()) * 2);
   }
   DisplayLines();
   if(!MEX_Lock) {
      MExecution_Button.Color(clrRed);
   }
   else if(MEX_Lock) {
      MExecution_Button.Color(clrBlack);
   }
}
void MarkUpDisplay() {
   if(MarkUp_bool) {
      MarkUp();
      LondonSession();
      TokyoSession();
   }
   else if(!MarkUp_bool) {
         MarkUp_Clean();
   }
}
void OnTick(){
   OMB_Mex();
   CPS();
   PatternDisplay();
   TimeSettings();
   LH_PatternPreChecker();
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

/*
   PatternDisplay();
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
    PanelDisplayUpdate();*/
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
//OM Brain
CAppDialog OMB_E;
CButton AlertDir_Toggle;
CButton MarkUp_Toggle;
CButton Execution_Toggle;
//This button, depending on Alert, Mark Up or Execution is what allows the chart to show. Allowing multiple charts at once or none.
CButton Chart_Toggle;

//Alert Direction
CButton Buy_Button;
CButton Sell_Button;
CButton Both_Button;
CLabel AlertDir_;


CButton Continue_Button;

CButton AlertO_Toggle;
CLabel ChoppyPattern_Label;
CButton LiquidLoad_Button;

CLabel Alert_Label;

//Execution
CButton EBuy_Button;
CButton ESell_Button;
CEdit AccountSize_Edit;
CLabel AccountSize_Label;
CLabel Risk_Label;
CEdit StopLoss_Edit;
CLabel StopLoss_Label;

CButton MExecution_Button;

CLabel PipLot_Label;
CLabel OderType_Label;

CButton StarSL_Button;
CButton EngulfingSL_Button;

CButton P10_Button;
CButton P15_Button;
CButton P20_Button;
CButton P25_Button;

CLabel TradeType_Label;
CButton C_Button;
CButton S_Button;
CButton X_Button;

void Init_Panel() {
   if(!OMB_E.Create(0, "O(M).Brain Execution",0,20,20,360,424))
      return(INIT_FAILED);
   //Chart Type
   if(!CreateAlertDir_Toggle())
      return(false);
   if(!CreateMarkUp_Toggle())
      return(false);
   if(!CreateExecution_Toggle())
      return(false);
   if(!CreateChart_Toggle())
      return(false);
   
   //Execution Page
   if(!CreateEBuy_Button())
      return(false);
   if(!CreateESell_Button())
      return(false);
   if(!OMB_E.Add(EBuy_Button))
      return(false);
   if(!OMB_E.Add(ESell_Button))
      return(false);
   if(!Create_StopLossEdit())
      return(false);
   if(!OMB_E.Add(StopLoss_Edit))
      return(false);
   if(!Create_StopLossLabel())
      return(false);
   if(!OMB_E.Add(StopLoss_Label))
      return(false);
   
   
   if(!Create_RiskLabel())
      return(false);
   if(!OMB_E.Add(Risk_Label))
      return(false);
      
   if(!CreateMExecution_Button())
      return(false);
   if(!OMB_E.Add(MExecution_Button))
      return(false);
      
   if(!CreateOderType_Label())
      return(false);
   if(!OMB_E.Add(OderType_Label))
      return(false);

   if(!CreatePipLot_Label())
      return(false);
   if(!OMB_E.Add(PipLot_Label))
      return(false);
   
   if(!CreateStarSL_Button())
      return(false);
   if(!OMB_E.Add(StarSL_Button))
      return(false);
   
   if(!CreateEngulfingSL_Button())
      return(false);
   if(!OMB_E.Add(EngulfingSL_Button))
      return(false);
   
   //Pips
   if(!CreateP10_Button())
      return(false);
   if(!OMB_E.Add(P10_Button))
      return(false);
   
   if(!CreateP15_Button())
      return(false);
   if(!OMB_E.Add(P15_Button))
      return(false);
   
   if(!CreateP20_Button())
      return(false);
   if(!OMB_E.Add(P20_Button))
      return(false);
   
   if(!CreateP25_Button())
      return(false);
   if(!OMB_E.Add(P25_Button))
      return(false);
      
   //Trade Type
   if(!CreateTradeType_Label())
      return(false);
   if(!OMB_E.Add(TradeType_Label))
      return(false);
      
   if(!CreateC_Button())
      return(false);
   if(!OMB_E.Add(C_Button))
      return(false);
      
   if(!CreateS_Button())
      return(false);
   if(!OMB_E.Add(S_Button))
      return(false);
      
   if(!CreateX_Button())
      return(false);
   if(!OMB_E.Add(X_Button))
      return(false);
   
   //Swing Button Toggle
   if(!CreateBuy_Button())
      return(false);
   if(!CreateSell_Button())
      return(false);
   if(!CreateBoth_Button())
      return(false);
   if(!OMB_E.Add(Buy_Button))
      return(false);
   if(!OMB_E.Add(Sell_Button))
      return(false);
   if(!OMB_E.Add(Both_Button))
      return(false);
      
      
   if(!CreateContinuation_Button())
      return(false);
   if(!OMB_E.Add(Continue_Button))
      return(false);
      
   if(!CreateAlertO_Toggle())
      return(false);
   if(!OMB_E.Add(AlertO_Toggle))
      return(false);
      
   if(!CreateLiquidLoad_Button())
      return(false);
   if(!OMB_E.Add(LiquidLoad_Button))
      return(false);
      
   //TCL
   if(!Create_Alert_Label())
      return(false);
   if(!OMB_E.Add(Alert_Label))
      return(false);
}
//Execution Page
bool CreateEBuy_Button(void) {
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP + 30;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
   
   if(!EBuy_Button.Create(0, "EBuy", 0,x1,y1,x2,y2))
      return(false);
   if(!EBuy_Button.Text("Buy"))
      return(false);
   if(!EBuy_Button.ColorBackground(clrLime))
      return(false);
   if(!OMB_E.Add(EBuy_Button))
      return(false);
   if(!EBuy_Button.Hide())
      return(false);
      
   return(true);
}
bool CreateESell_Button(void) {
   int x1=INDENT_LEFT+ 156;
   int y1=INDENT_TOP + 30;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
   
   if(!ESell_Button.Create(0, "ESell", 0,x1,y1,x2,y2))
      return(false);
   if(!ESell_Button.Text("Sell"))
      return(false);
   if(!ESell_Button.ColorBackground(clrRed))
      return(false);
   if(!ESell_Button.Color(clrWhite))
      return(false);
   if(!OMB_E.Add(ESell_Button))
      return(false);
   if(!ESell_Button.Hide())
      return(false);
      
   return(true);
}
bool Create_StopLossEdit(void) {
   int x1=INDENT_LEFT + 106;
   int y1=INDENT_TOP + 90;
   int x2=x1+BUTTON_WIDTH + 50;
   int y2=y1+BUTTON_HEIGHT;
   if(!StopLoss_Edit.Create(0, "Stop Loss", 0,x1,y1,x2,y2))
      return(false);
   if(!StopLoss_Edit.Text(StopLoss_d))
      return(false);
   if(!StopLoss_Edit.TextAlign(ALIGN_RIGHT))
      return(false);
   if(!OMB_E.Add(StopLoss_Edit))
      return(false);
   if(!StopLoss_Edit.Hide())
      return(false);
      
   return(true);
}
bool Create_StopLossLabel(void) {
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP + 90;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
   
   if(!StopLoss_Label.Create(0, "Stop Loss Label", 0,x1,y1,x2,y2))
      return(false);
   if(!StopLoss_Label.Text("Stop Loss: "))
      return(false);
   if(!OMB_E.Add(StopLoss_Label))
      return(false);
   if(!StopLoss_Label.Hide())
      return(false);
      
   return(true);
}


bool Create_RiskLabel(void) {
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP + 60;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
   
   if(!Risk_Label.Create(0, "Risk Percentage", 0,x1,y1,x2,y2))
      return(false);
   if(!Risk_Label.Text("Risk Percentage: 1%"))
      return(false);
   if(!OMB_E.Add(Risk_Label))
      return(false);
   if(!Risk_Label.Hide())
      return(false);
      
   return(true);
}

bool CreateMExecution_Button(void) {
   int x1=INDENT_LEFT + 66;
   int y1=INDENT_TOP + 290;
   int x2=x1+BUTTON_WIDTH + 20;
   int y2=y1+BUTTON_HEIGHT + 10;
   
   if(!MExecution_Button.Create(0, "Market Execution", 0,x1,y1,x2,y2))
      return(false);
   if(!MExecution_Button.Text("Market Execution"))
      return(false);
   if(!MExecution_Button.ColorBackground(clrAliceBlue))
      return(false);
   if(!OMB_E.Add(MExecution_Button))
      return(false);
   if(!MExecution_Button.Hide())
      return(false);
      
   return(true);
}

bool CreateOderType_Label(void) {
   int x1=INDENT_LEFT + 77;
   int y1=INDENT_TOP + 240;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
   
   if(!OderType_Label.Create(0, "Order Type: Buy", 0,x1,y1,x2,y2))
      return(false);
   if(!OderType_Label.Text("Order Type: Buy"))
      return(false);
   if(!OMB_E.Add(OderType_Label))
      return(false);
   if(!OderType_Label.Hide())
      return(false);
      
   return(true);
}

bool CreatePipLot_Label(void) {
   int x1=INDENT_LEFT + 77;
   int y1=INDENT_TOP + 260;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
   
   if(!PipLot_Label.Create(0, "Pip Lot", 0,x1,y1,x2,y2))
      return(false);
   if(!PipLot_Label.Text("Pips / Lot: "))
      return(false);
   if(!OMB_E.Add(PipLot_Label))
      return(false);
   if(!PipLot_Label.Hide())
      return(false);
      
   return(true);
}
bool CreateStarSL_Button(void) {
   int x1=INDENT_LEFT + 178;
   int y1=INDENT_TOP + 120;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
   
   if(!StarSL_Button.Create(0, "Star SL", 0,x1,y1,x2,y2))
      return(false);
   if(!StarSL_Button.Text("Star SL"))
      return(false);
   if(!OMB_E.Add(StarSL_Button))
      return(false);
   if(!StarSL_Button.Hide())
      return(false);
      
   return(true);
}
bool CreateEngulfingSL_Button(void) {
   int x1=INDENT_LEFT-11;
   int y1=INDENT_TOP + 120;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
   
   if(!EngulfingSL_Button.Create(0, "Engulfing SL", 0,x1,y1,x2,y2))
      return(false);
   if(!EngulfingSL_Button.Text("Engulfing SL"))
      return(false);
   if(!OMB_E.Add(EngulfingSL_Button))
      return(false);
   if(!EngulfingSL_Button.Hide())
      return(false);
      
   return(true);
}
//Pips

bool CreateP15_Button(void) {
   int x1=INDENT_LEFT + 178;
   int y1=INDENT_TOP + 150;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
   
   if(!P15_Button.Create(0, "15 Pips", 0,x1,y1,x2,y2))
      return(false);
   if(!P15_Button.Text("15 Pips"))
      return(false);
   if(!OMB_E.Add(P15_Button))
      return(false);
   if(!P15_Button.Hide())
      return(false);
      
   return(true);
}
bool CreateP10_Button(void) {
   int x1=INDENT_LEFT-11;
   int y1=INDENT_TOP + 150;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
   
   if(!P10_Button.Create(0, "10 Pips", 0,x1,y1,x2,y2))
      return(false);
   if(!P10_Button.Text("10 Pips"))
      return(false);
   if(!OMB_E.Add(P10_Button))
      return(false);
   if(!P10_Button.Hide())
      return(false);
      
   return(true);
}


bool CreateP25_Button(void) {
   int x1=INDENT_LEFT + 178;
   int y1=INDENT_TOP + 180;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
   
   if(!P25_Button.Create(0, "25 Pips", 0,x1,y1,x2,y2))
      return(false);
   if(!P25_Button.Text("25 Pips"))
      return(false);
   if(!OMB_E.Add(P25_Button))
      return(false);
   if(!P25_Button.Hide())
      return(false);
      
   return(true);
}
bool CreateP20_Button(void) {
   int x1=INDENT_LEFT-11;
   int y1=INDENT_TOP + 180;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
   
   if(!P20_Button.Create(0, "20 Pips", 0,x1,y1,x2,y2))
      return(false);
   if(!P20_Button.Text("20 Pips"))
      return(false);
   if(!OMB_E.Add(P20_Button))
      return(false);
   if(!P20_Button.Hide())
      return(false);
      
   return(true);
}
//Trade Type
bool CreateTradeType_Label(void) {
   int x1=INDENT_LEFT-11;
   int y1=INDENT_TOP + 210;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
   
   if(!TradeType_Label.Create(0, "Trade Type", 0,x1,y1,x2,y2))
      return(false);
   if(!TradeType_Label.Text("Trade Type:"))
      return(false);
   if(!OMB_E.Add(TradeType_Label))
      return(false);
   if(!TradeType_Label.Hide())
      return(false);
      
   return(true);
}

bool CreateC_Button(void) {
   int x1=INDENT_LEFT + 205;
   int y1=INDENT_TOP + 210;
   int x2=x1+BUTTON_WIDTH - 40;
   int y2=y1+BUTTON_HEIGHT;
   
   if(!C_Button.Create(0, "C Trade", 0,x1,y1,x2,y2))
      return(false);
   if(!C_Button.Text("C Trade"))
      return(false);
   if(!OMB_E.Add(C_Button))
      return(false);
   if(!C_Button.Hide())
      return(false);
      
   return(true);
}
bool CreateS_Button(void) {
   int x1=INDENT_LEFT + 135;
   int y1=INDENT_TOP + 210;
   int x2=x1+BUTTON_WIDTH - 40;
   int y2=y1+BUTTON_HEIGHT;
   
   if(!S_Button.Create(0, "S Trade", 0,x1,y1,x2,y2))
      return(false);
   if(!S_Button.Text("S Trade"))
      return(false);
   if(!OMB_E.Add(S_Button))
      return(false);
   if(!S_Button.Hide())
      return(false);
      
   return(true);
}
bool CreateX_Button(void) {
   int x1=INDENT_LEFT + 65;
   int y1=INDENT_TOP + 210;
   int x2=x1+BUTTON_WIDTH - 40;
   int y2=y1+BUTTON_HEIGHT;
   
   if(!X_Button.Create(0, "X Trade", 0,x1,y1,x2,y2))
      return(false);
   if(!X_Button.Text("X Trade"))
      return(false);
   if(!OMB_E.Add(X_Button))
      return(false);
   if(!X_Button.Hide())
      return(false);
      
   return(true);
}

//Chart Type
bool CreateAlertDir_Toggle(void) {
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP + 10;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
   
   if(!AlertDir_Toggle.Create(0, "Alert Dir", 0,x1,y1,x2,y2))
      return(false);
   if(!AlertDir_Toggle.Text("Alert Dir"))
      return(false);
   if(!AlertDir_Toggle.ColorBackground(clrPink))
      return(false);
   if(!OMB_E.Add(AlertDir_Toggle))
      return(false);
      
   return(true);
}
bool CreateMarkUp_Toggle(void) {
   int x1=INDENT_LEFT + 100;
   int y1=INDENT_TOP + 10;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
   
   if(!MarkUp_Toggle.Create(0, "Mark Up", 0,x1,y1,x2,y2))
      return(false);
   if(!MarkUp_Toggle.Text("Mark Up"))
      return(false);
   if(!MarkUp_Toggle.ColorBackground(clrCyan))
      return(false);
   if(!OMB_E.Add(MarkUp_Toggle))
      return(false);
      
   return(true);
}
bool CreateExecution_Toggle(void) {
   int x1=INDENT_LEFT + 200;
   int y1=INDENT_TOP + 10;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
   
   if(!Execution_Toggle.Create(0, "Execution", 0,x1,y1,x2,y2))
      return(false);
   if(!Execution_Toggle.Text("Execution"))
      return(false);
   if(!Execution_Toggle.ColorBackground(clrAliceBlue))
      return(false);
   if(!OMB_E.Add(Execution_Toggle))
      return(false);
      
   return(true);
}
bool CreateChart_Toggle(void) {
   int x1=INDENT_LEFT + 100;
   int y1=INDENT_TOP + 30;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
   
   if(!Chart_Toggle.Create(0, "Chart", 0,x1,y1,x2,y2))
      return(false);
   if(!Chart_Toggle.Text("Chart"))
      return(false);
   if(!Chart_Toggle.ColorBackground(clrBisque))
      return(false);
   if(!OMB_E.Add(Chart_Toggle))
      return(false);
      
   return(true);
}

//Alert Dir
bool CreateBuy_Button(void) {
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP + 40;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
   
   if(!Buy_Button.Create(0, "Buy", 0,x1,y1,x2,y2))
      return(false);
   if(!Buy_Button.Text("Buy"))
      return(false);
   if(!Buy_Button.ColorBackground(clrLime))
      return(false);
   if(!OMB_E.Add(Buy_Button))
      return(false);
      
   return(true);
}
bool CreateSell_Button(void) {
   int x1=INDENT_LEFT+ 156;
   int y1=INDENT_TOP + 40;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
   
   if(!Sell_Button.Create(0, "Sell", 0,x1,y1,x2,y2))
      return(false);
   if(!Sell_Button.Text("Sell"))
      return(false);
   if(!Sell_Button.ColorBackground(clrRed))
      return(false);
   if(!Sell_Button.Color(clrWhite))
      return(false);
   if(!OMB_E.Add(Sell_Button))
      return(false);
   
      
   return(true);
}
bool CreateBoth_Button(void) {
   int x1=INDENT_LEFT + 80;
   int y1=INDENT_TOP + 70;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
   
   if(!Both_Button.Create(0, "Both", 0,x1,y1,x2,y2))
      return(false);
   if(!Both_Button.Text("Both"))
      return(false);
   if(!Both_Button.ColorBackground(clrAqua))
      return(false);
   if(!Both_Button.Color(clrBlack))
      return(false);
   if(!OMB_E.Add(Both_Button))
      return(false);
   
      
   return(true);
}
bool Create_AlertDir(void) {
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
   
   if(!AlertDir_.Create(0, "Alert Dir", 0,x1,y1,x2,y2))
      return(false);
   if(!AlertDir_.Text("<<Alert Directions>>"))
      return(false);
   if(!OMB_E.Add(AlertDir_))
      return(false);
      
   return(true);
}
bool CreateContinuation_Button(void) {
   int x1=INDENT_LEFT + 80;
   int y1=INDENT_TOP + 100;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
   
   if(!Continue_Button.Create(0, "Continuation", 0,x1,y1,x2,y2))
      return(false);
   if(!Continue_Button.Text("Continue: Off"))
      return(false);
   if(!Continue_Button.ColorBackground(clrAzure))
      return(false);
   if(!Continue_Button.Color(clrBlack))
      return(false);
   if(!OMB_E.Add(Continue_Button))
      return(false);
      
   return(true);
}
bool CreateAlertO_Toggle(void) {
   int x1=INDENT_LEFT + 80;
   int y1=INDENT_TOP + 160;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
   
   if(!AlertO_Toggle.Create(0, "Alerts Off", 0,x1,y1,x2,y2))
      return(false);
   if(!AlertO_Toggle.Text("Alerts Off"))
      return(false);
   if(!AlertO_Toggle.ColorBackground(clrBlack))
      return(false);
   if(!AlertO_Toggle.Color(clrWhite))
      return(false);
   if(!OMB_E.Add(AlertO_Toggle))
      return(false);
      
   return(true);
}
bool CreateLiquidLoad_Button(void) {
   int x1=INDENT_LEFT + 80;
   int y1=INDENT_TOP + 270;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
   
   if(!LiquidLoad_Button.Create(0, "Liquid Load", 0,x1,y1,x2,y2))
      return(false);
   if(!LiquidLoad_Button.Text("Liquid Load"))
      return(false);
   if(!LiquidLoad_Button.ColorBackground(clrBlue))
      return(false);
   if(!LiquidLoad_Button.Color(clrWhite))
      return(false);
   if(!OMB_E.Add(LiquidLoad_Button))
      return(false);
      
   return(true);
}
bool Create_Alert_Label(void) {
   int x1=INDENT_LEFT + 60;
   int y1=INDENT_TOP + 180;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
   
   if(!Alert_Label.Create(0, "Alert Label", 0,x1,y1,x2,y2))
      return(false);
   if(!Alert_Label.Text("Alert Direction:   " + AlertStr))
      return(false);
   if(!OMB_E.Add(Alert_Label))
      return(false);
      
   return(true);
}
double VPA = 0;
string Pre30Swing = "";
int AlertO_Toggle_int = 0;

int ChoppyP_int = 0;
double ChoppyP = 0;

double TopRange_double;
double BottomRange_double;
double OversoldPoint;
double OverboughtPoint;

int LiquidityPoint = 0;

int SwingCorrelationPoint = 0;

string Pattern_OMB_E;

bool PageMerge = false;
//0 =  Alert Dir | 1 = Mark Up | 2 = Execution
void NeoChartEvent(const int id,
                  const long& lparam,
                  const double& dparam,
                  const string& sparam) {
   OMB_E.ChartEvent(id,lparam,dparam,sparam);
   if(id==CHARTEVENT_OBJECT_ENDEDIT){
      if(sparam=="Stop Loss") {
         StopLoss_d = StopLoss_Edit.Text();
         DisplayLines();
         Print("Manual: Stop Loss Changed to ", StopLoss_Edit.Text());
      }
   }
   if(id==CHARTEVENT_OBJECT_CLICK){
   //Execution
      if(sparam=="EBuy"){
         CandleType();
         StopLoss_d = CurrentPrice() - 0.0005;
         OderType_Label.Text("Order Type: Buy");
         OrderType_ = "Buy";
         DisplayLines();
         Print("Order Type Set To Buy");
      }
      if(sparam=="ESell"){
         CandleType();
         StopLoss_d = CurrentPrice() + 0.0005;
         OderType_Label.Text("Order Type: Sell");
         OrderType_ = "Sell";
         DisplayLines();
         Print("Order Type Set To Sell");
      }
      if(sparam=="Star SL") {
         CandleType();
         StopLoss_d = StarStopLoss();
         StopLoss_Edit.Text(StarStopLoss());
         DisplayLines();
         Print("Star 3C: Stop Loss Changed to ", StopLoss_Edit.Text());
      }
      if(sparam=="Engulfing SL") {
         CandleType();
         StopLoss_d = EngulfingStopLoss();
         StopLoss_Edit.Text(EngulfingStopLoss());
         DisplayLines();
         Print("Engulfing 2C: Stop Loss Changed to ", StopLoss_Edit.Text());
      }
      if(sparam=="10 Pips") {
         StopLoss_d = NumPip_SL(10);
         StopLoss_Edit.Text(StopLoss_d);
         DisplayLines();
         Print("Stop Loss Changed to ", StopLoss_Edit.Text());
      }
      if(sparam=="15 Pips") {
         StopLoss_d = NumPip_SL(15);
         StopLoss_Edit.Text(StopLoss_d);
         DisplayLines();
         Print("Stop Loss Changed to ", StopLoss_Edit.Text());
      }
      if(sparam=="20 Pips") {
         StopLoss_d = NumPip_SL(20);
         StopLoss_Edit.Text(StopLoss_d);
         DisplayLines();
         Print("Stop Loss Changed to ", StopLoss_Edit.Text());
      }
      if(sparam=="25 Pips") {
         StopLoss_d = NumPip_SL(25);
         StopLoss_Edit.Text(StopLoss_d);
         DisplayLines();
         Print("Stop Loss Changed to ", StopLoss_Edit.Text());
      }
      if(sparam=="X Trade") {
         //RiskPercentage = 0.005;
         RiskPercentage = 0.005;
         MEX_Lock = true;
         Risk_Label.Text("Risk Percentage: 0.5%");
         Print("Risk Percent Changed To 0.5%");
      }
      if(sparam=="S Trade") {
         RiskPercentage = 0.02;
         MEX_Lock = true;
         Risk_Label.Text("Risk Percentage: 2%");
         Print("Risk Percent Changed To 2%");
      }
      if(sparam=="C Trade") {
         RiskPercentage = 0.01;
         MEX_Lock = true;
         Risk_Label.Text("Risk Percentage: 1%");
         Print("Risk Percent Changed To 1%");
      }
      
      if(MEX_Lock) {
         if(sparam=="Market Execution") {
            MEX();
            ObjectDelete(_Symbol, "Entry Line");
            ObjectDelete(_Symbol, "Stop Loss Line");
         }
   }
   //Type
      if(sparam=="Alert Dir"){
         Show_AlertDir();
         ADC_bool = true;
         if(!PageMerge){
            
            MarkUp_bool = false;
            MarkUp_Clean();
         }
         Hide_Execution();
      }
      if(sparam=="Mark Up"){
         Hide_AlertDir();
         MarkUp_bool = true;
         MarkUpDisplay();
         if(!PageMerge){
            ADC_bool = false;
         }
         Hide_Execution();
      }
      if(sparam=="Execution"){
         Show_Execution();
         OMB_Mex();
         if(!PageMerge){
            ADC_bool = false;
            MarkUp_bool = false;
            MarkUp_Clean();
         }
         Hide_AlertDir();
      }
      if(sparam=="Chart"){
         if(PageMerge) {
            PageMerge = false;
            MessageBox("Chart UnMerged");
         }
         else if(!PageMerge) {
            PageMerge = true;
            MessageBox("Chart Merged");
         }
      }
   //Alert Dir
      if(sparam=="Buy"){
         ContinuationAlertAdd = "";
         Continue_Button.Text("Continue: Off");
         Direction = "Buy";
         Continue_ = false;
         SendNotification(_Symbol + " " + Direction + " Direction Set");
         MessageBox(_Symbol + " " + Direction + " Direction Set");
         PanelDisplayUpdate();
         Print("Previous 30M Swing: Bull");
      }
      if(sparam=="Sell"){
         ContinuationAlertAdd = "";
         Continue_Button.Text("Continue: Off");
         Direction = "Sell";
         Continue_ = false;
         SendNotification(_Symbol + " " + Direction + " Direction Set");
         MessageBox(_Symbol + " " + Direction + " Direction Set");
         PanelDisplayUpdate();
         Print("Previous 30M Swing: Bear");
      }
      if(sparam=="Both"){
         ContinuationAlertAdd = "";
         Continue_Button.Text("Continue: Off");
         Direction = "Both";
         Continue_ = false;
         SendNotification(_Symbol + " " + Direction + " Direction Set");
         MessageBox(_Symbol + " " + Direction + " Direction Set");
         PanelDisplayUpdate();
      }
      if(sparam=="Continuation"){
            if(!Continue_) {
               ContinuationAlertAdd = "Continuation";
               Continue_Button.Text("Continue: On");
               MessageBox(_Symbol + " " + "Continue Alerts On");
               Continue_ = true;
            }
            else if(Continue_) {
               ContinuationAlertAdd = "";
               Continue_Button.Text("Continue: Off");
               MessageBox(_Symbol + " " + "Continue Alerts Off");
               Continue_ = false;
            }
         PanelDisplayUpdate();
         Print("Swing and Consolidation Range Reset");
      }
      if(sparam=="Alerts Off"){
         ContinuationAlertAdd = "";
         Direction = "Off";
         Continue_ = false;
         SendNotification(_Symbol + " Direction Set Off"); 
         MessageBox(_Symbol + " Direction Set Off"); 
         PanelDisplayUpdate();
      }
      if(sparam=="Liquid Load"){
         LiquidityHit_Fr_DownSide = true;
         LiquidityHit_Fr_UpSide = true;
         SendNotification(_Symbol + " Loaded Liquidity Up & Down Side"); 
         MessageBox(_Symbol + "  Loaded Liquidity Up & Down Side"); 
         PanelDisplayUpdate();
      }
   }
   /*
   
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
   } */
}
void Show_AlertDir() {
   Buy_Button.Show();
   Sell_Button.Show();
   Both_Button.Show();
   AlertDir_.Show();
   Continue_Button.Show();
   AlertO_Toggle.Show();
   ChoppyPattern_Label.Show();
   LiquidLoad_Button.Show();
   Alert_Label.Show();
}
void Hide_AlertDir() {
   Buy_Button.Hide();
   Sell_Button.Hide();
   Both_Button.Hide();
   AlertDir_.Hide();
   Continue_Button.Hide();
   AlertO_Toggle.Hide();
   ChoppyPattern_Label.Hide();
   LiquidLoad_Button.Hide();
   Alert_Label.Hide();
}

bool ADC_bool = true;
bool MarkUp_bool = false;
void Show_MarkUp() {
   
}

void Hide_Execution() {
   EBuy_Button.Hide();
   ESell_Button.Hide();
   StopLoss_Edit.Hide();
   StopLoss_Label.Hide();
   AccountSize_Edit.Hide();
   AccountSize_Label.Hide();
   Risk_Label.Hide();
   MExecution_Button.Hide();
   OderType_Label.Hide();
   PipLot_Label.Hide();
   StarSL_Button.Hide();
   EngulfingSL_Button.Hide();
   P10_Button.Hide();
   P15_Button.Hide();
   P20_Button.Hide();
   P25_Button.Hide();
   TradeType_Label.Hide();
   C_Button.Hide();
   S_Button.Hide();
   X_Button.Hide();
   ExecutionLines = false;
   ObjectDelete(_Symbol, "Take Profit Line");
   ObjectDelete(_Symbol, "Stop Loss Line");
   ObjectDelete(_Symbol, "Entry Line");
}
void Show_Execution() {
   ExecutionLines = true;
   EBuy_Button.Show();
   ESell_Button.Show();
   StopLoss_Edit.Show();
   StopLoss_Label.Show();
   AccountSize_Edit.Show();
   AccountSize_Label.Show();
   Risk_Label.Show();
   MExecution_Button.Show();
   OderType_Label.Show();
   PipLot_Label.Show();
   StarSL_Button.Show();
   EngulfingSL_Button.Show();
   P10_Button.Show();
   P15_Button.Show();
   P20_Button.Show();
   P25_Button.Show();
   TradeType_Label.Show();
   C_Button.Show();
   S_Button.Show();
   X_Button.Show();
}
bool ExecutionLines = false;
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
                  LiquidityPointCheck("Bearish");
                  SwingCorrelationCheck("Bearish");
               }
}

string ContinuationAlertAdd = "";
string AlertStr = "";
void PanelDisplayUpdate() {
   AlertStr = Direction + " " + ContinuationAlertAdd;
   Alert_Label.Text("Alert Direction:   " + AlertStr);
}
//Mark Up
bool Display = false;
bool MarkUpCPS_bool = false;
void MarkUp() {
      ObjectCreate(_Symbol, "NY Session Line",OBJ_VLINE,0,StringToTime("15:00"),0);
      ObjectSetInteger(0,"NY Session Line",OBJPROP_COLOR,clrPink);
      
      ObjectCreate(_Symbol, "London Session Line",OBJ_VLINE,0,StringToTime("10:00"),0);
      ObjectSetInteger(0,"London Session Line",OBJPROP_COLOR,clrPink);
      
      ObjectCreate(_Symbol, "Tokyo Session Line",OBJ_VLINE,0,StringToTime("1:00"),0);
      ObjectSetInteger(0,"Tokyo Session Line",OBJPROP_COLOR,clrPink);
      
                     //ObjectSetInteger(0,"Rectangle",OBJPROP_COLOR,clrBlue);
                     //ObjectSetInteger(0,"Morning Star: " + i,OBJPROP_BACK,false);
      
   
  
}
//ObjectCreate(_Symbol,"Overbought Line",OBJ_HLINE,0,0,SessionStats_High("10:00", "15:00"));
void LondonSession() {
   double From;
   double To;
   while(i < Window)
   {
   if(MUCandles[i].Time == StringToTime("10:00")) {
      From = i;
   }
   if(MUCandles[i].Time == StringToTime("15:00")) {
      To = i + 1;
   } 
   
   ++i;
   }
   
   if(i == Window || i > Window){
         i = 0;
   }
   LondonLines_(From, To);
   //Print("To: ", To, " From: ", From, " High: ");
}
int z = 0; 
void LondonLines_(int From, int To) {
   int size = From - To;
      ObjectDelete(_Symbol, "Overbought Line");
      ObjectCreate(_Symbol,"Overbought Line",OBJ_HLINE,0,0, HighCal(Highs_,ArraySize(Highs_),To,From, "London"));
      ObjectSetInteger(0,"Overbought Line",OBJPROP_COLOR,clrCyan);
      
      ObjectDelete(_Symbol, "Oversold Line");
      ObjectCreate(_Symbol,"Oversold Line",OBJ_HLINE,0,0,LowCal(Lows_,ArraySize(Lows_),To,From, "London"));
      ObjectSetInteger(0,"Oversold Line",OBJPROP_COLOR,clrCyan);
   
   ++z;
   if(z == size || z > size){
         z = 0;
   }
   //Print();
}
void TokyoSession() {
   double From;
   double To;
   while(i < Window)
   {
   if(MUCandles[i].Time == StringToTime("1:00")) {
      From = i;
   }
   if(MUCandles[i].Time == StringToTime("10:00")) {
      To = i + 1;
   }
   ++i;
   }
   if(i == Window || i > Window){
         i = 0;
   }
   TokyoLines_(From, To);
   Print("Tokyo From: ", From, " To: ", To);
   
}
int x = 0;
void TokyoLines_(int From, int To) {
   int size = From - To;
      float TRL = HighCal(Highs_,ArraySize(Highs_),To,From, "Tokyo");
      float BRL = LowCal(Lows_,ArraySize(Lows_),To,From, "Tokyo");
      ObjectDelete(_Symbol, "Top Range Line");
      ObjectCreate(_Symbol,"Top Range Line",OBJ_HLINE,0,0,TRL);
      ObjectSetInteger(0,"Top Range Line",OBJPROP_COLOR,clrBlack);
      
      ObjectDelete(_Symbol, "Bottom Range Line");
      ObjectCreate(_Symbol,"Bottom Range Line",OBJ_HLINE,0,0,BRL);
      ObjectSetInteger(0,"Bottom Range Line",OBJPROP_COLOR,clrBlack);
      
      ObjectDelete(_Symbol, "Mid Range Line");
      ObjectCreate(_Symbol,"Mid Range Line",OBJ_HLINE,0,0,((TRL - BRL) / 2) + BRL);
      ObjectSetInteger(0,"Mid Range Line",OBJPROP_COLOR,clrBlack);
   ++x;
   if(x == size || x > size){
         x = 0;
   }
   //Print("To: ", To, " From: ", From, " Size: ", size, "int: ", x);
}

float HighCal(float Array_[], int arr_size, int To, int From, string Type) {
  
   float HighVal = Array_[To];
   
   for(int a=To; a<=From; a++)
    {
        if(HighVal < Array_[a]) {
            HighVal = Array_[a];
        }
    }
    
   Print("Element[", To, "] Value: ", HighVal, " ", Type);
   return HighVal;
}
float LowCal(float Array_[], int arr_size, int To, int From, string Type) {
  
   float LowVal = Array_[To];
   
   for(int a=To; a<=From; a++)
    {
        if(LowVal > Array_[a]) {
            LowVal = Array_[a];
        }
    }
    
   Print("Element[", To, "] Value: ", LowVal, " ", Type);
   return LowVal;
}
void MarkUp_Clean() {
   //ObjectDelete(_Symbol, "Overbought Line");
   ObjectDelete(_Symbol, "Top Range Line");
   ObjectDelete(_Symbol, "Bottom Range Line");
   ObjectDelete(_Symbol, "Mid Range Line");
   ObjectDelete(_Symbol, "Overbought Line");
   ObjectDelete(_Symbol, "Oversold Line");
   ObjectDelete(_Symbol, "NY Session Line");
   ObjectDelete(_Symbol, "London Session Line");
   ObjectDelete(_Symbol, "Tokyo Session Line");
   Display = false;
}
int e = 0;
void CandleType() {
   for(e;e<3;e++) {
      HCandles_[e].Close = iClose(_Symbol, PERIOD_CURRENT, e);
      HCandles_[e].Open = iOpen(_Symbol, PERIOD_CURRENT, e);
      HCandles_[e].High = iHigh(_Symbol, PERIOD_CURRENT, e);
      HCandles_[e].Low = iLow(_Symbol, PERIOD_CURRENT, e);
      HCandles_[e].Time = MQLR_Bars(e, "Time");
      //Bullish or Bearish?
      if(HCandles_[e].Open < HCandles_[e].Close){
         HCandles_[e].CandleType = "Bullish";
      }
      else {
         HCandles_[e].CandleType = "Bearish";
      }
   }
}

double CurrentPrice() {
   return iClose(_Symbol, PERIOD_CURRENT, 0);
}

void DisplayLines(){
   if(ExecutionLines){
      string EntryLineName = "Entry Line";
      ObjectDelete(_Symbol, EntryLineName);
      ObjectCreate(_Symbol, EntryLineName, OBJ_HLINE,0,HCandles_[0].Time, CurrentPrice());
      ObjectSetInteger(0,EntryLineName,OBJPROP_COLOR,clrAliceBlue);
      ObjectSetInteger(0,EntryLineName,OBJPROP_ZORDER,0);
      string SL_LineName = "Stop Loss Line";
      ObjectDelete(_Symbol, SL_LineName);
      ObjectCreate(_Symbol, SL_LineName, OBJ_HLINE,0,HCandles_[0].Time, StopLoss_d);
      ObjectSetInteger(0,SL_LineName,OBJPROP_COLOR,clrRed);
      ObjectSetInteger(0,SL_LineName,OBJPROP_ZORDER,0);
      
      string TP_LineName = "Take Profit Line";
      ObjectDelete(_Symbol, TP_LineName);
      ObjectCreate(_Symbol, TP_LineName, OBJ_HLINE,0,HCandles_[0].Time, TakeProfit_d);
      ObjectSetInteger(0,TP_LineName,OBJPROP_COLOR,clrLime);
      ObjectSetInteger(0,TP_LineName,OBJPROP_ZORDER,0);
      
      PipLot_Label.Text("Pips / Lot: " + PipCount_() + " / " + LotSize_Calc());
   }
}

double StarStopLoss() {
   double SL;
   if(OrderType_ == "Buy") {
      SL = MathMin(MathMin(HCandles_[0].Low, HCandles_[1].Low), HCandles_[2].Low);
   }
   else if(OrderType_ == "Sell") {
      SL = MathMax(MathMax(HCandles_[0].High, HCandles_[1].High), HCandles_[2].High);
   }
   return SL;
}

double EngulfingStopLoss() {
   double SL;
   if(OrderType_ == "Buy") {
      SL = MathMin(HCandles_[0].Low, HCandles_[1].Low);
   }
   else if(OrderType_ == "Sell") {
      SL = MathMax(HCandles_[0].High, HCandles_[1].High);
   }
   return SL;
}
double PipCount_(){
   double Difference = (CurrentPrice() - StopLoss_d);
   double result;
   if(Difference < 0) {
      result = Difference * -1;
   }
   else {
      result = Difference;
   }
   return result * 10000;
}
double NumPip_SL(double Pips) {
   double PipDistance = Pips / 10000;
   double result;
   if(OrderType_ == "Buy") {
      result = CurrentPrice() - PipDistance;
   }
   else if(OrderType_ == "Sell") {
      result = CurrentPrice() + PipDistance;
   }
   return result;
}
double LotSize_Calc(){
   return StringSubstr((AccountSize * RiskPercentage) / (10 * PipCount_()),0,4);
}

void MEX() {
   if(OrderType_ == "Buy") {
      OrderSend(_Symbol, OP_BUY, LotSize_Calc(),NULL,3,StopLoss_d,NULL,NULL,NULL,0,clrGreen);
   }
   else if(OrderType_ == "Sell") {
      OrderSend(_Symbol, OP_SELL, LotSize_Calc(),NULL,3,StopLoss_d,NULL,NULL,NULL,0,clrRed);
   }
}
