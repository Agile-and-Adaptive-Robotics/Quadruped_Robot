//Test Pressure Sensor Functionality.

//Include necessary header files.
#include <stdio.h>
#include <avr/io.h>
#include <avr/interrupt.h>
#define sbi(var, mask)   ((var) |= (uint8_t)(1 << mask))
#define cbi(var, mask)   ((var) &= (uint8_t)~(1 << mask))

//Define the clock speed.
#define F_CPU 16000000UL // 16 MHz CPU Clock Frequency
#include <util/delay.h>   // Include the built in Delay Function

//Define global variables.
unsigned int dac_data = 0;
unsigned int count = 0;
float duty_cycle_conversion;
float pressure_conversion;
float dac_conversion;
const float Kp = 1.0;

// SPI write read function
unsigned char spi_write_read(unsigned char spi_data)
{
	SPDR=spi_data;
	while ((SPSR & (1<<SPIF))==0);	// Wait until the data transfer is complete.
	return SPDR;
}

int main (void)
{

	//Compute the pressure conversion factor.
	pressure_conversion = 5./1023;
	
	//Compute the dac conversion factor.
	dac_conversion = 4095/5.;
	
	//Setup pins for SPI Interface, Chip Select, LEDs, and Serial Communication.
	DDRB = 0b00101111;		//Set Output Ports for the SPI Interface & Chip Select.
	DDRC = 0b00111000;		//Set pins 3, 4, & 5 on Port C as output for LEDs.
	DDRD = 0b11100010;		//Set pin 1 on port D as output for serial communication.  Set pins 5, 6, & 7 on Port D as output for LEDs.
	
	//Initialize the DAC Pins.
	sbi(PORTB,0);			//Set the Chip Select high.
	sbi(PORTB,1);			//Set the LDAC high.
	
	//Initialize the LED Pins.
	sbi(PORTC,3);
	sbi(PORTC,4);
	sbi(PORTC,5);
	
	sbi(PORTD,5);
	sbi(PORTD,6);
	sbi(PORTD,7);
	
	//Setup for ADC.
	ADCSRA = 0b10000111;	//ADC on, /128 for a 16 MHz clock, interrupt off.
	
	// Setup for SPI Communication.
	SPCR=0b01010010;
	SPSR=0b00000000;
	
	//Setup the timer for the interrupts.
	TCCR1B |= (1 << WGM12); // Configure timer 1 for CTC mode
	TIMSK1 |= (1 << OCIE1A); // Enable CTC interrupt

	//Enable global interrupts.
	sei();

	//Compute the target timer count (i.e., the CTC compare value).
	// OCR1A = Target_Timer_Count = (Clock_Frequency / (Prescale * Target_Frequency)) – 1
	//OCR1A = 15624;	//Set CTC compare value to 1 Hz at 1MHz AVR clock, with a prescaler of 64			//Original Example.
	//OCR1A = 62499;	//Set CTC compare value to 1 Hz at 16MHz AVR clock, with a prescaler of 256			//1 Hz Example.
	//OCR1A = 1999;		//Set CTC compare value to 1 kHz at 16MHz AVR clock, with a prescaler of 8			//1 kHz Example.
	//OCR1A = 399;		//Set CTC compare value to 5 kHz at 16MHz AVR clock, with a prescaler of 8			//5 kHz Example.
	//OCR1A = 15;			//Set CTC compare value to ~416 kHz at 16MHz AVR clock, with a prescaler of 1	//Fastest Example (~416 kHz).
	OCR1A = 15999;		//16MHz clock, prescaler of 1, 1 kHz interrupt.
	
	//Set the timer prescaler.
	//TCCR1B |= ((1 << CS10) | (1 << CS11)); // Start timer at Fcpu/64
	//TCCR1B |= ((0 << CS10) | (0 << CS11) | (1 << CS12)); // Start timer at Fcpu/256						//1 Hz Example.
	//TCCR1B |= ((0 << CS10) | (1 << CS11) | (0 << CS12)); // Start timer at Fcpu/8							//1 kHz and 5 kHz Example.
	TCCR1B |= ((1 << CS10) | (0 << CS11) | (0 << CS12));	//Sets Prescaler to 1.

	//Create an empty loop.
	while(1){}

}

ISR(TIMER1_COMPA_vect)
{

	//Define local variables.
	unsigned char			spi_data_0;
	unsigned char			spi_data_1;
	unsigned char			dummy_read;
	unsigned int			adc_data1;
	unsigned int			adc_data2;
	float					p_actual;
	
	
	/*
	//Read from the ADC Channels.
	
	//Set the AD Channel.
	ADMUX  = 0b00000000;	//Set the AD input to Channel 0.

	//Start the AD conversion.
	ADCSRA = ADCSRA | 0b01000000;				    // Start AD conversion.  Sets bit 7 to 1 and leaves all other bits the same.
	while ((ADCSRA & 0b01000000) == 0b01000000);    // Wait while AD conversion is executed.  Waits until bit 7 is set to 1.
	
	//Retrieve the Desired Pressure ADC value from Channel 0.
	adc_data1 = ADCW;					//[0-1023] Desired Pressure.
	
	//Set the AD Channel.
	ADMUX  = 0b00000001;	//Set the AD input to Channel 1.
	
	//Start the AD conversion.
	ADCSRA = ADCSRA | 0b01000000;				    // Start AD conversion.  Sets bit 7 to 1 and leaves all other bits the same.
	while ((ADCSRA & 0b01000000) == 0b01000000);    // Wait while AD conversion is executed.  Waits until bit 7 is set to 1.
	
	//Retrieve the pressure sensor ADC value from Channel 1.
	adc_data2 = ADCW;					//[0-1023] Actual Pressure.
	
	//Convert the adc value for the actual pressure into a voltage.
	p_actual = pressure_conversion*adc_data2;			//[V] Pressure Sensor Reading.  Converts [0-1023] to [0-5] V.
	*/
	
	//Convert the actual pressure voltage into a dac value.
	dac_data = dac_conversion*5.;				//[0-4095] Actual Pressure.  Converts [0-5] V to [0-4095].
	
	
	//Output a value to the DAC.  DAC value should be [0-4095].
	
	//Convert the ADC data to a form that the DAC will recognize.
	spi_data_0 = 0x00;								//Zero spi_data_0.
	spi_data_0 = (dac_data & 0x0F00) >> 8;			//Set up the first byte to write by mapping bits 8-11 to the lower 4 bit positions.
	spi_data_0 = spi_data_0 + 0b00110000;			//Now add the upper 4 DAC control bits.
	spi_data_1 = (dac_data & 0xFF);					//Setup the second byte to write by mapping bits 0-7 to the lower 8 bit positions.

	//Write the ADC data to the DAC.
	cbi(PORTB,0);								// Activate the chip - set chip select to zero
	dummy_read = spi_write_read(spi_data_0);	// Write/Read first byte
	dummy_read = spi_write_read(spi_data_1);  	// Write/Read second byte
	sbi(PORTB,0);								// Release the chip  - set chip select to one
	
	//Cycle the LDAC.
	cbi(PORTB,1);			//Set the LDAC low.
	_delay_ms(0.0001);		//Wait the specified LDAC duration.
	sbi(PORTB,1);			//Set the LDAC high.
	
	//Advance the counter.
	++count;
	
}