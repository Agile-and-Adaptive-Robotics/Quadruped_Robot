/*
 * Hip_Sweep
 * 
 * Sweep hip back and forth in continuous motion
 * 
 * ISSUES:
 * Angle and dtOn do not have linear relationship
 *    -> Redo logic that adjusts dtOn (find equation?)
 * Movement still rather jerky
 *    -> Shorter time intervals?
 *    -> Consider how to deal with shaking upon changing dtOn
 * 
 * Author: Flora Huang
 * Last Updated: 11 July 2022
 */

# include <Arduino.h>

// Define pins for muscles:
# define Hip1 32
# define Hip2 33

// Pulsing parameters: 
int dtOn    = 0;   // [ms] Time on HIGH per pulsing period
int currHip = 0;   // Muscle currently controlling hip

// Other variables:
bool systemOn = false;              // Whether pulsing is currently active
unsigned long sweepStart;           // Time sweeping began
unsigned long previousAdjust = 0;   // Time pulsing parameters were last adjusted
unsigned long previousPrint = 0;    // Time info was previously displayed

void setup() {
  Serial.begin(115200);

  pinMode(Hip1, OUTPUT);
  pinMode(Hip2, OUTPUT);
}

void loop() {
  // If 1 is entered, toggle system on/off:
  if (Serial.available()) {
    if (Serial.read() == '1') {
      systemOn = !systemOn;
      resetMuscles(); 
      sweepStart = millis(); 
    }
    Serial.flush();
  }

  int relTime = (millis() - sweepStart) % 200;   // Relative time within each cycle

  // If system is on, sweep hip:
  if (systemOn) {
    // Convert relative time to corresponding dtOn:
    if (millis() - previousAdjust > 1000) {
      if (relTime <= 50) {           // dtOn 0 -> 50
        dtOn = relTime;
        currHip = Hip1;
      } else if (relTime <= 100) {   // dtOn 49 -> 0
        dtOn = abs(relTime - 100);
        currHip = Hip1;
      } else if (relTime <= 150) {   // dtOn 1 -> 50
        dtOn = relTime - 100;
        currHip = Hip2;
      } else {                       // dtOn 49 -> 1
        dtOn = abs(relTime - 200);
        currHip = Hip2;
      }
      previousAdjust = millis();
    }
    
    pulseMuscle(currHip, dtOn);
    displayInfo(currHip, dtOn, relTime);
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
 * Set all muscles to LOW
 */
  digitalWrite(Hip1, LOW);
  digitalWrite(Hip2, LOW);
}

void displayInfo(int muscle, int dtOn, int relTime) {
/*
 * Print program info
 */
  if (millis() - previousPrint > 1000) {
    Serial.print("Muscle = ");
    Serial.print(muscle);
    Serial.print("\t");
    Serial.print("dtOn = ");
    Serial.print(dtOn);
    Serial.print("\t");
    Serial.print("Time = ");
    Serial.println(relTime); \
    previousPrint = millis();   
  }
}
