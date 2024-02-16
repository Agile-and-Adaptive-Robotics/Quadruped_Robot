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
int32_t currentLoad;
int32_t currentPosition;
int32_t maxTorque = 6; 
int32_t degree = 45;
int32_t positionCalibration = 2048/180;
int32_t neutral = 2048;


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
  motor.goalPosition(ID,neutral);

  delay(2000);

  // move motor 90 degrees
  motor.goalPosition(ID,neutral-degree*positionCalibration);
}

void loop() {
  // read and print current load
  // load reading of 0 - 1023 is mapped to 0 - 100% of maximum torque in the CCW direction
  // load reading of 1024 - 2047 is mapped to 0 - 100% of maximum torque in the CW direction
  motor.readRegister(ID,"Present_Position",&currentPosition);
  int32_t position = (currentPosition/positionCalibration)-51;
  Serial.print(position);
  Serial.print("°, ");
  motor.readRegister(ID,"Present_Load",&currentLoad);
  if(currentLoad > 1023){
    int32_t load = ((currentLoad - 1024)/1023)*maxTorque;
    Serial.print(currentLoad);
    Serial.println(" CW");
  }
  else{
    int32_t load = (currentLoad/1023)*maxTorque;
    Serial.print(currentLoad);
    Serial.println(" CCW");
  }
}
