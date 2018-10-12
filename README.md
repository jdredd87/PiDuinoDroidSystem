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

<b>Arduino.GarageOpener</b> - Arduino Nano - Controller for running relays, DHT11 Temp/Humidity Sensor, and RCWL Microwave Radar motion sensor.

<b>PiServer.GarageOpener</b> - Pi 3 B+ - 3.5" Touch Screen Pi running a simple HTTP Web Server to allow incoming connection calls. Communicates USB>Serial to Arduino.GarageOpener.


--------------------------------------
Development progress Videos 
--------------------------------------

https://www.youtube.com/watch?v=vZCPzQGDBzw
https://www.youtube.com/watch?v=oDaqcbC0SLI
https://www.youtube.com/watch?v=zTPaBP4n-cU
https://www.youtube.com/watch?v=LNig2HaAZyQ
https://www.youtube.com/watch?v=iCGkV5GjvTM

--------------------------------------
Arduino Side - Parts List
--------------------------------------

<b>Arduino NANO</b> https://www.amazon.com/ATmega328P-Microcontroller-Board-Cable-Arduino/dp/B00NLAMS9C/ref=sr_1_8?s=pc&ie=UTF8&qid=1539367762&sr=1-8&keywords=arduino+nano

<b>Arduino NANO terminal adapter</b> https://www.amazon.com/gp/product/B00X3L2RJK/ref=oh_aui_detailpage_o07_s00?ie=UTF8&psc=1

<b>DHT11 sensor</b> https://www.amazon.com/Sensitivity-Control-Temperature-Humidity-20-90-RH/dp/B01N017ZPW/ref=sr_1_4?s=electronics&ie=UTF8&qid=1539367848&sr=1-4&keywords=DHT11+SENSOR&dpID=41DtBtxuCHL&preST=_SY300_QL70_&dpSrc=srch
<b> I would recommend geting a DHT22 or better. DHT11 is what I had laying around at the time</b>

<b>RCWL-0516 motion sensor</b> https://www.amazon.com/gp/product/B06XCPCKFB/ref=oh_aui_detailpage_o02_s00?ie=UTF8&psc=1

<b>Dual Relay</b> https://www.amazon.com/SunFounder-Channel-Optocoupler-Expansion-Raspberry/dp/B00E0NTPP4/ref=sr_1_1_sspa?s=electronics&ie=UTF8&qid=1539367943&sr=1-1-spons&keywords=arduino+dual+relay&psc=1

Bread board and wires....



