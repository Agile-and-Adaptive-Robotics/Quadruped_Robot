//  check the range of motion for each spring
//
//  motor will rotate the spring at 2 degrees/second until
//  user terminates program upon spring self-inpacting.
//
//  end position to be saved in Matlab for each spring configuration.

#include <DynamixelWorkbench.h>

// create instance of dynamixel motor
DynamixelWorkbench motor;

uint8_t ID = 1;
int32_t movingSpeed = 18;   //  0 - 1023 is mapped to 0 - 116.62 rpm (0.114 rpm per unit)
int middle = 2048;
int32_t position;
int32_t torque;
char input;                 
// 'x' toggles motor counter-clockwise rotation
// 'a' toggles motor clockwise rotation
// 's' sets motor back to neutral
unsigned char CCW = 0;
unsigned char CW = 0;
unsigned char on = 1;

void setup() {

  // initialize serial communication
  Serial.begin(57600);

  uint16_t model_number = 0;

  // initialize communication with dynamixel
  motor.init("1", 1000000);
  motor.ping(ID, &model_number);

  // move motor to neutral position
  motor.goalPosition(ID,middle);

  // set moving speed of motor to ~2 degrees/second
  motor.writeRegister(ID,"Moving_Speed",movingSpeed);
}

void loop() {

  motor.readRegister(ID,"Present_Position",&position);
  motor.readRegister(ID,"Present_Load",&torque);

  Serial.println(position);
  // Serial.print(",");
  Serial.println(torque);

  if(Serial.available() > 0){  //   if serial data is available   
    input = Serial.read();     //   read data from the serial port into input character variable
    Serial.flush();            //   clear serial data
    Control(input);
  }
}

void Control(char input) {
  switch(input) {
    // 's' sets motor back to its middle position
    case 's':
    motor.goalPosition(ID,middle);
    break;

    // 'x' toggles motor counter-clockwise rotation
    case 'x':
    CW = 0;
    CCW = CCW ^ 0x01;
    if(CCW == on) {
      motor.goalPosition(ID,1024);
    }
    else{
      motor.goalPosition(ID,position);
    }
    break;

    // 'a' toggles motor clockwise rotation
    case 'a':
    CCW = 0;
    CW = CW ^ 0x01;
    if(CW == on) {
      motor.goalPosition(ID,3072);
    }
    else{
      motor.goalPosition(ID,position);
    }
    break;
    
  }
}