#include <DynamixelWorkbench.h>

// create instance of dynamixel motor
DynamixelWorkbench motor;

char function;
int valueLow;
int valueHigh;


void setup() {
// initialize serial communication
  Serial.begin(57600);
}

void loop() {

if(Serial.available()==3){
  function = Serial.read();
  valueLow = Serial.read();
  valueHigh = Serial.read();
  Serial.print("function = ");
  Serial.println(function);
  Serial.print("values = ");
  Serial.print(valueLow);
  Serial.print(", ");
  Serial.println(valueHigh);
  }

Serial.flush();
}
