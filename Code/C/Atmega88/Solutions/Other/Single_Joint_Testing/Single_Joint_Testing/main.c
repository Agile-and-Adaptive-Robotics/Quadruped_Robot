//Single Joint Testing.

//Include necessary .h files.
#include <stdio.h>
#include <avr/io.h>
#include <avr/interrupt.h>

//Define the clock speed.
#define F_CPU 16000000UL // 16 MHz CPU Clock Frequency
#include <util/delay.h>   // Include the built in Delay Function

//Define pin setting and clearing functions.
#define sbi(var, mask)   ((var) |= (uint8_t)(1 << mask))
#define cbi(var, mask)   ((var) &= (uint8_t)~(1 << mask))

//Define SPIF value (used for SPI communication).
#define SPIF 7

//Define USART parameters.
#define FOSC F_CPU					//CPU Clock Frequency must be set correctly for the USART to work
#define BAUD 9600
//#define BAUD 921600
#define MYUBRR FOSC/16/BAUD-1

//Declare USART functions.
//static int    uart_putchar(char c, FILE *stream);
void uart_putchar(char c, FILE *stream);
unsigned char uart_getchar(void);
static FILE mystdout = FDEV_SETUP_STREAM(uart_putchar, NULL, _FDEV_SETUP_WRITE);

//Define global constants.
const unsigned int freq_dac = 4000;							//DAC Frequency.
const unsigned int freq_pwm = 100;							//PWM Frequency.
const float Kp = 1.0;										//[-] Proportional Gain.
const float duty_cycle_conversion = 1./5.;					//[%/V] Voltage to duty cycle conversion factor.
const float extensor_pressure_conversion = 5./951;			//[V/#] Bit to voltage conversion factor for extensor pressure readings.
const float flexor_pressure_conversion = 5./961;			//[V/#] Bit to voltage conversion factor for flexor pressure readings.
const float joint_angle_conversion = 5./991;				//[V/#] Bit to voltage conversion factor for joint angle readings.
const unsigned int extensor_pressure_offset = 0;			//[#] Bit offset for extensor pressure sensor.
const unsigned int flexor_pressure_offset = 23;				//[#] Bit offset for flexor pressure sensor.
const unsigned int joint_angle_offset = 0;					//[#] Bit offset for potentiometer.
const float dac_on_value = round((5./5.12)*4095);			//[#] Value to which the dac should be set when the valve manifold is turned on.
char mychar[6] = "Hello";

//Define global variables.
unsigned int num_total;										//Total number of points per cycle.
unsigned int num_crit;
unsigned int bDacOn = 1;									//[-] Boolean to determine whether the Dac is on.
unsigned int dac_data = 0;									//[#] Value to send to dac.
unsigned int count = 0;										//[#] Counter for the number of interrupt cycles.

//Implement the SPI write_read function.
unsigned char spi_write_read(unsigned char spi_data)
{
	SPDR=spi_data;
	while ((SPSR & (1<<SPIF))==0);	//Wait until the data transfer is complete.
	return SPDR;
}

int main (void)
{
	
	//Compute the total number of points per cycle.
	num_total = freq_dac/freq_pwm;
	
	//Compute the value to which to set the dac when we turn it on.
	//dac_on_value = round((5./5.12)*4095);
	
	//Compute the pressure conversion factor.
	//pressure_conversion = 5./1023;
	
	//Compute the duty cycle conversion factor.
	//duty_cycle_conversion = 1./5.;
	
	//Setup pins for SPI Interface, Chip Select, and Serial Communication.
	DDRB = 0b00101111;		//Set Output Ports for the SPI Interface & Chip Select.
	DDRC = 0b00000000;		//Set port C for ADC.
	DDRD = 0b00000010;		//Set pin 1 on port D as output for serial communication.
	
	//Initialize the DAC Pins.
	sbi(PORTB,0);			//Set the Chip Select high.
	sbi(PORTB,1);			//Set the LDAC high.
	
	//Setup for ADC.
	ADCSRA = 0b10000111;	//ADC on, /128 for a 16 MHz clock, interrupt off.
	
	// Setup for SPI.
	SPCR=0b01010010;
	SPSR=0b00000000;
	
	//Setup the timer for the interrupts.
	TCCR1B |= (1 << WGM12);										// Configure timer 1 for CTC mode
	TIMSK1 |= (1 << OCIE1A);									// Enable CTC interrupt
	sei();														// Enable global interrupts
	OCR1A = 15999;												//Set target timer count for 1 kHz interrupt given 16MHz clock & prescaler of 1. Use 3999 for 4 kHz under same conditions. OCR1A = Target_Timer_Count = (Clock_Frequency / (Prescale * Target_Frequency)) – 1
	TCCR1B |= ((1 << CS10) | (0 << CS11) | (0 << CS12));		//Sets the prescaler to 1.

	//USART Setup
	UBRR0H = MYUBRR >> 8;
	UBRR0L = MYUBRR;
	UCSR0B = (1<<RXEN0)|(1<<TXEN0);
	stdout = &mystdout; //Required for printf init

	//Create an empty loop.
	while(1){}

}

ISR(TIMER1_COMPA_vect)
{

	//Define local variables.
	unsigned char			spi_data_0;
	unsigned char			spi_data_1;
	unsigned char			dummy_read;
	unsigned int			extensor_pressure_adc;
	unsigned int			flexor_pressure_adc;
	unsigned int			joint_angle_adc;
	float					extensor_pressure_voltage;
	float					flexor_pressure_voltage;
	float					joint_angle_voltage;
	float					duty_cycle;
	float					p_desired;
	float					p_actual;
	float					p_error;
	float					control_signal;

	
	//Read from the ADC Channels.
	
	//Read in the extensor pressure sensor ADC value from Channel 0.
	ADMUX  = 0b00000000;																//Set the AD input to Channel 0.
	ADCSRA = ADCSRA | 0b01000000;														// Start AD conversion.  Sets bit 7 to 1 and leaves all other bits the same.
	while ((ADCSRA & 0b01000000) == 0b01000000);										// Wait while AD conversion is executed.  Waits until bit 7 is set to 1.
	extensor_pressure_adc = ADCW;														//[0-1023] Extensor Pressure.  Retrieve the extensor pressure ADC value from Channel 0.
	extensor_pressure_voltage = extensor_pressure_conversion*extensor_pressure_adc;		//[V] Extensor Pressure.  Converts the extensor pressure from an ADC value to a voltage value.
	
	//Read in the flexor pressure sensor ADC value from Channel 1.
	ADMUX  = 0b00000001;																							//Set the AD input to Channel 1.
	ADCSRA = ADCSRA | 0b01000000;																					// Start AD conversion.  Sets bit 7 to 1 and leaves all other bits the same.
	while ((ADCSRA & 0b01000000) == 0b01000000);																	// Wait while AD conversion is executed.  Waits until bit 7 is set to 1.
	flexor_pressure_adc = ADCW;																						//[0-1023] Flexor Pressure.  Retrieve the flexor pressure ADC value from Channel 1.
	flexor_pressure_voltage = flexor_pressure_conversion*(flexor_pressure_adc - flexor_pressure_offset);			//[V] Flexor Pressure.  Converts the flexor pressure from an ADC value to a voltage value.
	
	//Read in the joint angle potentiometer ADC value from Channel 2.
	ADMUX  = 0b00000010;												//Set the AD input to Channel 2.
	ADCSRA = ADCSRA | 0b01000000;										// Start AD conversion.  Sets bit 7 to 1 and leaves all other bits the same.
	while ((ADCSRA & 0b01000000) == 0b01000000);						// Wait while AD conversion is executed.  Waits until bit 7 is set to 1.
	joint_angle_adc = ADCW;												//[0-1023] Joint Angle.  Retrieve the joint angle potentiometer ADC value from Channel 2.
	joint_angle_voltage = joint_angle_conversion*joint_angle_adc;		//[V] Joint Angle.  Converts the joint angle from an ADC value to a voltage value.

	//Set the dac value high.
	dac_data = dac_on_value;


	//This block of code is for the PWM PCL Pressure Control Method.
	/*
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
	*/
	
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
	
	
	//Print out any required information for debugging.
	//printf("Error, vel_Set_v, adc_input, adc_output %d    %d    %d    %d\n", (int) Error,(int) Vel_Set_v,adc_input,adc_output );
	//printf("P_ext = %d, P_flx = %d, theta = %d\n", extensor_pressure_adc, flexor_pressure_adc, joint_angle_adc);
	//printf("P_ext = %d, P_flx = %d, theta = %d\n", (int)(extensor_pressure_voltage*100), (int)(flexor_pressure_voltage*100), (int)(joint_angle_voltage*100));
	//printf("P_ext_adc = %d, P_ext_volt = %d, P_flx_adc = %d, P_flx_volt = %d, theta_adc = %d, theta_volt = %d\n", extensor_pressure_adc, (int)(extensor_pressure_voltage*100), flexor_pressure_adc, (int)(flexor_pressure_voltage*100), joint_angle_adc, (int)(joint_angle_voltage*100));
	
	printf(mychar);
	
	/*
	for (int k = 0; k <= (sizeof(mychar)/sizeof(mychar[0])) ; ++k )
	{
		uart_putchar(mychar[k], stdout);
	}
	*/

	//uart_putchar(mychar[0], stdout);

	
	//Advance the counter.
	++count;
	
}

/*
//Implement the USART putchar function.
static int uart_putchar(char c, FILE *stream)
{
	if (c == '\n') uart_putchar('\r', stream);
	
	loop_until_bit_is_set(UCSR0A, UDRE0);
	UDR0 = c;
	
	return 0;
}
*/

//Implement the USART putchar function.
void uart_putchar(char c, FILE *stream)
{
	if (c == '\n') uart_putchar('\r', stream);
	
	loop_until_bit_is_set(UCSR0A, UDRE0);
	UDR0 = c;
}

//Implement the USART getchar function.
unsigned char uart_getchar(void)
{
	while( !(UCSR0A & (1<<RXC0)) );
	return(UDR0);
}