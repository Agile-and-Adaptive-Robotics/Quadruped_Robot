// Encoder Functions.

// This script implements encoder functions.

// Include the associated header file.
#include "Slave_Micro_Header.h"


// Implement a function to get the encoder increment.
int8_t get_encoder_increment( void )
{
	
	// Define the possible encoder increments.
	int8_t encoder_increments[16] = { 0, 1, -1, 0, -1, 0, 0, 1, 1, 0, 0, -1, 0, -1, 1, 0 };			// -1 = CW rotation, 0 = No rotation (or implausible rotation), 1 = CWW rotation.
	
	// Define a variable to store the encoder state.
	static uint8_t encoder_state = 0;
	
	// Shift the encoder state to two bits to the left to make room for the new B A pin states on the right.
	encoder_state <<= 2;
	
	// Add the new B A pin states in bit positions 1 and 0, respectively.
	//encoder_state |= ( (ENCODER_PORT >> 6) & 0b00000011 );					// We shift the encoder port 6 bits to the right because encoder pin A = pin 6 and encoder pin B = pin 7.
	encoder_state |= (ENCODER_PORT >> 6);					// We shift the encoder port 6 bits to the right because encoder pin A = pin 6 and encoder pin B = pin 7.

	// Return the encoder increment.
	return ( encoder_increments[ ( encoder_state & 0b00001111 ) ] );			// Note that we use & 0b00001111 in order to ensure that there are no non-zero higher digits from previous calls of this function.
	
}


// Implement a function to track the encoder value.
void apply_encoder_increment( struct sensor_data_struct * sensor_data_ptr, int8_t encoder_increment )
{
	
	// Determine how to advance the encoder value.
	if ( (sensor_data_ptr->joint_value == MAX_ENCODER_VALUE) && (encoder_increment == 1)  )					// If we need to increase the joint value but are already at the maximum possible joint value...
	{
		
		// Set the joint value to zero.
		sensor_data_ptr->joint_value = 0;
		
	}
	else if ( (sensor_data_ptr->joint_value == 0) && (encoder_increment == -1) )							// If we need to decrease the joint vlaue but are already at the lowest possible joint value...
	{
		
		// Set the joint value to the maximum possible value.
		sensor_data_ptr->joint_value = MAX_ENCODER_VALUE;
		
	}
	else																									// Otherwise...
	{
		
		// Increase or decrease the joint value as necessary.
		sensor_data_ptr->joint_value += encoder_increment;
		
	}
	
}


// Implement a function to reset the encoder value.
void reset_encoder_value( struct sensor_data_struct * sensor_data_ptr )
{
	
	// Set the current joint value to the encoder reference value.
	sensor_data_ptr->joint_value = ENCODER_REFERENCE_VALUE;
	
}

