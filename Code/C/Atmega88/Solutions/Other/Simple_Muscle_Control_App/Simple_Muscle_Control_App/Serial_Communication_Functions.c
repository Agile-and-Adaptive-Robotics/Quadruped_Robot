//Serial Communication Functions.
//This script implements functions for serial communication.

//Include the associated header file.
#include "Simple_Muscle_Control_App_Header.h"

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
	uart_putchar(0b11111111, stdout);
	uart_putchar(0b11111111, stdout);
	//uart_putchar(0b11111111, stdout);
	//uart_putchar(0b11111111, stdout);
	
}

//Implement a function that sends the serial communication ending byte sequence.
void serial_write_end_bytes( void )
{
	
	//Write the end sequence to the serial port.
	uart_putchar(0b00000000, stdout);
	
}

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
	uart_putchar(int_bytes[0], stdout);
	uart_putchar(int_bytes[1], stdout);
	
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
	uart_putchar(2*array_length, stdout);								//This assumes that the array length is less than 128.
	
	//Write out each integer low & high bytes.
	for (int i = 0; i < array_length; ++i)
	{
		
		//Convert the integer into its high and low bytes.
		int_bytes = int2lowhighbytes( myint_array[i] );
		
		//Write out the low and high integer bytes.
		uart_putchar(int_bytes[0], stdout);
		uart_putchar(int_bytes[1], stdout);
		
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

//Implement a function to read in an integer array from matlab.
struct int_array serial_read_matlab_int_array( void )
{
	
	//Define local variables.
	struct int_array myint_array;
	unsigned char num_ints;							//This assumes that the number of integers being sent is < 128.
	unsigned char low_byte;
	unsigned char high_byte;
	static unsigned int array[128];					//Define an array to store the incoming integers.
	
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
	myint_array.array = array;
	myint_array.length = num_ints;
	
	//Return the int_array.
	return myint_array;
}
