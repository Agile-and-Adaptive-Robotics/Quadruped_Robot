/*
 * Angle_Test
 * 
 * Tests control of test bench leg through pulse width modulation (PWM)
 * Program outputs angle of hip, knee, and ankle joint during pulsing
 * 
 * Author: Flora Huang
 * Last Updated: 7 July 2022
 */
 
# include <Arduino.h>
# include <Encoder.h>

// Define pins for muscles:
# define Hip1 32
# define Hip2 33
# define Ankle1 34
# define Ankle2 36
# define Knee1 35
# define Knee2 37

// Create Encoder objects for joints:
Encoder encoderHip(2,3);
Encoder encoderAnk(4,5);
Encoder encoderKne(6,7);

// Variables for joints:
float angleHip, angleKne, angleAnk;         // Averaged joint angle

// Variables for muscles:
int currMuscle;   // Muscle currently being pulsed

// Variables for controlling program flow (time, on/off, etc.):
unsigned long pulseStart    = 0;          // Time pulsing began
bool pulsing                = false;      // Whether a muscle is currently being pulsed
unsigned long previousPrint = millis();   // Previous time data was printed

void setup() {
  Serial.begin(115200);

  // Set pins to output:
  pinMode(Hip1, OUTPUT);
  pinMode(Hip2, OUTPUT);
  pinMode(Ankle1, OUTPUT);
  pinMode(Ankle2, OUTPUT);
  pinMode(Knee1, OUTPUT);
  pinMode(Knee2, OUTPUT);
}

void loop() {
  // Monitor for inputs if no muscle is pulsing:
  if (!pulsing) {
    if (Serial.available()) {   
      selectMuscle(Serial.read());   // Translate user input into corresponding muscle

      // Begin pulsing if valid input is received: 
      if (currMuscle != -1) {
        pulseStart = millis();
        pulsing = true;
        setupPulse();
      }

      Serial.flush();
    } 
  } 
  // Pulse muscle for 10 seconds, then reset muscles
  else {
    if (millis() - pulseStart <= 10000) {
      pulseMuscle();
      updateJointInfo();
      displayJointInfo();
    } 
    else {
      pulsing = false;
      resetMuscles();
    }
  }
}

void selectMuscle(char userInput) {
/*
 * Selects muscle that corresponds with userNum
 */  
  switch (userInput) {
    case '1':
      currMuscle = Hip1;
      break;
    case '2':
      currMuscle = Hip2;
      break;
    case '3':
      currMuscle = Ankle1;
      break;
    case '4':
      currMuscle = Ankle2;
      break;
    case '5':
      currMuscle = Knee1;
      break;
    case '6':
      currMuscle = Knee2;
      break;
    default:
      currMuscle = -1;   // -1 indicates invalid input was entered
      break;
  }
}

void setupPulse() {
/*
 * Reset variables to prepare for pulsing
 */
  angleHip = encoderHip.read()*0.04395;
  angleKne = encoderKne.read()*0.04395;
  angleAnk = encoderAnk.read()*0.04395;
}

void pulseMuscle() {
/*
 * Pulses given muscle
 */
  // Variables for pulsing:
  int dtOn    = 30;                  // [ms] Time on HIGH per period
  int freq    = 20;                  // [Hz] Number of periods per 1000 milliseconds
  int period  = 1000/freq;           // [ms] Length of each period
  int relTime = millis() % period;   // Relative time within each period

  // Turn muscle on or off based on relative time:
  if (relTime <= dtOn) {
    digitalWrite(currMuscle, HIGH);
  } else {
    digitalWrite(currMuscle, LOW);
  }
}

void updateJointInfo() {
/*
 * Read and update joint angles
 */
  float beta = 0.15;
  float tempAvgHip = 0, tempAvgKne = 0, tempAvgAnk = 0;

  // Sum 20 angle readings for each joint and convert to degrees:
  for (int i=0; i<20; i++) {
    tempAvgHip += encoderHip.read()*0.04395;
    tempAvgKne += encoderKne.read()*0.04395;
    tempAvgAnk += encoderAnk.read()*0.04395;
  }

  // Calculate average:
  tempAvgHip /= 20;
  tempAvgKne /= 20;
  tempAvgAnk /= 20;

  // Apply averaging strategy and update joint angles:
  angleHip = beta*tempAvgHip + (1-beta)*angleHip;
  angleKne = beta*tempAvgKne + (1-beta)*angleKne;
  angleAnk = beta*tempAvgAnk + (1-beta)*angleAnk; 
}

void displayJointInfo() {
/*
 * Display information about joints
 */
  unsigned long timeInterval = 1000;   // Time between each print

  // Print info if enough time has passed since last print: 
  if (millis() - previousPrint >= timeInterval) {
    // Serial.print("Hip angle = ");
    Serial.print(angleHip);
    Serial.print("\t");
    // Serial.print("Knee angle = ");
    Serial.print(angleKne);
    Serial.print("\t");
    // Serial.print("Ankle angle = ");
    Serial.println(angleAnk);
    previousPrint = millis();
  }
}

void resetMuscles() {
/*
 * Sets all muscles to LOW
 */
 digitalWrite(Hip1, LOW);
 digitalWrite(Hip2, LOW);
 digitalWrite(Ankle1, LOW);
 digitalWrite(Ankle2, LOW);
 digitalWrite(Knee1, LOW);
 digitalWrite(Knee2, LOW);
}
