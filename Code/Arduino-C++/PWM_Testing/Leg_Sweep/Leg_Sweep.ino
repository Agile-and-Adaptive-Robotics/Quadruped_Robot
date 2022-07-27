/*
 * Leg_Sweep
 * 
 * Program pulses hip, knee, and ankle simultaneously to sweep leg
 * 
 * TO DO:
 * - 
 * 
 * ISSUES:
 * - Leg shakes when a muscle turns fully on/off
 * 
 * Author: Flora Huang
 * Last Updated: 27 July 2022
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
const int STAGE_9      = 0;    // 
const int STAGE_10     = 0;    // 
const int STAGE_TOTAL  = STAGE_1 + STAGE_2 + STAGE_3 + STAGE_4 + STAGE_5 + STAGE_6 + STAGE_7 + STAGE_8 + STAGE_9 + STAGE_10;
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
unsigned long stage9_start  = 0;
unsigned long stage10_start = 0;

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

      calcDtOnHip(HIP_TARGET_R);

      // Knee

      calcDtOnAnk(0);
    } 
    else if (cycTime < STAGE_1 + STAGE_2) {
      readInitAngles(&stage2_start, STAGE_2);
      stepTime = cycTime - STAGE_1;
      
      adjustLeg(angleHip, HIP_TARGET_R, &dtOnHip, &previousAdjHip);
      
      extendLeg('k', initKne, KNE_TARGET_R, STAGE_2, stepTime);

      extendLeg('a', initAnk, ANK_TARGET_R, STAGE_2, stepTime);
    } 
    else if (cycTime < STAGE_1 + STAGE_2 + STAGE_3) {
      readInitAngles(&stage3_start, STAGE_3);
      stepTime = cycTime - (STAGE_1 + STAGE_2);
      
      extendLeg('h', initHip, 0, STAGE_3, stepTime);
      
      adjustLeg(angleKne, KNE_TARGET_R, &dtOnKne, &previousAdjKne);

      // Ankle
    } 
    else if (cycTime < STAGE_1 + STAGE_2 + STAGE_3 + STAGE_4) {
      readInitAngles(&stage4_start, STAGE_4);
      stepTime = cycTime - (STAGE_1 + STAGE_2 + STAGE_3);

      digitalWrite(Hip1, LOW);
      currHip = Hip2;
      extendLeg('h', initHip, HIP_TARGET_L, STAGE_4, stepTime);
      
      adjustLeg(angleKne, KNE_TARGET_R, &dtOnKne, &previousAdjKne);

      digitalWrite(Ankle1, LOW);
      currAnk = Ankle2;
      calcDtOnAnk(ANK_TARGET_L);
    } 
    else if (cycTime < STAGE_1 + STAGE_2 + STAGE_3 + STAGE_4+ STAGE_5) {
      readInitAngles(&stage5_start, STAGE_5);
      stepTime = cycTime - (STAGE_1 + STAGE_2 + STAGE_3 + STAGE_4);
      
      adjustLeg(angleHip, HIP_TARGET_L, &dtOnHip,&previousAdjHip);
      
      extendLeg('k', initKne, 0, STAGE_5, stepTime);

      extendLeg('a', initAnk, 0, STAGE_5, stepTime);
    } 
    else if (cycTime < STAGE_1 + STAGE_2 + STAGE_3 + STAGE_4 + STAGE_5 + STAGE_6) {
      readInitAngles(&stage6_start, STAGE_6);
      stepTime = cycTime - (STAGE_1 + STAGE_2 + STAGE_3 + STAGE_4 + STAGE_5);

      adjustLeg(angleHip, HIP_TARGET_L, &dtOnHip, &previousAdjHip);

      digitalWrite(Knee1, LOW);
      currKne = Knee2;
      extendLeg('k', initKne, KNE_TARGET_L, STAGE_6, stepTime);

      // Ankle
    }
    else if (cycTime < STAGE_1 + STAGE_2 + STAGE_3 + STAGE_4 + STAGE_5 + STAGE_6 + STAGE_7) {
      readInitAngles(&stage7_start, STAGE_7);
      stepTime = cycTime - (STAGE_1 + STAGE_2 + STAGE_3 + STAGE_4 + STAGE_5 + STAGE_6);

      extendLeg('h', initHip, 0, STAGE_7, stepTime);

      adjustLeg(angleKne, KNE_TARGET_L, &dtOnKne,&previousAdjKne);

      // Ankle
    }
    else if (cycTime < STAGE_1 + STAGE_2 + STAGE_3 + STAGE_4 + STAGE_5 + STAGE_6 + STAGE_7 + STAGE_8) {
      if (millis() - stage8_start > STAGE_8 * STAGE_LENGTH) {
        initHip = calcAngleHip();
        initKne = calcAngleKne();
        initAnk = calcAngleAnk();
        stage8_start = millis();
        cycCounter += 1;
      }
      
      stepTime = cycTime - (STAGE_1 + STAGE_2 + STAGE_3 + STAGE_4 + STAGE_5 + STAGE_6 + STAGE_7);

      digitalWrite(Hip2, LOW);
      currHip = Hip1;
      extendLeg('h', initHip, HIP_TARGET_R, STAGE_8, stepTime);

      digitalWrite(Knee2, LOW);
      currKne = Knee1;
      dtOnKne = 5;

      digitalWrite(Ankle2, LOW);
      currAnk = Ankle1;
      extendLeg('a', initAnk, 0, STAGE_8, stepTime);
    }
    else if (cycTime < STAGE_1 + STAGE_2 + STAGE_3 + STAGE_4 + STAGE_5 + STAGE_6 + STAGE_7 + STAGE_8 + STAGE_9) {
      readInitAngles(&stage9_start, STAGE_9);
      stepTime = cycTime - (STAGE_1 + STAGE_2 + STAGE_3 + STAGE_4 + STAGE_5 + STAGE_6 + STAGE_7 + STAGE_8);

      // Hip

      // Knee

      // Ankle
    }
    else if (cycTime < STAGE_1 + STAGE_2 + STAGE_3 + STAGE_4 + STAGE_5 + STAGE_6 + STAGE_7 + STAGE_8 + STAGE_9 + STAGE_10) {
      readInitAngles(&stage10_start, STAGE_10);
      stepTime = cycTime - (STAGE_1 + STAGE_2 + STAGE_3 + STAGE_4 + STAGE_5 + STAGE_6 + STAGE_7 + STAGE_8 + STAGE_9);

      // Hip

      // Knee

      // Ankle
    }

    pulseMuscle(currHip, dtOnHip);
    pulseMuscle(currKne, dtOnKne);
    pulseMuscle(currAnk, dtOnAnk);
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
 * Set dtOn to correct value to extend joint to desired angle
 */
  // [degrees] Amount of adjustment from initial angle required:
  float adjustAmount = ((targetAngle - initAngle) / totalTime) * (currTime + 1);

  // Update dtOn for correct joint:
  switch (joint) {
    case 'h':
      refHip = initAngle + adjustAmount;
      calcDtOnHip(refHip);
      break;
    case 'k':
      refKne = initAngle + adjustAmount;
      calcDtOnKne(refKne);
      break;
    case 'a':
      refAnk = initAngle + adjustAmount;
      calcDtOnAnk(refAnk);
      break;
  }
}

void adjustLeg(float currAngle, float target, float *dtOn, unsigned long *previousAdj) {
/*
 * Adjust dtOn to maintain leg at target angle
 */
  if (millis() - *previousAdj >= STAGE_LENGTH) {
    if (target > 0) {
      if (currAngle < (target - DEVIATION)) {
        *dtOn += 0.5;
      } else if (currAngle > (target + DEVIATION)) {
        *dtOn -= 0.5;
      }
    } else {
      if (currAngle < (target - DEVIATION)) {
        *dtOn -= 0.5;
      } else if (currAngle > (target + DEVIATION)) {
        *dtOn += 0.5;
      }
    }
    *previousAdj = millis();
  }
}

void calcDtOnHip(float hip) {
 /*
 * Calculate dtOn from hip angle using best fit equations
 * Note: exp(x) = e^x
 */
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

  if (dtOnHip > 50) {
    dtOnHip = 50;
  }
}

float calcAngleHip() {
/*
 * Calculate hip angle from dtOn
 */
  float angle; 
  
  if (currHip == Hip1) {
    if (dtOnHip <= 7.103) {
      angle = 0;
    } else if (dtOnHip <= 19.817) {
      angle = 60.6077 - 30.9148 * log(dtOnHip);
    } else if (dtOnHip <= 34.63) {
      angle = 37.9365 - 23.3237 * log(dtOnHip);
    } else {
      angle = -15.4466 - 8.26376 * log(dtOnHip);
    }
  } else if (currHip == Hip2) {
    if (dtOnHip <= 8.835) {
      angle = 0;
    } else if (dtOnHip <= 14.707) {
      angle = -72.8896 + 33.4555 * log(dtOnHip);
    } else if (dtOnHip <= 33.821) {
      angle = -22.2 + 14.6 * log(dtOnHip);
    } else {
      angle = 28.8104 + 0.112872 * log(dtOnHip);
    }
  }

  return angle;
}

void calcDtOnKne(float knee) {
 /*
 * Calculate dtOn from knee angle using best fit equations
 * Note: exp(x) = e^x
 */
  // Calculate dtOn:
  if (knee <= -51.094) {
    dtOnKne = exp((knee + 35.7827) / -4.32654);
  } else if (knee <= -45.623) {
    dtOnKne = exp((knee - 70.1469) / -34.2596);
  } else if (knee <= 0) {
    dtOnKne = exp((knee - 106.384) / -44.9832);
  } else if (knee <= 20.344) {
    dtOnKne = exp((knee + 117.77) / 40.9058);
  } else if (knee <= 25.522) {
    dtOnKne = exp((knee + 59.5613) / 23.6659);
  } else {
    dtOnKne = exp((knee + 0.173934) / 7.1473);
  }

  if (dtOnKne > 50) {
    dtOnKne = 50;
  }
}

float calcAngleKne() {
/*
 * Calculate knee angle from dtOn
 */
  float angle;

  if (currKne == Knee1) {
    if (dtOnKne <= 10.644) {
      angle = 0;
    } else if (dtOnKne <= 29.347) {
      angle = 106.384 - 44.9832 * log(dtOnKne);
    } else if (dtOnKne <= 34.428) {
      angle = 70.1469 - 34.2596 * log(dtOnKne);
    } else {
      angle = -35.7827 - 4.32654 * log(dtOnKne);
    }   
  } else if (currKne == Knee2) {
    if (dtOnKne <= 17.797) {
      angle = 0;
    } else if (dtOnKne <= 29.265) {
      angle = -117.77 + 40.9058 * log(dtOnKne);
    } else if (dtOnKne <= 36.422) {
      angle = -59.5613 + 23.6659 * log(dtOnKne);
    } else {
      angle = -0.173934 + 7.1473 * log(dtOnKne);
    }

    if (dtOnAnk > 50) {
      dtOnAnk = 50;
    }
  }

  return angle;
}

void calcDtOnAnk(float ankle) {
 /*
 * Calculate dtOn from ankle angle using best fit equations
 * Note: exp(x) = e^x
 */
  // Calculate dtOn:
  if (currAnk == Ankle2) {
    if (ankle <= 21.213) {
      dtOnAnk = exp((ankle + 195.195) / 67.295);
    } else if (ankle <= 29.217) {
      dtOnAnk = exp((ankle + 40.0957) / 19.3167);
    } else {
      dtOnAnk = exp((ankle - 2.90771) / 7.24748);
    }     
  } else if (currAnk == Ankle1) {
    if (ankle <= 26.816) {
      dtOnAnk = exp((ankle - 93.13) / -27.4485);
    } else if (ankle <= 35.78) {
      dtOnAnk = exp((ankle - 52.9086) / -10.8003);
    } else {
      dtOnAnk = 10;
    }
  }
}

float calcAngleAnk() {
/*
 * Calculate ankle angle from dtOn
 */
  float angle;

  if (currAnk == Ankle2) {
    if (dtOnAnk <= 18.185) {
      angle = 0;
    } else if (dtOnAnk <= 24.923) {
      angle = -195.195 + 67.295 * log(dtOnAnk);
    } else if (dtOnAnk <= 37.719) {
      angle = -40.9057 + 19.3167 * log(dtOnAnk);
    } else {
      angle = 2.90771 + 7.24748 * log(dtOnAnk);
    }    
  } else if (currAnk == Ankle1) {
    if (dtOnAnk <= 5) {
      angle = 35.78;
    } else if (dtOnAnk <= 11.201) {
      angle = 52.9086 - 10.8003 * log(dtOnAnk);
    } else if (dtOnAnk <= 25) {
      angle = 93.13 - 27.4485 * log(dtOnAnk);
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
  
  dtOnHip = 0;
  dtOnKne = 5;
  dtOnAnk = 10;
}
