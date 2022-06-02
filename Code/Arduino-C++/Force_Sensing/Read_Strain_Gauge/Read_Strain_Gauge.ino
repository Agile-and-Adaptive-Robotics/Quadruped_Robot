#include "HX711.h"

// HX711 circuit wiring
const int LOADCELL_DOUT_PIN = 2;
const int LOADCELL_SCK_PIN = 3;
const int GAIN = 128;

HX711 scale;

void setup() {
  Serial.begin(9600);
  scale.begin(LOADCELL_DOUT_PIN, LOADCELL_SCK_PIN, GAIN);
  
  scale.set_scale();
  scale.tare();  //Reset the scale to 0

  //long zero_factor = scale.read_average(10); //Get a baseline reading
  //Serial.print("Zero factor: "); //This can be used to remove the need to tare the scale. Useful in permanent scale projects.
  //Serial.println(zero_factor);

}

void loop() {

  long temp = Serial.read();
  long reading = scale.read();
//  if(temp == 'a')
//      Serial.println(scale.read_average(15));
  Serial.println(reading);
//
//  float calc = (4.571e-5)*reading + 40.52; //linear fit
////  float factor = pow(reading,2);
////  float calc = (-8.218e-12*factor) + 3.557e-05*reading + 37.65; //quadratic fit
//
//  Serial.print("Reading: ");
//  Serial.println(calc);

  delay(100);
}
