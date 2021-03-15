// Conversion Functions.
// This script implements microcontroller data type conversion functions.

// Include the associated header file.
#include "Slave_Micro_Header.h"

// Implement a function to convert integers to their low and high bytes.
uint8_t * int2lowhighbytes( uint16_t myint )
{
	
	// Define an array to store the integer bytes.
	static uint8_t int_bytes[2];
	
	// Calculate the low byte.
	int_bytes[0] = myint % 256;
	
	// Calculate the high byte.
	int_bytes[1] = floor(myint/256);
	
	// Return the integer array.
	return int_bytes;
	
}

// Implement a function to convert integers to their low and high bytes.
uint16_t lowhighbytes2int( uint8_t low_byte, uint8_t high_byte )
{
	
	// Compute the integer represented by these low and high bytes.
	uint16_t myint = low_byte + 256*high_byte;
	
	// Return the integer array.
	return myint;
	
}

// Implement a function to convert a byte array to an uint16.
uint16_t byte_array2int( uint8_t byte_array[] )
{
	
	// Define a uint16 value for output.
	uint16_t my_int;
	
	// Assign each byte of the uint16 individually.
	for ( int k = 0; k < 2; ++k )
	{
		*((uint8_t*)(&my_int) + k) = byte_array[k];
	}
	
	// Return the float.
	return my_int;
	
}

// Implement a function to convert a byte array to a single.
float byte_array2float( uint8_t byte_array[] )
{
	
	// Define a floating point value for output.
	float my_float;
	
	// Define the number of bytes to expect.
	uint8_t num_bytes_per_float = 4;
	
	// Assign each byte of the float individually.
	for ( int k = 0; k < num_bytes_per_float; ++k )
	{
		*((uint8_t*)(&my_float) + k) = byte_array[k];
	}
	
	// Return the float.
	return my_float;
	
}

// Implement a function to convert an uint16 to a byte array.
void int2byte_array( uint16_t my_int, uint8_t byte_array[] )
{
	
	// Iterate through each of the uint16's bytes and store them in an array.
	for ( int k = 0; k < 2; ++k )
	{
		byte_array[k] = *((uint8_t*)(&my_int) + k);
	}
	
}

// Implement a function to convert a single to a byte array.
void float2byte_array( float my_float, uint8_t byte_array[] )
{
	
	// Iterate through each of the float's bytes and store them in an array.
	for ( int k = 0; k < 4; ++k )
	{
		byte_array[k] = *((uint8_t*)(&my_float) + k);
	}
	
}

// Implement a function to convert an adc value to an uint16.
uint16_t ADC2uint16( uint16_t ADC_value )
{
	
	// Define a variable to store the uint16 ADC value.
	uint16_t ADCuint16;
	
	// Convert the ADC value to a uint16.
	ADCuint16 = round( (65535./1023.)*ADC_value );

	// Return the uint16 value associated with the ADC value.
	return ADCuint16;
	
}

// Implement a function to convert an uint16 value to an adc value.
uint16_t uint162ADC( uint16_t uint16_value )
{
	
	// Define a variable to store the ADC value.
	uint16_t ADC_value;
	
	// Convert the uint16 to an ADC value.
	ADC_value = round( (1023./65535.)*uint16_value );
	
	// Return the ADC value.
	return ADC_value;
	
}

// Implement a function to convert an ADC value to a voltage (0-5 float).
float ADC2Voltage( uint16_t ADC_value )
{
	
	// Define local variables.
	float voltage;
	
	// Convert the ADC value to a voltage.
	// voltage = (5./1023)*ADC_value;
	voltage = (4.3/1023)*ADC_value;

	// Return the voltage.
	return voltage;
	
}

// Implement a function to convert a voltage (0-4.3 float) to a uint16 (0-65535).
uint16_t voltage2uint16( float voltage )
{
	
	// Define local variables.
	uint16_t value;
	
	// Convert the voltage to a uint16.
	value = round( (65535/4.3)*voltage );
	
	// Return the uint16.
	return value;
	
}

// Implement a function to scale the ADC values.
uint16_t ScaleADC( uint16_t ADC_value )
{
	
	// Define local variables.
	uint16_t nADC_value;
	
	// Determine whether we need to prevent overflow.
	if (ADC_value > 880)			// If this value would cause overflow...
	{
		// Set the ADC value to the maximum allowable value.
		ADC_value = 880;
	}
	
	// Compute the scaled ADC value.
	nADC_value = floor((1023./880.)*ADC_value);
	
	// Return the scaled ADC value.
	return nADC_value;
	
}
