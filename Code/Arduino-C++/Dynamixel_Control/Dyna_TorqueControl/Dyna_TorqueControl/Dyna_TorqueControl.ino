#include <DynamixelWorkbench.h>

DynamixelWorkbench dxl_wb;

int32_t torqueCCW = 512;
int32_t torqueCW = 1534;
int32_t torqueOn = 1;
int32_t torqueOff = 0;
int32_t timeInterval = 10;
int32_t stepDelay = 2000;
int input;

unsigned long previousTime = millis();

void setup() {

  Serial.begin(57600);
  uint16_t model_number = 0;
  uint8_t ID = 1;

  // initialize communication with dynamixels
  dxl_wb.init("1", 1000000);
  dxl_wb.ping(ID, &model_number);
  dxl_wb.writeRegister(ID, "Torque_Control_Mode_Enable", torque_on);

}
void loop() {

  if(Serial.available()){
    int input = Serial.parseInt();
    if(input != '\n'){
    Control(input);
    }
  }

  if(millis() - previousTime >= timeInterval){
    dataPrint();
    previousTime = millis();
  }

}

void Control(input){
  dxl_wb.writeRegister(ID, "Goal_Torque", input);
}

void dataPrint() {

  int32_t presentPosition;

  dxl_wb.getPresentPositionData(ID, (int32_t)&present_position);
  Serial.print(input);
  Serial.print(",");
  Serial.println(present_position);
  Serial.print(",");
  Serial.println(millis() % 1000);

}