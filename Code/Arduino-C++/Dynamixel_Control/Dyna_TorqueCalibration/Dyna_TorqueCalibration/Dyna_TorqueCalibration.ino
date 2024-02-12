// manual calibration of Dynamixel torque sensor
//
// apply a known torque to the Dynamixel motor and compare
// the current load output to the known torque.
//
// theoretical stall torque of MX-64AT with 12V supply is 6.0 N-m

#include <DynamixelWorkbench.h>

// create instance of dynamixel motor
DynamixelWorkbench motor;

uint8_t ID = 1;
int currentLoad;
int maxTorque; 

void setup() {
  // initialize serial communication
  Serial.begin(57600);

  uint16_t model_number = 0;

  // initialize communication with dynamixel
  motor.init("1", 1000000);
  motor.ping(ID, &model_number);

  // read motor maximum torque
  motor.readRegister(ID,"Torque_Limit",&maxTorque);

  // move motor to neutral position
  motor.goalPosition(ID,(int)2048);

  delay(2000);

  // move motor 90 degrees
  motor.goalPosition(ID,(int)1024);
}

void loop() {
  // read and print current load
  // load reading of 0 - 1023 is mapped to 0 - 100% of maximum torque in the CCW direction
  // load reading of 1024 - 2047 is mapped to 0 - 100% of maximum torque in the CW direction

  motor.readRegister(ID,"Present_Load",&currentLoad);
  Serial.println(currentLoad);

}
