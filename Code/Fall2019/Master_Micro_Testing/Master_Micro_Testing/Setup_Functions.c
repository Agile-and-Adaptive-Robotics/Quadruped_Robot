//Setup Functions.
//This script implements microcontroller setup functions for pins, ADC, SPI, timer interrupts, and USART.

//Include the associated header file.
#include "Master_Micro_Testing_Header.h"

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
	DDRB = 0b00101110;		//Set Port B inputs/outputs. 0 = SS, 1 = LDAC, 2 = DAC Chip Select, 3 = MOSI, 4 = MISO, 5 = SCK, 6 = Oscillator 1, 7 = Oscillator 2.
	DDRC = 0b00000000;		//Set Port C inputs/outputs. 0 = MUX, 1-5 = Optional Inputs, 6 = Reset, 7 = Unused.
	DDRD = 0b11111110;		//Set Port D inputs/outputs. 0 = RXD, 1 = TXD, 2-7 = MUX channel selection (ABCDEF).
	
	//Initialize Port B.
	sbi(PORTB, 1);			//Set LDAC high.
	sbi(PORTB, 2);			//Set DAC Chip Select high.
	cbi(PORTB, 3);			//Set MOSI low.
	cbi(PORTB, 5);			//Set SCK low.
		
	//Initialize Port D.
	cbi(PORTD, 2);			//Set MUX channel selection pins low.
	cbi(PORTD, 3);
	cbi(PORTD, 4);
	cbi(PORTD, 5);
	cbi(PORTD, 6);
	cbi(PORTD, 7);

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
	//Define local variables.
	unsigned char temp;
	
	// Setup for SPI.
	SPCR=0b01010010;		//0, 1 = SPI Clock Rate Setting (SPR0, SPR1); 2 = SPI Clock Phase (CPHA); 3 = SPI Clock Polarity (CPOL); 4 = Master / Slave Setting (MSTR); 5 = SPI Data Order (DORD); 6 = SPI Enable (SPE); 7 = SPI Interrupt Enable (SPIE)
	
	//Clear the SPI Status Register (SPSR) and SPI Data Register (SPDR) by reading them.
	temp = SPSR;
	temp = SPDR;
	
}

//Implement a function to setup timer interrupts.
void SetupTimerInterrupts( void )
{
	//Setup timer interrupt properties.
	TCCR1B |= (1 << WGM12);										// Configure timer 1 for CTC mode
	TIMSK1 |= (1 << OCIE1A);									// Enable CTC interrupt
	sei();													// Enable global interrupts
	//cli();														// Disable global interrupts
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
