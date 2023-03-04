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

extern int Window = 1000;   // Number of candles to scan
HCandles HCandles_[1000];
float Highs_[1000];
float Lows_[1000];
int i = 0;
bool CandleInfoProcess_ = false;

void CPS(){
   while(i < Window)
   {
   if(i >= 0){
         HCandles_[i].RCN = i;
         HCandles_[i].Close = iClose(_Symbol, PERIOD_CURRENT, i);
         HCandles_[i].Open = iOpen(_Symbol, PERIOD_CURRENT, i);
         HCandles_[i].High = iHigh(_Symbol, PERIOD_CURRENT, i);
         Highs_[i] = iHigh(_Symbol, PERIOD_CURRENT, i);
         HCandles_[i].Low = iLow(_Symbol, PERIOD_CURRENT, i);
         Lows_[i] = iLow(_Symbol, PERIOD_CURRENT, i);
         HCandles_[i].Time = MQLR_Bars(i, "Time");
         HCandles_[i].Pattern = "";
         
      //Print("First Candle Time: " + MQLR_Bars(i + 1, "Time") + " || " + "Second: " + MQLR_Bars(i + 1, "Time"));
      }
      ++i;
   }
   
   if(i == Window || i > Window){
         i = 0;
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
bool Display = false;
void MarkUp() {
   if(!Display) {
      ObjectCreate(_Symbol, "NY Session Line",OBJ_VLINE,0,StringToTime("15:00"),0);
      ObjectSetInteger(0,"NY Session Line",OBJPROP_COLOR,clrPink);
      
      ObjectCreate(_Symbol, "London Session Line",OBJ_VLINE,0,StringToTime("10:00"),0);
      ObjectSetInteger(0,"London Session Line",OBJPROP_COLOR,clrPink);
      
      ObjectCreate(_Symbol, "Tokyo Session Line",OBJ_VLINE,0,StringToTime("1:00"),0);
      ObjectSetInteger(0,"Tokyo Session Line",OBJPROP_COLOR,clrPink);
      
                     //ObjectSetInteger(0,"Rectangle",OBJPROP_COLOR,clrBlue);
                     //ObjectSetInteger(0,"Morning Star: " + i,OBJPROP_BACK,false);
                     Display = true;
      
   }
  
}
void OnTick() {
   CPS();
   //Print(TimeToString(HCandles_[0].Time));
   MarkUp();
   LondonSession();
   TokyoSession();
}
//ObjectCreate(_Symbol,"Overbought Line",OBJ_HLINE,0,0,SessionStats_High("10:00", "15:00"));
void LondonSession() {
   double From;
   double To;
   while(i < Window)
   {
   if(HCandles_[i].Time == StringToTime("10:00")) {
      From = i;
   }
   if(HCandles_[i].Time == StringToTime("15:00")) {
      To = i;
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
      //ObjectCreate(_Symbol,"Overbought Line",OBJ_HLINE,0,0,FindHighestInIsolatedArray(Highs_, arr_size, To, From));
      ObjectCreate(_Symbol,"Overbought Line",OBJ_HLINE,0,0, HighCal(Highs_,ArraySize(Highs_),To,From));
      ObjectSetInteger(0,"Overbought Line",OBJPROP_COLOR,clrCyan);
      
      ObjectDelete(_Symbol, "Oversold Line");
      ObjectCreate(_Symbol,"Oversold Line",OBJ_HLINE,0,0,LowCal(Lows_,ArraySize(Lows_),To,From));
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
   if(HCandles_[i].Time == StringToTime("1:00")) {
      From = i;
   }
   if(HCandles_[i].Time == StringToTime("10:00")) {
      To = i;
   }
   else { To = 0; }
   ++i;
   }
   if(i == Window || i > Window){
         i = 0;
   }
   TokyoLines_(From, To);
   
}
int x = 0;
void TokyoLines_(int From, int To) {
   int size = From - To;
      float TRL = HighCal(Highs_,ArraySize(Highs_),To,From);
      float BRL = LowCal(Lows_,ArraySize(Lows_),To,From);
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

float HighCal(float Array_[], int arr_size, int To, int From) {
  
   float HighVal = Array_[To];
   
   for(int a=To; a<=From; a++)
    {
        if(HighVal < Array_[a]) {
            HighVal = Array_[a];
        }
    }
    
   Print("Element[", To, "] Value: ", HighVal);
   return HighVal;
}
float LowCal(float Array_[], int arr_size, int To, int From) {
  
   float LowVal = Array_[To];
   
   for(int a=To; a<=From; a++)
    {
        if(LowVal > Array_[a]) {
            LowVal = Array_[a];
        }
    }
    
   Print("Element[", To, "] Value: ", LowVal);
   return LowVal;
}
