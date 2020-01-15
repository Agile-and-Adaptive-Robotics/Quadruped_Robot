//Digital PWM Closed Loop Control.

//Include necessary .h files.
#include <stdio.h>
#include <avr/io.h>
#include <avr/interrupt.h>
#define sbi(var, mask)   ((var) |= (uint8_t)(1 << mask))
#define cbi(var, mask)   ((var) &= (uint8_t)~(1 << mask))

//Define the clock speed.
#define F_CPU 16000000UL // 16 MHz CPU Clock Frequency
#include <util/delay.h>   // Include the built in Delay Function

//Define global variables.
const unsigned int freq_dac = 4000;							//DAC Frequency.
const unsigned int freq_pwm = 100;
unsigned int num_total;
unsigned int num_crit;
float dac_on_value;
unsigned int bDacOn = 1;
unsigned int dac_data = 0;
unsigned int count = 0;
float duty_cycle_conversion;
float pressure_conversion;
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
	
	//Compute the total number of points per cycle.
	num_total = freq_dac/freq_pwm;
	
	//Compute the value to which to set the dac when we turn it on.
	dac_on_value = round((5./5.12)*4095);
	
	//Compute the pressure conversion factor.
	pressure_conversion = 5./1023;
	
	//Compute the duty cycle conversion factor.
	duty_cycle_conversion = 1./5.;
	
	//Setup pins for SPI Interface, Chip Select, LEDs, and Serial Communication.
	DDRB = 0b00101111;		//Set Output Ports for the SPI Interface & Chip Select.
	DDRC = 0b00111000;		//Set pins 3, 4, & 5 on Port C as output for LEDs.
	DDRD = 0b11100010;		//Set pin 1 on port D as output for serial communication.  Set pins 5, 6, & 7 on Port D as output for LEDs.
	
	//Initialize the pin values.
	sbi(PORTB,0);			//Set the Chip Select high.
	sbi(PORTB,1);			//Set the LDAC high.
	
	sbi(PORTC,3);			//Turn Off LEDs.
	sbi(PORTC,4);
	sbi(PORTC,5);
	
	sbi(PORTD,5);
	sbi(PORTD,6);
	sbi(PORTD,7);
	
	//Setup for ADC.
	ADCSRA = 0b10000111;	//ADC on, /128 for a 16 MHz clock, interrupt off.
	
	// Setup for SPI.
	SPCR=0b01010010;
	SPSR=0b00000000;
	
	//Setup the timer for the interrupts.
	TCCR1B |= (1 << WGM12); // Configure timer 1 for CTC mode
	TIMSK1 |= (1 << OCIE1A); // Enable CTC interrupt

	sei(); // Enable global interrupts

	// OCR1A = Target_Timer_Count = (Clock_Frequency / (Prescale * Target_Frequency)) � 1

	//OCR1A = 15624;	//Set CTC compare value to 1 Hz at 1MHz AVR clock, with a prescaler of 64			//Original Example.
	//OCR1A = 62499;	//Set CTC compare value to 1 Hz at 16MHz AVR clock, with a prescaler of 256			//1 Hz Example.
	//OCR1A = 1999;		//Set CTC compare value to 1 kHz at 16MHz AVR clock, with a prescaler of 8			//1 kHz Example.
	//OCR1A = 399;		//Set CTC compare value to 5 kHz at 16MHz AVR clock, with a prescaler of 8			//5 kHz Example.
	//OCR1A = 15;			//Set CTC compare value to ~416 kHz at 16MHz AVR clock, with a prescaler of 1	//Fastest Example (~416 kHz).
	OCR1A = 3999;		//16MHz clock, prescaler of 1, 4 kHz interrupt.
	
	//TCCR1B |= ((1 << CS10) | (1 << CS11)); // Start timer at Fcpu/64
	//TCCR1B |= ((0 << CS10) | (0 << CS11) | (1 << CS12)); // Start timer at Fcpu/256						//1 Hz Example.
	//TCCR1B |= ((0 << CS10) | (1 << CS11) | (0 << CS12)); // Start timer at Fcpu/8							//1 kHz and 5 kHz Example.
	TCCR1B |= ((1 << CS10) | (0 << CS11) | (0 << CS12)); // Start timer at Fcpu/1							//1 kHz and 5 kHz Example.

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
	float					duty_cycle;
	float					p_desired;
	float					p_actual;
	float					p_error;
	float					control_signal;

	
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
		


	//Compute the Control Signal.
	
	//Convert the adc value for the desired pressure into a voltage.
	p_desired = pressure_conversion*adc_data1;			//[V] Desired Pressure. Converts [0-1023] to [0-5] V.
	
	//Convert the adc value for the actual pressure into a voltage.
	p_actual = pressure_conversion*adc_data2;			//[V] Pressure Sensor Reading.  Converts [0-1023] to [0-5] V.
	
	//Compute the pressure error value.
	p_error = p_desired - p_actual;			//[V] Pressure Error.
	
	//Compute the control signal.
	control_signal = Kp*p_error;			//[V] Control Signal.

	
	//Compute the Duty Cycle from the Control Signal.
	
	//Compute the duty cycle.
	//duty_cycle = duty_cycle_conversion*control_signal;	//Converts from [0-5] V to [0-1] %.
	//duty_cycle = (1.2/5.0)*control_signal + 0.15;	//Converts from [0-5] V to [0-1] %					40 Hz PWM.
	//duty_cycle = (0.30/5.0)*control_signal + 0.23;	//Converts from [0-5] V to [0-1] %				80 Hz PWM.
	duty_cycle = (0.25/5.0)*control_signal + 0.255;	//Converts from [0-5] V to some duty cycle range between [0-1] %				100 Hz PWM.

	//duty_cycle = (0.20/1023)*adc_data1 + 0.20;			//Works for 40Hz PWM.

	//duty_cycle = (1./1023)*adc_data1;
	//duty_cycle = (1./1023)*adc_data2;

	//Compute the number of points for the given duty cycle.
	num_crit = round(duty_cycle*num_total);
	
	//Determine whether to turn the output pin on or off.
	if (count >= num_total)								//If the count has reached the maximum value...
	{
		count = 0;								//Reset the counter to zero.
		dac_data = dac_on_value;				//Turn the dac output on.
		bDacOn = 1;
	}
	else if ( bDacOn && (count >= num_crit) )			//If we are in the active part of the cycle...
	{
		dac_data = 0;									//Turn the dac output off.
		bDacOn = 0;
	}
		
		
	
	//Output the PWM to the Valve Manifold.
		
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