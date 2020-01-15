//Serial Communication Functions.
//This script implements functions for serial communication.

//Include the associated header file.
#include "Flow_Rate_Control_Valve_Header.h"

//Implement the USART putchar function.
void uart_putchar(char c, FILE *stream)
{
	if (c == '\n') uart_putchar('\r', stream);
	
	loop_until_bit_is_set(UCSR0A, UDRE0);
	UDR0 = c;
}

//Implement the USART getchar function.
unsigned char uart_getchar(void)
{
	while( !(UCSR0A & (1<<RXC0)) );
	return(UDR0);
}

//Implement a function that sends the serial communication startup byte sequence.
void serial_write_start_bytes( void )
{
	
	//Write the start up sequence to the serial port.
	for (int i = 0; i < window_size; ++i)
	{
		uart_putchar(0b11111111, stdout);
	}
	
}

//Implement a function that sends the serial communication ending byte sequence.
void serial_write_end_bytes( void )
{
	
	//Write the end sequence to the serial port.
	uart_putchar(0b00000000, stdout);
	
}

//Implement a function to serially write strings to matlab.
void serial_write_string2matlab( char mystring[] )
{

	//Write the start sequence to the serial port.
	serial_write_start_bytes();
	
	//Write out the string length.
	uart_putchar(strlen(mystring), stdout);
	
	//Write out the string.
	printf(mystring);
	
}

//Implement a function to serially write ints to matlab.
void serial_write_int2matlab( int myint )
{
	
	//Convert the integer into its high and low bytes.	
	int * int_bytes = int2lowhighbytes(myint);
	
	//Write the start sequence to the serial port.
	serial_write_start_bytes();
	
	//Write out the number of bytes to expect.
	uart_putchar(0b00000010, stdout);
	
	//Write out the low and high integer bytes.
	for (int k = 0; k < NUM_BYTES_PER_UINT16; ++k)
	{
		uart_putchar(int_bytes[k], stdout);
	}
	
	//Write out the end sequence to the serial port.
	serial_write_end_bytes();
	
	
}

//Implement a function to serially write an int array to matlab.
void serial_write_int_array2matlab( int myint_array[], int array_length )
{
	
	//Preallocate an array to store the low/high bytes of each integer.
	int * int_bytes;
	
	//Write the start sequence to the serial port.
	serial_write_start_bytes();
	
	//Write the number of bytes to expect.
	uart_putchar(NUM_BYTES_PER_UINT16*array_length, stdout);								//This assumes that the array length is less than 128.
	
	//Write out each integer low & high bytes.
	for (int k1 = 0; k1 < array_length; ++k1)
	{
		
		//Convert the integer into its high and low bytes.
		int_bytes = int2lowhighbytes( myint_array[k1] );
		
		//Write out the low and high integer bytes.
		for (int k2 = 0; k2 < NUM_BYTES_PER_UINT16; ++k2)
		{
			uart_putchar(int_bytes[k2], stdout);
		}
		
	}
	
	//Write out the end sequence to the serial port.
	serial_write_end_bytes();
	
}

//Implement a function to serially write a single array to matlab.
void serial_write_single_array2matlab( float myfloat_array[], int array_length )
{
	
	//Preallocate an array to store the bytes of each float.
	unsigned char float_bytes[NUM_BYTES_PER_FLOAT];
	
	//Write the start sequence to the serial port.
	serial_write_start_bytes();
	
	//Write the number of bytes to expect.
	uart_putchar(NUM_BYTES_PER_FLOAT*array_length, stdout);								//This assumes that the array length is less than 128.
	
	//Write out the float bytes.
	for (int k1 = 0; k1 < array_length; ++k1)
	{
		//Convert the current float to bytes.
		float2byte_array( myfloat_array[k1], float_bytes );

		//Write out the float bytes.
		for (int k2 = 0; k2 < NUM_BYTES_PER_FLOAT; ++k2)
		{
			uart_putchar(float_bytes[k2], stdout);
		}

	}
	
	//Write out the end sequence to the serial port.
	serial_write_end_bytes();
	
}

//Implement a function to serially write sensor data singles to Matlab.
void serial_write_sensor_data_ints2matlab( struct int_array_struct * sensor_data_ptr )
{
	
	//Preallocate an array to store the bytes of each uint16.
	volatile unsigned char int_bytes_temp[NUM_BYTES_PER_UINT16];
	volatile unsigned char id_byte_temp;
	uint16_t check_sum;
	unsigned char check_sum_mod;
	
	//Write the start sequence to the serial port.
	serial_write_start_bytes();
	
	//Increase the check sum.
	check_sum = 2*255;
	
	//Write the number of muscle ID / value pairs to expect.
	uart_putchar(sensor_data_ptr->length, stdout);								//This assumes that the array length is less than 255.
	
	//Increase the check sum.
	check_sum += sensor_data_ptr->length;
	
	//Write out the bytes for each sensor ID and value.
	for (int k1 = 0; k1 < sensor_data_ptr->length; ++k1)
	{
		//Convert the current integer to bytes.
		int2byte_array( sensor_data_ptr->values[k1], int_bytes_temp );

		//Retrieve the current ID byte.
		id_byte_temp = sensor_data_ptr->IDs[k1];

		//Write out the muscle id.
		uart_putchar(id_byte_temp, stdout);

		//Advance the check sum.
		check_sum += id_byte_temp;

		//Write out the value bytes.
		for (int k2 = 0; k2 < NUM_BYTES_PER_UINT16; ++k2)
		{
			//Write out the value bytes.
			uart_putchar(int_bytes_temp[k2], stdout);
			
			//Advance thhe check sum.
			check_sum += int_bytes_temp[k2];
		}
		
	}
	
	//Roll over the check sum.
	check_sum_mod = check_sum % 256;
	
	//Write out the check sum.
	uart_putchar(check_sum_mod, stdout);
	
	//Write out the end sequence to the serial port.
	//serial_write_end_bytes();
	
}

//Implement a function to serially write sensor data singles to Matlab.
void serial_write_sensor_data_singles2matlab( struct single_array_struct * sensor_data_ptr )
{
	
	//Preallocate an array to store the bytes of each float.
	unsigned char float_bytes_temp[NUM_BYTES_PER_FLOAT];
	unsigned char id_byte_temp;
	
	//Write the start sequence to the serial port.
	serial_write_start_bytes();
	
	//Write the number of muscle ID / value pairs to expect.
	uart_putchar(sensor_data_ptr->length, stdout);								//This assumes that the array length is less than 255.
	
	//Write out the bytes for each muscle ID and value.
	for (int k1 = 0; k1 < sensor_data_ptr->length; ++k1)
	{
		//Convert the current float to bytes.
		float2byte_array( sensor_data_ptr->values[k1], float_bytes_temp );

		//Retrieve the current ID byte.
		id_byte_temp = sensor_data_ptr->IDs[k1];

		//Write out the muscle id.
		uart_putchar(id_byte_temp, stdout);

		//Write out the float bytes.
		for (int k1 = 0; k1 < NUM_BYTES_PER_FLOAT; ++k1)
		{
			uart_putchar(float_bytes_temp[k1], stdout);
		}
		

	}
	
	//Write out the end sequence to the serial port.
	serial_write_end_bytes();
	
}

//Implement a function to search the buffer for the start up sequence.
void wait_for_start_sequence( void )
{
	
	//Define local variables.
	unsigned char start_sequence_detected = 0;
	unsigned char match_found;
	unsigned char byte_window[window_size];
		
	//Preallocate the byte window to be all zeros.
	for (int k = 0; k < window_size; ++k)
	{
		byte_window[k] = 0;
	}
		
	//Search through the buffer until the start sequence is encountered.
	while (!start_sequence_detected)				//While the start sequence has not been detected...
	{
		//Shift all of the values in the byte window up an entry.
		for ( int k = window_size; k > 0; --k)						//Iterate through each of the entries in the byte window...
		{
			byte_window[k] = byte_window[k - 1];					//Shift the byte window values up by one index.
		}
			
		//Read in the next entry in the buffer.
		byte_window[0] = uart_getchar();
			
		//Set the match found flag to true.
		match_found = 1;
			
		//Determine whether the byte window matches the start up sequence.
		for ( int k = 0; k < window_size; ++k)
		{
			match_found = match_found & (byte_window[k] == 255);
		}
			
		//Set whether the start sequence was detected.
		start_sequence_detected = match_found;
			
	}
	
}

//Implement a function to read in an integer from matlab.
unsigned int serial_read_matlab_int( void )
{

	//Define local variables.
	unsigned char low_byte;
	unsigned char high_byte;
	unsigned int myint;

	//Wait for the start sequence to be received.
	wait_for_start_sequence();
	
	//Read in the low byte.
	low_byte = uart_getchar();
	
	//Read in the high byte.
	high_byte = uart_getchar();
	
	//Convert the bytes into an integer.
	myint = lowhighbytes2int(low_byte, high_byte);
	
	//Return the integer.
	return myint;
	
}

//Implement a function to read in an integer array from Matlab.
struct int_struct serial_read_matlab_int_array( void )
{
	
	//Define local variables.
	struct int_struct myint_struct;
	unsigned char num_ints;							//This assumes that the number of integers being sent is < 128.
	unsigned char low_byte;
	unsigned char high_byte;
	static unsigned int array[24];					//Define an array to store the incoming integers.
	
	//Wait for the start sequence to be received.
	wait_for_start_sequence();
	
	//Read in the number of integers to expect.
	num_ints = uart_getchar();
	
	//Read in each pair of low and high bytes and convert them to integers.
	for ( int k = 0; k < num_ints; ++k)
	{
		//Read in the low and high bytes.
		low_byte = uart_getchar();
		high_byte = uart_getchar();
		
		//Convert these bytes to an integer.
		array[k] = lowhighbytes2int(low_byte, high_byte);
	}
	
	//Store the integer array and number of bytes into an int_array.
	myint_struct.array = array;
	myint_struct.length = num_ints;
	
	//Return the int_array.
	return myint_struct;
}

//Implement a function to read in an single array from Matlab.
struct float_struct serial_read_matlab_single_array( void )
{
	//Define local variables.
	struct float_struct myfloat_struct;
	unsigned char num_singles;					//This assumes that the number of singles being sent is < 128.
	static float array[24];					//Define an array to store the incoming integers.
	static unsigned char float_bytes[NUM_BYTES_PER_FLOAT];
	
	//Wait for the start sequence to be received.
	wait_for_start_sequence();
	
	//Read in the number of singles to expect.
	num_singles = uart_getchar();
	
	//Read in each single.
	for ( int k1 = 0; k1 < num_singles; ++k1)
	{
		//Read in the float bytes.
		for ( int k2 = 0; k2 < NUM_BYTES_PER_FLOAT; ++k2)
		{
			float_bytes[k2] = uart_getchar();
		}
		
		//Store this byte array into a float.
		array[k1] = byte_array2float(float_bytes);
		
	}
	
	//Store the integer array and number of bytes into an int_array.
	myfloat_struct.array = array;
	myfloat_struct.length = num_singles;
	
	//Return the int_array.
	return myfloat_struct;
}

//Implement a function to read matlab muscle activation uint16s.
void serial_read_matlab_muscle_command_ints( struct int_array_struct * command_data_ptr )
{
	
	//Define local variables.
	unsigned char num_commands;										//This assumes that the number of ints being sent is <255.
	static unsigned char int_bytes[NUM_BYTES_PER_UINT16];

	//Wait for the start sequence to be received.
	wait_for_start_sequence();
	
	//Read in the number of commands to expect.
	num_commands = uart_getchar();
	
	//Read in each single.
	for ( int k1 = 0; k1 < num_commands; ++k1)
	{
		//Read in the ID byte.
		command_data_ptr->IDs[k1] = uart_getchar();
		
		//Read in the float bytes.
		for (int k2 = 0; k2 < NUM_BYTES_PER_UINT16; ++k2)
		{
			int_bytes[k2] = uart_getchar();
		}
		
		//Store this byte array into a uint16.
		command_data_ptr->values[k1] = byte_array2int(int_bytes);
	}
	
	//Store the number of commands into the structure length field.
	command_data_ptr->length = num_commands;

}

//Implement a function to read matlab muscle activation singles.
void serial_read_matlab_muscle_command_singles( struct single_array_struct * command_data_ptr )
{
	
	//Define local variables.
	unsigned char num_commands;					//This assumes that the number of singles being sent is <255.
	static unsigned char float_bytes[NUM_BYTES_PER_FLOAT];

	//Wait for the start sequence to be received.
	wait_for_start_sequence();
	
	//Read in the number of commands to expect.
	num_commands = uart_getchar();
	
	//Read in each single.
	for ( int k1 = 0; k1 < num_commands; ++k1)
	{
		//Read in the ID byte.
		command_data_ptr->IDs[k1] = uart_getchar();
		
		//Read in the float bytes.
		for ( int k2 = 0; k2 < NUM_BYTES_PER_FLOAT; ++k2)
		{
			float_bytes[k2] = uart_getchar();
		}
		
		//Store this byte array into a float.
		command_data_ptr->values[k1] = byte_array2float(float_bytes);
	}
	
	//Store the number of commands into the structure length field.
	command_data_ptr->length = num_commands;

}


