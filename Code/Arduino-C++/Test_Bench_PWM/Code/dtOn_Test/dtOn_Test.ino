/*
 * dtOn_Test
 * 
 * Adjusts the amount of time signal is on HIGH per period (dtOn) to produce different duty cycles.
 * Program automatically increments through different dtOn values and prints joint angles to serial monitor.
 * Enter '1' to turn program on/off.
 * 
 * Author: Flora Huang
 * Last Updated: 17 August 2022 
 */
 
# include <Arduino.h>
# include <Encoder.h>

// Pins for muscles:
# define Hip1 32
# define Hip2 33
# define Knee1 36
# define Knee2 34
# define Ankle1 37
# define Ankle2 35

// Encoder objects for joints:
Encoder encoderHip(2,3);
Encoder encoderAnk(4,5);
Encoder encoderKne(6,7);

// Joint angle variables:
float angleHip, angleKne, angleAnk; 

// Muscle variables:
int currMuscle = Hip1;   // Muscle currently being pulsed (edit this to change active muscle)

// Program control (time, on/off, etc.) variables:
unsigned long pulseStart    = 0;          // Time pulsing began
bool pulsing                = false;      // Whether a muscle is currently being pulsed
unsigned long previousPrint = millis();   // Previous time data was printed
unsigned long timeInterval  = 1000;       // Time between each print

// Pulsing variables:
int dtOn;   // Time signal is on HIGH per period

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
  // Turn pulsing on/off if 1 is entered:
  if (Serial.available()) {
    if (Serial.read() == '1') {
      if (pulsing) {
        resetMuscles();
      } else {
        resetVariables();
        pulseStart = millis();
      }
      pulsing = !pulsing;
    }
    Serial.flush();
  }

  // Increment dtOn from 1 to 50, then turn off pulsing:
  if (pulsing) {
    int relTime = ((millis() - pulseStart) / 10000) + 50;
    if (relTime <= 50) {
      dtOn = relTime;
      pulseMuscle();
      updateJointInfo();
      displayJointInfo();
    } else {
      pulsing = false;
      resetMuscles();
    }
  }
}

void resetVariables() {
/*
 * Reset variables to prepare for new pulse
 */
  angleHip = angleKne = angleAnk = 0;
}

void pulseMuscle() {
/*
 * Pulses given muscle
 */
  // Variables for pulsing:
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
  // Print info if enough time has passed since last print: 
  if (millis() - previousPrint >= timeInterval) {
    Serial.print("dtOn = ");
    Serial.print(dtOn);
    Serial.print("\t");
    Serial.print("Hip angle = ");
    Serial.print(angleHip);
    Serial.print("\t");
    Serial.print("Knee angle = ");
    Serial.print(angleKne);
    Serial.print("\t");
    Serial.print("Ankle angle = ");
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
