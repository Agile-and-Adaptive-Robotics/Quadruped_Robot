// SPI Functions.

// This script implements functions for SPI communication.

// Include the associated header file.
#include "Master_Micro_Header.h"


// Implement a function to read a uint8_t via SPI.
uint8_t spi_read_uint8( void )
{
	// Create a variable to store the SPI data.
	uint8_t spi_data;
	
	// Wait for a SPI data transfer to be complete.
	while (!(SPSR & (1<<SPIF)));
	
	// Read in the SPI data.
	spi_data = SPDR;
	
	// Return the SPI data.
	return spi_data;
	
}


// Implement a function to write a uint8_t via SPI.
void spi_write_uint8( uint8_t spi_data )
{
	
	// Write the SPI data.
	SPDR = spi_data;
	
	// Wait for the SPI data transfer to be complete.
	while ((SPSR & (1<<SPIF))==0);
	
}


// Implement a function to simultaneously read and write a uint8_t via SPI.
uint8_t spi_read_write_uint8( uint8_t spi_data )
{
	
	// Write the SPI data.
	SPDR = spi_data;
	
	// Wait for the SPI data transfer to be complete.
	while (!(SPSR & (1<<SPIF)));
	
	// Read in the SPI data.
	spi_data = SPDR;
	
	// Return the SPI data.
	return spi_data;

}


// Implement a function to read a uint16_t via SPI.
uint16_t spi_read_uint16( void )
{
	
	// Define local variables.
	uint8_t spi_byte_low;
	uint8_t spi_byte_high;
	uint16_t value_received;
	
	// Write the SPI byte to the slave.
	spi_byte_low = spi_read_write_uint8( spi_byte_low );
	_delay_ms(SPI_DELAY);
	spi_byte_high = spi_read_write_uint8( spi_byte_high );
	
	// Construct the uint16 that we received from the slave.
	value_received = (spi_byte_high << 8) | spi_byte_low;
	
	// Return the uint16 we received from the slave.
	return value_received;
	
}


// Implement a function to write a uint16_t via SPI.
void spi_write_uint16( uint16_t value_to_write )
{
	
	// Define local variables.
	uint8_t spi_byte_low;
	uint8_t spi_byte_high;
		
	// Convert the uint16 to SPI bytes.
	spi_byte_low = (value_to_write & 0xFF);					// Retrieve the lower byte from the value to write.
	// spi_byte_high = (value_to_write & 0x0F00) >> 8;			// Retrieve the upper byte from the value to write.  Note that the 0x0F00 is valid for 12 bit values.
	spi_byte_high = (value_to_write & 0xFF00) >> 8;			// Retrieve the upper byte from the value to write.  Note that 0xFF00 is valid for 16 bit values (i.e., two byte values such as uint16).
		
	// Write the SPI byte to the slave.
	spi_write_uint8( spi_byte_low );
	_delay_ms(SPI_DELAY);
	spi_write_uint8( spi_byte_high );
	
}


// Implement a function to simultaneously read and write a uint16 via SPI.
uint16_t spi_read_write_uint16( uint16_t value_to_write )
{
	
	// Define local variables.
	uint8_t spi_byte_low;
	uint8_t spi_byte_high;
	uint16_t value_received;
		
	// Convert the ADC value to SPI bytes.
	spi_byte_low = (value_to_write & 0xFF);					// Retrieve the lower byte from the value to write.
	spi_byte_high = (value_to_write & 0xFF00) >> 8;			// Retrieve the upper byte from the value to write.  Note that 0xFF00 is valid for 16 bit values (i.e., two byte values such as uint16).

	// Write the SPI byte to the slave.
	spi_byte_low = spi_read_write_uint8( spi_byte_low );
	_delay_ms(SPI_DELAY);
	spi_byte_high = spi_read_write_uint8( spi_byte_high );
		
	// Construct the uint16 that we received from the slave.
	value_received = (spi_byte_high << 8) | spi_byte_low;
		
	// Return the uint16 we received from the slave.
	return value_received;
	
	
}


// Implement a function to read a uint16_t via SPI from a specific slave.
uint16_t spi_read_slave_uint16( uint8_t slave_num )
{
	
	// Create a local variable to store the received variable.
	uint16_t value_received;
	
	// Set the multiplexer channel so that we can perform a slave select for Micro-Micro SPI.
	set_multiplexer_channel( slave_num + 37 );

	// Re-establish control over the slave select pin.
	DDRB |= (1 << 0);						// Ensure the the SS pin is set to output.

	// Pull the slave select pin low to initiate SPI communication.
	cbi(PORTB, 0);
	
	// Read the uint16 via SPI.
	value_received = spi_read_uint16();
	
	// Pull the slave select pin high to end SPI communication.
	sbi(PORTB, 0);
	
	// Relinquish control of the slave select pin.
	DDRB &= ~(1 << 0);					// Set the SS pin to input.
	
	// Return the received value.
	return value_received;
	
}


// Implement a function to write a uint16_t via SPI to a specific slave.
void spi_write_uint162slave( uint16_t value_to_write, uint8_t slave_num )
{
	
	// Set the multiplexer channel so that we can perform a slave select for Micro-Micro SPI.
	set_multiplexer_channel( slave_num + 37 );

	// Re-establish control over the slave select pin.
	DDRB |= (1 << 0);						// Ensure the the SS pin is set to output.

	// Pull the slave select pin low to initiate SPI communication.
	cbi(PORTB, 0);
		
	// Write the uint16 via SPI.
	spi_write_uint16( value_to_write );
		
	// Pull the slave select pin high to end SPI communication.
	sbi(PORTB, 0);
		
	// Relinquish control of the slave select pin.
	DDRB &= ~(1 << 0);					// Set the SS pin to input.
	
}


// Implement a function to read and write a uint16_t via SPI from / to a specific slave.
uint16_t spi_read_write_uint162slave( uint16_t value_to_write, uint8_t slave_num )
{
	
	// Create a local variable to store the received variable.
	uint16_t value_received;
	
	// Set the multiplexer channel so that we can perform a slave select for Micro-Micro SPI.
	set_multiplexer_channel( slave_num + 37 );

	// Re-establish control over the slave select pin.
	DDRB |= (1 << 0);						// Ensure the the SS pin is set to output.

	// Pull the slave select pin low to initiate SPI communication.
	cbi(PORTB, 0);
	
	// Read the uint16 via SPI.
	value_received = spi_read_write_uint16( value_to_write );
	
	// Pull the slave select pin high to end SPI communication.
	sbi(PORTB, 0);
	
	// Relinquish control of the slave select pin.
	DDRB &= ~(1 << 0);					// Set the SS pin to input.
	
	// Return the received value.
	return value_received;
	
}


void WriteCommandData2Slaves( struct int_array_struct * command_data_ptr )
{

	// Define local variables.
	uint8_t k2;						// Index in the slave info structure array associated with the current muscle ID.

	// Write the command data to the appropriate slave microcontroller.
	for (uint8_t k1; k1 < command_data_ptr->length; ++k1)
	{
		
		// Retrieve the muscle index.
		k2 = get_slave_index( command_data_ptr->IDs[k1] );
		
		// Write to the appropriate slave.
		if (!(k2 == 255))																	// If we detected a valid muscle ID...
		{
			
			// Write the corresponding value to the associated slave microcontroller.
			spi_write_uint162slave( command_data_ptr->values[k1], slave_info[k2].slave_num );

			// Code to Test Whether the Master & Slave are getting the same command data value for a given slave.
			
			if (slave_info[k2].slave_num == 2)		// If the current command value is being sent to slave number 1...
			{
				
				if (command_data_ptr->values[k1] > activation_threshold)		// If the current command value is above the activation threshold...
				{
					write2DAC( DAC_ON_VALUE );										// Set the DAC high.
				}
				else
				{
					write2DAC( DAC_OFF_VALUE );											// Set the DAC low.
				}
			}

		}
		
	}
	
}


void SwapMasterSlaveData( struct int_array_struct * command_data_ptr, struct int_array_struct * sensor_data_ptr )
{

	// Define local variables.
	uint8_t k2;						// Index in the slave info structure array associated with the current muscle ID.
	uint16_t p_actual_uint16;		// The actual pressure value associated with the current slave represented as an uint16.
	uint8_t sensor_data_index = 0;	// Index associated with the sensor data structure.

	// Initialize the sensor data structure length to zero.
	sensor_data_ptr->length = 0;

	// Write the command data to the appropriate slave microcontroller.
	for (uint8_t k1; k1 < command_data_ptr->length; ++k1)
	{
		
		// Retrieve the muscle index.
		k2 = get_slave_index( command_data_ptr->IDs[k1] );
		
		// Write to the appropriate slave.
		if (!(k2 == 255))																	// If we detected a valid muscle ID...
		{

			// Write the corresponding uint16 value to the associated slave microcontroller and retrieve a uint16 from the slave.
			//p_actual_uint16 = spi_read_write_uint16( command_data_ptr->values[k1], slave_info[k2].slave_num );
			p_actual_uint16 = spi_read_write_uint162slave( command_data_ptr->values[k1], slave_info[k2].slave_num );
			// p_actual_uint16 = 65535;

			// Store the sensor data ID, sensor data ADC uint16 value, and sensor data length values.
			sensor_data_ptr->IDs[sensor_data_index] = sensor_data_index + 1;									// Set the sensor data ID.
			sensor_data_ptr->values[sensor_data_index] = p_actual_uint16;			// Read in from the current multiplexer channel.
			// sensor_data_ptr->values[sensor_data_index] = 0;			// Read in from the current multiplexer channel.
			++sensor_data_ptr->length;											// Increase the sensor data array length counter by one.

			// Advance the sensor data index.
			++sensor_data_index;
		}
		
	}
	
	for (uint8_t k; k < 14; ++k)
	{
		
		// Fill in the missing encoder values.
		sensor_data_ptr->IDs[sensor_data_index] = sensor_data_index + 1;									// Set the sensor data ID.
		sensor_data_ptr->values[sensor_data_index] = 0;			// Read in from the current multiplexer channel.
		++sensor_data_ptr->length;
		
		// Advance the sensor data index.
		++sensor_data_index;
		
	}

	
}
