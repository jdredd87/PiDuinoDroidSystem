# PiDuinoDroidSystem
My DIY Home Garage Opener 

I have a "dumb" garage door opener system, and doing small tests, was able to open them with an Arduino and relays.

So I figured I would try and tie this all up together making it overly complicated with Pi's and Arduinos and other parts that I already had laying around.

This is built to be customized to my setup. So no easy to use interfaces to add/remove/configure ect. All will be hard coded. At least in the very beginning to get stuff actually working. But I hope it gives people an idea down the road what can be done.

Some things I will be long hand coding until I am happy then will see about going back around to optimize. 

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

--------------------------------------
Raspberry Pi Side - Parts List
--------------------------------------

<b>Raspberry Pi 3 B+</b> https://www.adafruit.com/product/3775?gclid=CjwKCAjwjIHeBRAnEiwAhYT2h9VmcdKUHQMfaMPVxf_UVYF8soZdEQLZq4ty0Nue1fsj5kMxVL4vxhoCd9gQAvD_BwE

<b>3.5" TFT Screen</b> https://www.adafruit.com/product/2441

--------------------------------------
Recommend to add this to possibly fix any WIFI dropping over time.
--------------------------------------

added to /etc/rc.local:

iwconfig wlan0 power off

--------------------------------------
Guides / Help / Components used for the Pi / Lazarus
--------------------------------------

<b>FreePascal / Lazarus</b>
https://backports.debian.org/Instructions/ <---- needed to run latest FPC/Lazarus
https://forum.lazarus.freepascal.org/index.php/topic,38728.15.html <---- when I had issues installing components
https://github.com/JurassicPork/TLazSerial <---- Serial Port component for Lazarus / Linux
http://wiki.freepascal.org/Indy_with_Lazarus <---- INDY components for Lazarus

--------------------------------------
Wiring Diagram
--------------------------------------


[[https://github.com/jdredd87/PiDuinoDroidSystem/blob/master/Wiring-Diagram.png|alt=wiring]]
