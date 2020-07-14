#include "printf.h"
#include "Timer.h"
#include "Project1.h"
#define Mem_Length 50

module Project1C {
  uses {
    interface Boot;
    interface Receive;
    interface AMSend;
    interface Timer<TMilli> as MilliTimer;
    interface SplitControl as AMControl;
    interface Packet;
  }
}

implementation {
  message_t packet;
  bool locked;
  uint8_t i;
  uint8_t cnt = 0;
  //Stores the last 50 ID received
  uint8_t received_id [Mem_Length];

  void saveID(uint8_t ID) {
    //Don't save the same ID twice if you receive it one after the other
    if (cnt >= 1 && received_id[cnt] != ID) {
      if (cnt < Mem_Length) {
        received_id[cnt] = ID;
        cnt++;
      } else {
        //If we don't have enough space, clear the array and star over
        for (i = 0; i < Mem_Length; i++) {
          received_id[i] = 0;
        }
        received_id[0] = ID;
        cnt = 1;
      }
      return;
    }
    if (cnt == 0) {
      received_id[cnt] = ID;
      return;
    }
  }
 
  event void Boot.booted() {
    call AMControl.start();
  }

  event void AMControl.startDone(error_t err) {
    //Start Timer of 500 ms
    call MilliTimer.startPeriodic(500);	
  }

  event void MilliTimer.fired() {
    if (locked) {
      return;
    }
    else {
      radio_msg_t* rcm = (radio_msg_t*)call Packet.getPayload(&packet, sizeof(radio_msg_t));
      if (rcm == NULL) {
        return;
      }
      //Send broadcast mote's ID
      rcm->id = TOS_NODE_ID;
      if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(radio_msg_t)) == SUCCESS) {
        locked = TRUE;
      }
    }
  }

  event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len) {
    if (len != sizeof(radio_msg_t)) {
      return bufPtr;
    }
    else {
      radio_msg_t* rcm = (radio_msg_t*)payload;
      //Store the received ID
      saveID(rcm->id);
      //Forward the received ID
      printf("%u\n", rcm->id);
      printfflush();
      return bufPtr;
    }
  }

  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
    if (&packet == bufPtr) {
      locked = FALSE;
    }
  }

  event void AMControl.stopDone(error_t err) {
    // do nothing
  }
}
