# Keep your distance!

This project aims to design and implement a software prototype for a social distancing application using TinyOS, Node-Red and IFTTT, tested with Cooja. 

The application is meant to understand and to alert you when two people (motes) are close to each other. 

### TinyOS
- Each mote broadcasts its presence every 500ms with a message containing its ID number. Other motes receive this message only if they are adequately near.
- When a mote is in the proximity area of another mote and receive a message, it stores the received mote ID and triggers an alarm. Such alarm contains the ID number of the near mote. It is shown in Cooja and forwarded to Node-Red with a different socket for each mote.

### Node-Red
- Upon the reception of the alert, Node-red sends a notification through IFTTT to the corresponding user's mobile phone.

