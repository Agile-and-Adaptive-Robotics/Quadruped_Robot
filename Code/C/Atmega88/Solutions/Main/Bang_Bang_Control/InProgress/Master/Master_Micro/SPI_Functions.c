// SPI Functions.

// This script implements functions for SPI communication.

// Include the associated header file.
#include "Master_Micro_Header.h"



// ---------- UINT8 SPI READ WRITE FUNCTIONS ----------

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



// ---------- UINT16 SPI READ WRITE FUNCTIONS ----------

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



// ---------- UINT8 ARRAY SPI READ WRITE FUNCTIONS ----------

// Implement a function to read an uint8 array via SPI.
void spi_read_uint8_array( uint8_t read_array[], uint8_t num_uint8s_to_read )
{
	
	// Read each uint8 and store them in the read array.
	for ( uint8_t k = 0; k < num_uint8s_to_read; ++k)				// Iterate through each uint8 to read...
	{
		
		// Read the current uint8 via SPI.
		read_array[k] = spi_read_uint8();
		
	}
	
}


// Implement a function to write an uint8 array via SPI.
void spi_write_uint8_array( uint8_t write_array[], uint8_t num_uint8s_to_write )
{
	
	// Write each uint8 via SPI.
	for ( uint8_t k = 0; k < num_uint8s_to_write; ++k )				// Iterate through each uint8 to write...
	{
		
		// Write the current uint8 via SPI.
		spi_write_uint8( write_array[k] );
		
	}
	
}


// Implement a function to read and write an uint8 array via SPI.
void spi_read_write_uint8_array( uint8_t write_array[], uint8_t read_array[], uint8_t num_uint8s_to_read_write )
{
	
	// Read and write each uint8 via SPI.
	for ( uint8_t k = 0; k < num_uint8s_to_read_write; ++k )						// Iterate through each read / write uint8...
	{
		
		// Read and write the current uint8 via SPI.
		read_array[k] = spi_read_write_uint8( write_array[k] );
		
		// Ensure that sufficient time has passed for the slave to complete the SPI transfer.
		_delay_ms(SPI_DELAY);
		
	}
	
}



// ---------- SLAVE SPI INITIATION AND TERMINATION FUNCTIONS ----------

// Implement a function to initiate SPI communication with a specific slave.
void initiate_SPI( uint8_t slave_index )
{
		
	// Set the multiplexer channel so that we can perform a slave select for Micro-Micro SPI.
	set_multiplexer_channel( slave_index + 37 );

	// Re-establish control over the slave select pin.
	DDRB |= (1 << 0);						// Ensure the the SS pin is set to output.

	// Pull the slave select pin low to initiate SPI communication.
	cbi(PORTB, 0);
	
}


// Implement a function to terminate SPI communication with the currently active slave.
void terminate_SPI( void )
{
	
	// Pull the slave select pin high to end SPI communication.
	sbi(PORTB, 0);
		
	// Relinquish control of the slave select pin.
	DDRB &= ~(1 << 0);					// Set the SS pin to input.
	
}



// ---------- SLAVE UINT8 SPI READ WRITE FUNCTIONS ----------

// Implement a function to read a uint8_t via SPI from a specific slave.
uint8_t spi_read_slave_uint8( uint8_t slave_index )
{
	
	// Initiate SPI communication with the given slave.
	initiate_SPI( slave_index );
	
	// Read the uint16 via SPI.
	uint8_t value_received = spi_read_uint8();
	
	// Terminate SPI communication with the given slave.
	terminate_SPI();

	// Return the received value.
	return value_received;
	
}


// Implement a function to write a uint8_t via SPI to a specific slave.
void spi_write_slave_uint8( uint8_t value_to_write, uint8_t slave_index )
{
	
	// Initiate SPI communication with the given slave.
	initiate_SPI( slave_index );
	
	// Write the uint16 via SPI.
	spi_write_uint8( value_to_write );
	
	// Terminate SPI communication with the given slave.
	terminate_SPI();
	
}


// Implement a function to read and write a uint8_t via SPI from / to a specific slave.
uint8_t spi_read_write_slave_uint8( uint8_t value_to_write, uint8_t slave_index )
{
	
	// Initiate SPI communication with the given slave.
	initiate_SPI( slave_index );
	
	// Read the uint16 via SPI.
	uint8_t value_received = spi_read_write_uint8( value_to_write );
	
	// Terminate SPI communication with the given slave.
	terminate_SPI();
	
	// Return the received value.
	return value_received;
	
}



// ---------- SLAVE UINT16 SPI READ WRITE FUNCTIONS ----------

// Implement a function to read a uint16_t via SPI from a specific slave.
uint16_t spi_read_slave_uint16( uint8_t slave_index )
{
	
	// Initiate SPI communication with the given slave.
	initiate_SPI( slave_index );
	
	// Read the uint16 via SPI.
	uint16_t value_received = spi_read_uint16();
	
	// Terminate SPI communication with the given slave.
	terminate_SPI();
	
	// Return the received value.
	return value_received;
	
}


// Implement a function to write a uint16_t via SPI to a specific slave.
void spi_write_slave_uint16( uint16_t value_to_write, uint8_t slave_index )
{
	
	// Initiate SPI communication with the given slave.
	initiate_SPI( slave_index );
		
	// Write the uint16 via SPI.
	spi_write_uint16( value_to_write );
		
	// Terminate SPI communication with the given slave.
	terminate_SPI();
	
}


// Implement a function to read and write a uint16_t via SPI from / to a specific slave.
uint16_t spi_read_write_slave_uint16( uint16_t value_to_write, uint8_t slave_index )
{

	// Initiate SPI communication with the given slave.
	initiate_SPI( slave_index );
	
	// Read the uint16 via SPI.
	uint16_t value_received = spi_read_write_uint16( value_to_write );
	
	// Terminate SPI communication with the given slave.
	terminate_SPI();
	
	// Return the received value.
	return value_received;
	
}



// ---------- SLAVE UINT8 ARRAY SPI READ WRITE FUNCTIONS ----------

// Implement a function to read a uint8_t array via SPI from a specific slave.
void spi_read_slave_uint8_array( uint8_t read_array[], uint8_t num_uint8s_to_read, uint8_t slave_index )
{
	
	// Initiate SPI communication with the given slave.
	initiate_SPI( slave_index );
	
	// Read the uint8_t array via SPI from this slave.
	spi_read_uint8_array( read_array, num_uint8s_to_read );
	
	// Terminate SPI communication with the given slave.
	terminate_SPI();
	
}


// Implement a function to write a uint8_t array via SPI to a specific slave.
void spi_write_slave_uint8_array( uint8_t write_array[], uint8_t num_uint8s_to_write, uint8_t slave_index )
{
	
	// Initiate SPI communication with the given slave.
	initiate_SPI( slave_index );
		
	// Read the uint8_t array via SPI from this slave.
	spi_write_uint8_array( write_array, num_uint8s_to_write );
		
	// Terminate SPI communication with the given slave.
	terminate_SPI();
	
}


// Implement a function to read and write a uint8_t array via SPI to a specific slave.
void spi_read_write_slave_uint8_array( uint8_t write_array[], uint8_t read_array[], uint8_t num_uint8s_to_read_write, uint8_t slave_index )
{
	
	// Initiate SPI communication with the given slave.
	initiate_SPI( slave_index );
		
	// Read the uint8_t array via SPI from this slave.
	spi_read_write_uint8_array( write_array, read_array, num_uint8s_to_read_write );
		
	// Terminate SPI communication with the given slave.
	terminate_SPI();
	
}



// ---------- SENSOR / COMMAND SLAVE UINT16 SPI READ WRITE FUNCTIONS ----------

// Implement a function to read a specific sensor from a specific slave.
void spi_read_specific_slave_specific_sensor( struct slave_struct_array * slave_ptr, uint8_t slave_ID, uint8_t sensor_ID )
{
			
	// Get the slave index associated with this slave ID.			
	uint8_t slave_index = get_slave_index_from_slave_ID( slave_ptr, slave_ID );
			
	// Define the byte array to write to the slave microcontroller.
	uint8_t write_array[SINGLE_SENSOR_MESSAGE_LENGTH] = { 0, sensor_ID, 0, 0 };			// { 0 = Ignore command byte, sensor_ID = sensor ID byte, 0 = dummy command byte, 0 = dummy command byte }
		
	// Initialize a uint8 array to store the retrieved sensor value from the slave microcontroller.
	uint8_t read_array[SINGLE_SENSOR_MESSAGE_LENGTH];
		
	// Read the uint8 array from the slave microcontroller.
	spi_read_write_slave_uint8_array( write_array, read_array, SINGLE_SENSOR_MESSAGE_LENGTH, slave_index );

	// Retrieve the bytes associated with the sensor value.  (When we read a single sensor, we should get 4 read bytes.  The first and second bytes we disregard.  The third and fourth bytes we interpret as being the low and high bytes of the sensor value, respectively.)
	uint8_t value_received_byte_array[NUM_BYTES_PER_UINT16] = { read_array[2], read_array[3] };

	// Convert the sensor value bytes to a uint16 sensor value.
	uint16_t value_received = byte_array2uint16( value_received_byte_array );

	// Determine where to store the received sensor value.
	switch ( sensor_ID )						// If the sensor ID is...
	{
		case 1 :								// ... 1, then...
			
			// Store the received sensor value as pressure sensor value 1.
			slave_ptr->slave[slave_index].pressure_sensor_value1 = value_received;
			
			// End the switch statement.
			break;
			
		case 2 :								// ... 2, then...
			
			// Store the received sensor value as pressure sensor value 2.
			slave_ptr->slave[slave_index].pressure_sensor_value2 = value_received;
			
			// End the switch statement.
			break;
			
		case 3 :								// ... 3, then...
			
			// Store the received sensor value as a joint value.
			slave_ptr->slave[slave_index].joint_value = value_received;
			
			// End the switch statement.
			break;
	}
	
}


// Implement a function to read all of the sensors from a specific slave.
void spi_read_specific_slave_all_sensors( struct slave_struct_array * slave_ptr, uint8_t slave_ID )
{
	
	// Get the slave index associated with this slave ID.
	uint8_t slave_index = get_slave_index_from_slave_ID( slave_ptr, slave_ID );

	// Define the byte array to write to the slave microcontroller.
	uint8_t write_array[ALL_SENSORS_MESSAGE_LENGTH] = { 0, 255, 0, 0, 0, 0, 0, 0 };			// { 0 = ignore command byte, 255 = read all sensors, all other 0s = dummy command bytes }
	
	// Initialize a uint8 array to store the retrieved sensor value from the slave microcontroller.
	uint8_t read_array[ALL_SENSORS_MESSAGE_LENGTH];
			
	// Read and write the uint8 arrays (write_array = bytes to send to the slave microcontroller, read_array = bytes that will be received from the slave microcontroller).
	spi_read_write_slave_uint8_array( write_array, read_array, ALL_SENSORS_MESSAGE_LENGTH, slave_index );

	// Retrieve the bytes associated with the sensor value.  (When we read from all of the sensors, we should get 2 + 2 n read bytes where n is the number of sensors we are reading.  The first and second bytes we disregard.  The third and fourth bytes we interpret as being the low and high bytes of the first pressure sensor, respectively.  So on and so forth.)
	uint8_t pressure_sensor1_byte_array[NUM_BYTES_PER_UINT16] = { read_array[2], read_array[3] };
	uint8_t pressure_sensor2_byte_array[NUM_BYTES_PER_UINT16] = { read_array[4], read_array[5] };
	uint8_t joint_angle_byte_array[NUM_BYTES_PER_UINT16] = { read_array[6], read_array[7] };

	// Convert the sensor value bytes to a uint16 sensor value.
	uint16_t pressure_sensor1_value_received = byte_array2uint16( pressure_sensor1_byte_array );
	uint16_t pressure_sensor2_value_received = byte_array2uint16( pressure_sensor2_byte_array );
	uint16_t joint_angle_value_received = byte_array2uint16( joint_angle_byte_array );

	// Store the received sensor values.
	slave_ptr->slave[slave_index].pressure_sensor_value1 = pressure_sensor1_value_received;
	slave_ptr->slave[slave_index].pressure_sensor_value2 = pressure_sensor2_value_received;
	slave_ptr->slave[slave_index].joint_value = joint_angle_value_received;

}


// Implement a function to read a specific sensor or all of the sensors from a specific slave.
void spi_read_specific_slave_sensor( struct slave_struct_array * slave_ptr, uint8_t slave_ID, uint8_t sensor_ID )
{
	
	// Determine whether to read a specific sensor or all of the sensors from the given slave.
	if ( !(sensor_ID == 255) )						// If the sensor ID is not set to 255. (Note: A sensor ID of 255 indicates that we want to read all of the sensors.)
	{
		
		// Read the specified sensor from this slave.
		spi_read_specific_slave_specific_sensor( slave_ptr, slave_ID, sensor_ID );
		
	}
	else
	{
		
		// Read all of the sensors from this slave.
		spi_read_specific_slave_all_sensors( slave_ptr, slave_ID );
		
	}
	
}



// Implement a function to write a specific command value to a specific slave.
void spi_write_specific_slave_specific_command( struct slave_struct_array * slave_ptr, uint8_t slave_ID, uint8_t command_ID )
{
	
	// Get the slave index associated with this slave ID.
	uint8_t slave_index = get_slave_index_from_slave_ID( slave_ptr, slave_ID );
		
	// Set the write value to zero.
	uint16_t write_value = 0;	
	
	// Determine which command value to write.
	switch ( command_ID )						// If the command ID is...
	{
		case 1 :								// ... 1, then...
				
			// Set the value to write to be the desired pressure.
			write_value = slave_ptr->slave[slave_index].desired_pressure;
				
			// End the switch statement.
			break;
	}
		
	// Initialize an uint8 array to store the bytes of the value to write.
	uint8_t write_value_byte_array[NUM_BYTES_PER_UINT16];
		
	// Retrieve the bytes associated with the desired pressure.
	uint162byte_array( write_value, write_value_byte_array );
		
	// Define the byte array to write to the slave microcontroller.
	uint8_t write_array[SINGLE_SENSOR_MESSAGE_LENGTH] = { command_ID, 0, write_value_byte_array[0], write_value_byte_array[1] };			// { command_ID = sets which value the command data represents, 0 = ignore read data, all other bytes = command data }
			
	// Write the uint8 arrays (write_array = bytes to send to the slave microcontroller).
	spi_write_slave_uint8_array( write_array, SINGLE_SENSOR_MESSAGE_LENGTH, slave_index );

}



// Implement a function to read a specific sensor value while writing a specific command value to a specific slave.
void spi_read_write_specific_slave_specific_sensor_specific_command( struct slave_struct_array * slave_ptr, uint8_t slave_ID, uint8_t command_ID, uint8_t sensor_ID )
{
	
	// Get the slave index associated with this slave ID.
	uint8_t slave_index = get_slave_index_from_slave_ID( slave_ptr, slave_ID );

	// Set the write value to zero.
	uint16_t write_value = 0;
		
	// Determine which command value to write.
	switch ( command_ID )						// If the command ID is...
	{
		case 1 :								// ... 1, then...
		
			// Set the value to write to be the desired pressure.
			write_value = slave_ptr->slave[slave_index].desired_pressure;
		
			// End the switch statement.
			break;
	}
	
	// Initialize an uint8 array to store the bytes of the value to write.
	uint8_t write_value_byte_array[NUM_BYTES_PER_UINT16];
	
	// Retrieve the bytes associated with the desired pressure.
	uint162byte_array( write_value, write_value_byte_array );
		
	// Define the byte array to write to the slave microcontroller.
	uint8_t write_array[SINGLE_SENSOR_MESSAGE_LENGTH] = { command_ID, sensor_ID, write_value_byte_array[0], write_value_byte_array[1] };
			
	// Initialize a uint8 array to store the retrieved sensor value from the slave microcontroller.
	uint8_t read_array[SINGLE_SENSOR_MESSAGE_LENGTH];
			
	// Read and write the uint8 arrays (write_array = bytes to send to the slave microcontroller, read_array = bytes that will be received from the slave microcontroller).
	spi_read_write_slave_uint8_array( write_array, read_array, SINGLE_SENSOR_MESSAGE_LENGTH, slave_index );

	// Retrieve the bytes associated with the sensor value.
	uint8_t value_received_byte_array[NUM_BYTES_PER_UINT16] = { read_array[2], read_array[3] };

	// Convert the sensor value bytes to a uint16 sensor value.
	uint16_t value_received = byte_array2uint16( value_received_byte_array );

	// Determine where to store the received sensor value.
	switch ( sensor_ID )						// If the sensor ID is...
	{
		case 1 :								// ... 1, then...
				
			// Store the received sensor value as pressure sensor value 1.
			slave_ptr->slave[slave_index].pressure_sensor_value1 = value_received;
				
			// End the switch statement.
			break;
				
		case 2 :								// ... 2, then...
				
			// Store the received sensor value as pressure sensor value 2.
			slave_ptr->slave[slave_index].pressure_sensor_value2 = value_received;
				
			// End the switch statement.
			break;
				
		case 3 :								// ... 3, then...
				
			// Store the received sensor value as a joint value.
			slave_ptr->slave[slave_index].joint_value = value_received;
				
			// End the switch statement.
			break;
	}

	
	
}


// Implement a function to read all of the sensor values while writing a specific command value to a specific slave.
void spi_read_write_specific_slave_all_sensors_specific_command( struct slave_struct_array * slave_ptr, uint8_t slave_ID, uint8_t command_ID )
{
	
	// Get the slave index associated with this slave ID.
	uint8_t slave_index = get_slave_index_from_slave_ID( slave_ptr, slave_ID );

	// Set the write value to zero.
	uint16_t write_value = 0;
	
	// Determine which command value to write.
	switch ( command_ID )						// If the command ID is...
	{
		case 1 :								// ... 1, then...
		
			// Set the value to write to be the desired pressure.
			write_value = slave_ptr->slave[slave_index].desired_pressure;
		
			// End the switch statement.
			break;
	}
	
	// Initialize an uint8 array to store the bytes of the value to write.
	uint8_t write_value_byte_array[NUM_BYTES_PER_UINT16];
	
	// Retrieve the bytes associated with the desired pressure.
	uint162byte_array( write_value, write_value_byte_array );
	
	// Define the byte array to write to the slave microcontroller.
	uint8_t write_array[ALL_SENSORS_MESSAGE_LENGTH] = { command_ID, 255, write_value_byte_array[0], write_value_byte_array[1], 0, 0, 0, 0 };
		
	// Initialize a uint8 array to store the retrieved sensor value from the slave microcontroller.
	uint8_t read_array[ALL_SENSORS_MESSAGE_LENGTH];
		
	// Read and write the uint8 arrays (write_array = bytes to send to the slave microcontroller, read_array = bytes that will be received from the slave microcontroller).
	spi_read_write_slave_uint8_array( write_array, read_array, ALL_SENSORS_MESSAGE_LENGTH, slave_index );

	// Retrieve the bytes associated with the sensor value.
	uint8_t pressure_sensor1_byte_array[NUM_BYTES_PER_UINT16] = { read_array[2], read_array[3] };
	uint8_t pressure_sensor2_byte_array[NUM_BYTES_PER_UINT16] = { read_array[4], read_array[5] };
	uint8_t joint_angle_byte_array[NUM_BYTES_PER_UINT16] = { read_array[6], read_array[7] };

	// Convert the sensor value bytes to a uint16 sensor value.
	uint16_t pressure_sensor1_value_received = byte_array2uint16( pressure_sensor1_byte_array );
	uint16_t pressure_sensor2_value_received = byte_array2uint16( pressure_sensor2_byte_array );
	uint16_t joint_angle_value_received = byte_array2uint16( joint_angle_byte_array );

	// Store the received sensor values.
	slave_ptr->slave[slave_index].pressure_sensor_value1 = pressure_sensor1_value_received;
	slave_ptr->slave[slave_index].pressure_sensor_value2 = pressure_sensor2_value_received;
	slave_ptr->slave[slave_index].joint_value = joint_angle_value_received;
	
}


// Implement a function to read a specific or all sensor values while writing a specific command value to a specific slave.
void spi_read_write_specific_slave_sensor_specific_command( struct slave_struct_array * slave_ptr, uint8_t slave_ID, uint8_t command_ID, uint8_t sensor_ID )
{
	
	// Determine how to interact with the slave.
	if (!(sensor_ID == 255))					// If we want to read a specific sensor while writing a specific command...
	{
		
		// Write the specific command while reading the specific sensor from the given slave.
		spi_read_write_specific_slave_specific_sensor_specific_command( slave_ptr, slave_ID, command_ID, sensor_ID );
		
	}
	else
	{
		
		// Write the specific command while reading all of the sensors from the given slave.
		spi_read_write_specific_slave_all_sensors_specific_command( slave_ptr, slave_ID, command_ID );
		
	}
	
}



// ---------- MULTISLAVE UINT16 SPI READ WRITE FUNCTIONS ----------

// Implement a function to read a specific sensor value or all sensor values from all of the slaves.
void spi_read_all_slaves_sensor( struct slave_struct_array * slave_ptr, uint8_t sensor_ID )
{

	// Read the specified sensor (or all sensors) from each of the slaves.	
	for ( uint8_t k = 0; k < NUM_SLAVES; ++k )					// Iterate through each slave...
	{
		
		// Read the specified sensor (or all sensors) from this specific slave.
		spi_read_specific_slave_sensor( slave_ptr, slave_ptr->slave[k].slave_ID, sensor_ID );
		
	}
	
}


// Implement a function to read a specific sensor value, or all sensor values, from a specific slave or all slaves.
void spi_read_slave_sensor( struct slave_struct_array * slave_ptr, uint8_t slave_ID, uint8_t sensor_ID )
{
	
	// Determine whether to read from a specific slave or all of the slaves.
	if ( !(slave_ID == 255) )						// If the slave ID is not 255... (A slave ID of 255 means that we want to read from all of the slaves.)
	{
		
		// Read the sensor(s) from a specific slave.
		spi_read_specific_slave_sensor( slave_ptr, slave_ID, sensor_ID );
		
	} 
	else
	{
		
		// Read the sensor(s) from all of the slaves. 
		spi_read_all_slaves_sensor( slave_ptr, sensor_ID );
		
	}
	
}


// Implement a function to write a specific command value to all of the slaves.
void spi_write_all_slaves_specific_command( struct slave_struct_array * slave_ptr, uint8_t command_ID )
{
	
	// Write the specified command to each of the slaves.
	for ( uint8_t k = 0; k < NUM_SLAVES; ++k )					// Iterate through each slave...
	{
			
		// Write the specified command to this specific slave.
		spi_write_specific_slave_specific_command( slave_ptr, slave_ptr->slave[k].slave_ID, command_ID );
		
	}
	
}


// Implement a function to write a specific command value to a specific slave or all of the slaves.
void spi_write_slave_specific_command( struct slave_struct_array * slave_ptr, uint8_t slave_ID, uint8_t command_ID )
{
	
	// Determine whether to write the specific command to all of the slaves or only one of the slaves.
	if ( !(slave_ID == 255) )				// If the slave ID is not 255... (A slave ID of 255 means that we want to write to all of the slaves.)
	{
		
		// Write the specific command to this specific slave.
		spi_write_specific_slave_specific_command( slave_ptr, slave_ID, command_ID );
		
	}
	else
	{
		
		// Write the specific command to all of the slaves.
		spi_write_all_slaves_specific_command( slave_ptr, command_ID );
		
	}
	
	
}


// Implement a function to write a specific command value and read a specific sensor value, or all of the sensor values, from all of the slaves.
void spi_read_write_all_slaves_sensor_specific_command( struct slave_struct_array * slave_ptr, uint8_t command_ID, uint8_t sensor_ID )
{
	
	// Write the specified command while reading the specified sensor value, or all sensor values, to / from each of the slaves.
	for ( uint8_t k = 0; k < NUM_SLAVES; ++k )					// Iterate through each slave...
	{
			
		// Write the specified command while reading the specified sensor value, or all sensor values, to / from each of the slaves.
		spi_read_write_specific_slave_sensor_specific_command( slave_ptr, slave_ptr->slave[k].slave_ID, command_ID, sensor_ID );
		
	}
	
}


// Implement a function to write a specific command value and read a specific sensor value, or all of the sensor values, from a specific slave or all of the slaves.
void spi_read_write_slave_sensor_specific_command( struct slave_struct_array * slave_ptr, uint8_t slave_ID, uint8_t command_ID, uint8_t sensor_ID )
{
	
	// Determine whether to write the specific command and read a specific or all sensor values from a specific slave or from all slaves.
	if ( !(slave_ID == 255) )				// If the slave ID is not 255... (A slave ID of 255 means that we want to write to all of the slaves.)
	{
			
		// Write the specific command to this specific slave.
		spi_read_write_specific_slave_sensor_specific_command( slave_ptr, slave_ID, command_ID, sensor_ID );
		
	}
	else
	{
			
		// Write the specific command to all of the slaves.
		spi_read_write_all_slaves_sensor_specific_command( slave_ptr, command_ID, sensor_ID );
		
	}
	
}






