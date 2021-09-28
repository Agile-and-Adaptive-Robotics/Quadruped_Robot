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
//const float p_threshold = (4.3/90)*10;				// [V] Represents 10 psi as a voltage [0-5].
const float p_threshold = (4.3/90)*1;				// [V] Represents 10 psi as a voltage [0-5].


//Define global variables.
unsigned int dac_data = 0;									//[#] Value to send to dac.
unsigned int count = 0;										//[#] Counter for the number of interrupt cycles.
unsigned char clock_pin_state = 0;							//[T/F] Clock Pin State.
volatile unsigned char spi_bytes[NUM_BYTES_PER_UINT16] = {0b00000000, 0b00000000};
volatile unsigned char spi_bytes_to_send[NUM_SPI_BYTES] = {0b00000000, 0b00000000};
volatile uint8_t spi_index = 0;

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
	
	//// ON/OFF CONTROL.
	//
	////Define local variables.
	//uint16_t spi_value;
	//
	////Convert the current SPI bytes into a SPI value.
	//spi_value = byte_array2int(spi_bytes);
		//
	//// Treat the spi value as an activation level.  If the activation level is above the activation threshold, open the valve.
	//on_off_threshold_control( spi_value );
	
	
	// BANG-BANG CONTROL.
		
	// Define local variables.
	float p_desired;
	float p_actual;
	uint16_t p_actual_ADC;
	uint16_t p_actual_int;
	unsigned char p_actual_bytes[2];
	
	// Retrieve the desired pressure value from the SPI bytes.
	p_desired = ADC2Voltage( uint162ADC( byte_array2int( spi_bytes ) ) );						// [0-4.3] Desired pressure as a floating point voltage.
		
	//p_desired = 2.15;
		
	// Read in the current pressure value integer.
	//p_actual = ADC2Voltage( readADC( 0 ) );													// [0-4.3] Actual pressure as a floating point voltage.
	//p_actual_ADC = readADC( 0 );																// [0-1023] Actual pressure as a uint16_t (12 bit).
	p_actual_ADC = ScaleADC( readADC( 0 ) );																// [0-1023] Actual pressure as a uint16_t (12 bit).
	
	// Convert the current pressure value integer to a uint16.
	p_actual_int = ADC2uint16( p_actual_ADC );													// [0-65535] Actual pressure as a uint16_t (16 bit)
	
	// Convert the current pressure integer into its constitute byte array.
	int2byte_array( p_actual_int, p_actual_bytes );
	
	// Determine whether we finished sending the last spi byte array to the master.
	if (spi_index == 0)							// If we finished sending the last spi byte array to the master...
	{
	
		// Store the current pressure byte array into the spi bytes to send array.
		spi_bytes_to_send[0] = p_actual_bytes[0];
		spi_bytes_to_send[1] = p_actual_bytes[1];
		
		//spi_bytes_to_send[0] = 0b00000000;
		//spi_bytes_to_send[1] = 0b00000000;

		//spi_bytes_to_send[0] = 0b11111111;
		//spi_bytes_to_send[1] = 0b11111111;
		
		//spi_bytes_to_send[0] = 0b11111111;
		//spi_bytes_to_send[1] = 0b00001111;
		
		//p_actual_int = 0b0000111111111111;
		//p_actual_int = 0;

		//spi_bytes_to_send[0] = p_actual_int & 0x00FF;
		//spi_bytes_to_send[1] = p_actual_int >> 8;

		
		// Load the spi data register with the first byte of the new array to send.
		SPDR = spi_bytes_to_send[0];
		
	}

	// Convert the current pressure ADC integer to a voltage.
	p_actual = ADC2Voltage( p_actual_ADC );														// [0-4.3] Actual pressure as a floating point voltage.
			
	// Perform bang-bang control.  i.e., if the actual pressure is sufficiently far below the desired pressure, open the valve to increase the pressure.  If the actual pressure is sufficiently far above the actual pressure, close the valve to decrease the pressure.
	bang_bang_pressure_control( p_desired, p_actual );
	
	// Toggle a pin each time this interrupt executes.
	PORTD ^= (1 << 3);
	
}

ISR(SPI_STC_vect)
{
	//Disable global interrupts.
	cli();

	//Define local variables.
	unsigned char spi_byte;

	//Read in the SPI value.
	spi_byte = SPDR;
	
	// Advance the spi index & ensure that it is in bounds.
	spi_index = (spi_index + 1) % NUM_SPI_BYTES;
	
	// Set the spi data register to contain the next byte we want to send.
	SPDR = spi_bytes_to_send[spi_index];
	//SPDR = 0b00000000;
	//SPDR = 0b11111111;
	
	//Cycle the SPI bytes.
	spi_bytes[0] = spi_bytes[1];
	spi_bytes[1] = spi_byte;
	
	//Toggle Pin D4 to indicate complete SPI transfer.
	PORTD ^= (1 << 4);
	//PORTD |= (1 << 4);
	//PORTD &= ~(1 << 4);
	
	//Enable global interrupts.
	sei();
}
