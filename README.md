# PiDuinoDroidSystem
My DIY Home Garage Opener and Security System ( Ties into my houses old Security System sensors/alarm )

My "new" home has an old 22 year old security system that isn't being used.

Doing initial testing, I was able to interface with sensors doing small tests.

I also have a "dumb" garage door openers, and doing small tests, was able to open them with an Arduino and relays.

So I figured I would try and tie this all up together making it overly complicated with a bunch of Pi's and Arduinos and other parts that I already had laying around.

------------------------------------

<b>Arduino.GarageOpener</b> - Arduino Nano - Controller for running relays and DHT11 Temp/Humidity Sensor

<b>PiServer.GarageOpener</b> - Pi 3 B+ - 3.5" Touch Screen Pi running a REST WebServer to allow incoming connection calls. Communicates USB>Serial to Arduino.GarageOpener.

<b>Arduino.SecurityBox</b> - Arduino Mega For Android Board - Controller for door sensors, motion sensor, alarm.

<b>Android.SecurityBox</b> - Android - UI Interface to Arduino.SecurityBox via USB to USB.


