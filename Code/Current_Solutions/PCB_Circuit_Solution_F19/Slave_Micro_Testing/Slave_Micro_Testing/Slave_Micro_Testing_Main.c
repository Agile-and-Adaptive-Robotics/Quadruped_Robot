//Slave Micro Testing Main Script

//This script serves to test the functionality of individual slave microcontroller modules.

//Include the associated header file.
#include "Slave_Micro_Testing_Header.h"

//Define global constants.
const float extensor_pressure_conversion = 5./951;			//[V/#] Bit to voltage conversion factor for extensor pressure readings.
const float flexor_pressure_conversion = 5./961;			//[V/#] Bit to voltage conversion factor for flexor pressure readings.
const float joint_angle_conversion = 5./991;				//[V/#] Bit to voltage conversion factor for joint angle readings.
const unsigned int extensor_pressure_offset = 0;			//[#] Bit offset for extensor pressure sensor.
const unsigned int flexor_pressure_offset = 23;				//[#] Bit offset for flexor pressure sensor.
const unsigned int joint_angle_offset = 0;					//[#] Bit offset for potentiometer.
const float dac_on_value = round((5./5.12)*4095);			//[#] Value to which the dac should be set when the valve manifold is turned on.
const unsigned int dac_off_value = 0;
const unsigned char window_size = 2;						//[#] Define the size of the start sequence.
const unsigned int num_adc_channels = 2;					//[#] Define the number of adc channels.
const unsigned char multiplexer_pins1[3] = {2, 3, 4};
const unsigned char multiplexer_pins2[3] = {5, 6, 7};
const unsigned char * multiplexer_port = &PORTD;
const unsigned char num_pressure_sensors = 24;
const unsigned char num_potentiometers = 14;
const unsigned char num_sensors_total = 38;
const struct muscle_info_struct muscle_info[NUM_FRONT_LEG_MUSCLES] = { {39, &PORTB, 2}, {40, &PORTC, 3}, {41, &PORTC, 1}, {42, &PORTC, 4}, {43, &PORTC, 2}, {44, &PORTC, 5} };
//const uint16_t activation_threshold = 32767;
const uint16_t activation_threshold = 5000;
const float p_threshold = (5./90)*10;				// [V] Represents 10 psi as a voltage [0-5].


//Define global variables.
unsigned int dac_data = 0;									//[#] Value to send to dac.
unsigned int count = 0;										//[#] Counter for the number of interrupt cycles.
unsigned char clock_pin_state = 0;							//[T/F] Clock Pin State.
volatile unsigned char spi_bytes[NUM_BYTES_PER_UINT16];

//Implement the main function.
int main (void)
{
	
	//Setup the microcontroller.
	SetupMicro();

	//PORTD |= (1 << 4);
	//PORTD &= ~(1 << 4);

	//Create an empty loop.
	while(1)
	{
		
	}

}

//Implement the first timer interrupt function.
ISR(TIMER1_COMPA_vect)
{			
	
	//// THIS IS ON OFF CONTROL USING MY FUNCTION.
	//
	////Define local variables.
	//uint16_t spi_value;
	//
	////Convert the current SPI bytes into a SPI value.
	//spi_value = byte_array2int(spi_bytes);
		//
	//// Treat the spi value as an activation level.  If the activation level is above the activation threshold, open the valve.
	//on_off_threshold_control( spi_value );
	
	
	// THIS IS BANG-BANG CONTROL WITH MY FUNCTION.
		
	// Define local variables.
	float p_desired;
	float p_actual;
		
	// Retrieve the desired pressure value from the SPI bytes.
	p_desired = ADC2Voltage( uint162ADC( byte_array2int( spi_bytes ) ) );						// [0-5] Desired pressure as a floating point voltage.
		
	//p_desired = 2.5;
		
	// Read in the current pressure value.
	p_actual = ADC2Voltage( readADC( 0 ) );														// [0-5] Actual pressure as a floating point voltage.
		
	// Perform bang-bang control.  i.e., if the actual pressure is sufficiently far below the desired pressure, open the valve to increase the pressure.  If the actual pressure is sufficiently far above the actual pressure, close the valve to decrease the pressure.
	bang_bang_pressure_control( p_desired, p_actual );
		

	

	//// THIS IS BANG-BANG CONTROL WITHOUT MY FUNCTION.
	//
	//// Define local variables.
	//float p_desired;
	//float p_actual;
	//float p_upper;
	//float p_lower;
	//
	//// Retrieve the desired pressure value from the SPI bytes.
	//p_desired = ADC2Voltage( uint162ADC( byte_array2int( spi_bytes ) ) );						// [0-5] Desired pressure as a floating point voltage.
//
	//// Compute the lower and upper pressure bounds.
	//p_lower = p_desired - p_threshold;
	//p_upper = p_desired + p_threshold;
//
	//// Read in the current pressure value.
	//p_actual = ADC2Voltage( readADC( 0 ) );
		//
	//// Determine whether to open or close the valve.
	//if (p_actual > p_upper)				// If the current pressure is above the upper pressure limit...
	//{
		//// Close the valve to exhaust air.
		//PORTB &= ~(1 << 1);
	//}
	//else if (p_actual < p_lower)		// If the current pressure is below the lower pressure limit...
	//{
		//// Open the valve to add air.
		//PORTB |= (1 << 1);
	//}
	
	
	
	
	
	
	
	// Toggle a pin each time this interrupt executes.
	PORTD ^= (1 << 3);
	
}

ISR(SPI_STC_vect)
{
	////Disable global interrupts.
	//cli();

	//Define local variables.
	unsigned char spi_byte;

	//Read in the SPI value.
	spi_byte = SPDR;
	
	//Cycle the SPI bytes.
	spi_bytes[0] = spi_bytes[1];
	spi_bytes[1] = spi_byte;
	
	//Toggle Pin D4 to indicate complete SPI transfer.
	PORTD ^= (1 << 4);
	//PORTD |= (1 << 4);
	//PORTD &= ~(1 << 4);
	
	////Enable global interrupts.
	//sei();
}
