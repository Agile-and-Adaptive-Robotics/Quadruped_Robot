/* qtb_dataStream.ino
 * 
 * This sketch generates a data stream based on readings taken from encoders 
 * 
 * User-board communications are enabled via the serial window with limited
 * ability to control key variables. Parseable serial inputs are:
 * 'e': tares encoder
 * 
 * Notes:
 * (1) Effectively serves as a pause function for the displayed data stream
 * 
 * (3) Because the encoders are inherently noisy, averaging strategies are 
 * often useful for data collection efforts. Here an exponentially-weighted
 * average (avg_strategy = 2) with a gain variable (beta, see "user-controlled
 * variables" below) that can be tuned to balance response speed with signal
 * stability is used. The number of readings across which to average is controlled
 * by the variable n below.
 * 
 * Written by Stu McNeal
 * 10/5/2022
 */

#include <Arduino.h>
#include <Encoder.h>

// **********************************************************************
// user-controlled variables
// ----------------------------------------------------------------------

//--time controls
unsigned int timeInterval = 10; // [ms] time between readings printed

float beta        = 0.15;//gain variable representing weight of new reading. (must be 0 < beta < 1)
int n             = 20  ;//[#] number of readings across which to average

// **********************************************************************

// create encoder objects
Encoder encoder(2,3);

// initialize joint position vars
double position   = -999.0;

// initialize joint position vars for averaging
double angle = 0;

// initialize time vars
unsigned long previousTime = millis();

// ******************** setup() ****************************************
void setup(){
  // initialize serial communications
  Serial.begin(115200);
}

// ******************** loop() *****************************************
void loop(){
  // once timeInterval has passed, fetch current joint angles
  if(millis() - previousTime >= timeInterval)
  {
    //update encoder readings
    updateJointAngles();
    
    //reset the timer
    previousTime = millis();
  }

  // Serial Interfacing
  if(Serial.available()) {
    char msg = Serial.read();
    if (msg != '\n'){
    parseMsg(msg);
    }
    Serial.flush();
  }
} 

// ******************** parseMsg(msg) **********************************
void parseMsg(char msg){ 
  /* parseMsg(msg) receives the character sent by the user to the serial 
   * window and toggles the corresponding control, described below. parseMsg(msg) returns nothing.
   * 
   * parseMsg interprets the following serial inputs:
   * 'e': tares encoder
   * 's': toggles averaging strategy. [0] -> [1] -> [2] -> [0] -> [1] -> ...
   */
  // turn on the muscle of interest
  if(msg == 'e'){
    encoder.write(0);//tare encoder
  } else{
    Serial.println("no matches");
  }
}

// ******************** updateJointAngles() ****************************
void updateJointAngles(){
  /* This function updates encoder readings according to the averaging 
  * strategy determined by the avg_strategy variable. If 
  * displayMsg==true, the function calls printEncoders(). Returns 
  * nothing.

  * avg_strategy == 2: exponentially-weighted averaging applied
  */
    // generate vars to hold the current average sensor value
    float tempAvgAngle=0;
  
    // calculate the current sensor average (in degrees)
    for (int i=0;i<n;i++){
      tempAvgAngle += encoder.read()*0.04395;
    }
    tempAvgAngle /= n;
    angle = beta*tempAvgAngle + (1-beta)*angle; 
  printMsg();
}

// ******************** printMsg() *************************************
void printMsg(){ 
    Serial.print(angle);
    Serial.print(",");
    Serial.println(millis() % 1000);
}
