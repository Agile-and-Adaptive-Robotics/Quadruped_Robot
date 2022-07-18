/*
 * Leg_Sweep
 * 
 * Program pulses hip, knee, and ankle simultaneously to sweep leg
 * 
 * TO DO:
 * 1. Sweep hip to desired boundary angles [-25, 25]
 *      -> Sweep to target then adjust adpatively 
 * 2. Sweep knee and angle jointly
 *      -> Pay attention to each other's position
 * 
 * ISSUES:
 * - Hip2 readings have changed??
 * 
 * Author: Flora Huang
 * Last Updated: 15 July 2022
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

// Sweeping constants:
const int STEP_LENGTH   = 25;    // Number of relTime values in each step of motion sequence
const int TARGET_HIP    = 25;    // [degrees] Positive target for hip angle
// const int TARGET_KNE;
// const int TARGET_ANK;
const int DEVIATION     = 1;     // [degrees] Accepted deviation(+/-) from target
const int TIME_INTERVAL = 200;   // [ms] Time between each adjustment in sweeping

// Sweeping variables:
float initHip, initKne, initAnk;   // [degrees] Initial angle readings at beginning of each step
float refHip, refKne, refAnk;      // [degrees] Reference for where joint angles should be

// Pulsing variables:
int currHip, currKne, currAnk;     // Muscle currently controlling joint
float dtOnHip, dtOnKne, dtOnAnk;   // [ms] Time on HIGH per pulsing period

// Program control (time, on/off, etc.) variables:
bool pulsing                = false;   // Whether muscles are currently pulsing
unsigned long pulseStart    = 0;       // [ms] Time pulsing began
unsigned long stepChange    = 0;       // [ms] Time when program transitioned from one step of motion sequence to another
unsigned long previousPrint = 0;       // [ms] Time info was previously printed

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
  // Toggle pulsing on/off if 1 is entered:
  if (Serial.available()) {
    if (Serial.read() == '1') {
      pulsing = !pulsing;
      resetMuscles();
      resetVariables();
      pulseStart = stepChange =  millis();
    }
    Serial.flush();
  }

  if (pulsing) {
    // Relative time within each cycle:
    int relTime = ((millis() - pulseStart) / TIME_INTERVAL) % ((STEP_LENGTH * 6) + 1);
    
    // Select leg actions based on current time in cycle:
    if (relTime <= STEP_LENGTH) {
      extendLeg('h', -TARGET_HIP, initHip, relTime);
      // TO DO: Knee action
      // TO DO: Ankle action
    } else if (relTime <= STEP_LENGTH * 2) {
      // TO DO: Maintain hip angle
      // TO DO: Knee action
      // TO DO: Ankle action
    } else if (relTime <= STEP_LENGTH * 3) {
      extendLeg('h', 0, initHip, (relTime - (STEP_LENGTH * 2)));
      // TO DO: Knee action
      // TO DO: Ankle action
    } else if (relTime <= STEP_LENGTH * 4) {
      extendLeg('h', TARGET_HIP, initHip, (relTime - (STEP_LENGTH * 3)));
      // TO DO: Knee action
      // TO DO: Ankle action
    } else if (relTime <= STEP_LENGTH * 5) {
      // TO DO: Maintain hip angle
      // TO DO: Knee action
      // TO DO: Ankle action
    } else if (relTime <= STEP_LENGTH * 6) {
      extendLeg('h', 0, initHip, (relTime - (STEP_LENGTH * 5)));
      // TO DO: Knee action
      // TO DO: Ankle action
    }

    // Update initial angle readings at beginning of each step:
    if (millis() - stepChange > TIME_INTERVAL * STEP_LENGTH) {
      readJointInfo();
      initHip = angleHip;
      initKne = angleKne;
      initAnk = angleKne;
      stepChange = millis();
    }

    // Pulse muscles:
    // pulseMuscle(currHip, dtOnHip);
    // pulseMuscle(currKne, dtOnKne);
    // pulseMuscle(currAnk, dtOnAnk);

    // displayInfo();
  }
}

void extendLeg(char joint, int targetAngle, float currAngle, int relTime) {
/*
 * Extend given joint to target angle
 */
  int adjustFactor;   // Factor (+ or -) to adjust angle by

  // Set adjustment factor:
  if (currAngle < (targetAngle - DEVIATION)) {
    adjustFactor = 1;
  } else if (currAngle > (targetAngle + DEVIATION)) {
    adjustFactor = -1;
  } else {
    return;
  }

  // Scale adjustment factor:
  adjustFactor *= abs((targetAngle - currAngle) / STEP_LENGTH);

  // Update dtOn for correct joint:
  switch (joint) {
    case 'h':
      refHip = currAngle + (adjustFactor * relTime);
      calcDtOnHip(refHip);
      break;
    case 'k':
      // TO DO: Calculate knee dtOn
      break;
    case 'a':
      // TO DO: Calculate ankle dtOn
      break;
  }
}

void calcDtOnHip(float hip) {
/*
 * Calculate dtOn from hip angle using best fit equations
 * Note: exp(x) = e^x
 */
  if (hip <= -44.739) {
    dtOnHip = exp((hip + 15.4466) / -8.26376);
    currHip = Hip1;
  } else if (hip <= -31.721) {
    dtOnHip = exp((hip - 37.9365) / -23.3237);
    currHip = Hip1;
  } else if (hip < 0) {
    dtOnHip = exp((hip - 60.6077) / -30.9148);
    currHip = Hip1;
  } else if (hip == 0) {
    dtOnHip = 0;
    currHip = Hip1;
  } else if (hip <= 17.049) {
    dtOnHip = exp((hip + 72.8896) / 33.4555); 
    currHip = Hip2;
  } else if (hip <= 29.208) {
    dtOnHip = exp((hip + 22.2) / 14.6);
    currHip = Hip2;
  } else {
    dtOnHip = exp((hip - 28.8104) / 0.112872);
    currHip = Hip2;
  }

  // Ensure dtOn is no greater than 50:
  if (dtOnHip > 50) {
    dtOnHip = 50;
  }
}

void readJointInfo() {
/*
 * Read and update joint angles
 */
  float beta = 0.15;
  float tempAvgHip = 0, tempAvgKne = 0, tempAvgAnk = 0;

  // Sum 20 angle readings and convert to degrees:
  for (int i=0; i<20; i++) {
    tempAvgHip += encoderHip.read()*0.04395;
    tempAvgKne += encoderKne.read()*0.04395;
    tempAvgAnk += encoderAnk.read()*0.04395;
  }

  // Calculate average:
  tempAvgHip /= 20;
  tempAvgKne /= 20;
  tempAvgAnk /= 20;

  // Apply averaging strategy and update joint angle:
  angleHip = beta*tempAvgHip + (1-beta)*angleHip;
  angleKne = beta*tempAvgKne + (1-beta)*angleKne;
  angleAnk = beta*tempAvgAnk + (1-beta)*angleAnk;
}

void pulseMuscle(int muscle, float dtOn) {
/*
 * Pulse given muscle at given dtOn
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

void displayInfo () {
/*
 * Print information about joints and pulsing
 */
  readJointInfo();

  // Print info if enough time has passed since last print:
  if (millis() - previousPrint >= TIME_INTERVAL) {
    Serial.print("Current Hip Target = ");
    Serial.print(refHip);
    Serial.print("\t");
    Serial.print("Actual Hip = ");
    Serial.print(angleHip);
    Serial.print("\t");
    Serial.print("Hip dtOn = ");
    Serial.println(dtOnHip);
    Serial.print("Current Knee Target = ");
    Serial.print(refKne);
    Serial.print("\t");
    Serial.print("Actual Knee = ");
    Serial.print(angleHip);
    Serial.print("\t");
    Serial.print("Knee dtOn = ");
    Serial.println(dtOnKne);
    Serial.print("Current Ankle Target = ");
    Serial.print(refAnk);
    Serial.print("\t");
    Serial.print("Actual Ankle = ");
    Serial.print(angleAnk);
    Serial.print("\t");
    Serial.print("Ankle dtOn = ");
    Serial.println(dtOnAnk);

    previousPrint = millis();
  }
}

void resetMuscles() {
/*
 * Turn off all muscles
 */
  digitalWrite(Hip1, LOW);
  digitalWrite(Hip2, LOW);
  digitalWrite(Knee1, LOW);
  digitalWrite(Knee2, LOW);
  digitalWrite(Ankle1, LOW);
  digitalWrite(Ankle2, LOW);
}

void resetVariables() {
/*
 * Reset variable values to prepare for new pulse
 */
  angleHip = angleKne = angleAnk = 0;
  initHip = initKne = initAnk = 0;
  currHip = currKne = currAnk = 0;
  dtOnHip = dtOnKne = dtOnAnk = 0;
}
