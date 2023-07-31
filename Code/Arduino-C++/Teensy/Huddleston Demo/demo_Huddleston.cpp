#include <Arduino.h>
#include <Encoder.h>

//Create Objects
Encoder encoder1(2,3);
Encoder encoder2(4,5);
Encoder encoder3(6,7);

//Declare Variables
unsigned long previousTime = 0;
unsigned long timeInterval = 4000; // 1 s
unsigned long previousTime1 = millis();
unsigned long timeInterval1 = 100; //.25 

int demoMode = 0;

int Hip1   = 32; // Hip 1
int Hip2   = 33; // Hip 2
int Ankle1 = 34; // Ankle 1
int Ankle2 = 36; // Ankle 2
int Knee1  = 35; // Knee 1
int Knee2  = 37; // Knee 2

int stateH1 = LOW;
int stateH2 = LOW;
int stateA1 = LOW;
int stateA2 = LOW;
int stateK1 = LOW;
int stateK2 = LOW;

double positionEncoder1 = -999.0;
double positionEncoder2 = -999.0;
double positionEncoder3 = -999.0;

unsigned long currentTime;
int value = 1000;

void updateActuators() 
{
    previousTime = currentTime;
    digitalWrite(Hip1, stateH1);
    digitalWrite(Hip2, stateH2);
    digitalWrite(Knee1, stateK1);
    digitalWrite(Knee2, stateK2);
    digitalWrite(Ankle1, stateA1);
    digitalWrite(Ankle2, stateA2);
}

void setup() 
{
  Serial.begin(115200);

  pinMode(Hip1, OUTPUT);
  pinMode(Hip2, OUTPUT);
  pinMode(Ankle1, OUTPUT);
  pinMode(Ankle2, OUTPUT);
  pinMode(Knee1, OUTPUT);
  pinMode(Knee2, OUTPUT);
}

void loop() 
{

  currentTime = millis();

  // Serial Interfacing
  if(Serial.available()) {
    char input1 = Serial.read();
    if(input1 == '1') {
        demoMode = 1;
        stateH1 = HIGH;
        stateH2 = LOW;
        stateK1 = LOW;
        stateK2 = HIGH;
        stateA1 = HIGH;
        stateA2 = LOW;
        updateActuators();   
    }

    if(input1 == '0') {
        demoMode = 0;
        stateH1 = LOW;
        stateH2 = LOW;
        stateK1 = LOW;
        stateK2 = LOW;
        stateA1 = LOW;
        stateA2 = LOW;
        updateActuators(); 
    }

    if(input1 == '9') 
    {    
        encoder1.write(0);
        encoder2.write(0);
        encoder3.write(0);
    }
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

  //Movement State Machine

  if((demoMode == 1) && (positionEncoder1 > 47) && (positionEncoder3 < 45) && (positionEncoder2 > 27)) 
  {
    demoMode = 2;
    stateH1 = HIGH;
    stateH2 = LOW;
    stateK1 = HIGH;
    stateK2 = LOW;
    stateA1 = HIGH;
    stateA2 = LOW;
    updateActuators(); 
  }

  if((demoMode == 2) && (positionEncoder1 > 47) && (positionEncoder3 > 60) && (positionEncoder2 > 27)) 
  {
    demoMode = 3;
    stateH1 = LOW;
    stateH2 = HIGH;
    stateK1 = HIGH;
    stateK2 = LOW;
    stateA1 = LOW;
    stateA2 = HIGH;
    updateActuators();   
  }

  if((demoMode == 3) && (positionEncoder1 < 30) && (positionEncoder3 > 70) && (positionEncoder2 < 25)) 
  {
    demoMode = 4;
    stateH1 = LOW;
    stateH2 = HIGH;
    stateK1 = LOW;
    stateK2 = HIGH;
    stateA1 = LOW;
    stateA2 = HIGH;
    updateActuators();  
  }

  if((demoMode == 4) && (positionEncoder1 < 25) && (positionEncoder3 < 55) && (positionEncoder2 < 20)) 
  { 
    demoMode = 5;
    stateH1 = LOW;
    stateH2 = LOW;
    stateK1 = LOW;
    stateK2 = LOW;
    stateA1 = LOW;
    stateA2 = LOW;
    updateActuators();  
  } 

  if((demoMode == 5) && (currentTime - previousTime >= timeInterval)) 
  { 
    demoMode = 1;
    stateH1 = HIGH;
    stateH2 = LOW;
    stateK1 = LOW;
    stateK2 = HIGH;
    stateA1 = HIGH;
    stateA2 = LOW;
    updateActuators();  
  } 

}