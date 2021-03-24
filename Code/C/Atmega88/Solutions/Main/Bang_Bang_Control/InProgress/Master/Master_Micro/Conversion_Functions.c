// Conversion Functions.

// This script implements microcontroller data type conversion functions.

// Include the associated header file.
#include "Master_Micro_Header.h"


// Implement a function to convert a byte array to an uint16.
uint16_t byte_array2uint16( uint8_t byte_array[] )
{
	
	// Define a uint16 value for output.
	uint16_t my_int;
	
	// Assign each byte of the float individually.
	for ( uint8_t k = 0; k < NUM_BYTES_PER_UINT16; ++k )
	{
		*((uint8_t*)(&my_int) + k) = byte_array[k];
	}
	
	// Return the float.
	return my_int;
	
}


// Implement a function to convert an uint16 to a byte array.
void uint162byte_array( uint16_t my_int, uint8_t byte_array[] )
{
	
	// Iterate through each of the uint16's bytes and store them in an array.
	for ( uint8_t k = 0; k < NUM_BYTES_PER_UINT16; ++k )
	{
		byte_array[k] = *((uint8_t*)(&my_int) + k);
	}
	
}


// Implement a function to convert a byte array to a single.
float byte_array2float( uint8_t byte_array[] )
{
	
	// Define a floating point value for output.
	float my_float;
	
	// Assign each byte of the float individually.
	for ( uint8_t k = 0; k < NUM_BYTES_PER_FLOAT; ++k )
	{
		*((uint8_t*)(&my_float) + k) = byte_array[k];
	}
	
	// Return the float.
	return my_float;
	
}


// Implement a function to convert a single to a byte array.
void float2byte_array( float my_float, uint8_t byte_array[] )
{
	
	// Iterate through each of the float's bytes and store them in an array.
	for ( uint8_t k = 0; k < NUM_BYTES_PER_FLOAT; ++k )
	{
		byte_array[k] = *((uint8_t*)(&my_float) + k);
	}
	
}


// Implement a function to convert a 10 bit integer to a 12 bit integer.
uint16_t uint102uint12( uint16_t my_uint10 )
{
	
	// Define a variable to store the uint12 value.
	uint16_t my_uint12;
	
	// Convert the uint10 value to a uint12 value.
	my_uint12 = round((4095./1023.)*my_uint10);
	
	// Return the uint12 value associated with the given uint10.
	return my_uint12;
	
}


// Implement a function to convert a 12 bit integer to a 10 bit integer.
uint16_t uint122uint10( uint16_t my_uint12 )
{
	
	// Define a variable to store the uint10 value.
	uint16_t my_uint10;
	
	// Convert the uint12 value to a uint10 value.
	my_uint10 = round((1023./4095.)*my_uint12);
	
	// Return the uint10 value associated with the given uint12.
	return my_uint10;
	
}


// Implement a function to convert a 10 bit integer to a 16 bit integer.
uint16_t uint102uint16( uint16_t my_uint10 )
{
	
	// Define a variable to store the uint16 value.
	uint16_t my_uint16;
	
	// Convert the uint10 value to a uint16 value.
	//my_uint16 = (65535/1023)*my_uint10;
	my_uint16 = round((65535./1023.)*my_uint10);

	// Return the uint16 value associated with the given uint10.
	return my_uint16;
	
}


// Implement a function to convert a 16 bit integer to a 10 bit integer.
uint16_t uint162uint10( uint16_t my_uint16 )
{
	
	// Define a variable to store the uint10 value.
	uint16_t my_uint10;
	
	// Convert the uint16 value to a uint10 value.
	//my_uint10 = (1023/65535)*my_uint16;
	my_uint10 = round((1023./65535.)*my_uint16);

	// Return the uint10 value associated with the given uint16.
	return my_uint10;
	
}


// Implement a function to convert a 12 bit integer to a 16 bit integer.
uint16_t uint122uint16( uint16_t my_uint12 )
{
	
	// Define a variable to store the uint16 value.
	uint16_t my_uint16;
	
	// Convert the uint12 value to a uint16 value.
	my_uint16 = round((65535./4095.)*my_uint12);

	// Return the uint16 value associated with the given uint12.
	return my_uint16;
	
}


// Implement a function to convert a 16 bit integer to a 12 bit integer.
uint16_t uint162uint12( uint16_t my_uint16 )
{
	
	// Define a variable to store the uint12 value.
	uint16_t my_uint12;
	
	// Convert the uint16 value to a uint12 value.
	my_uint12 = round((4095./65535.)*my_uint16);

	// Return the uint12 value associated with the given uint16.
	return my_uint12;
	
}


// Implement a function to convert voltage uint16s to voltage floats.
float volt_uint162volt_float( uint16_t volt_uint16 )
{
	
	// Create a variable to store the voltage float.
	float volt_float;
	
	// Convert the voltage uint16 to a voltage float.
	//volt_float = (5./65535)*volt_uint16;
	volt_float = (5./65535.)*volt_uint16;

	// Return the voltage float.
	return volt_float;
	
}


// Implement a function to convert voltage floats to voltage uint16s.
uint16_t volt_float2volt_uint16( float volt_float )
{
	
	// Create a variable to store the voltage uint16.
	uint16_t volt_int;
	
	// Convert the voltage float to a voltage uint16.
	//volt_int = (65535/5.)*volt_float;
	volt_int = (65535./5.)*volt_float;

	// Return the voltage integer.
	return volt_int;
	
}

