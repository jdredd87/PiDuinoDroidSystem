/* Arduino dual garage door controller - Steven Chesser - Steven.Chesser@TWC.COM */

/* This uses very simple calls / responses.
    The client side will send over a single char.
    The response will be %name%value with a CRLF.
    This was written for MY home situation so if you have more than two doors or just one, just modify the code to fit the bill.
    Or modify it further to be configurable.
*/


/* Hardware used for this.

   Arduino NANO
   DHT11 Temperature / Humdity Sensor  ( this may switch to DHT22 or better )
   RCWL-0516 Microwave Radar Sensor ( toggle pi that there is motion near by to enable touch screen )
   Isolated Dual Relay ( toggle garage doors to open or close )
   Piezo Buzzer ( make tones )
   Two Magnetic Door Switches ( used to detect garage door is opened or closed )
*/

/*
  Controller Input Codes
  1 = Activate Relay 1
  2 = Activate Relay 2
  3 = Activate Relay 1 & 2
  4 = Get magnets 1 & 2 state
  R = Reset
  T = Get temperature and humidity
  S = Enable sounds ( buzzer tones )
  M = Disable sounds ( mute buzzer )
  A = Get sound state
*/

/*
  Controller Responses
  1 = %relay1%
  2 = %relay2%
  3 = %relay1%
      %relay2%
  4 = %magsensor%messagetext = door1;door2 states
  R = %init%messagetext
  T = %dht11error%messagetext = DHT11 sensor error message
  T = %dht11data%messagetext = DHT11 sensor data, *F;*C;Humidity%
  S = %sound%1 = sounds on
  M = %sound%0 = sounds off
  A = %sound%1 or %sound%0
*/

/*
   SimpleDHT Library by Winlin  @ https://github.com/winlinvip/SimpleDHT
*/


#include <SimpleDHT.h>

/* Define our PINs and Variables */

#define buzzerPin 3
#define magnet1Pin 7
#define magnet2Pin 8
#define DHT11Pin 9
#define motionPin 2

int build = 1; // build version that will show up on the pi

int relay1Pin = A0; // garage door relay 1
int relay2Pin = A1; // garage door relay 2

int magState1; // garage door 1 magnet door sensor
int magState2; // garage door 2 magnet door sensor

int DHTerr; // DHT11 Temp sensor error

int motionVal = 0; // RCWL motion sensor value

double motionCheck = 0; // Dummy counter to delay motion sensing ( could a resistor maybe to adjust sensativty and skip this )

byte temperatureF = 0; // DHT11 temp in *F
byte temperatureC = 0; // DHT11 temp in *C
byte humidity = 0; // DHT11 humidity in %

bool useSound = false; // toggle buzzer sound

/* Setup Arduino */

SimpleDHT11 dht11(DHT11Pin);

void setup() {

  pinMode(buzzerPin, OUTPUT);
  pinMode(relay1Pin, OUTPUT);
  pinMode(relay2Pin, OUTPUT);
  pinMode(motionPin, INPUT);
  pinMode(magnet1Pin, INPUT_PULLUP);
  pinMode(magnet2Pin, INPUT_PULLUP);
  digitalWrite(relay1Pin, HIGH); // set relays so they are open
  digitalWrite(relay2Pin, HIGH);

  Serial.begin(9600);
  Serial.flush();

  Serial.println("%init%Starting Garage Door Service");
  Serial.print("%build%");

  Serial.println(int(build));
  delay(1000);
  Serial.println("%msg%");
}

void(* resetFunc) (void) = 0;

void loop() {

  motionCheck++; // dumpy way of limiting reporting from the motion sensor
  // 20,000 ticks here to allow the next check
  // can use a resistor to reduce the sensitivity
  // but this was my work around for that for now as I wanted
  // high sensativity but reduce the ammount of times it was needed
  // to check and report back.

  if (motionCheck > 20000) {
    motionVal = digitalRead(motionPin);
    if (motionVal > 0) {
      Serial.println("%motion%");
    }
    motionCheck = 0;
  }


  magState1 = digitalRead(magnet1Pin);
  magState2 = digitalRead(magnet2Pin);

  // beep 
  if (magState1 == HIGH) {
    if (useSound) {
      tone(buzzerPin, 400);
      delay(250);
      noTone(buzzerPin);
    }
  }

// beep

  if (magState2 == HIGH) {  
    if (useSound) {
      tone(buzzerPin, 800);
      delay(250);
      noTone(buzzerPin);
    }
  }


// if we got datavail lets read it and see if we have any valid command chars
// and do some work and send back a response

  if (Serial.available()) {

    char recieved = Serial.read();

    if (recieved == '1') // toggle door 1
    {
      recieved = 0;
      Serial.flush();
      if (useSound) {
        tone(buzzerPin, 1000);

        delay(500);
        tone(buzzerPin, 500);
        delay(500);
        noTone(buzzerPin);
      }
      digitalWrite(relay1Pin, LOW);
      delay(150);
      digitalWrite(relay1Pin, HIGH);
      Serial.println("%relay1%");
    }
    else if (recieved == '2') // toggle door 2
    {
      recieved = 0;
      Serial.flush();
      if (useSound) {
        tone(buzzerPin, 2000);
        delay(500);
        tone(buzzerPin, 1500);
        delay(500);
        noTone(buzzerPin);
      }
      digitalWrite(relay2Pin, LOW);
      delay(150);
      digitalWrite(relay2Pin, HIGH);
      Serial.println("%relay2%");
    }
    else if (recieved == '3') // toggle both doors
    {
      recieved = 0;
      Serial.flush();
      if (useSound) {
        tone(buzzerPin, 3000);
        delay(500);
        tone(buzzerPin, 2500);
        delay(500);
        noTone(buzzerPin);
      }
      digitalWrite(relay1Pin, LOW);
      digitalWrite(relay2Pin, LOW);
      delay(150);
      digitalWrite(relay1Pin, HIGH);
      digitalWrite(relay2Pin, HIGH);
      Serial.println("%relay1%");
      Serial.println("%relay2%");

    }
    else if (recieved == '4') // get mag sensors data
    {
      if (magState1 == HIGH) {
        Serial.print("%magsensor%1");
      } else
      {
        Serial.print("%magsensor%0");
      }

      if (magState2 == HIGH) {
        Serial.println(";1");
      } else
      {
        Serial.println(";0");
      }
    }
    else if (recieved == 'R') // reset code
    {
      recieved = 0;
      Serial.flush();
      resetFunc();
    }
    else if (recieved == 'B') // get build
    {
      recieved = 0;
      Serial.print("%build%");
      Serial.println(int(build));
    }
    else if (recieved == 'T') // get temps
    {
      recieved = 0;
      DHTerr = SimpleDHTErrSuccess;
      temperatureF = 255;
      temperatureC = 255;
      humidity = 255;
      if ((DHTerr = dht11.read(&temperatureC, &humidity, NULL)) != SimpleDHTErrSuccess) {
        Serial.print("%dht11error%");
        Serial.println(DHTerr);
      } else
      {
        temperatureF = round((1.8 * temperatureC) + 32);
        Serial.print("%dht11data%");
        Serial.print((int)temperatureF); Serial.print(';');
        Serial.print((int)temperatureC); Serial.print(';');
        Serial.println((int)humidity);
      }
    }
    else if (recieved == 'S') // toggle sound on
    {
      recieved = 0;
      useSound = true;
      Serial.println("%sound%1");
    }
    else if (recieved == 'M') // toggle sound mute
    {
      recieved = 0;
      useSound = false;
      Serial.println("%sound%0");
    }
    else if (recieved == 'A') // get sound state
    {
      recieved = 0;
      Serial.print("%sound%");
      Serial.println(String(useSound));

    }
  }
}
