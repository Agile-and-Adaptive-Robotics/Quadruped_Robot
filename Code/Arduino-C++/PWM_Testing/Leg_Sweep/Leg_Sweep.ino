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
 * - Functions may no longer be accurate (pressure changed?)
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

// Program control (time, on/off, etc.) variables:
bool pulsing                = false;   // Whether muscles are currently pulsing
unsigned long pulseStart    = 0;       // Time pulsing began
unsigned long previousPrint = 0;       // Time info was previously printed

// Motion stages constants:
// Length of stage x = STAGE_x * STAGE_LENGTH
const int STAGE_1      = 25;   // Hip + to 0
const int STAGE_2      = 0;    // Hip 0 to - 
const int STAGE_3      = 25;   // Knee/ankle bend
const int STAGE_4      = 25;   // Hip - to 0
const int STAGE_5      = 0;    // Hip 0 to +
const int STAGE_6      = 25;   // Knee/ankle straighten
const int STAGE_TOTAL  = STAGE_1 + STAGE_2 + STAGE_3 + STAGE_4 + STAGE_5 + STAGE_6;
const int STAGE_LENGTH = 200;   // [ms]

// Motion stages variables:
unsigned long stage1_start = 0;
unsigned long stage2_start = 0;
unsigned long stage3_start = 0;
unsigned long stage4_start = 0;
unsigned long stage5_start = 0;
unsigned long stage6_start = 0; 

// Joint angle variables:
float angleHip, angleKne, angleAnk;   // Current joint angles
float initHip, initKne, initAnk;      // Joint angles at beginning of current stage

// Joint target constants:
const float HIP_TARGET = 25;
const float KNE_TARGET = 0;
const float ANK_TARGET = 0;

// Joint target variables (reference target at current time):
float refHip, refKne, refAnk;

// Pulsing variables:
int currHip, currKne, currAnk;     // Muscle currently controlling joint
float dtOnHip, dtOnKne, dtOnAnk;   // [ms] Time on HIGH per pulsing period

void setup() {
  Serial.begin(115200);

  // Set muscle pins to output:
  pinMode(Hip1, OUTPUT);
  pinMode(Hip2, OUTPUT);
  pinMode(Knee1, OUTPUT);
  pinMode(Knee2, OUTPUT);
  pinMode(Ankle1, OUTPUT);
  pinMode(Ankle2, OUTPUT);

  Serial.println("MAKE SURE TO WAIT 5 SECONDS BEFORE PULSING\n");
}
    
void loop() {
  // Toggle pulsing on/off of 1 is entered:
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

  if (pulsing) {
    // Relative time within each cycle:
    int cycTime = ((millis() - pulseStart) / STAGE_LENGTH) % (STAGE_TOTAL);
    // Relative time within each step:
    int stepTime;   

    // Select leg actions based on current stage in cycle:
    if (cycTime < STAGE_1) {
      if (millis() - stage1_start > STAGE_1 * STAGE_LENGTH) {
        initHip = angleHip;
        initKne = angleKne;
        initAnk = angleAnk;
        stage1_start = millis();
      } 
      
      stepTime = cycTime;
      extendLeg('h', initHip, -HIP_TARGET, STAGE_1, stepTime);
    } 
    else if (cycTime < STAGE_1 + STAGE_2) {
      if (millis() - stage2_start > STAGE_2 * STAGE_LENGTH) {
        initHip = angleHip;
        initKne = angleKne;
        initAnk = angleAnk;
        stage2_start = millis();
      } 

      stepTime = cycTime - STAGE_1;
      // Hold hip
    } 
    else if (cycTime < STAGE_1 + STAGE_2 + STAGE_3) {
      if (millis() - stage3_start > STAGE_3 * STAGE_LENGTH) {
        initHip = angleHip;
        initKne = angleKne;
        initAnk = angleAnk;
        stage3_start = millis();
      } 

      stepTime = cycTime - (STAGE_1 + STAGE_2);
      extendLeg('h', initHip, 0, STAGE_3, stepTime);
    } 
    else if (cycTime < STAGE_1 + STAGE_2 + STAGE_3 + STAGE_4) {
      if (millis() - stage4_start > STAGE_4 * STAGE_LENGTH) {
        initHip = angleHip;
        initKne = angleKne;
        initAnk = angleAnk;
        stage4_start = millis();
      } 
      
      stepTime = cycTime - (STAGE_1 + STAGE_2 + STAGE_3);
      extendLeg('h', initHip, HIP_TARGET, STAGE_4, stepTime);
    } 
    else if (cycTime < STAGE_1 + STAGE_2 + STAGE_3 + STAGE_4+ STAGE_5) {
      if (millis() - stage5_start > STAGE_5 * STAGE_LENGTH) {
        initHip = angleHip;
        initKne = angleKne;
        initAnk = angleAnk;
        stage5_start = millis();
      } 

      stepTime = cycTime - (STAGE_1 + STAGE_2 + STAGE_3 + STAGE_4);
      // Hold hip
    } 
    else {
      if (millis() - stage6_start > STAGE_6 * STAGE_LENGTH) {
        initHip = angleHip;
        initKne = angleKne;
        initAnk = angleAnk;
        stage6_start = millis();
      } 

      stepTime = cycTime - (STAGE_1 + STAGE_2 + STAGE_3 + STAGE_4 + STAGE_5);
      extendLeg('h', initHip, 0, STAGE_6, stepTime);
    }

    pulseMuscle(currHip, dtOnHip);
    readJoints();
    displayInfo();
  }
}

void extendLeg(char joint, float initAngle, float targetAngle, int totalTime, int currTime) {
/*
 * Set dtOn to correct value to bring joint to desired angle
 */
  // [degrees] Amount of adjusted from initial angle required:
  float adjustAmount = ((targetAngle - initAngle) / totalTime) * (currTime + 1);

  // Update dtOn for correct joint:
  switch (joint) {
    case 'h':
      refHip = initAngle + adjustAmount;
      calcDtOnHip(refHip);
      break;
    case 'k':
      break;
    case 'a':
      break;
  }
}

void calcDtOnHip(float hip) {
 /*
 * Calculate dtOn from hip angle using best fit equations
 * Note: exp(x) = e^x
 */
  // Select correct hip muscle to pulse:
  if (hip < 0) {
    currHip = Hip1;
  } else {
    currHip = Hip2;
  }

  // Calculate dtOn:
  if (hip <= -44.739) {
    dtOnHip = exp((hip + 15.4466) / -8.26376);
  } else if (hip <= -31.721) {
    dtOnHip = exp((hip - 37.9365) / -23.3237);
  } else if (hip < 0) {
    dtOnHip = exp((hip - 60.6077) / -30.9148);
  } else if (hip == 0) {
    dtOnHip = 0;
  } else if (hip <= 17.049) {
    dtOnHip = exp((hip + 72.8896) / 33.4555); 
  } else if (hip <= 29.208) {
    dtOnHip = exp((hip + 22.2) / 14.6);
  } else {
    dtOnHip = exp((hip - 28.8104) / 0.112872);
  }

  // Ensure dtOn is within limits:
  if (dtOnHip < 0) {
    dtOnHip = 0;
  } else if (dtOnHip > 50) {
    dtOnHip = 50;
  }
} 

void readJoints() {
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

void displayInfo() {
/*
 * Print information about joints and pulsing
 */

  // Print info if enough time has passed since last print:
  if (millis() - previousPrint >= STAGE_LENGTH) {
    Serial.print("Current Hip Target = ");
    Serial.print(refHip);
    Serial.print("\t");
    Serial.print("Actual Hip = ");
    Serial.print(angleHip);
    Serial.print("\t");
    Serial.print("Hip dtOn = ");
    Serial.println(dtOnHip);
    /*
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
    */

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
