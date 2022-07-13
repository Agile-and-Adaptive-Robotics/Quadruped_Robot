/*
 * Control_Test
 * 
 * Program adjusts pulsing parameters to achieve desired joint angle
 * 
 * TO DO: 
 * 1. Integrate dtOn vs. joint angle equations
 * 2. Redo knee and ankle control (figure out effects of muscles)
 * 3. Simultaneous control of multiple joints (how to not have different muscles counteract each other?)
 * 
 * Author: Flora Huang
 * Last Updated: 13 July 2022
 */
  
# include <Arduino.h>
# include <Encoder.h>

// Define pins for muscles:
# define Hip1 32     // Moves hip right
# define Hip2 33     // Moves hip left 
# define Ankle1 34   // Moves knee left <- only works when hip is pulsing left
# define Ankle2 36   // Moves knee right
# define Knee1 35    // Moves ankle left
# define Knee2 37    // ???

// Create Encoder objects for joints:
Encoder encoderHip(2,3);
Encoder encoderAnk(4,5);
Encoder encoderKne(6,7);

// Variables for joint angles:
float angleHip, angleKne, angleAnk;

// Control parameters:
float targetHip = 10;
float targetKne = -20;
float targetAnk = 10;

// Pulsing paramters:
int currHip, currKne, currAnk;   // Muscle currently being pulsed
int dtOnHip, dtOnKne, dtOnAnk;   // [ms] Amount of time muscle is set to HIGH when pulsing

// Other variables:
bool systemOn                = false;   // Whether muscles are currently being pulsed
unsigned long previousAdjust = 0;       // Last time pulsing paramters were adjusted
unsigned long previousPrint  = 0;       // Last time status info was printed

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
  // If 1 is entered, toggle system on/off:
  if (Serial.available()) {
    if (Serial.read() == '1') {
      systemOn = !systemOn;
      resetMuscles();
      resetVariables();
    }
    Serial.flush();
  }

  // If system is on, pulse muscles:
  if (systemOn) {
    // Adjust pulsing parameters every 200 ms:
    if (millis() - previousAdjust > 200) {
      adjustHip();
      adjustKne();
      adjustAnk();
      previousAdjust = millis();
    }

    // Pulse according to current paramters: 
    pulseMuscle(currHip, dtOnHip);
    // pulseMuscle(currKne, dtOnKne);
    // pulseMuscle(currAnk, dtOnAnk);

    displayStatus();
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

void adjustHip() {
/*
 * Adjust hip to target angle
 * TO DO: Integrate best fit equations into adaptive logic
 */    
  // 
}

void adjustKne() {
/*
 * Adjust knee to target angle
 * TO DO: Figure out which muscles control knee
 */
  //
}

void adjustAnk() {
/*
 * Adjust ankle to target ankle
 * TO DO: Figure out which muscles control ankle
 */
  //
}

void pulseMuscle(int muscle, int dtOn) {
/*
 * Pulses given muscle at given dtOn
 */
  // Variables for pulsing:
  int freq    = 20;                  // [Hz] Number of periods per 1000 milliseconds
  int period  = 1000/freq;           // [ms] Length of each period
  int relTime = millis() % period;   // Relative time within each period

  // Turn muscle on or off based on relative time:
  if (relTime <= dtOn) {
    digitalWrite(muscle, HIGH);
  } else {
    digitalWrite(muscle, LOW);
  }
}

void displayStatus() {
/*
 * Print status of joints
 */  
  if (millis() - previousPrint > 1000) {
    readJoints();
    
    Serial.print("Hip target = ");
    Serial.print(targetHip);
    Serial.print("\t");
    Serial.print("Hip angle = ");
    Serial.println(angleHip);
    /*
    Serial.print("Knee target = ");
    Serial.print(targetKne);
    Serial.print("\t");
    Serial.print("Knee angle = ");
    Serial.println(angleKne);  
    Serial.print("Ankle target = ");
    Serial.print(targetAnk);
    Serial.print("\t");
    Serial.print("Ankle angle = ");
    Serial.println(angleAnk);
    */

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

void resetVariables() {
/*
 * Reset variables to prepare for new pulsing session
 */
 angleHip = encoderHip.read()*0.04395;
 angleKne = encoderKne.read()*0.04395;
 angleAnk = encoderAnk.read()*0.04395;

 currHip = currKne = currAnk = 0;
 dtOnHip = dtOnKne = dtOnAnk = 0;
}
