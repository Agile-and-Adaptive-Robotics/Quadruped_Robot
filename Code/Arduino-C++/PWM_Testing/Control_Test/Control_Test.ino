/*
 * Control_Test
 * 
 * Program adjusts pulsing parameters to achieve desired joint angle
 * 
 * TO DO: 
 * Simultaneous control of multiple joints (how to not have different muscles counteract each other?)
 * Smoothen motion towards target (shorter/more increments?)
 * 
 * ISSUES: 
 * Angle readings incosistent (issue with encoders?)
 * Are ankle and knee muscles switched? Figure out effects of each muscle
 * 
 * Author: Flora Huang
 * Last Updated: 8 July 2022
 */

/*
 * SOLO ANGLE RANGES:
 * 
 * HIP:
 * Hip1: [-42.28, 0]
 * Hip2: [0, 26.56]
 * 
 * KNEE:
 * Ankle2: [-45, 0]
 * 
 * ANKLE:
 * Knee1: [0, 25]
 */

/*
 * TARGET SET:
 * angleHip = -18
 * angleKne = -22
 * angleAnk = 40
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
float angleHip, angleKne, angleAnk;

// Control parameters:
float targetHip = -10;
float targetKne = -20;
float targetAnk = 10;
float deviation = 5;   // Accepted deviation(+/-) from target angle

// Pulsing paramters:
int currHip, currKne, currAnk;   // Muscle currently being pulsed
int dtOnHip, dtOnKne, dtOnAnk;   // [ms] Amount of time muscle is set to HIGH when pulsing

// Other variables:
bool systemOn                = false;   // Whether muscles are currently being pulsed
unsigned long previousAdjust = 0;       // Last time pulsing was adjusted
unsigned long previousPrint  = 0;       // Last time status info was printed

void setup() {
  Serial.begin(115200);

  // Set pins to output:
  pinMode(Hip1, OUTPUT);     // Moves hip right
  pinMode(Hip2, OUTPUT);     // Moves hip left 
  pinMode(Ankle1, OUTPUT);   // Moves knee left <- only works when hip is pulsing left
  pinMode(Ankle2, OUTPUT);   // Moves knee right
  pinMode(Knee1, OUTPUT);    // Moves ankle left
  pinMode(Knee2, OUTPUT);    // ???
}

void loop() {
  // If 1 is entered, toggle system on/off:
  if (Serial.available()) {
    if (Serial.read() == '1') {
      systemOn = !systemOn;
      resetVariables();
    }
    Serial.flush();
  }

  // If system is on, adjust joints. Otherwise, turn off all muscles:
  if (systemOn) {
    readJoints();
    
    // Only make new adjustment once every 5 seconds:
    if (millis() - previousAdjust > 5000) {
      adjustHip();
      adjustKne();
      adjustAnk();
      previousAdjust = millis();
    }

    // Pulse according to current paramters: 
    pulseMuscle(currHip, dtOnHip);
    pulseMuscle(currKne, dtOnKne);
    pulseMuscle(currAnk, dtOnAnk);

    displayStatus();
  } else {
    resetMuscles();
  }
}

void resetVariables() {
/*
 * Reset variables after pulsing starts/stops
 */
 angleHip = encoderHip.read()*0.04395;
 angleKne = encoderKne.read()*0.04395;
 angleAnk = encoderAnk.read()*0.04395;

 currHip = currKne = currAnk = 0;
 dtOnHip = dtOnKne = dtOnAnk = 0;
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
 */    
  if (targetHip >= 0) {
    currHip = Hip2;
      
    if (angleHip < (targetHip - deviation)) {
      dtOnHip += 5;
    } else if (angleHip > (targetHip + deviation)) {
      dtOnHip -= 5;
    } 
  } else if (targetHip < 0) {
    currHip = Hip1;
      
    if (angleHip < (targetHip - deviation)) {
      dtOnHip -= 5;
    } else if (angleHip > (targetHip + deviation)) {
      dtOnHip += 5;
    } 
  }
}

void adjustKne() {
/*
 * Adjust knee to target angle
 */
  currKne = Ankle2;

  if (angleKne < (targetKne - deviation)) {
    dtOnKne -= 5;
  } else if (angleKne > (targetKne + deviation)) {
    dtOnKne += 5;
  }
}

void adjustAnk() {
/*
 * Adjust ankle to target ankle
 */
  currAnk = Knee1;

  if (angleAnk < (targetAnk - deviation)) {
    dtOnAnk += 5;
  } else if (angleAnk > (targetAnk + deviation)) {
    dtOnAnk -= 5;
  }
}

void displayStatus() {
/*
 * Print status of joints
 */
  readJoints();
  
  if (millis() - previousPrint > 1000) {
    Serial.print("Hip target = ");
    Serial.print(targetHip);
    Serial.print("\t");
    Serial.print("Hip angle = ");
    Serial.println(angleHip);
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

    previousPrint = millis();
  }
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
