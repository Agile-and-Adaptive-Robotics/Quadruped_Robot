//Conversion Functions.
//This script implements microcontroller data type conversion functions.

//Include the associated header file.
#include "Flow_Rate_Control_Valve_Header.h"

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
	
	//Assign each byte of the float individually.
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
	ADCuint16 = (65535/910)*ADC_value;
	
	//Return the uint16 value associated with the ADC value.
	return ADCuint16;
	
}

char get_char_bits(char mychar, char no_of_bits)
{
    return mychar & ((no_of_bits << 1) - 1);
}
