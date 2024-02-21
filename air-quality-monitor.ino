/*
    Air Quality Monitor
    by Szymon Gierczak 000771448
*/

// MHZ19 Carbon Dioxide sensor library
#include "MHZ19.h" // https://github.com/WifWaf/MH-Z19

// PMS5003 PM2.5 sensor library
#include "PMS.h" //https://github.com/fu-hsi/pms

// MQ131 concentration ozone gas sensor library
#include "MQ131.h" // https://github.com/ostaquet/Arduino-MQ131-driver

// DHT22 humidity and temperature sensor library
#include "dht.h" // https://github.com/RobTillaart/DHTlib

// DS3231 real time clock library
#include "DS3231.h" // http://www.rinkydinkelectronics.com/library.php?id=73


#include <SoftwareSerial.h>
//#include <Wire.h>

//Includes SSD1306 display libraries
//#include <Arduino.h> 
//#include <U8g2lib.h> 
//#ifdef U8X8_HAVE_HW_SPI
//#include <SPI.h>
//#endif
//#ifdef U8X8_HAVE_HW_I2C
//#include <Wire.h>
//#endif


// Constructor for SSD1306
//U8G2_SSD1306_128X32_UNIVISION_F_HW_I2C u8g2(U8G2_R0, /* reset=*/ U8X8_PIN_NONE, /* clock=*/ SCL, /* data=*/ SDA);   // pin remapping with ESP8266 HW I2C

int sensorPin = A0;
int sensorValue = 0;

#define led 13 // Onboard LED
#define vocPin 7  // VOC sensor activation
#define dht22 5 // DHT22 temperature and humidity sensor

dht DHT; // Creats a DHT object
DS3231  rtc(SDA, SCL); // Initiate the DS3231 Real Time Clock module using the I2C interface
Time  t; // Init a Time-data structure
MHZ19 myMHZ19;    // CO2 Sensor

SoftwareSerial BTserial(19, 18);// Calls SoftwareSerial as BTserial on pins 19(RX) and 18(TX)
SoftwareSerial co2Serial(2, 3);  // MH-Z19 serial
SoftwareSerial pmsSerial(8, 9); // PM2.5 serial
PMS pms(pmsSerial);
PMS::DATA data;

unsigned long dataTimer = 0;
unsigned long dataTimer3 = 0;
unsigned long dataTimer4 = 0;

//Declare values for sensors 
int readDHT, temp, hum;
int CO2;
int o3;
int voc;
int pm25;
int hours, minutes;
int previousMinutes = 1;

String timeString;
String receivedData = "Z";
// Stores the last 24 hour sensor values in arrays, increments of 15, 24 hour we need 96 bytes.
uint8_t tempData[48] = {};
uint8_t humData[48] = {};
uint8_t vocData[48] = {};
uint8_t co2Data[48] = {};
uint8_t pm25Data[48] = {};
uint8_t o3Data[48] = {};
int8_t last24Hours[12] = {};
int maxV = 0;
int8_t r = 99;

void setup() {

  BTserial.begin(9600); // Opens serial connection for bluetooth
  pinMode(6, OUTPUT); // Ozone sensor pin
  pinMode(vocPin, OUTPUT); // VOC sensor pin
  
  // Warming up sensors
  digitalWrite(6, HIGH); // Ozone sensor
  digitalWrite(vocPin, HIGH); // VOC sensor
  delay(20 * 1000); // delay 20 seconds
  digitalWrite(6, LOW);
  digitalWrite(vocPin, LOW);
  
  // Initialize all sensors
  rtc.begin(); // Real time clock turns on
  co2Serial.begin(9600); // Opens serial connection for co2 sensor
  pmsSerial.begin(9600); // Opens serial connection for pm2.5 sensor
  myMHZ19.begin(co2Serial); // myMHZ19 connects to co2Serial
  myMHZ19.autoCalibration(false);  // Turn auto calibration off)
  MQ131.begin(6, A0, LOW_CONCENTRATION, 1000000); //
  MQ131.setTimeToRead(5); // Interval in seconds to read MHZ19
  MQ131.setR0(9000);
}
void loop() {
  
  // Read temperature and humidity from DHT22 sensor
  readDHT = DHT.read22(dht22); // Reads the data from the sensor
  temp = DHT.temperature; // Gets the values of the temperature
  hum = DHT.humidity; // Gets the values of the humidity

  // Read voc sensor for 2 seconds
  digitalWrite(vocPin, HIGH);
  delay(2000); // Keeps sensor on before reading
  voc = analogRead(A1); // Reading analog values from 0 to 1024 for voc.
  digitalWrite(vocPin, LOW);

  // Read CO2 sensor for 3 seconds
  co2Serial.listen();
  dataTimer = millis();
  while (millis() - dataTimer <= 3000) {
    CO2 = myMHZ19.getCO2(); // Request CO2 (as ppm)
  }

  // Read Particulate Matter sensor for 2 seconds
  pmsSerial.listen();
  dataTimer3 = millis();
  while (millis() - dataTimer3 <= 2000) {
    pms.readUntil(data);
    pm25 = data.PM_AE_UG_2_5;
  }

  // Read MQ131 Ozone sensor
  MQ131.sample();
  o3 = MQ131.getO3(PPB);

  // Get the time from the DS3231 Real Time Clock module
  t = rtc.getTime();
  hours = t.hour;
  minutes = t.min;
  // Store current sensors data
  storeData();

  // Send the data to bluetooth
  dataTimer4 = millis();
  while (millis() - dataTimer4 <= 200) {
    
    // Sends co2 data
    BTserial.print("co2V.val=");
    BTserial.print(CO2);
    
    // Sends PM2.5 data
    BTserial.print("pm25V.val=");
    BTserial.print(pm25);
    
    // Sends ozone data
    BTserial.print("o3V.val=");
    BTserial.print(o3);
    
    // Sends temperature data
    BTserial.print("tempV.val=");
    BTserial.print(temp);
    
    // Sends humdiity data  
    BTserial.print("humV.val=");
    BTserial.print(hum);
    
    // Sends voc data 
    BTserial.print("vocV.val=");
    BTserial.print(voc);
  }
}

void storeData() {
  // Storing current sensor values into arrays
  if ((minutes - previousMinutes) >= 15) {  // store the value each 2 minutes
    memmove(tempData, &tempData[1], sizeof(tempData)); // Slide data down one position
    tempData[sizeof(tempData) - 1] = temp; // store newest value to last position
    memmove(humData, &humData[1], sizeof(humData));
    humData[sizeof(humData) - 1] = hum;
    memmove(vocData, &vocData[1], sizeof(vocData));
    // we use bytes for storing the data, as we said the Arduino Pro mini doesn't have enough memory, so we must convert the values from 0 to 1000 to 0 to 255 which is one byte
    vocData[sizeof(vocData) - 1] = map(voc, 0, 1000, 0, 255);
    memmove(co2Data, &co2Data[1], sizeof(co2Data));
    co2Data[sizeof(co2Data) - 1] = map(CO2, 0, 3000, 0, 255);
    memmove(pm25Data, &pm25Data[1], sizeof(pm25Data));
    pm25Data[sizeof(pm25Data) - 1] = map(pm25, 0, 1000, 0, 255);
    memmove(o3Data, &o3Data[1], sizeof(o3Data));
    o3Data[sizeof(o3Data) - 1] = map(o3, 0, 1000, 0, 255);
    previousMinutes = minutes;

  }
  // So these if statemets check whether have passed 15 mins since the last time we stored a value - you can change this to any minutes you want, but you need to do that on both if statemets, for example "10" in the first if statement, and "-50" in the second if statement
  else if ((minutes - previousMinutes) == -45) { // when minutes start from 0, next hour
    memmove(tempData, &tempData[1], sizeof(tempData)); // Slide data down one position
    tempData[sizeof(tempData) - 1] = temp; // store newest value to last position
    memmove(humData, &humData[1], sizeof(humData));
    humData[sizeof(humData) - 1] = hum;
    memmove(vocData, &vocData[1], sizeof(vocData));
    vocData[sizeof(vocData) - 1] = map(voc, 0, 1000, 0, 255);
    memmove(co2Data, &co2Data[1], sizeof(co2Data));
    co2Data[sizeof(co2Data) - 1] = map(CO2, 0, 3000, 0, 255);
    memmove(pm25Data, &pm25Data[1], sizeof(pm25Data));
    pm25Data[sizeof(pm25Data) - 1] = map(pm25, 0, 1000, 0, 255);
    memmove(o3Data, &o3Data[1], sizeof(o3Data));
    o3Data[sizeof(o3Data) - 1] = map(o3, 0, 1000, 0, 255);
    previousMinutes = minutes;
  }
}
