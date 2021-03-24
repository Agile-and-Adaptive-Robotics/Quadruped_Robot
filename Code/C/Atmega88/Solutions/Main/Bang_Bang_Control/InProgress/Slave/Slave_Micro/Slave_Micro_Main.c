// Slave Micro Main Script

// This script implements a local pressure control algorithm based on the desired pressure command received from the Master microcontroller while simultaneously reading and reporting on sensor values.

// Include the associated header file.
#include "Slave_Micro_Header.h"

// Define global constants.
// const uint16_t activation_threshold = 32767;
const uint16_t activation_threshold = 5000;
// const float p_threshold = (4.3/90)*10;				// [V] Represents 10 psi as a voltage [0-5].
const float p_threshold = (4.3/90)*1;				// [V] Represents 10 psi as a voltage [0-5].

// Define global variables (local to this file).
static volatile struct command_data_struct command_data = { .desired_pressure = 0 };
static volatile struct sensor_data_struct sensor_data = { .pressure_sensor_value1 = 0, .pressure_sensor_value2 = 0, .joint_value = 0 };
static volatile struct SPI_data_struct SPI_manager = { .spi_index = 0, .max_spi_index = 3, .spi_bytes_received = {0, 0}, .command_ID = 1, .sensor_ID = 1 };
	

// Implement the main function.
int main (void)
{
	
	// Setup the microcontroller.
	setup_micro();

	// Set the SPI bytes to send to be all zeros.
	initialize_spi_bytes_to_send( &SPI_manager );

	// Toggle a pin to indicate that the microcontroller setup was completed.
	//toggle_pin( &PORTD, 4 );
	tbi(PORTD, 4);

	// Create an empty loop.
	while(1){}

}



// Implement a function to execute the bang-bang control algorithm at a fixed time interval.
ISR(TIMER1_COMPA_vect)								// First timer interrupt function.
{
	
	// BANG-BANG CONTROL.
	
	// Read the sensor values.
	read_analog_sensors( &sensor_data );
	
	// Retrieve the desired pressure value from the SPI bytes.	
	float desired_pressure_float = desired_pressure_uint162desired_pressure_float( command_data.desired_pressure );
		
	// Retrieve the measured pressure value from the pressure sensors.
	float measured_pressure_float = volt_float2measured_pressure_float( volt_uint162volt_float( sensor_data.pressure_sensor_value1 ) );

	// Perform bang-bang control.  i.e., if the actual pressure is sufficiently far below the desired pressure, open the valve to increase the pressure.  If the actual pressure is sufficiently far above the actual pressure, close the valve to decrease the pressure.
	bang_bang_pressure_control( desired_pressure_float, measured_pressure_float );
	
	// Toggle a pin each time this interrupt executes.
	//toggle_pin( &PORTD, 3 );
	tbi(PORTD, 3);
	
}


// Implement a function to interpret Master microcontroller commands sent via SPI.
ISR(SPI_STC_vect)							// SPI Interrupt Service Routine.
{
	
	// Disable the timer interrupt.  (It is more important to process SPI inputs / outputs than to execute the control law at the prescribed timing.)
	cbi(TIMSK1, OCIE1A);

	// Read in the SPI value.
	uint8_t spi_byte = SPDR;
	
	// Determine how to process this SPI byte.
	if ( SPI_manager.spi_index == 0 )				// If this is the first byte of this sentence...
	{
		
		// Update the command ID.
		SPI_manager.command_ID = spi_byte;
		
	}
	else if ( SPI_manager.spi_index == 1 )			// If this is the second byte of this sentence...
	{
		
		// Update the sensor ID.
		SPI_manager.sensor_ID = spi_byte;
		
		// Stage the appropriate sensor values for SPI transmission.	
		stage_sensor_values( &sensor_data, &SPI_manager );
		
		// Store the first SPI byte to send.
		SPDR = SPI_manager.spi_bytes_to_send[0];
		
	}
	else if ( SPI_manager.spi_index >= 2 )			// If this is the third or more byte of this sentence...
	{
		
		// Stage the command value(s).		
		stage_command_value( spi_byte, &command_data, &SPI_manager );
		
		// Store the next SPI byte to send into the SPDR.
		SPDR = SPI_manager.spi_bytes_to_send[SPI_manager.spi_index - 1];
		
	}
	
	// Advance the SPI index & ensure that it is in bounds.
	SPI_manager.spi_index = (SPI_manager.spi_index + 1) % SPI_manager.max_spi_index;
	
	// Toggle a pin to indicate complete SPI transfer.
	//toggle_pin( &PORTD, 4 );
	tbi(PORTD, 4);
	
	// Enable the timer interrupt.
	sbi(TIMSK1, OCIE1A);
	
}


// Implement a function to interpret encoder pin change interrupts.
ISR(PCINT2_vect)					// Pin Change Interrupt Service Routine (Pin Group 2: PCINT23-PCINT16).  Only tracks those pins that have been enabled (PCINT23-PCINT21).
{
	
	// Disable global interrupts.
	cli();
	
	// Determine whether to increment the encoder or to reset the encoder value.
	if ( ENCODER_PORT & ( 1 << ENCODER_INDEX ) )					// If the encoder index is high..
	{
		
		// Reset the encoder value.
		reset_encoder_value( &sensor_data );
		
	}
	else															// Otherwise...
	{
		
		// Get the current encoder increment.
		int8_t encoder_increment = get_encoder_increment();
			
		// Apply the encoder increment to the current joint angle.
		apply_encoder_increment( &sensor_data, encoder_increment );
		
	}
	
	// Enable global interrupts.
	sei();
	
}

