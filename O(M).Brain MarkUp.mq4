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
   //TokyoSession();
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
double highest = 0;
double lowest = 100;
void LondonLines_(int From, int To) {
   int size = From - To;
   if(highest <= HCandles_[z + To].High) {
      highest = HCandles_[z + To].High;
   }
   
   if(lowest >= HCandles_[z + To].Low) {
      lowest = HCandles_[z + To].Low;
   }
   int arr_size = ArraySize(Highs_);
      ObjectDelete(_Symbol, "Overbought Line");
      //ObjectCreate(_Symbol,"Overbought Line",OBJ_HLINE,0,0,FindHighestInIsolatedArray(Highs_, arr_size, To, From));
      ObjectCreate(_Symbol,"Overbought Line",OBJ_HLINE,0,0,highest);
      ObjectSetInteger(0,"Overbought Line",OBJPROP_COLOR,clrCyan);
      
      ObjectDelete(_Symbol, "Oversold Line");
      ObjectCreate(_Symbol,"Oversold Line",OBJ_HLINE,0,0,lowest);
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
double T_highest = 0;
double T_lowest = 100;
int x = 0;
void TokyoLines_(int From, int To) {
   int size = From - To;
   if(T_highest <= HCandles_[x + To].High) {
      T_highest = HCandles_[x + To].High;
   }
   
   if(T_lowest >= HCandles_[x + To].Low) {
      T_lowest = HCandles_[x + To].Low;
   }
      ObjectDelete(_Symbol, "Top Range Line");
      ObjectCreate(_Symbol,"Top Range Line",OBJ_HLINE,0,0,T_highest);
      ObjectSetInteger(0,"Top Range Line",OBJPROP_COLOR,clrBlack);
      
      ObjectDelete(_Symbol, "Bottom Range Line");
      ObjectCreate(_Symbol,"Bottom Range Line",OBJ_HLINE,0,0,T_lowest);
      ObjectSetInteger(0,"Bottom Range Line",OBJPROP_COLOR,clrBlack);
      
      ObjectDelete(_Symbol, "Mid Range Line");
      ObjectCreate(_Symbol,"Mid Range Line",OBJ_HLINE,0,0,((T_highest - T_lowest) / 2) + T_lowest);
      ObjectSetInteger(0,"Mid Range Line",OBJPROP_COLOR,clrBlack);
   ++x;
   if(x == size || x > size){
         x = 0;
   }
   Print("To: ", To, " From: ", From, " Size: ", size, "int: ", x);
}
float FindHighestInIsolatedArray(float arr[], int arr_size, int start_index, int end_index)
{
    float isolated_arr[]; // initialize new array to empty
    
    for(int i=start_index; i<=end_index; i++)
    {
        ArrayResize(isolated_arr, ArraySize(isolated_arr)+1); // add one element to the isolated array
        isolated_arr[ArraySize(isolated_arr)-1] = arr[i]; // add the isolated value to the end of the isolated array
    }
    
    float highest_value = isolated_arr[0];
    for(int a=1; a<ArraySize(isolated_arr); a++)
    {
        if(isolated_arr[a] > highest_value)
        {
            highest_value = isolated_arr[a]; // update highest value if found a new highest value
        }
    }
    
    Print("The highest value within the isolated array is: ", highest_value);
}
/*On Sunday you have to complete the code from ChatGPT, we want an instant markup not one that takes too long*/

