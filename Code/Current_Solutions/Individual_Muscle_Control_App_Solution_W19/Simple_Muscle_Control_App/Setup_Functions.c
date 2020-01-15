//Setup Functions.
//This script implements microcontroller setup functions for pins, ADC, SPI, timer interrupts, and USART.

//Include the associated header file.
#include "Simple_Muscle_Control_App_Header.h"

//Implement a function to setup mircocontroller functionality.
void SetupMicro( void )
{
	
	//Setup the microcontroller pins.
	SetupPins();
	
	//Setup for ADC.
	SetupADC();
	
	//Setup SPI communication.
	SetupSPI();
	
	//Setup timer interrupts.
	SetupTimerInterrupts();
	
	//Setup USART communication.
	SetupUSART();	
	
}

//Implement a function to setup the microcontroller pins.
void SetupPins( void )
{
	//Setup pins for SPI Interface, Chip Select, and Serial Communication.
	DDRB = 0b00101111;		//Set Output Ports for the SPI Interface & Chip Select.
	DDRC = 0b00110000;		//Set port C for ADC.
	DDRD = 0b11111110;		//Set pin 1 on port D as output for serial communication and pin 7 as a cycle pin to test the clock.
		
	//Initialize the clock pin.
	cbi(PORTD, 2);
	cbi(PORTD, 3);
	cbi(PORTD, 4);
	cbi(PORTD, 5);
	cbi(PORTD, 6);
	cbi(PORTD, 7);
		
	//Initialize the valve pins.
	cbi(PORTB, 2);
	cbi(PORTC, 1);
	cbi(PORTC, 2);
	cbi(PORTC, 3);
	cbi(PORTC, 4);
	cbi(PORTC, 5);
	
	//Initialize the DAC Pins.
	sbi(PORTB, 0);			//Set the Chip Select high.
	sbi(PORTB, 1);			//Set the LDAC high.
}

//Implement a function to setup ADC.
void SetupADC( void )
{
	//Setup the ADC.
	ADCSRA = 0b10000111;	//ADC on, /128 for a 16 MHz clock, interrupt off.		
}

//Implement a function to setup SPI communication.
void SetupSPI( void )
{
	// Setup for SPI.
	SPCR=0b01010010;
	SPSR=0b00000000;
}

//Implement a function to setup timer interrupts.
void SetupTimerInterrupts( void )
{
	//Setup timer interrupt properties.
	TCCR1B |= (1 << WGM12);										// Configure timer 1 for CTC mode
	TIMSK1 |= (1 << OCIE1A);									// Enable CTC interrupt
	sei();														// Enable global interrupts
	OCR1A = 15999;												//Set target timer count for 1 kHz interrupt given 16MHz clock & prescaler of 1. Use 3999 for 4 kHz under same conditions. OCR1A = Target_Timer_Count = (Clock_Frequency / (Prescale * Target_Frequency)) – 1
	TCCR1B |= ((1 << CS10) | (0 << CS11) | (0 << CS12));		//Sets the prescaler to 1.
}

//Implement a function to setup USART communication.
void SetupUSART( void )
{
	//USART Setup
	UBRR0H = MYUBRR >> 8;
	UBRR0L = MYUBRR;
	UCSR0B = (1<<RXEN0)|(1<<TXEN0);
	stdout = &mystdout;
}
