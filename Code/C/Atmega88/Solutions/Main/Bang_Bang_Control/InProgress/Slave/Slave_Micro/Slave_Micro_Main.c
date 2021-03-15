// Slave Micro Main Script

// This script implements the main bang-bang control algorithm on the slave microcontrollers.

// Include the associated header file.
#include "Slave_Micro_Header.h"

// Define global constants.
// const uint16_t activation_threshold = 32767;
const uint16_t activation_threshold = 5000;
// const float p_threshold = (4.3/90)*10;				// [V] Represents 10 psi as a voltage [0-5].
const float p_threshold = (4.3/90)*1;				// [V] Represents 10 psi as a voltage [0-5].

// Define global variables.
volatile unsigned char spi_bytes[NUM_BYTES_PER_UINT16] = {0b00000000, 0b00000000};
volatile unsigned char spi_bytes_to_send[NUM_SPI_BYTES] = {0b00000000, 0b00000000};
volatile uint8_t spi_index = 0;


// Implement the main function.
int main (void)
{
	
	// Setup the microcontroller.
	SetupMicro();

	// Toggle a pin to indicate that the mircrocontroller setup was completed.
	toggle_pin( &PORTD, 4 )

	// Create an empty loop.
	while(1){}

}

// Implement a function to execute the bang-bang control algorithm at a fixed time interval.
ISR(TIMER1_COMPA_vect)								// First timer interrupt function.
{			
	
	// // ON/OFF CONTROL.
	//
	// //Define local variables.
	// uint16_t spi_value;
	//
	// //Convert the current SPI bytes into a SPI value.
	// spi_value = byte_array2int(spi_bytes);
		//
	// // Treat the spi value as an activation level.  If the activation level is above the activation threshold, open the valve.
	// on_off_threshold_control( spi_value );
	
	
	// BANG-BANG CONTROL.
		
	// Define local variables.
	float p_desired;
	float p_actual;
	uint16_t p_actual_ADC;
	uint16_t p_actual_int;
	uint8_t p_actual_bytes[2];
	
	// Retrieve the desired pressure value from the SPI bytes.
	p_desired = ADC2Voltage( uint162ADC( byte_array2int( spi_bytes ) ) );						// [0-4.3] Desired pressure as a floating point voltage.
			
	// Read in the current pressure value integer.
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
		
		// Load the spi data register with the first byte of the new array to send.
		SPDR = spi_bytes_to_send[0];
		
	}

	// Convert the current pressure ADC integer to a voltage.
	p_actual = ADC2Voltage( p_actual_ADC );														// [0-4.3] Actual pressure as a floating point voltage.
			
	// Perform bang-bang control.  i.e., if the actual pressure is sufficiently far below the desired pressure, open the valve to increase the pressure.  If the actual pressure is sufficiently far above the actual pressure, close the valve to decrease the pressure.
	bang_bang_pressure_control( p_desired, p_actual );
	
	// Toggle a pin each time this interrupt executes.
	toggle_pin( &PORTD, 3 )
	
}

// Implement a function to 
ISR(SPI_STC_vect)
{
	
	// Disable global interrupts.
	cli();

	// Define local variables.
	uint8_t spi_byte;

	// Read in the SPI value.
	spi_byte = SPDR;
	
	// Advance the spi index & ensure that it is in bounds.
	spi_index = (spi_index + 1) % NUM_SPI_BYTES;
	
	// Set the spi data register to contain the next byte we want to send.
	SPDR = spi_bytes_to_send[spi_index];
	// SPDR = 0b00000000;
	// SPDR = 0b11111111;
	
	// Cycle the SPI bytes.
	spi_bytes[0] = spi_bytes[1];
	spi_bytes[1] = spi_byte;
	
	// Toggle a pin to indicate complete SPI transfer.
	toggle_pin( &PORTD, 4 )
	
	// Enable global interrupts.
	sei();
	
}
