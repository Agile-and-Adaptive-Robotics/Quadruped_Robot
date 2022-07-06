/*
 * PWM_Testing
 * 
 * Tests control of test bench leg through pulse width modulation (PWM)
 * Program outputs angle of hip, knee, and ankle joint during pulsing
 * 
 * IN PROGRESS: 
 * Tracks minimum and maximum reading for each joint per 10-second cycle
 * Program outputs their difference (variance)
 * 
 * Author: Flora Huang
 * Last Updated: 6 July 2022
 */
 
# include <Arduino.h>
# include <Encoder.h>

// Define pins for leg components:
# define Hip1 32
# define Hip2 33
# define Ankle1 34
# define Ankle2 36
# define Knee1 35
# define Knee2 37

// Create Encoder objects for the hip, ankle, and knee:
Encoder encoderHip(2,3);
Encoder encoderAnk(4,5);
Encoder encoderKne(6,7);

// Variables for joint angles:
float angleHip = 0;
float angleKne = 0;
float angleAnk = 0;

// Variables for minimum and maximum readings:
float minHip, maxHip;
float minKne, maxKne;
float minAnk, maxAnk;

// Variables for tracking time:
unsigned long cycleStart;                 // Time duty cycle began
unsigned long previousPrint = millis();   // Previous time angle info was printed
unsigned long timeInterval  = 1000;       // Time between each print
  
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
  resetMuscles();                   // Set all muscles to LOW
  
  if (Serial.available()) {
    char userNum = Serial.read();   // Read user input from serial port
    
    if (userNum != '\n') {
      cycleStart = millis();        // Set pulse cycle start time to current time
      selectMuscle(userNum);        // Select corresponding muscle to be pulsed
    }
    
    Serial.flush();
    Serial.println();
  }
}

void selectMuscle(char userNum) {
/*
* Selects muscle that corresponds with userNum
*/
  switch (userNum) {
    case '1':
      pulseMuscle(Hip1);
      break;
    case '2':
      pulseMuscle(Hip2);
      break;
    case '3':
      pulseMuscle(Ankle1);
      break;
    case '4':
      pulseMuscle(Ankle2);
      break;
    case '5':
      pulseMuscle(Knee1);
      break;
    case '6':
      pulseMuscle(Knee2);
      break;
     default:
      Serial.println("No matches");
      break;
  }
}

void pulseMuscle(int muscle) {
/*
 * Pulses given muscle
 */
 // Variables for pulsing
  int freq      = 20;                 // Number of duty cycles per 1000 milliseconds
  int dutyCycle = 1000/freq;          // Length of each duty cycle
  int dtOn      = 15;                 // Milliseconds on HIGH per duty cycle

  // Set min and max values to current joint angles to prepare for comparison:
  minHip = maxHip = encoderHip.read()*0.04395;
  minKne = maxKne = encoderHip.read()*0.04395;
  minAnk = maxAnk = encoderAnk.read()*0.04395;

  // Pulsing cycle runs until 10 seconds have passed
  while (millis() - cycleStart <= 10000) {
    int relTime = millis() % dutyCycle;   // Relative time within each duty cycle

    // Turn muscle to HIGH or LOW based on relative time:
    if (relTime <= dtOn) {
      digitalWrite(muscle, HIGH);
    } else {
      digitalWrite(muscle, LOW);
    }

    updateJointInfo();
    displayJointInfo();
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

void updateJointInfo() {
/*
 * Read and update joint angles
 */ 
  // Variables for calculating joint angles:
  float beta = 0.15;
  float tempAvgHip = 0, tempAvgKne = 0, tempAvgAnk = 0;

  // Sum 20 position values for each joint and convert to degrees:
  for (int i=0; i<20; i++) {
    // Read current angle of joints:
    float newHip = encoderHip.read()*0.04395;
    float newKne = encoderKne.read()*0.04395;
    float newAnk = encoderAnk.read()*0.04395;

    // Add reading to cumulative sum:
    tempAvgHip += newHip;
    tempAvgKne += newKne;
    tempAvgAnk += newAnk;

    // Compare reading to min and max values:
    minHip = min(minHip, newHip);
    maxHip = max(maxHip, newHip);
    minKne = min(minKne, newKne);
    maxKne = max(maxKne, newKne);
    minAnk = min(minAnk, newAnk);
    maxAnk = max(maxAnk, newAnk);
  }

  // Calculate average:
  tempAvgHip /= 20;
  tempAvgKne /= 20;
  tempAvgAnk /= 20;

  // Calculate angle of joints:
  angleHip = beta*tempAvgHip + (1-beta)*angleHip;
  angleKne = beta*tempAvgKne + (1-beta)*angleKne;
  angleAnk = beta*tempAvgAnk + (1-beta)*angleAnk;
}

void displayJointInfo() {
/*
 * Display information about joints
 */
  if (millis() - previousPrint >= timeInterval) {
    // Serial.print("Hip Angle = ");
    Serial.print(angleHip);
    Serial.print("\t");
    // Serial.print("Hip Var = ");
    Serial.print(maxHip - minHip);
    Serial.print("\t");
    // Serial.print("Knee Angle = ");
    Serial.print(angleKne);
    Serial.print("\t");
    // Serial.print("Knee Var = ");
    Serial.print(maxKne - minKne);
    Serial.print("\t");
    // Serial.print("Ankle Angle = ");
    Serial.print(angleAnk);
    Serial.print("\t");
    // Serial.print("Ankle Var = ");
    Serial.print(maxAnk - minAnk);
    Serial.println();
    previousPrint = millis();
  }
}
