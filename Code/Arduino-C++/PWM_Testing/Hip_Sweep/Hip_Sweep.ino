/*
 * Hip_Sweep
 * 
 * Sweep hip back and forth in continuous motion
 * 
 * Author: Flora Huang
 * Last Updated: 13 July 2022
 */

# include <Arduino.h>
# include <Encoder.h>

// Pins for muscles:
# define Hip1 32
# define Hip2 33

// Encoder objects for joints:
Encoder encoderHip(2,3);

// Variables for joints:
float angleHip = 0;
float targetHip = 0;

// Variables for muscles:
int currHip = 0;

// Variables for pulsing:
float dtOnHip = 0;

// Variables for controlling program flow (time, on/off, etc.):
unsigned long pulseStart     = 0;       // [ms] Time pulsing began
bool pulsing                 = false;   // Whether a muscle is currently pulsing
unsigned long previousPrint  = 0;       // [ms] Time info was previously printed
unsigned long previousAdjust = 0;       // [ms] Time target angle was previously adjusted

void setup() {
  Serial.begin(115200);

  // Set pins to output:
  pinMode(Hip1, OUTPUT);
  pinMode(Hip2, OUTPUT);
}

/*
void loop() {
  // Monitor for inputs if no muscle is pulsing:
  if (!pulsing) {
    if (Serial.available()) {
      //Read in user input and convert to float:
      String userInput = Serial.readStringUntil('\n');
      targetHip = userInput.toFloat();
      calcDtOnHip();   // Calculate dtOn from targetHip

      // Begin pulsing if valid input is received:
      if (dtOnHip >= 0 && dtOnHip <= 50) {
        pulsing = true;
        angleHip = 0;   // Reset angleHip
        pulseStart = millis();
      } else {
        Serial.println("Input is out of possible hip angle range!\n");
      }

      Serial.flush();
    }
  }
  // Pulse muscle for 10 seconds, then reset muscles:
  else {
    if (millis() - pulseStart <= 10000) {
      pulseMuscle(currHip, dtOnHip);   // Pulse hip
      updateJointInfo();
      displayJointInfo();
    } else {
      pulsing = false;
      resetMuscles();
    }
  }
}
*/

void loop() {
  // Toggle pulsing on/off if 1 is entered:
  if (Serial.available()) {
    if (Serial.read() == '1') {
      pulsing = !pulsing;
      resetMuscles();
      angleHip = 0;
      pulseStart = millis();
    }
    Serial.flush();
  }

  int relTime = ((millis() - pulseStart) / 200) % 155;   // Relative time within each cycle

  // If pulsing, continuously adjust target angle to sweep hip:
  if (pulsing) {
    if (millis() - previousAdjust > 200) {
      if (relTime <= 48) {           // targetHip 0 -> -48
        targetHip = -relTime;
      } else if (relTime <= 96) {    // targetHip -47 -> 0
        targetHip = relTime - 96;
      } else if (relTime <= 125) {   // targetHip 1 -> 29
        targetHip = relTime - 96;
      } else {                       // targetHip 28 -> 1
        targetHip = -relTime + 154;
      }

      calcDtOnHip();   // Calculate dtOn from target angle
      previousAdjust = millis();
    }

    pulseMuscle(currHip, dtOnHip);
    displayJointInfo();
  }
}

void calcDtOnHip() {
/*
 * Calculate dtOn from target angle using best fit equations
 * Note: exp(x) = e^x
 */
  if (targetHip <= -44.739) {
    dtOnHip = exp((targetHip + 15.4466) / -8.26376);
    // Ensure dtOn does not exceed 50:
    if (dtOnHip > 50) {
      dtOnHip = 50;
    }
    currHip = Hip1;
  } else if (targetHip <= -31.721) {
    dtOnHip = exp((targetHip - 37.9365) / -23.3237);
    currHip = Hip1;
  } else if (targetHip < 0) {
    dtOnHip = exp((targetHip - 60.6077) / -30.9148);
    currHip = Hip1;
  } else if (targetHip == 0) {
    dtOnHip = 0;
    currHip = Hip1;
  } else if (targetHip <= 17.049) {
    dtOnHip = exp((targetHip + 72.8896) / 33.4555); 
    currHip = Hip2;
  } else if (targetHip <= 29.208) {
    dtOnHip = exp((targetHip + 22.2) / 14.6);
    currHip = Hip2;
  } else {
    dtOnHip = exp((targetHip - 28.8104) / 0.112872);
    // Ensure dtOn is less than 50:
    if (dtOnHip > 50) {
      dtOnHip = 50;
    }
    currHip = Hip2;
  } 
}

void pulseMuscle(int muscle, float dtOn) {
/*
 * Pulses given muscle at given dtOn
 */
  // Variables for pulsing:
  int freq    = 20;                  // [Hz] Number of periods per 1000 milliseconds
  int period  = 1000/freq;           // [ms] Length of each period
  int relTime = millis() % period;   // [ms] Relative time within each period

  // Turn muscle on or off based on relative time:
  if (relTime <= dtOn) {
    digitalWrite(muscle, HIGH);
  } else {
    digitalWrite(muscle, LOW);
  }
}

void updateJointInfo() {
/*
 * Read and update joint angles
 */
  float beta = 0.15;
  float tempAvgHip = 0;

  // Sum 20 angle readings and convert to degrees:
  for (int i=0; i<20; i++) {
    tempAvgHip += encoderHip.read()*0.04395;
  }

  // Calculate average:
  tempAvgHip /= 20;

  // Apply averaging strategy and update joint angle:
  angleHip = beta*tempAvgHip + (1-beta)*angleHip;
}

void displayJointInfo() {
/*
 * Display information about joints
 */
  unsigned long timeInterval = 200;   // [ms] Time between each print

  updateJointInfo();
  
  // Print info if enough time has passed since last print:
  if (millis() - previousPrint >= timeInterval) {
    // Serial.print("Target angle = ");
    Serial.print(targetHip);
    Serial.print("\t");
    // Serial.print("Current angle = ");
    Serial.println(angleHip);
    // print("\t");
    // Serial.print("dtOn = ");
    // Serial.println(dtOnHip);
    previousPrint = millis();
  }
}

void resetMuscles() {
/*
 * Sets all muscles to LOW
 */
  digitalWrite(Hip1, LOW);
  digitalWrite(Hip2, LOW);
}
