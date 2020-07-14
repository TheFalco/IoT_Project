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
  
  //Stores the last 50 IDs received
  uint8_t received_id [Mem_Length];
  
  event void Boot.booted() {
  
  	//After the boot of the mote, start radio component
  	dbg("log", "Mote %u: mote booted.\n", TOS_NODE_ID);
    call AMControl.start();
  }

  event void AMControl.startDone(error_t err) {
  	dbg("log", "Mote %u: radio module active.\n", TOS_NODE_ID);
    //After radio module start, create timer (500ms)
    call MilliTimer.startPeriodic(500);	
  }

  event void MilliTimer.fired() {
    dbg("log", "Mote %u: timer fired.\n", TOS_NODE_ID);
    if (locked) {
      return;
    }
    else {
      radio_msg_t* rcm = (radio_msg_t*)call Packet.getPayload(&packet, sizeof(radio_msg_t));
      if (rcm == NULL) {
      	dbg("log", "Mote %u: error creating new message. No message will be sent.\n", TOS_NODE_ID);
        return;
      }
      
      //Send mote ID as broadcast message through radio component
      rcm->id = TOS_NODE_ID;
      if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(radio_msg_t)) == SUCCESS) {
      	dbg("log", "Mote %u: broadcast message sent.\n", TOS_NODE_ID);
        locked = TRUE;
      }
    }
  }
 
  void saveID(uint8_t ID) {
  
    //Don't save the same ID twice if you receive it one after the other
    if (cnt > 0 && received_id[cnt - 1] != ID) {
      if (cnt < Mem_Length) {
      	dbg("log", "Mote %u: storing ID in memory... ID: %u.\n", TOS_NODE_ID, ID);
        received_id[cnt] = ID;
        dbg("log", "Mote %u: ID stored. ID: %u.\n", TOS_NODE_ID, ID);
        cnt++;
      } 
      else {
        //If the array is full, shift-left the cells of the array by one
        dbg("log", "Mote %u: memory is full, left-shift FIFO.\n", TOS_NODE_ID);
        for (i = 0; i < Mem_Length - 1; i++) {
          received_id[i] = received_id[i + 1];
        }
        dbg("log", "Mote %u: shift completed.\n", TOS_NODE_ID);
        //and add the last received ID
        dbg("log", "Mote %u: storing ID in memory... ID: %u.\n", TOS_NODE_ID, ID);
        received_id[Mem_Length - 1] = ID;
        dbg("log", "Mote %u: ID stored. ID: %u.\n", TOS_NODE_ID, ID);
      }
      return;
    }
    else{
    	dbg("log", "Mote %u: ID already present in memory in the last position. ID: %u.\n", TOS_NODE_ID, ID);
    }
    if (cnt == 0) {
      dbg("log", "Mote %u: no IDs saved. Storing the first one in memory... ID: %u.\n", TOS_NODE_ID, ID);
      received_id[cnt] = ID;
      dbg("log", "Mote %u: first ID stored. ID: %u.\n", TOS_NODE_ID, ID);
      cnt++;
      return;
    }
  } 
 
  event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len) {
    if (len != sizeof(radio_msg_t)) {
      dbg("log", "Mote %u: received malformed packet.\n", TOS_NODE_ID);
      return bufPtr;
    }
    else {
      radio_msg_t* rcm = (radio_msg_t*)payload;
      dbg("log", "Mote %u: received packet from mote %u.\n", TOS_NODE_ID, rcm->id);
      //Store the received ID in the received_id array
      dbg("log", "Mote %u: saving in memory last id received (%u)...\n", TOS_NODE_ID, rcm->id);
      saveID(rcm->id);
      
      //Forward the received ID through corresponding port for node-red (using printf function)
      dbg("log", "Mote %u: forwarding message to Node-Red. id: %u.\n", TOS_NODE_ID, rcm->id);
      printf("%u\n", rcm->id);
      dbg("log", "Mote %u: forward done. message id: %u.\n", TOS_NODE_ID, rcm->id);
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
