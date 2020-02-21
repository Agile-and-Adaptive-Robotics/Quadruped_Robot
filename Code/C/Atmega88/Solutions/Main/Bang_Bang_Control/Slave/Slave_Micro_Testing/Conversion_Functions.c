//Conversion Functions.
//This script implements microcontroller data type conversion functions.

//Include the associated header file.
#include "Slave_Micro_Testing_Header.h"

//Implement a function to convert integers to their low and high bytes.
int * int2lowhighbytes(int myint)
{
	
	//Define an array to store the integer bytes.
	static int int_bytes[2];
	
	//Calculate the low byte.
	int_bytes[0] = myint % 256;
	
	//Calculate the high byte.
	int_bytes[1] = floor(myint/256);
	
	//Return the integer array.
	return int_bytes;
	
}

//Implement a function to convert integers to their low and high bytes.
unsigned int lowhighbytes2int(unsigned int low_byte, unsigned int high_byte)
{
	
	//Compute the integer represented by these low and high bytes.
	unsigned int myint = low_byte + 256*high_byte;
	
	//Return the integer array.
	return myint;
	
}

//Implement a function to convert a byte array to an uint16.
uint16_t byte_array2int(unsigned char byte_array[])
{
	
	//Define a uint16 value for output.
	uint16_t my_int;
	
	//Assign each byte of the uint16 individually.
	for ( int k = 0; k < 2; ++k )
	{
		*((unsigned char*)(&my_int) + k) = byte_array[k];
	}
	
	//Return the float.
	return my_int;
	
}

//Implement a function to convert a byte array to a single.
float byte_array2float(unsigned char byte_array[])
{
	
	//Define a floating point value for output.
	float my_float;
	
	//Define the number of bytes to expect.
	unsigned char num_bytes_per_float = 4;
	
	//Assign each byte of the float individually.
	for ( int k = 0; k < num_bytes_per_float; ++k )
	{
		*((unsigned char*)(&my_float) + k) = byte_array[k];
	}
	
	//Return the float.
	return my_float;
	
}

//Implement a function to convert an uint16 to a byte array.
void int2byte_array(uint16_t my_int, unsigned char byte_array[])
{
	
	//Iterate through each of the uint16's bytes and store them in an array.
	for ( int k = 0; k < 2; ++k )
	{
		byte_array[k] = *((unsigned char*)(&my_int) + k);
	}
	
}

//Implement a function to convert a single to a byte array.
void float2byte_array(float my_float, unsigned char byte_array[])
{
	
	//Iterate through each of the float's bytes and store them in an array.
	for ( int k = 0; k < 4; ++k )
	{
		byte_array[k] = *((unsigned char*)(&my_float) + k);
	}
	
}

//Implement a function to convert muscle integers to muscle voltages.
float muscle_int2muscle_volt(unsigned int muscle_int)
{
	
	//Create a variable to store the muscle voltage.
	float muscle_volt;
	
	//Convert the muscle activation integer to a muscle voltage.
	muscle_volt = (5./65535)*muscle_int;
	
	//Return the muscle voltage.
	return muscle_volt;
	
}

//Implement a function to convert sensor voltages to sensor integers.
unsigned int sensor_volt2sensor_int(unsigned int sensor_volt)
{
	
	//Create a variable to store the sensor integer.
	unsigned int sensor_int;
	
	//Convert the sensor voltage to an integer.
	sensor_int = (65535/5.)*sensor_volt;
	
	//Return the sensor integer.
	return sensor_int;
	
}

//Implement a function to convert an adc value to an uint16.
uint16_t ADC2uint16( unsigned int ADC_value )
{
	
	//Define a variable to store the uint16 ADC value.
	uint16_t ADCuint16;
	
	//Convert the ADC value to a uint16.
	//ADCuint16 = (65535/1023)*ADC_value;
	ADCuint16 = round( (65535/1023)*ADC_value );

	//Return the uint16 value associated with the ADC value.
	return ADCuint16;
	
}

// Implement a function to convert an uint16 value to an adc value.
unsigned int uint162ADC( uint16_t uint16_value )
{
	
	// Define a variable to store the ADC value.
	unsigned int ADC_value;
	
	// Convert the uint16 to an ADC value.
	ADC_value = round( (1023./65535.)*uint16_value );
	
	// Return the ADC value.
	return ADC_value;
	
}

// Implement a function to convert an ADC value to a voltage (0-5 float).
float ADC2Voltage( unsigned int ADC_value )
{
	
	// Define local variables.
	float voltage;
	
	// Convert the ADC value to a voltage.
	//voltage = (5./1023)*ADC_value;
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
