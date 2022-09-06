// Setup Functions.

// This script implements microcontroller setup functions for pins, ADC, SPI, timer interrupts, and USART.

// Include the associated header file.
#include "Slave_Micro_Header.h"


// Implement a function to setup microcontroller functionality.
void setup_micro( void )
{
	
	//Setup the microcontroller pins.
	setup_pins();
	
	//Setup for ADC.
	setup_ADC();
	
	//Setup SPI communication.
	setup_SPI();
	
	//Setup timer interrupts.
	setup_timer_interrupts();
	
	//Setup USART communication.
	setup_USART();	
	
	//Enable global interrupts.
	sei();													// Enable global interrupts
	
}


// Implement a function to setup the microcontroller pins.
void setup_pins( void )
{
	//Setup pins for SPI Interface, Chip Select, and Serial Communication.
	DDRB = 0b00010011;		//Set Port B inputs/outputs. 0 = Optional Output, 1 = To Transistor Array, 2 = SS, 3 = MOSI, 4 = MISO, 5 = SCK, 6 = Oscillator 1, 7 = Oscillator 2.
	DDRC = 0b00000000;		//Set Port C inputs/outputs. 0 = Input 0 (Pressure 1), 1 = Input 1 (Pressure 2), 2 = Input 3 (Joint Angle), 3 = Optional Input 3, 4 = Optional Input 4, 5 = Optional Input 5, 6 = Reset, 7 = Unused. 
	DDRD = 0b00111110;		//Set Port D inputs/outputs. 0 = RXD, 1 = TXD, 2-5 = Optional Outputs, 6 = Encoder Pin A, 7 = Encoder Pin B 
		
	//Initialize Port B.
	cbi(PORTB, 0);			//Set optional output low.
	cbi(PORTB, 1);			//Set output to transistor array low.
	cbi(PORTB, 4);			//Set MISO low.
		
	//Initialize Port D.
	cbi(PORTD, 2);			//Set all optional outputs low.
	cbi(PORTD, 3);
	cbi(PORTD, 4);
	cbi(PORTD, 5);

}


// Implement a function to setup ADC.
void setup_ADC( void )
{
	//Setup the ADC.
	ADCSRA = 0b10000111;	//ADC on, /128 for a 16 MHz clock, interrupt off.		
}


// Implement a function to setup SPI communication.
void setup_SPI( void )
{
	
	//Define local variables.
	uint8_t temp;
	
	//Configure the SPI Control Register (SPCR).
	//SPCR=0b01000010;			//0, 1 = SPI Clock Rate Setting (SPR0, SPR1); 2 = SPI Clock Phase (CPHA); 3 = SPI Clock Polarity (CPOL); 4 = Master / Slave Setting (MSTR); 5 = SPI Data Order (DORD); 6 = SPI Enable (SPE); 7 = SPI Interrupt Enable (SPIE)
	SPCR=0b11000010;			//0, 1 = SPI Clock Rate Setting (SPR0, SPR1); 2 = SPI Clock Phase (CPHA); 3 = SPI Clock Polarity (CPOL); 4 = Master / Slave Setting (MSTR); 5 = SPI Data Order (DORD); 6 = SPI Enable (SPE); 7 = SPI Interrupt Enable (SPIE)
	
	//Clear the SPI Status Register (SPSR) and SPI Data Register (SPDR) by reading them.
	temp = SPSR;
	temp = SPDR;
	
}


// Implement a function to setup timer interrupts.
void setup_timer_interrupts( void )
{
	//Setup timer interrupt properties.
	TCCR1B |= (1 << WGM12);										// Configure timer 1 for CTC mode
	TIMSK1 |= (1 << OCIE1A);									// Enable CTC interrupt
	OCR1A = 15999;												//Set target timer count for 1 kHz interrupt given 16MHz clock & prescaler of 1. Use 3999 for 4 kHz under same conditions. OCR1A = Target_Timer_Count = (Clock_Frequency / (Prescale * Target_Frequency)) – 1
	TCCR1B |= ((1 << CS10) | (0 << CS11) | (0 << CS12));		//Sets the prescaler to 1.
}


// Implement a function to setup pin change interrupts.
void setup_pin_change_interrupts( void )
{
	
	// Set which pins contribute to the pin change interrupt.
	PCMSK2 |= ( (1 << PCINT21) |(1 << PCINT22) | (1 << PCINT23) );					// Pins PD5 = PCINT21, Pins PD6 = PCINT22, and PD7 = PCINT23 contribute to the pin change interrupt.
	
	// Enable the pin change interrupts.
	PCICR |= (1 << PCIE2);
	
}

// Implement a function to setup USART communication.
void setup_USART( void )
{
	//USART Setup
	UBRR0H = MYUBRR >> 8;
	UBRR0L = MYUBRR;
	UCSR0B = (1<<RXEN0)|(1<<TXEN0);
	stdout = &mystdout;
}

