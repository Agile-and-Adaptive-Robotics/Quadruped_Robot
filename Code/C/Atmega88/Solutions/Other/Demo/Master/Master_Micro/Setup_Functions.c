//Setup Functions.

//This script implements microcontroller setup functions for pins, ADC, SPI, timer interrupts, and USART.

//Include the associated header file.
#include "Master_Micro_Header.h"

//Implement a function to setup microcontroller functionality.
void setup_micro( void )
{
	
	//Setup the microcontroller pins.
	setup_pins();
	
	//Setup for ADC.
	setup_adc();
	
	//Setup SPI communication.
	setup_spi();
	
	//Setup timer interrupts.
	setup_timer_interrupts();
	
	//Setup USART communication.
	setup_usart();	
	
}

//Implement a function to setup the microcontroller pins.
void setup_pins( void )
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
void setup_adc( void )
{
	//Setup the ADC.
	ADCSRA = 0b10000111;	//ADC on, /128 for a 16 MHz clock, interrupt off.		
}

//Implement a function to setup SPI communication.
void setup_spi( void )
{
	//Define local variables.
	uint8_t temp;
	
	// Setup for SPI.
	SPCR=0b01010010;		//0, 1 = SPI Clock Rate Setting (SPR0, SPR1); 2 = SPI Clock Phase (CPHA); 3 = SPI Clock Polarity (CPOL); 4 = Master / Slave Setting (MSTR); 5 = SPI Data Order (DORD); 6 = SPI Enable (SPE); 7 = SPI Interrupt Enable (SPIE)
	
	//Clear the SPI Status Register (SPSR) and SPI Data Register (SPDR) by reading them.
	temp = SPSR;
	temp = SPDR;
	
}

//Implement a function to setup timer interrupts.
void setup_timer_interrupts( void )
{
	//Setup timer interrupt properties.
	TCCR1B |= (1 << WGM12);										// Configure timer 1 for CTC mode
	TIMSK1 |= (1 << OCIE1A);									// Enable CTC interrupt
	sei();													// Enable global interrupts
	OCR1A = 15999;												//Set target timer count for 1 kHz interrupt given 16MHz clock & prescaler of 1. Use 3999 for 4 kHz under same conditions. OCR1A = Target_Timer_Count = (Clock_Frequency / (Prescale * Target_Frequency)) – 1
	TCCR1B |= ((1 << CS10) | (0 << CS11) | (0 << CS12));		//Sets the prescaler to 1.
}

//Implement a function to setup USART communication.
void setup_usart( void )
{
	//USART Setup
	UBRR0H = MYUBRR >> 8;
	UBRR0L = MYUBRR;
	UCSR0B = (1<<RXEN0)|(1<<TXEN0);
	stdout = &mystdout;
}

// Implement a function to initialize the slave manager.
void initialize_slave_manager( struct slave_struct_array * slave_ptr )
{
	
	// Disable global interrupts.
	cli(  );

	// Set the slave manager number of slaves.
	slave_ptr->num_slaves = NUM_SLAVES;

	// Initialize a counter to keep track of the joint ID.
	uint8_t joint_counter = 0;

	// Set the slave manager data.
	for ( uint8_t k = 0; k < NUM_SLAVES; ++k )						// Iterate through each slave...
	{
			
		// Set the slave ID for this slave.
		slave_ptr->slave[k].slave_ID = k + 1;
			
		// Set the muscle ID for this slave.
		slave_ptr->slave[k].muscle_ID = k + 39;
			
		// Set the first pressure sensor ID for this slave.
		slave_ptr->slave[k].pressure_sensor_ID1 = k + 1;
			
		// Determine how to set the second pressure sensor ID and whether to advance the joint counter.
		if ( k % 2 == 0 )											// If the index for this slave is even...
		{
				
			// Set the second pressure sensor ID for this slave.
			slave_ptr->slave[k].pressure_sensor_ID2 = k + 2;
				
			// Advance the joint counter.
			++joint_counter;
				
		}
		else
		{
				
			// Set the second pressure sensor ID for this slave.
			slave_ptr->slave[k].pressure_sensor_ID2 = k;
				
		}
			
		// Set the joint counter.
		slave_ptr->slave[k].joint_ID = joint_counter;
			
		// Set the sensor values and desired pressure value to be zero.
		slave_ptr->slave[k].pressure_sensor_value1 = 0;
		slave_ptr->slave[k].pressure_sensor_value2 = 0;
		slave_ptr->slave[k].joint_value = 0;
		slave_ptr->slave[k].desired_pressure = 0;
			
	}

	// Enable global interrupts.
	sei(  );
	
}


