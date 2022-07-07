/*
 * Control_Test
 * 
 * IN PROGRESS:
 * Program adjusts pulsing parameters to achieve desired joint angle
 * 
 * Author: Flora Huang
 * Last Updated: 7 July 2022
 */

 /*
  * Muscle -> Angle Ranges
  * Hip1: [-42.28, 0]
  * Hip2: [0, 26.56]
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

// Variables for joint angles:
float angleHip = 0, angleKne = 0, angleAnk = 0;

// Control parameters:
float targetHip, targetKne, targetAnk;
float deviation = 5;   // Accepted deviation(+/-) from target angle

// Other variables:
bool systemOn = false;   // Whether pulsing functions are currently running

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
  // If 1 is entered, toggle systemOn:
  if (Serial.available()) {
    if (Serial.read() == 1) {
      systemOn = !systemOn;
    }
    Serial.flush();
  }

  // If system is on, adjust joints. Otherwise, turn off all muscles:
  if (systemOn) {
    adjustHip();
    adjustKne();
    adjustAnk();
  } else {
    resetMuscles();
    angleHip = angleKne = angleAnk = 0;   // Reset angle variables
  }
}

void adjustHip() {
/*
 * Adjust hip to target angle
 */
  readJoints();   // Read current angle of joints
  
  if (targetHip >= 0) {
    if (angleHip < (targetHip - deviation) {
      // Increase Hip2 dtOn
    } else if (angleHip > (targetHip + deviation)) {
      // Decrease Hip2 dtOn
    } else {
      // Maintain Hip2 dtOn
    }
  } else if (targetHip < 0) {
    if (angleHip < (targetHip - deviation) {
      // Decrease Hip1 dtOn
    } else if (angleHip > (targetHip + deviation) {
      // Increase Hip1 dtOn
    } else {
      // Maintain Hip1 dtOn
    }
  }
}

void readJoints() {
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
