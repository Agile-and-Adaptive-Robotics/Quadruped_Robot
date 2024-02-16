#include <DynamixelWorkbench.h>

// create instance of dynamixel motor
DynamixelWorkbench motor;

uint8_t ID = 1;
int32_t currentLoad = 1;
int32_t maxTorque = 1;
int32_t currentTorque;
String direction;
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

  // read current load 
  motor.readRegister(ID,"Present_Load",&currentLoad);
  Serial.println(currentLoad);
  
}
