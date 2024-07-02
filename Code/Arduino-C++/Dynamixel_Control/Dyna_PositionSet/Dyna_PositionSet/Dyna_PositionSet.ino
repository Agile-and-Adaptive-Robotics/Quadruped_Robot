#include <DynamixelWorkbench.h>

DynamixelWorkbench dxl_wb;

uint8_t ID = 1;
int32_t torqueOn = 1;
int32_t torqueOff = 0;
int32_t presentPosition = 0;
int32_t timeInterval = 10;
int32_t stepDelay = 2000;
unsigned long previousTime = millis();

char inputBuffer[4];
int32_t value;

void setup() {

  Serial.begin(57600);
  uint16_t modelNumber = 0;

  // initialize communication with dynamixels
  dxl_wb.init("1", 1000000);
  dxl_wb.ping(ID, &modelNumber);
  dxl_wb.writeRegister(ID, "Torque_Control_Mode_Enable", torqueOn);

}
void loop() {
  if(Serial.available()> 1 ){
    Serial.readBytes(inputBuffer,sizeof(inputBuffer));
    value = atoi(inputBuffer);
    memset(inputBuffer,0,sizeof(inputBuffer));
    dxl_wb.writeRegister(ID,"Goal_Torque",value);
    Serial.print("Goal Torque = ");
    Serial.println(value);


  }
}