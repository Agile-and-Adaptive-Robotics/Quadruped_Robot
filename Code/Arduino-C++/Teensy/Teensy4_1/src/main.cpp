#include <Arduino.h>
#include <Encoder.h>

//Create Objects
Encoder encoder1(2,3);
Encoder encoder2(4,5);
Encoder encoder3(6,7);

//Declare Variables
unsigned long previousTime = millis();
unsigned long timeInterval = 1; //1 ms
unsigned long previousTime1 = millis();
unsigned long timeInterval1 = 500; //.25 

int pressureSensor1 = 14;
int pressureSensor2 = 15;
int pressureSensor3 = 20;
int pressureSensor4 = 21;
int pressureSensor5 = 22;
int pressureSensor6 = 23;

int pressureReading1;
int pressureReading2;
int pressureReading3;
int pressureReading4;
int pressureReading5;
int pressureReading6;

double positionEncoder1 = -999.0;
double positionEncoder2 = -999.0;
double positionEncoder3 = -999.0;

void setup() {
  Serial.begin(115200);
  
  pinMode(32, OUTPUT); //Hip 1
  pinMode(33, OUTPUT); //Hip 2
  pinMode(34, OUTPUT); //Ankle 1
  pinMode(35, OUTPUT); //Knee 1
  pinMode(36, OUTPUT); //Ankle 2
  pinMode(37, OUTPUT); //Knee 2
}

void loop() {

  //Read Keyboard Input
  if(Serial.available()) {
    char input1 = Serial.read();
    if(input1 == '1') {
      digitalWrite(32, HIGH);
    }

    else if(input1 == '0') {
      digitalWrite(32,LOW);
    }
  }

  //Read Pressure Sensors
  unsigned long currentTime = millis();

  if (currentTime - previousTime >= timeInterval) {
    pressureReading1  = 0.797*analogRead(pressureSensor1)-127;
    pressureReading2  = 0.797*analogRead(pressureSensor2)-127;
    pressureReading3  = 0.797*analogRead(pressureSensor3)-127;
    pressureReading4  = 0.797*analogRead(pressureSensor4)-127;
    pressureReading5  = 0.797*analogRead(pressureSensor5)-127;
    pressureReading6  = 0.797*analogRead(pressureSensor6)-127;
    previousTime = currentTime;
  }

  //Print Pressure Sensor Data
  if (currentTime - previousTime1 >= timeInterval1) {
    Serial.print("Sensor 1:  ");
    Serial.print(pressureReading1);
    Serial.print("\t");
    Serial.print("Sensor 2:  ");
    Serial.print(pressureReading2);
    Serial.print("\t");
    Serial.print("Sensor 3:  ");
    Serial.print(pressureReading3);
    Serial.print("\t");
    Serial.print("Sensor 4:  ");
    Serial.print(pressureReading4);
    Serial.print("\t");
    Serial.print("Sensor 5:  ");
    Serial.print(pressureReading5);
    Serial.print("\t");
    Serial.print("Sensor 6:  ");
    Serial.print(pressureReading6);
    Serial.println();
    
    previousTime1 = currentTime;
  }

  // Reading Encoders
  double newEncoder1;
  double newEncoder2;
  double newEncoder3;

  newEncoder1 = encoder1.read()*0.04395; //Hip position in degrees
  newEncoder2 = encoder2.read()*0.04395; //Ankle position in degrees
  newEncoder3 = encoder3.read()*0.04395; //Knee position in degrees

  if (newEncoder1 != positionEncoder1) {
    positionEncoder1 = newEncoder1;
  }
   if (newEncoder2 != positionEncoder2) {
    positionEncoder2 = newEncoder2;
  } 
  if (newEncoder3 != positionEncoder3) {
    positionEncoder3 = newEncoder3;
  }

  if (currentTime - previousTime1 >= timeInterval1) 
  {
    Serial.print("Hip Angle = ");
    Serial.print(positionEncoder1);
    Serial.print("\t");
    Serial.print("\t");
    Serial.print("Knee Angle = ");
    Serial.print(positionEncoder3);
    Serial.print("\t");
    Serial.print("\t");
    Serial.print("Ankle Angle = ");
    Serial.print(positionEncoder2);
    Serial.println();
    previousTime1 = currentTime;
  }

}