# Set up IFTTT

In order to set up proprly IFTTT you have first to create an account on the [website](https://ifttt.com 'IFTTT main page') and then to create the right _applet_.

## Create your Applet

In order to do create the applet, from the main page of IFTTT's website press '_create_' or simply go to the following [link](https://ifttt.com/create 'Create web page').  
  
  
You have to choose first a service and then a required action to be performed.
- Service:  
Choose '__Webhooks__' and then '_Receive a web request_'.  
Now choose the event name: for this project we used `Keep_your_distance!`
- Action:  
Search for '__Notifications__' and then press on '_Send a notification from the IFTTT app_'.  
Now you can customise you notification text: we used `Keep your distance from mote {{Value1}}! On {{OccurredAt}} you were too close to another person.`  
  
Finally, press '__Create Action__' and '__Finish__'! Your _applet_ is now ready.

## Setting Node-RED

You need to retrive your personal key and replace the text '_YOURKEY_' from the template URL in the first two webrequests node with your key.  
The key can be find following this path: __My services__ -> __Webhooks__ -> __Settings__ and consists of the final part of the URL present on the page.   
`https://maker.ifttt.com/use/XXXXXXXXXXXXX`

## Receiving the notification

Just install _IFTTT_ mobile app and login.
