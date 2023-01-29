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
CButton Buy_Button;
CButton Sell_Button;
CEdit AccountSize_Edit;
CLabel AccountSize_Label;
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

struct HCandles  {   int RCN;      //RCN (Recent Candle Num)
                  double High;  // High
                  double Low;     // Low
                  double Open;       // Open
                  double Close;        // High
                  string CandleType;        // CandleType true = Bull, false = Bear
                  string Pattern;
                  datetime Time; //Time Printed
};
HCandles HCandles_[3]; 


int OnInit() {
   CandleType();
   StopLoss_d = CurrentPrice() - 0.0005;
   if(!OMB_E.Create(0, "O(M).Brain Execution",0,20,20,360,424))
      return(INIT_FAILED);
   if(!CreateBuy_Button())
      return(false);
   if(!CreateSell_Button())
      return(false);
   if(!OMB_E.Add(Buy_Button))
      return(false);
   if(!OMB_E.Add(Sell_Button))
      return(false);
   if(!Create_StopLossEdit())
      return(false);
   if(!OMB_E.Add(StopLoss_Edit))
      return(false);
   if(!Create_StopLossLabel())
      return(false);
   if(!OMB_E.Add(StopLoss_Label))
      return(false);
      
   if(!Create_AccountSizeEdit())
      return(false);
   if(!OMB_E.Add(AccountSize_Edit))
      return(false);
   if(!Create_AccountSizeLabel())
      return(false);
   if(!OMB_E.Add(AccountSize_Label))
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
      
   OMB_E.Run();
   return(INIT_SUCCEEDED);   
}
void OnDeinit(const int reason) {
   OMB_E.Destroy(reason);
}
bool CreateBuy_Button(void) {
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP;
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
   int y1=INDENT_TOP;
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
      
   return(true);
}
bool Create_AccountSizeEdit(void) {
   int x1=INDENT_LEFT + 106;
   int y1=INDENT_TOP + 60;
   int x2=x1+BUTTON_WIDTH + 50;
   int y2=y1+BUTTON_HEIGHT;
   if(!AccountSize_Edit.Create(0, "AccSize", 0,x1,y1,x2,y2))
      return(false);
   if(!AccountSize_Edit.Text(AccountSize))
      return(false);
   if(!AccountSize_Edit.TextAlign(ALIGN_RIGHT))
      return(false);
   if(!AccountSize_Edit.ReadOnly(true))
      return(false);
   if(!AccountSize_Edit.ColorBackground(clrGray))
      return(false);
   if(!OMB_E.Add(AccountSize_Edit))
      return(false);
      
   return(true);
}
bool Create_AccountSizeLabel(void) {
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP + 60;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
   
   if(!AccountSize_Label.Create(0, "Acc Size: ", 0,x1,y1,x2,y2))
      return(false);
   if(!AccountSize_Label.Text("Acc Size: "))
      return(false);
   if(!OMB_E.Add(AccountSize_Label))
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
      
   return(true);
}
string OrderType_ = "Buy";
double StopLoss_d = 0.0;
double AccountSize = 200000;
float LotSize = 0.0;
void OnChartEvent(const int id,
                  const long& lparam,
                  const double& dparam,
                  const string& sparam) {
   OMB_E.ChartEvent(id,lparam,dparam,sparam);
   
   if(id==CHARTEVENT_OBJECT_CLICK){
      if(sparam=="Buy"){
         CandleType();
         StopLoss_d = CurrentPrice() - 0.0005;
         OderType_Label.Text("Order Type: Buy");
         OrderType_ = "Buy";
         DisplayLines();
         Print("Order Type Set To Buy");
      }
      if(sparam=="Sell"){
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
      
      
      if(sparam=="Market Execution") {
         MEX();
         ObjectDelete(_Symbol, "Entry Line");
         ObjectDelete(_Symbol, "Stop Loss Line");
         ExpertRemove();
      }
   }
   if(id==CHARTEVENT_OBJECT_ENDEDIT){
      if(sparam=="Stop Loss") {
         StopLoss_d = StopLoss_Edit.Text();
         DisplayLines();
         Print("Manual: Stop Loss Changed to ", StopLoss_Edit.Text());
      }
   }
}
void OnTick() {
   CandleType();
   DisplayLines();
}
//Function that access the bars through MQLRates, then returns what is requested
double MQLR_Bars(int i, string Request){
   //Data Processing
   int HighestCandle, LowestCandle;
   
   double High[], Low[];
   
   ArraySetAsSeries(High, true);
   
   ArraySetAsSeries(Low, true);
   
   CopyHigh(_Symbol,PERIOD_CURRENT,0,3,High);
   
   CopyLow(_Symbol,PERIOD_CURRENT,0,3,Low);
   
   HighestCandle = ArrayMaximum(High,3,0);
   LowestCandle = ArrayMinimum(Low,3,0);
   
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
int i = 0;
void CandleType() {
   for(i;i<3;i++) {
      HCandles_[i].Close = iClose(_Symbol, PERIOD_CURRENT, i);
      HCandles_[i].Open = iOpen(_Symbol, PERIOD_CURRENT, i);
      HCandles_[i].High = iHigh(_Symbol, PERIOD_CURRENT, i);
      HCandles_[i].Low = iLow(_Symbol, PERIOD_CURRENT, i);
      HCandles_[i].Time = MQLR_Bars(i, "Time");
      //Bullish or Bearish?
      if(HCandles_[i].Open < HCandles_[i].Close){
         HCandles_[i].CandleType = "Bullish";
      }
      else {
         HCandles_[i].CandleType = "Bearish";
      }
   }
}
double CurrentPrice() {
   return iClose(_Symbol, PERIOD_CURRENT, 0);
}

void DisplayLines(){
   string EntryLineName = "Entry Line";
   ObjectDelete(_Symbol, EntryLineName);
   ObjectCreate(_Symbol, EntryLineName, OBJ_HLINE,0,HCandles_[0].Time, CurrentPrice());
   ObjectSetInteger(0,EntryLineName,OBJPROP_COLOR,clrAqua);
   ObjectSetInteger(0,EntryLineName,OBJPROP_ZORDER,0);
   string SL_LineName = "Stop Loss Line";
   ObjectDelete(_Symbol, SL_LineName);
   ObjectCreate(_Symbol, SL_LineName, OBJ_HLINE,0,HCandles_[0].Time, StopLoss_d);
   ObjectSetInteger(0,SL_LineName,OBJPROP_COLOR,clrRed);
   ObjectSetInteger(0,SL_LineName,OBJPROP_ZORDER,0);
   
   PipLot_Label.Text("Pips / Lot: " + PipCount_() + " / " + LotSize_Calc());
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
   return StringSubstr((AccountSize * 0.01) / (10 * PipCount_()),0,4);
}
void MEX() {
   if(OrderType_ == "Buy") {
      OrderSend(_Symbol, OP_BUY, LotSize_Calc(),NULL,3,StopLoss_d,NULL,NULL,NULL,0,clrGreen);
   }
   else if(OrderType_ == "Sell") {
      OrderSend(_Symbol, OP_SELL, LotSize_Calc(),NULL,3,StopLoss_d,NULL,NULL,NULL,0,clrRed);
   }
}

/*
Not Really important but an attempt to fix buttons and other inside 
elements positions base on panel position.
But the program is really just a One and Done thing. 
double UI_Correction_y() {
   return OMB_E.Top() - 20;
}
double UI_Correction_x() {
   return OMB_E.Left() - 20;
}*/ 