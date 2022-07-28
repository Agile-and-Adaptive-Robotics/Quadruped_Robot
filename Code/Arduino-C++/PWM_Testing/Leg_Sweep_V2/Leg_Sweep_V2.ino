/*
 * Leg_Sweep_V2
 * 
 * Alteranative version of Leg_Sweep that adjusts period instead of dtOn.
 * 
 * Author: Flora Huang
 * Last Updated: 28 July 2022
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
bool pulsing                 = false;   // Whether muscles are currently pulsing
unsigned long pulseStart     = 0;       // Time pulsing began
unsigned long previousPrint  = 0;       // Time info was previously printed
unsigned long previousAdjHip = 0;       // Time hip was previously adjusted
unsigned long previousAdjKne = 0;       // Time knee was previously adjusted
unsigned long previousAdjAnk = 0;       // Time ankle was previously adjusted
int cycCounter               = 0;       // Number of times cycle has run

// Motion stages constants:
// Length of stage x = STAGE_x * STAGE_LENGTH
const int STAGE_1      = 2;    // Set leg to initial position
const int STAGE_2      = 10;   // Knee/ankle extends
const int STAGE_3      = 10;   // Hip returns to 0
const int STAGE_4      = 10;   // Hip extends left
const int STAGE_5      = 5;    // Knee/ankle straightens 
const int STAGE_6      = 5;    // Knee/ankle straightens
const int STAGE_7      = 10;   // Hip returns to 0
const int STAGE_8      = 10;   // Hip extends right
const int STAGE_TOTAL  = STAGE_1 + STAGE_2 + STAGE_3 + STAGE_4 + STAGE_5 + STAGE_6 + STAGE_7 + STAGE_8;
const int STAGE_LENGTH = 200;   // [ms]

// Motion stages variables:
unsigned long stage1_start  = 0;
unsigned long stage2_start  = 0;
unsigned long stage3_start  = 0;
unsigned long stage4_start  = 0;
unsigned long stage5_start  = 0;
unsigned long stage6_start  = 0; 
unsigned long stage7_start  = 0;
unsigned long stage8_start  = 0;

// Joint angle variables:
float angleHip, angleKne, angleAnk;   // Current joint angles
float initHip, initKne, initAnk;      // Joint angles at beginning of current stage

// Joint target constants:
const float HIP_TARGET_R = -40;
const float HIP_TARGET_L = 40;
const float KNE_TARGET_R = -40;   
const float KNE_TARGET_L = 30;    
const float ANK_TARGET_R = 36;
const float ANK_TARGET_L = 32;    
const int DEVIATION      = 1;   // [degrees] Accepted deviation from target angle

// Joint target variables (reference target at current time):
float refHip, refKne, refAnk;

// Pulsing constants:
const int DT_SCALE = 1;   // Factor to scale dtOn and dtOff by

// Pulsing variables:
int currHip, currKne, currAnk;     // Muscle currently controlling joint
float dtOffHip, dtOffKne, dtOffAnk;   // [ms] Time on LOW per pulsing period

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
        cycCounter = 0;
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

    readJoints();

    // Select leg actions based on current stage in cycle:
    if (cycTime < STAGE_1) {
      readInitAngles(&stage1_start, STAGE_1);
      stepTime = cycTime;

      calcDtOffHip(HIP_TARGET_R);

      // Knee

      calcDtOffAnk(0);
    } 
    else if (cycTime < STAGE_1 + STAGE_2) {
      readInitAngles(&stage2_start, STAGE_2);
      stepTime = cycTime - STAGE_1;
      
      adjustLeg(angleHip, HIP_TARGET_R, &dtOffHip, &previousAdjHip);
      
      extendLeg('k', initKne, KNE_TARGET_R, STAGE_2, stepTime);

      extendLeg('a', initAnk, ANK_TARGET_R, STAGE_2, stepTime);
    } 
    else if (cycTime < STAGE_1 + STAGE_2 + STAGE_3) {
      readInitAngles(&stage3_start, STAGE_3);
      stepTime = cycTime - (STAGE_1 + STAGE_2);
      
      extendLeg('h', initHip, 0, STAGE_3, stepTime);
      
      adjustLeg(angleKne, KNE_TARGET_R, &dtOffKne, &previousAdjKne);

      // Ankle
    } 
    else if (cycTime < STAGE_1 + STAGE_2 + STAGE_3 + STAGE_4) {
      readInitAngles(&stage4_start, STAGE_4);
      stepTime = cycTime - (STAGE_1 + STAGE_2 + STAGE_3);

      digitalWrite(Hip1, LOW);
      currHip = Hip2;
      extendLeg('h', initHip, HIP_TARGET_L, STAGE_4, stepTime);
      
      adjustLeg(angleKne, KNE_TARGET_R, &dtOffKne, &previousAdjKne);

      digitalWrite(Ankle1, LOW);
      currAnk = Ankle2;
      calcDtOffAnk(ANK_TARGET_L);
    } 
    else if (cycTime < STAGE_1 + STAGE_2 + STAGE_3 + STAGE_4+ STAGE_5){
      readInitAngles(&stage5_start, STAGE_5);
      stepTime = cycTime - (STAGE_1 + STAGE_2 + STAGE_3 + STAGE_4);
      
      adjustLeg(angleHip, HIP_TARGET_L, &dtOffHip,&previousAdjHip);
      
      extendLeg('k', initKne, 0, STAGE_5, stepTime);

      extendLeg('a', initAnk, 0, STAGE_5, stepTime);
    } 
    else if (cycTime < STAGE_1 + STAGE_2 + STAGE_3 + STAGE_4 + STAGE_5 + STAGE_6) {
      readInitAngles(&stage6_start, STAGE_6);
      stepTime = cycTime - (STAGE_1 + STAGE_2 + STAGE_3 + STAGE_4 + STAGE_5);

      adjustLeg(angleHip, HIP_TARGET_L, &dtOffHip, &previousAdjHip);

      digitalWrite(Knee1, LOW);
      currKne = Knee2;
      extendLeg('k', initKne, KNE_TARGET_L, STAGE_6, stepTime);

      // Ankle
    }
    else if (cycTime < STAGE_1 + STAGE_2 + STAGE_3 + STAGE_4 + STAGE_5 + STAGE_6 + STAGE_7) {
      readInitAngles(&stage7_start, STAGE_7);
      stepTime = cycTime - (STAGE_1 + STAGE_2 + STAGE_3 + STAGE_4 + STAGE_5 + STAGE_6);

      extendLeg('h', initHip, 0, STAGE_7, stepTime);

      adjustLeg(angleKne, KNE_TARGET_L, &dtOffKne,&previousAdjKne);

      // Ankle
    }
    else if (cycTime < STAGE_1 + STAGE_2 + STAGE_3 + STAGE_4 + STAGE_5 + STAGE_6 + STAGE_7 + STAGE_8) {
      if (millis() - stage8_start > STAGE_8 * STAGE_LENGTH) {
        initHip = calcAngleHip();
        initKne = calcAngleKne();
        initAnk = calcAngleAnk();
        cycCounter += 1;
        stage8_start = millis();
      }
      
      stepTime = cycTime - (STAGE_1 + STAGE_2 + STAGE_3 + STAGE_4 + STAGE_5 + STAGE_6 + STAGE_7);

      digitalWrite(Hip2, LOW);
      currHip = Hip1;
      extendLeg('h', initHip, HIP_TARGET_R, STAGE_8, stepTime);

      digitalWrite(Knee2, LOW);
      currKne = Knee1;

      digitalWrite(Ankle2, LOW);
      currAnk = Ankle1;
      extendLeg('a', initAnk, 0, STAGE_8, stepTime);
    }

    pulseMuscle(currHip, dtOffHip);
    pulseMuscle(currKne, dtOffKne);
    pulseMuscle(currAnk, dtOffAnk);
    displayInfo();

    if (cycCounter == 3) {
      pulsing = !pulsing;
      resetMuscles();
    }
  }
}

void readInitAngles(unsigned long *stageStart, int stage) {
/*
 * Update initial joint angles at beginning of each step
 */
  if (millis() - *stageStart > stage * STAGE_LENGTH) {
    initHip = calcAngleHip();
    initKne = calcAngleKne();
    initAnk = calcAngleAnk();
    *stageStart = millis();
  } 
}

void extendLeg(char joint, float initAngle, float targetAngle, int totalTime, int currTime) {
/*
 * Set dtOff to correct value to extend joint to desired angle
 */
  // [degrees] Amount of adjustment from initial angle required:
  float adjustAmount = ((targetAngle - initAngle) / totalTime) * (currTime + 1);

  // Update dtOn for correct joint:
  switch (joint) {
    case 'h':
      refHip = initAngle + adjustAmount;
      calcDtOffHip(refHip);
      break;
    case 'k':
      refKne = initAngle + adjustAmount;
      calcDtOffKne(refKne);
      break;
    case 'a':
      refAnk = initAngle + adjustAmount;
      calcDtOffAnk(refAnk);
      break;
  }
}

void adjustLeg(float currAngle, float target, float *dtOff, unsigned long *previousAdj) {
/*
 * Adjust dtOff to maintain leg at target angle
 */
  if (millis() - *previousAdj >= STAGE_LENGTH) {
    if (target > 0) {
      if (currAngle < (target - DEVIATION)) {
        *dtOff -= 0.5;
      } else if (currAngle > (target + DEVIATION)) {
        *dtOff += 0.5;
      }
    } else {
      if (currAngle < (target - DEVIATION)) {
        *dtOff += 0.5;
      } else if (currAngle > (target + DEVIATION)) {
        *dtOff -= 0.5;
      }
    }
    *previousAdj = millis();
  }
}

void calcDtOffHip(float hip) {
/*
 * Calculate dtOff from hip angle using best fit equations
 */
  //
  if (hip <= -33.666) {
    dtOffHip = exp((hip + 211.278) / 60.6412);
  } else if (hip <= -8.053) {
    dtOffHip = exp((hip + 286.298) / 86.2552);
  } else if (hip <= 0) {
    dtOffHip = exp((hip + 122.12) / 35.3606);
  } else if (hip <= 27.609) {
    dtOffHip = exp((hip - 189.133) / -54.5478);
  } else {
    dtOffHip = exp((hip - 136.878) / -36.901);
  } 
}

float calcAngleHip() {
/*
 * Calculate hip angle from dtOff
 */
  float angle;

  if (currHip == Hip1) {
    if (dtOffHip <= 16) {
      angle = -43.38;
    } else if (dtOffHip <= 18.707) {
      angle = -211.278 + 60.6412 * log(dtOffHip);
    } else if (dtOffHip <= 25.175) {
      angle = -286.298 + 86.2552 * log(dtOffHip);
    } else if (dtOffHip <= 30) {
      angle = -122.12 + 35.3606 * log(dtOffHip);
    } else {
      angle = 0;
    }
  } else if (currHip == Hip2) {
    if (dtOffHip <= 16) {
      angle = 33.89;
    } else if (dtOffHip <= 19.32) {
      angle = 136.878 - 36.901 * log(dtOffHip);
    } else if (dtOffHip <= 30) {
      angle = 189.133 - 54.5478 * log(dtOffHip);
    } else {
      angle = 0;
    }
  }

  return angle;
}

void calcDtOffKne(float knee) {
/*
 * Calculate dtOff from knee angle using best fit equations
 */
  if (knee <= -20.634) {
    dtOffKne = exp((knee + 298.684) / 83.511);
  } else if (knee <= 0) {
    dtOffKne = exp((knee + 140.077) / 35.8739);
  } else if (knee <= 29.54) {
    dtOffKne = exp((knee - 231.422) / -71.7939);
  } else if (knee <= 32.737) {
    dtOffKne = exp((knee - 90.636) / -21.7272);
  } else {
    dtOffKne = exp((knee - 40.5086) / -2.91636);
  }
}

float calcAngleKne() {
/*
 * Calculate knee angle from dtOff
 */
  float angle;

  if (currKne == Knee1) {
    if (dtOffKne <= 16) {
      angle = -298.684 + 83.511 * log(dtOffKne);
    } else if (dtOffKne <= 27.924) {
      angle = -298.684 + 83.511 * log(dtOffKne);
    } else if (dtOffKne <= 40) {
      angle = -140.077 + 35.8739 * log(dtOffKne);
    } else {
      angle = 0;
    }
  } else if (currKne == Knee2) {
    if (dtOffKne <= 10) {
      angle = 33.93;
    } else if (dtOffKne <= 14.365) {
      angle = 40.5086 - 2.91636 * log(dtOffKne);
    } else if (dtOffKne <= 16.643) {
      angle = 90.636 - 21.7272 * log(dtOffKne);
    } else if (dtOffKne <= 25) {
      angle = 231.422 - 71.7939 * log(dtOffKne);
    } else {
      angle = 0;
    }
  }

  return angle;
}

void calcDtOffAnk(float ankle) {
/*
 * Calculate dtOff from ankle angle using best fit equations
 */
  if (ankle <= -21.017) {
    dtOffAnk = exp((ankle + 96.799) / 27.1634);
  } else if (ankle <= -17.341) {
    dtOffAnk = exp((ankle + 59.1653) / 13.6739);
  } else if (ankle <= 0) {
    dtOffAnk = exp((ankle + 122.328) / 34.3242);
  } else if (ankle <= 17.429) {
    dtOffAnk = exp((ankle - 171.661) / -61.1219);
  } else {
    dtOffAnk = exp((ankle - 56.0971) / -15.3242);
  }
}

float calcAngleAnk() {
/*
 * Calculate ankle angle from dtOff
 */
  float angle;

  if (currAnk == Ankle1) {
    if (dtOffAnk <= 12) {
      angle = -30.81;
    } else if (dtOffAnk <= 16.279) {
      angle = -96.799 + 27.1634 * log(dtOffAnk);
    } else if (dtOffAnk <= 21.3) {
      angle = -59.1653 + 13.6739 * log(dtOffAnk);
    } else if (dtOffAnk <= 30) {
      angle = -122.328 + 34.3242 * log(dtOffAnk);
    } else {
      angle = 0;
    }
  } else if (currAnk == Ankle2) {
    if (dtOffAnk <= 10) {
      angle = 22.37;
    } else if (dtOffAnk <= 12.47) {
      angle = 56.0971 - 15.3242 * log(dtOffAnk);
    } else if (dtOffAnk <= 16.585) {
      angle = 171.661 - 61.1219 * log(dtOffAnk);
    } else {
      angle = 0;
    }
  }

  return angle;
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

void pulseMuscle(int muscle, float dtOff) {
/*
 * Pulse given muscle at given dtOff
 */
  // Variables for pulsing:
  int dtOn    = 5 * DT_SCALE;        // [ms] Time on HIGH per period
  int period  = dtOn + dtOff;        // [ms] Length of each period
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
    Serial.print("Hip dtOff = ");
    Serial.println(dtOffHip);
    Serial.print("Current Knee Target = ");
    Serial.print(refKne);
    Serial.print("\t");
    Serial.print("Actual Knee = ");
    Serial.print(angleHip);
    Serial.print("\t");
    Serial.print("Knee dtOff = ");
    Serial.println(dtOffKne);
    Serial.print("Current Ankle Target = ");
    Serial.print(refAnk);
    Serial.print("\t");
    Serial.print("Actual Ankle = ");
    Serial.print(angleAnk);
    Serial.print("\t");
    Serial.print("Ankle dtOff = ");
    Serial.println(dtOffAnk);

    Serial.println();
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

  currHip = Hip1;
  currKne = Knee1;
  currAnk = Ankle1;
  
  // dtOffHip = dtOffKne = dtOffAnk = ?
}
