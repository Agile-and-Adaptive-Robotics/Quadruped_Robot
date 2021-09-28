//SPI Functions.
//This script implements functions for SPI communication.

//Include the associated header file.
#include "Master_Micro_Testing_Header.h"

//Implement the SPI write function.
void spi_write(unsigned char spi_data)
{
	SPDR = spi_data;
	while ((SPSR & (1<<SPIF))==0);	//Wait until the data transfer is complete.
}

//Implement the SPI read function.
unsigned char spi_read( void )
{
	//Create a variable to store the SPI data.
	unsigned char spi_data;
	
	//Wait for a SPI data transfer to be complete.
	while (!(SPSR & (1<<SPIF)));
	
	//Read in the SPI data.
	spi_data = SPDR;
	
	//Return the SPI data.
	return spi_data;
	
}

//Implement a function to perform SPI read and write.
unsigned char spi_read_write(unsigned char spi_data)
{
	
	//Write the SPI data.
	SPDR = spi_data;
	
	//Wait for a SPI data transfer to be complete.
	while (!(SPSR & (1<<SPIF)));
	
	//Read in the SPI data.
	spi_data = SPDR;
	
	//Return the SPI data.
	return spi_data;

}

//Implement a function to pass an integer from the Master microcontroller to a Slave microcontroller via SPI.
void write2slave( uint16_t value_to_write, uint8_t slave_num )
{
	
	//Define local variables.
	uint8_t spi_byte_low;
	uint8_t spi_byte_high;
	uint8_t dummy_spi_byte;
	
	//Convert the ADC value to SPI bytes.
	spi_byte_low = (value_to_write & 0xFF);					//Retrieve the lower byte from the value to write.
	//spi_byte_high = (value_to_write & 0x0F00) >> 8;			//Retrieve the upper byte from the value to write.  Note that the 0x0F00 is valid for 12 bit values.
	spi_byte_high = (value_to_write & 0xFF00) >> 8;			//Retrieve the upper byte from the value to write.  Note that 0xFF00 is valid for 16 bit values (i.e., two byte values such as uint16).

	//Set the multiplexer channel so that we can perform a slave select for Micro-Micro SPI.
	set_multiplexer_channel( slave_num + 37 );

	//Re-establish control over the slave select pin.
	DDRB |= (1 << 0);						//Ensure the the SS pin is set to output.

	//Pull the slave select pin low to initiate SPI communication.
	cbi(PORTB, 0);
		
	//_delay_ms(1);
	//_delay_ms(1000);
		
	//Write the SPI byte to the slave.
	//dummy_spi_byte = spi_read_write(0);
	//dummy_spi_byte = spi_read_write(255);
	dummy_spi_byte = spi_read_write(spi_byte_low);
	dummy_spi_byte = spi_read_write(spi_byte_high);
		
	//Pull the slave select pin high to end SPI communication.
	sbi(PORTB, 0);
		
	//Relinquish control of the slave select pin.
	DDRB &= ~(1 << 0);					//Set the SS pin to input.
}

void WriteCommandData2Slaves( struct int_array_struct * command_data_ptr )
{

	//Define local variables.
	uint8_t k2;						//Index in the slave info structure array associated with the current muscle ID.

	//Write the command data to the appropriate slave microcontroller.
	for (uint8_t k1; k1 < command_data_ptr->length; ++k1)
	{
		
		//Retrieve the muscle index.
		k2 = GetMuscleIndex( command_data_ptr->IDs[k1] );
		
		//Write to the appropriate slave.
		if (!(k2 == 255))																	//If we detected a valid muscle ID...
		{
			
			//Write the corresponding value to the associated slave microcontroller.
			write2slave( command_data_ptr->values[k1], slave_info[k2].slave_num );

			// Code to Test Whether the Master & Slave are getting the same command data value for a given slave.
			
			if (slave_info[k2].slave_num == 2)		// If the current command value is being sent to slave number 1...
			{
				
				if (command_data_ptr->values[k1] > activation_threshold)		// If the current command value is above the activation threshold...
				{
					write2DAC( 4095 );										// Set the DAC high.
				}
				else
				{
					write2DAC( 0 );											// Set the DAC low.
				}
			}

		}
		
	}
	
}


// Implement a function to pass a uint16 from the Master to the Slave while retrieving a uint16 from the Slave.
uint16_t spi_read_write_uint16( uint16_t value_to_write, uint8_t slave_num )
{
	
	//Define local variables.
	uint8_t spi_byte_low;
	uint8_t spi_byte_high;
	uint16_t value_received;
	
	//Convert the ADC value to SPI bytes.
	spi_byte_low = (value_to_write & 0xFF);					//Retrieve the lower byte from the value to write.
	spi_byte_high = (value_to_write & 0xFF00) >> 8;			//Retrieve the upper byte from the value to write.  Note that 0xFF00 is valid for 16 bit values (i.e., two byte values such as uint16).

	//Set the multiplexer channel so that we can perform a slave select for Micro-Micro SPI.
	set_multiplexer_channel( slave_num + 37 );

	//Re-establish control over the slave select pin.
	DDRB |= (1 << 0);						//Ensure the the SS pin is set to output.

	//Pull the slave select pin low to initiate SPI communication.
	cbi(PORTB, 0);
	
	//_delay_ms(1);
	//_delay_ms(1000);
	
	//Write the SPI byte to the slave.
	spi_byte_low = spi_read_write(spi_byte_low);
	_delay_ms(1);
	spi_byte_high = spi_read_write(spi_byte_high);
	
	// Construct the uint16 that we received from the slave.
	value_received = (spi_byte_high << 8) | spi_byte_low;
	
	//Pull the slave select pin high to end SPI communication.
	sbi(PORTB, 0);
	
	//Relinquish control of the slave select pin.
	DDRB &= ~(1 << 0);					//Set the SS pin to input.
	
	// Return the uint16 we received from the slave.
	return value_received;
	
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
		k2 = GetMuscleIndex( command_data_ptr->IDs[k1] );
		
		// Write to the appropriate slave.
		if (!(k2 == 255))																	// If we detected a valid muscle ID...
		{

			// Write the corresponding uint16 value to the associated slave microcontroller and retrieve a uint16 from the slave.
			p_actual_uint16 = spi_read_write_uint16( command_data_ptr->values[k1], slave_info[k2].slave_num );
			//p_actual_uint16 = 65535;

			// Store the sensor data ID, sensor data ADC uint16 value, and sensor data length values.
			sensor_data_ptr->IDs[sensor_data_index] = sensor_data_index + 1;									// Set the sensor data ID.
			sensor_data_ptr->values[sensor_data_index] = p_actual_uint16;			// Read in from the current multiplexer channel.
			//sensor_data_ptr->values[sensor_data_index] = 0;			//Read in from the current multiplexer channel.
			++sensor_data_ptr->length;											// Increase the sensor data array length counter by one.

			// Advance the sensor data index.
			++sensor_data_index;
		}
		
	}
	
	for (uint8_t k; k < 14; ++k)
	{
		
		// Fill in the missing encoder values.
		sensor_data_ptr->IDs[sensor_data_index] = sensor_data_index + 1;									//Set the sensor data ID.
		sensor_data_ptr->values[sensor_data_index] = 0;			//Read in from the current multiplexer channel.
		++sensor_data_ptr->length;
		
		// Advance the sensor data index.
		++sensor_data_index;
		
	}

	
}
