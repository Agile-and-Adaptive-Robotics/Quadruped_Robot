#include <PinChangeInterrupt.h>
const byte encoderPinA = 2;
const byte encoderPinB = 3;
const byte encoderTwoPinA = 4;
const byte encoderTwoPinB = 5;

volatile int count = 0;
volatile int countTwo = 0;
int protectedCount = 0;
int protectedCountTwo = 0;
int previousCount = 0;
int previousCountTwo =0;

#define readA bitRead(PIND,2)//faster than digitalRead()
#define readB bitRead(PIND,3)//faster than digitalRead()
#define readATwo bitRead(PIND,4)
#define readBTwo bitRead(PIND,5)

void setup() {
  Serial.begin (115200);
  Serial.println("starting");

  pinMode(encoderPinA, INPUT_PULLUP);
  pinMode(encoderPinB, INPUT_PULLUP);
  pinMode(encoderTwoPinA, INPUT_PULLUP);
  pinMode(encoderTwoPinB,INPUT_PULLUP);
 
  //attachInterrupt(digitalPinToInterrupt(encoderPinA), isrA, CHANGE);
  //attachInterrupt(digitalPinToInterrupt(encoderPinB), isrB, CHANGE);
  attachPCINT(digitalPinToPCINT(encoderPinA), isrA, CHANGE);
  attachPCINT(digitalPinToPCINT(encoderPinB), isrB, CHANGE);
  attachPCINT(digitalPinToPCINT(encoderTwoPinA),isrATwo,CHANGE);
  attachPCINT(digitalPinToPCINT(encoderTwoPinB),isrBTwo,CHANGE);
}

void loop() {
  noInterrupts();
  protectedCount = count;
  protectedCountTwo = countTwo;
  interrupts();
 
  if(protectedCount != previousCount) {
   //Serial.println(protectedCount);
  }
  if(protectedCountTwo != previousCountTwo){
  //  Serial.println(protectedCountTwo);
  }
  Serial.print(protectedCount);
  Serial.print(",");
  Serial.print(protectedCountTwo);
  Serial.println(",");
  
  previousCount = protectedCount;
  previousCountTwo = protectedCountTwo;
}

void isrA() {
  if(readB != readA) {
    count ++;
  } else {
    count --;
  }
}
void isrB() {
  if (readA == readB) {
    count ++;
  } else {
    count --;
  }
}
void isrATwo() {
  if(readBTwo != readATwo) {
    countTwo ++;
  } else {
    countTwo --;
  }
}
void isrBTwo() {
  if (readATwo == readBTwo) {
    countTwo ++;
  } else {
    countTwo --;
  }
}
