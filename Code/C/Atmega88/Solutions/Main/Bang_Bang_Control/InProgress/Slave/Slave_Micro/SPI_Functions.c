// Setup Functions.

// This script implements SPI related functions.

// Include the associated header file.
#include "Slave_Micro_Header.h"


// Implement a function to initialize the SPI bytes to send.
void initialize_spi_bytes_to_send( struct SPI_data_struct * SPI_manager_ptr )
{
	
	// Initialize the SPI bytes to send to be all zeros.
	for ( uint8_t k = 0; k < NUM_SPI_BYTES_TO_SEND; ++k )					// Iterate through each of the SPI bytes to send...
	{
		
		// Set each SPI byte to zero.
		SPI_manager_ptr->spi_bytes_to_send[k] = 0;
		
	}
	
}


// Implement a function to stage the first pressure sensor value for SPI transmission.
void stage_first_pressure_sensor_value( struct sensor_data_struct * sensor_data_ptr, struct SPI_data_struct * SPI_manager_ptr )
{
	
	// This function "stages" the first pressure sensor value for SPI transmission by assigning the bytes of the first pressure sensor value to the SPI bytes to send array (while setting the other bytes to zero).  It also sets the maximum SPI bytes for this transmission.
	
	// Set the SPI bytes to send to be all zeros.
	initialize_spi_bytes_to_send( SPI_manager_ptr );
					
	// Store the bytes of the first pressure sensor value into the SPI bytes to send array.
	uint162byte_array( sensor_data_ptr->pressure_sensor_value1, SPI_manager_ptr->spi_bytes_to_send );
					
	// Set the max SPI index to three.
	SPI_manager_ptr->max_spi_index = 3;		
	
}


// Implement a function to stage the second pressure sensor value for SPI transmission.
void stage_second_pressure_sensor_value( struct sensor_data_struct * sensor_data_ptr, struct SPI_data_struct * SPI_manager_ptr )
{
	
	// This function "stages" the second pressure sensor value for SPI transmission by assigning the bytes of the second pressure sensor value to the SPI bytes to send array (while setting the other bytes to zero).  It also sets the maximum SPI bytes for this transmission.
	
	// Set the SPI bytes to send to be all zeros.
	initialize_spi_bytes_to_send( SPI_manager_ptr );
	
	// Store the bytes of the second pressure sensor value into the SPI bytes to send array.
	uint162byte_array( sensor_data_ptr->pressure_sensor_value2, SPI_manager_ptr->spi_bytes_to_send );
	
	// Set the max SPI index to three.
	SPI_manager_ptr->max_spi_index = 3;
	
}


// Implement a function to stage the joint angle sensor value for SPI transmission.
void stage_joint_angle_sensor_value( struct sensor_data_struct * sensor_data_ptr, struct SPI_data_struct * SPI_manager_ptr )
{
	
	// This function "stages" the joint angle sensor value for SPI transmission by assigning the bytes of the joint angle sensor value to the SPI bytes to send array (while setting the other bytes to zero).  It also sets the maximum SPI bytes for this transmission.
	
	// Set the SPI bytes to send to be all zeros.
	initialize_spi_bytes_to_send( SPI_manager_ptr );
	
	// Store the bytes of the joint angle sensor value into the SPI bytes to send array.
	uint162byte_array( sensor_data_ptr->joint_value, SPI_manager_ptr->spi_bytes_to_send );
	
	// Set the max SPI index to three.
	SPI_manager_ptr->max_spi_index = 3;
	
}


// Implement a function to stage all of the sensor values for SPI transmission.
void stage_all_sensor_values( struct sensor_data_struct * sensor_data_ptr, struct SPI_data_struct * SPI_manager_ptr )
{
	
	// This function "stages" all of the sensor values for SPI transmission by assigning the bytes of each sensor value to the SPI bytes to send array.  It also sets the maximum SPI bytes for this transmission.

	// Create a variable to temporarily the bytes of the sensor values.
	uint8_t temp_bytes[NUM_BYTES_PER_UINT16];
					
	// Retrieve the bytes associated with the first pressure sensor.
	uint162byte_array( sensor_data_ptr->pressure_sensor_value1, temp_bytes );
					
	// Store the first pressure sensor value bytes into the bytes to send array.
	SPI_manager_ptr->spi_bytes_to_send[0] = temp_bytes[0];
	SPI_manager_ptr->spi_bytes_to_send[1] = temp_bytes[1];

	// Retrieve the bytes associated with the second pressure sensor.
	uint162byte_array( sensor_data_ptr->pressure_sensor_value2, temp_bytes );
					
	// Store the second pressure sensor value bytes into the bytes to send array.
	SPI_manager_ptr->spi_bytes_to_send[2] = temp_bytes[0];
	SPI_manager_ptr->spi_bytes_to_send[3] = temp_bytes[1];

	// Retrieve the bytes associated with the encoder value.
	uint162byte_array( sensor_data_ptr->joint_value, temp_bytes );
					
	// Store the second pressure sensor value bytes into the bytes to send array.
	SPI_manager_ptr->spi_bytes_to_send[4] = temp_bytes[0];
	SPI_manager_ptr->spi_bytes_to_send[5] = temp_bytes[1];
					
	// Set the max SPI index to three.
	SPI_manager_ptr->max_spi_index = 7;
	
}


// Implement a function to stage the appropriate sensor value(s) based on the sensor ID.
void stage_sensor_values( struct sensor_data_struct * sensor_data_ptr, struct SPI_data_struct * SPI_manager_ptr )
{
	
	// This function "stages" the appropriate sensor(s) value(s) for SPI transmission by assigning the bytes for the appropriate sensor(s) value(s) to the SPI bytes to send array.  It also sets the maximum SPI bytes for this transmission.

	// Determine which sensor values to stage.
	switch ( SPI_manager_ptr->sensor_ID )						// If the sensor ID is...
	{
		case 1 :								// ... 1, then...
		
			// Stage the first pressure sensor value for SPI transmission.
			stage_first_pressure_sensor_value( sensor_data_ptr, SPI_manager_ptr );
		
			// End the switch statement.
			break;
		
		case 2 :								// ... 2, then...
		
			// Stage the second pressure sensor value for SPI transmission.
			stage_second_pressure_sensor_value( sensor_data_ptr, SPI_manager_ptr );
		
			// End the switch statement.
			break;
		
		case 3 :								// ... 3, then...
		
			// Stage the joint angle sensor value for SPI transmission.
			stage_joint_angle_sensor_value( sensor_data_ptr, SPI_manager_ptr );
		
			// End the switch statement.
			break;
		
		case 255 : 								// ... 255, then...
		
			// Stage the all of the sensor values for SPI transmission.
			stage_all_sensor_values( sensor_data_ptr, SPI_manager_ptr );
		
			// End the switch statement.
			break;
		
	}
	
}


// Implement a function to store the received command bytes.
void store_command_value( struct command_data_struct * command_data_ptr, struct SPI_data_struct * SPI_manager_ptr )
{
	
	// This function stores the received command bytes into the appropriate command data value (such as the desired pressure value).
	
	// Determine whether these low and high SPI bytes need to be converted into a uint16 and stored.
	if ( (SPI_manager_ptr->spi_index == 3) )								// If this is the fourth byte we have received in this sentence...
	{
					
		// Convert these low and high SPI bytes to a uint16 and determine where to store them.
		switch ( SPI_manager_ptr->command_ID )						// If the command ID is...
		{
			case 1 :								// ... 1, then...
						
				// Convert the SPI bytes received into a uint16 and store the value into the desired pressure variable.
				command_data_ptr->desired_pressure = byte_array2uint16( SPI_manager_ptr->spi_bytes_received );
						
				// End the switch statement.
				break;
		}
					
	}
	
}


// Implement a function to stage the received command bytes.
void stage_command_value( uint8_t spi_byte, struct command_data_struct * command_data_ptr, struct SPI_data_struct * SPI_manager_ptr )
{

	// Determine whether this is the low or high byte of the command value.
	if ( SPI_manager_ptr->spi_index % 2 == 0 )			// If the SPI index is even...
	{
			
		// Store this byte into the lower byte of the SPI bytes received.
		SPI_manager_ptr->spi_bytes_received[0] = spi_byte;
			
	}
	else								// If the SPI index is odd...
	{
			
		// Store this byte into the higher byte of the SPI bytes received.
		SPI_manager_ptr->spi_bytes_received[1] = spi_byte;
			
		// Store the command value.
		store_command_value( command_data_ptr, SPI_manager_ptr );
			
	}
	
}

