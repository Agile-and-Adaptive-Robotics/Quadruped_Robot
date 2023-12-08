/* qtb_dataStream.ino
 * 
 * This sketch generates a data stream based on readings taken from encoders 
 * mounted to the Quadruped Test Bench in the Agile & Adaptive Robotics 
 * Laboratory at Portland State University. 
 * 
 * User-board communications are enabled via the serial window with limited
 * ability to control key variables. Parseable serial inputs are:
 * 'p': toggles message display (1) 
 * 'v': toggles message verbosity (2)
 * 'a': tares ankle encoder
 * 'h': tares hip encoder
 * 'k': tares knee encoder
 * 's': toggles averaging strategy (3). [1] -> [2] -> [0] -> [1] -> ...
 * 
 * Notes:
 * (1) Effectively serves as a pause function for the displayed data stream
 * 
 * (2) Verbose messages include language to inform the reader of both the 
 * encoder and the value. A fourth column reports the time modulus 
 * (reference = 1000 ms). Non-verbose messages contain only the encoder 
 * values and the time. 
 * 
 * (3) Because the encoders are inherently noisy, averaging strategies are 
 * often useful for data collection efforts. Here the user can choose from 
 * raw values (avg_strategy = 0), a simple averaging strategy (avg_strategy
 * = 1), or an exponentially-weighted average (avg_strategy = 2) with a gain
 * variable (beta, see "user-controlled variables" below) that can be tuned 
 * to balance response speed with signal stability. The number of readings 
 * across which to average is controlled by the variable n below.
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

//--averaging controls
int avg_strategy  = 1   ;//0: none (noisy); 1: standard averaging; 2: exponential (ie weighted) averaging (most stable)

float beta        = 0.15;//gain variable representing weight of new reading. (must be 0 < beta < 1)
int n             = 20  ;//[#] number of readings across which to average

//--display settings
bool displayMsg   = true;//determines whether to print angles to serial window
bool verboseMsg   = false;//determines whether context is printed with joint angles

// **********************************************************************

// define i/o pin locations (included here for system ID purposes)
#define Hip1 32   // Hip 1 
#define Hip2 33   // Hip 2
#define Ankle1 34 // Ankle 1
#define Ankle2 36 // Ankle 2
#define Knee1 35  // Knee 1
#define Knee2 37  // Knee 2

// create encoder objects
Encoder encoderHip(2,3);
Encoder encoderAnk(4,5);
Encoder encoderKne(6,7);

// initialize joint position vars
double positionHip   = -999.0;
double positionKnee  = -999.0;
double positionAnkle = -999.0;

// initialize joint position vars for averaging
double angleHip = 0;
double angleKne = 0;
double angleAnk = 0;

// initialize time vars
unsigned long previousTime = millis();

// ******************** setup() ****************************************
void setup(){
  // initialize serial communications
  Serial.begin(57600);
}

// ******************** loop() *****************************************
void loop(){
  // once timeInterval has passed, fetch current joint angles
  if(millis() - previousTime >= timeInterval)
  {
    //update encoder readings
    updateJointAngles();
    
    //if specified, print joint angles to serial monitor
    if(displayMsg){printMsg();}
    
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
   * 'p': toggles message display (ie pause the data stream)
   * 'v': toggles message verbosity
   * 'a': tares ankle encoder
   * 'h': tares hip encoder
   * 'k': tares knee encoder
   * 's': toggles averaging strategy. [0] -> [1] -> [2] -> [0] -> [1] -> ...
   */

   
  // turn on the muscle of interest
  if(msg == 'p'){
    displayMsg = !displayMsg;//toggle print messages
  } else if(msg == 'v'){
    verboseMsg = !verboseMsg;//toggle message verbosity
  } else if(msg == 'a'){
    encoderAnk.write(0);//tare ankle encoder
  } else if(msg == 'h'){
    encoderHip.write(0);//tare hip encoder
  } else if(msg == 'k'){
    encoderKne.write(0);//tare knee encoder
  } else if(msg == 's'){
    avg_strategy = (avg_strategy + 1) % 3;//toggle averaging strategy

    // notify user of current setting and pause for 3/4 seconds
    Serial.print("Averaging strategy = ");
    Serial.println(avg_strategy);
    delay(750);
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
  *
  * The averaging strategies, based on avg_strategy, are: 
  * avg_strategy == 0: no averaging applied, raw value printed 
  * avg_strategy == 1: simple averaging applied
  * avg_strategy == 2: exponentially-weighted averaging applied
  */
  
  // Case 0: raw values, no averaging applied:
  if (avg_strategy == 0){
    angleHip += encoderHip.read()*0.04395;
    angleKne += encoderKne.read()*0.04395;
    angleAnk += encoderAnk.read()*0.04395;
  } else {
    
    // generate vars to hold the current average sensor value
    float tempAvgHip=0, tempAvgKne=0, tempAvgAnk=0;
  
    // calculate the current sensor average (in degrees)
    for (int i=0;i<n;i++){
      tempAvgHip += encoderHip.read()*0.04395;
      tempAvgKne += encoderKne.read()*0.04395;
      tempAvgAnk += encoderAnk.read()*0.04395;
    }
    tempAvgHip /= n;  tempAvgKne /= n; tempAvgAnk /= n;

    // Case 1: normal averaging
    if (avg_strategy == 1){
      
      // update encoder vars using simple averaging
      angleHip = tempAvgHip; angleKne = tempAvgKne; angleAnk = tempAvgAnk;

    // Case 2: exponentially weighted averaging  
    } else if (avg_strategy == 2){
      
      // update encoder vars using an exponentially weighted average
      angleHip = beta*tempAvgHip + (1-beta)*angleHip; 
      angleKne = beta*tempAvgKne + (1-beta)*angleKne; 
      angleAnk = beta*tempAvgAnk + (1-beta)*angleAnk;
    }
  }
  if (displayMsg){printMsg();}
}

// ******************** printMsg() *************************************
void printMsg(){ 

  // if verboseMsg is enabled, print the verbose message
  if (verboseMsg) {
    Serial.print("Hip Angle = ");
    Serial.print(angleHip);
    Serial.print("\t");
    Serial.print("Knee Angle = ");
    Serial.print(angleKne);
    Serial.print("\t");
    Serial.print("Ankle Angle = ");
    Serial.print(angleAnk);
    Serial.print("\t");
    Serial.print("time = ");
    Serial.println(millis() % 1000);
  } else {
    Serial.print(angleHip);
    Serial.print(",");
    Serial.print(angleKne);
    Serial.print(",");
    Serial.print(angleAnk);
    Serial.print(",");
    Serial.println(millis() % 1000);
  }
}
