/*
 * Read_Pressure_Sensors
 * 
 * Take readings from pressure sensors. 
 * Enter value 0-100 to check pressure at various duty cycles.
 * Enter -1 to turn off muscles. 
 * 
 * Author: Flora Huang
 * Last Updated: 16 August 2022
 */

# include <Arduino.h>

// Pins for muscles:
# define Hip1 32
# define Hip2 33
# define Knee1 36
# define Knee2 34
# define Ankle1 37
# define Ankle2 35

// Pins for pressure sensors:
# define PHip1 A7 
# define PHip2 A0  
# define PKnee1 A8 
# define PKnee2 A1  
# define PAnkle1 A9 
# define PAnkle2 A6   

// Muscle currently being pulsed (edit this to pulse another muscle):
int currMuscle = Hip1;

bool pulsing   = false;                   // Whether muscle is currently being pulsed
unsigned long previousPrint = millis();   // Previous time info was printed to serial window 
String userInput;                         // User input into serial window
int dutyCycle;                            // Percentage of time on HIGH per period

void setup() {
  Serial.begin(115200);

  // Set muscle pins to output:
  pinMode(Hip1, OUTPUT);
  pinMode(Hip2, OUTPUT);
  pinMode(Knee1, OUTPUT);
  pinMode(Knee2, OUTPUT);
  pinMode(Ankle1, OUTPUT);
  pinMode(Ankle2, OUTPUT);
}

void loop() {  
  // Turn pulsing on/off based on user input: 
  if (Serial.available()) {
    userInput = Serial.readStringUntil('\n');
    dutyCycle = userInput.toInt();

    if (dutyCycle == -1) {
      resetMuscles();
      pulsing = false;
    } else {
      pulsing = true;
    }
    
    Serial.flush();
  }

  if (pulsing) {
    pulseMuscle();
    readPressureSensors();
  }
}

void pulseMuscle() {
/*
 * Pulses given muscle at given duty cycle
 */
  // Variables for pulsing:
  int freq    = 20;                             // [Hz] Number of periods per 1000 milliseconds
  int period  = 1000/freq;                      // [ms] Length of each period
  float dtOn  = (dutyCycle / 100.0) * period;   // [ms] Time on HIGH per period
  int relTime = millis() % period;              // Relative time within each period

  // Turn muscle on or off based on relative time:
  if (relTime <= dtOn) {
    digitalWrite(currMuscle, HIGH);
  } else {
    digitalWrite(currMuscle, LOW);
  }
}

void readPressureSensors() {
/*
 * Read and display pressure information
 */
  int pressureSensor = selectPressureSensor();                 // Select pressure sensor for current muscle
  float pressure = 0.797 * analogRead(pressureSensor) - 127;   // Read from sensor and convert to kPa

  // Print information to serial window:
  if (millis() - previousPrint >= 1000) {
    Serial.print("Duty cycle = ");
    Serial.print(dutyCycle);
    Serial.print("\t");
    Serial.print("Pressure = ");
    Serial.println(pressure);

    Serial.println();
    previousPrint = millis();
  }
}

int selectPressureSensor() {
/*
 * Return pressure sensor that corresponds to current muscle
 */
  int pressureSensor;
  
  switch (currMuscle) {
    case Hip1:
      pressureSensor = PHip1;
      break;
    case Hip2:
      pressureSensor = PHip2;
      break;
    case Knee1:
      pressureSensor = PKnee1;
      break;
    case Knee2:
      pressureSensor = PKnee2;
      break;
    case Ankle1:
      pressureSensor = PAnkle1;
      break;
    case Ankle2:
      pressureSensor = PAnkle2;
      break;
  }

  return pressureSensor;
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
