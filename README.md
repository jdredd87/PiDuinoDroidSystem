# PiDuinoDroidSystem
My DIY Home Garage Opener and Security System ( Ties into my houses old Security System sensors/alarm )

My "new" home has an old 22 year old security system that isn't being used.

Doing initial testing, I was able to interface with sensors doing small tests.

I also have a "dumb" garage door openers, and doing small tests, was able to open them with an Arduino and relays.

So I figured I would try and tie this all up together making it overly complicated with a bunch of Pi's and Arduinos and other parts that I already had laying around.

This is built to be customized to my home setup. So no easy to use interfaces to add/remove/configure ect. All will be hard coded. At least in the very beginning to get stuff actually working. But I hope it gives people an idea down the road what can be done.

<b>Arduino IDE</b> for Arduino Programming
<b>Embarcadero Delphi</b> for any and all Android/iOS/Win32 Programming
<b>FreePascal / Lazarus</b> for ARM Linux Programming

------------------------------------

<b>Arduino.GarageOpener</b> - Arduino Nano - Controller for running relays and DHT11 Temp/Humidity Sensor

<b>PiServer.GarageOpener</b> - Pi 3 B+ - 3.5" Touch Screen Pi running a REST WebServer to allow incoming connection calls. Communicates USB>Serial to Arduino.GarageOpener.

<b>Arduino.SecurityBox</b> - Arduino Mega For Android Board - Controller for door sensors, motion sensor, alarm.

<b>Android.SecurityBox</b> - Android - UI Interface to Arduino.SecurityBox via USB to USB.


