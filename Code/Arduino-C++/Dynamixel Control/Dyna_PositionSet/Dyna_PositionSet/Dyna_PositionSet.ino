#include <DynamixelWorkbench.h>

DynamixelWorkbench dxl_wb;

void setup() {

Serial.begin(57600);

int32_t get_data = 3;
uint16_t model_number = 0;
uint8_t ID = 1;
int32_t torque_ccw = 512;
int32_t torque_cw = 1534;
int32_t middle = 1024;
int32_t torque_on = 1;
int32_t torque_off = 0;
bool works = false;

// initialize communication with dynamixels
  dxl_wb.init("1",1000000);
  dxl_wb.ping(ID, &model_number);

// position control to check communication with motor
  dxl_wb.writeRegister(ID,"Goal_Position",torque_ccw);
  delay(500);
  dxl_wb.goalPosition(ID,torque_cw);
  delay(500);
  dxl_wb.goalPosition(ID,middle);
  delay(500);

  dxl_wb.setTorqueControlMode(ID);
  dxl_wb.writeRegister(ID,"Goal_Torque",torque_ccw);

  // dxl_wb.readRegister(ID,"Torque_Control_Mode_Enable",&get_data);
  works = dxl_wb.readRegister(ID,"Torque_Control_Mode_Enable",&get_data);
  // works = dxl_wb.readRegister(ID,"Torque_Ctrl_Mode_Enable",&get_data);
  Serial.println(works);

  Serial.println(get_data);
  delay(5000);
  dxl_wb.setPositionControlMode(ID);

}
void loop() {


}
