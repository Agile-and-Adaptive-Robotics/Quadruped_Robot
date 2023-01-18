// Serial Communication Functions.

// This script implements functions for serial communication.

// Include the associated header file.
#include "Slave_Micro_Header.h"



// ---------- USART UINT8 READ WRITE FUNCTIONS ----------

// Implement a function to read a uint8 from Matlab via USART.
uint8_t usart_read_uint8( void )
{
	
	// UCSRnA = USART Control and Status Register n A (e.g., UCSR0A = USART Control and Status Register 0 A).  Contains information relevant to USART operation, such as whether transmission / reception has been completed.
	// RXCn = The 7th bit of UCSRnA (e.g., RXC0 = 7th bit of UCSR0A).  Read only. 0 = No unread data in the receive buffer, 1 = Unread data in the recieve buffer.
	// UDRn = USART I/O Data Register n (e.g., UDR0 = USART I/O data Register 0). Read / Write.  Reading returns the contents of the Receive Data Buffer Register (RXB).  Writing sets the value of the Transmit Data Buffer Register (TXB).
	
	// Ensure that there is unread data to read before we attempt to read it.
	//while( !(UCSR0A & (1 << RXC0)) );
	loop_until_bit_is_set(UCSR0A, RXC0);			// I think that this does the same as the above line, but I haven't tested it out...

	// Read the received usart uint8.
	return UDR0;
	
}


// Implement a function to write a uint8 to Matlab via USART.
void usart_write_uint8( uint8_t write_value, FILE * stream )
{
	
	// UCSRnA = USART Control and Status Register n A (e.g., UCSR0A = USART Control and Status Register 0 A).  Contains information relevant to USART operation, such as whether transmission / reception has been completed.
	// UDREn = USART Data Register Empty (e.g., UDRE0 = USART Data Register Empty 0).  0 = The register is not empty and therefore not ready to be written to, 1 = The register is empty and therefore ready to be written to.
	
	// Determine whether to replace the uint8 we are writing.
	if (write_value == '\n')					// If the write value uint8 represents a new line character...
	{
		
		// Replace the new line character with a carriage return character.
		usart_write_uint8( '\r', stream );
		
	}
	
	// Ensure that the USART data register is ready to be written to.
	loop_until_bit_is_set(UCSR0A, UDRE0);
	
	// Write the uint8 to the
	UDR0 = write_value;
	
}



// ---------- USART UINT8 ARRAY READ WRITE FUNCTIONS ----------

// Implement a function to read a uint8 array from Matlab via USART.
void usart_read_uint8_array( uint8_t read_array[], uint8_t num_uint8s_to_read )
{
	
	// Read the uint8 array from Matlab via USART.
	for ( uint8_t k = 0; k < num_uint8s_to_read; ++k )				// Iterate through each of the uint8s...
	{
		
		// Read this uint8 from Matlab.
		read_array[k] = usart_read_uint8(  );
		
	}
	
}


// Implement a function to write a uint8 array to Matlab via USART.
void usart_write_uint8_array( uint8_t write_array[], uint8_t num_uint8s_to_write, FILE * stream )
{
	
	// Write each uint8 via USART.
	for ( uint8_t k = 0; k < num_uint8s_to_write; ++k )				// Iterate through each uint8 to write...
	{
			
		// Write the current uint8 via SPI.
		usart_write_uint8( write_array[k], stream );
			
	}
	
}



// ---------- USART UINT16 READ WRITE FUNCTIONS ----------

// Implement a function to read a uint16 from Matlab via USART.
uint16_t usart_read_uint16( void )
{
	
	// Define an array to store the uint8s.
	uint8_t read_array[NUM_BYTES_PER_UINT16];
	
	// Read the uint8 array from Matlab via USART.
	usart_read_uint8_array( read_array, NUM_BYTES_PER_UINT16  );
	
	// Convert the uint8 bytes received from Matlab to a uint16.
	uint16_t value_received = byte_array2uint16( read_array );
	
	// Return the received uint16.
	 return value_received;
	
}


// Implement a function to write a uint16 to Matlab via USART.
void usart_write_uint16( uint16_t write_value, FILE * stream )
{
	
	// Create an array to store the uint16 bytes.
	uint8_t write_array[NUM_BYTES_PER_UINT16];
	
	// Convert the uint16 into its constituent bytes.
	uint162byte_array( write_value, write_array );
	
	// Write the bytes to Matlab.
	usart_write_uint8_array( write_array, NUM_BYTES_PER_UINT16, stream );
	
}

