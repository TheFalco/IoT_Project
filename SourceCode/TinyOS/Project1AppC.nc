#define NEW_PRINTF_SEMANTICS
#include "printf.h"
#include "Project1.h"

configuration Project1AppC{
}
implementation {

  /****** COMPONENTS *****/
  components MainC, Project1C as App;
  components new TimerMilliC();
  components PrintfC;
  components SerialStartC;
  components new AMSenderC(AM_RADIO_COUNT_MSG);
  components new AMReceiverC(AM_RADIO_COUNT_MSG);
  components ActiveMessageC;

/****** INTERFACES *****/
  App.Boot -> MainC.Boot;
  App.MilliTimer -> TimerMilliC;
  App.AMSend -> AMSenderC;
  App.Packet -> AMSenderC;
  App.Receive -> AMReceiverC;
  App.AMControl -> ActiveMessageC;
}
