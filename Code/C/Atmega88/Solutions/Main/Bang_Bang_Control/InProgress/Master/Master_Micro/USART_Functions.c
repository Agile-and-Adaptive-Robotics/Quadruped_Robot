// Serial Communication Functions.

// This script implements functions for serial communication.

// Include the associated header file.
#include "Master_Micro_Header.h"



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



// ---------- USART INITIATION & TERMINATION FUNCTIONS ----------

// Implement a function that sends the serial communication startup byte sequence.
void usart_write_start_bytes( FILE * stream )
{
	
	// Create an array to store the start bytes.
	uint8_t write_array[START_WINDOW_SIZE];
	
	// Create the start bytes.
	for ( uint8_t k = 0; k < START_WINDOW_SIZE; ++k )					// Iterate through each of the start window bytes...
	{
		
		// Create this start byte.
		write_array[k] = 255;
		
	}
	
	// Write out the start bytes.
	usart_write_uint8_array( write_array, START_WINDOW_SIZE, stream );
	
}


// Implement a function that sends the serial communication ending byte sequence.
void usart_write_end_bytes( FILE * stream )
{
	
	// Create an array to store the end bytes.
	uint8_t write_array[END_WINDOW_SIZE];
		
	// Create the start bytes.
	for ( uint8_t k = 0; k < END_WINDOW_SIZE; ++k )					// Iterate through each of the start window bytes...
	{
			
		// Create this start byte.
		write_array[k] = 0;
			
	}
		
	// Write out the start bytes.
	usart_write_uint8_array( write_array, END_WINDOW_SIZE, stream );
	
}


// Implement a function to search the buffer for the start up sequence.
void wait_for_start_sequence( void )
{
	
	// Warning: Once this function has been initiated, the microcontroller will constantly scan the usart input buffer looking for the start sequence.  If the start sequence never comes, the microcontroller will be stuck waiting for the start sequence indefinitely.
	// If misalignment occurs between Matlab and the master, this function allows the master to scan through the usart input buffer to find the next start sequence.  i.e., even if one sentence is missed, Matlab and the master may become realigned on future communication attempts (ignoring any misaligned sentences).
	
	// Disable global interrupts.
	cli();
	
	// Define local variables.
	uint8_t start_sequence_detected = 0;
	uint8_t match_found;
	uint8_t byte_window[START_WINDOW_SIZE];
	
	// Preallocate the byte window to be all zeros.
	for (uint8_t k = 0; k < START_WINDOW_SIZE; ++k)
	{
		byte_window[k] = 0;
	}
	
	// Search through the buffer until the start sequence is encountered.
	while (!start_sequence_detected)				// While the start sequence has not been detected...
	{
		// Shift all of the values in the byte window up an entry.
		for ( uint8_t k = START_WINDOW_SIZE; k > 0; --k)						// Iterate through each of the entries in the byte window...
		{
			byte_window[k] = byte_window[k - 1];					// Shift the byte window values up by one index.
		}
		
		// Read in the next entry in the buffer.
		byte_window[0] = usart_read_uint8(  );
		
		// Set the match found flag to true.
		match_found = 1;
		
		// Determine whether the byte window matches the start up sequence.
		for ( uint8_t k = 0; k < START_WINDOW_SIZE; ++k)
		{
			match_found = match_found & (byte_window[k] == 255);
		}
		
		// Set whether the start sequence was detected.
		start_sequence_detected = match_found;
		
	}
	
	// Enable global interrupts.
	sei();
	
}



// ---------- HIGH LEVEL USART FUNCTIONS ----------

// Implement a function to read desired pressures from Matlab via USART.
void usart_read_matlab_desired_pressures( struct slave_struct_array * slave_ptr )
{
	
	// We assume that Matlab sends byte arrays with the following structure: {start_btyes, num_packets, ID1, Low1, High1, ..., IDn, Lown, Highn, end_bytes}.
	// Ex: {255 255, 3, 39, 0, 0, 42, 0, 0, 44, 0, 0, 0} = Set muscles 39, 42, and 44 to have zero desired pressure.
	
	// Define local variables.
	uint8_t num_commands;
	uint8_t muscle_ID;
	uint8_t slave_index;
	uint8_t desired_pressure_bytes[NUM_BYTES_PER_UINT16];

	// Wait for the start sequence to be received.
	wait_for_start_sequence();
	
	// Read in the number of commands to expect.
	num_commands = usart_read_uint8();
	
	// Read in each command packet from Matlab and store the desired pressure in the correct slave data structure.
	for ( uint8_t k1 = 0; k1 < num_commands; ++k1)				// Iterate through each of the command packets...
	{
		
		// Read in the muscle ID associated with this packet.
		muscle_ID = usart_read_uint8();
		
		// Read in the desired pressure value bytes.
		for (uint8_t k2 = 0; k2 < NUM_BYTES_PER_UINT16; ++k2)			// Iterate through each of the desired pressure value bytes...
		{
			
			// Read in this desired pressure byte.
			desired_pressure_bytes[k2] = usart_read_uint8();
			
		}
		
		// Retrieve the slave index associated with this muscle ID.		
		slave_index = get_slave_index_from_muscle_ID( slave_ptr, muscle_ID );
		
		// Store the desired pressure into the slave data structure.
		slave_ptr->slave[slave_index].desired_pressure = byte_array2uint16( desired_pressure_bytes );
		
	}

}


// Implement a function to write sensor data to Matlab via USART.
void usart_write_matlab_sensor_data( struct slave_struct_array * slave_ptr, FILE * stream )
{
	
	// Define local variables.
	uint8_t write_array[NUM_BYTES_PER_UINT16];
	uint16_t check_sum;						// Warning: A uint16 check sum can handle at least 257 bytes before overflowing, which we should be under.  If we go above 257 bytes per message, we need to add overflow handling.  The 257 limit assumes that each byte is maximally large (i.e., that all of the bytes are 255).
	uint8_t check_sum_mod;

	// Write the start bytes.
	usart_write_start_bytes( stream );
	
	// Advance the check sum.
	check_sum = 2*255;
	
	// Write the number of sensor data packets to expect (one per slave).
	usart_write_uint8( slave_ptr->num_slaves, stream );

	// Advance the check sum.
	check_sum += slave_ptr->num_slaves;
	
	// Write the data packets associated with each sensor.
	for ( uint16_t k1 = 0; k1 < slave_ptr->num_slaves; ++k1 )				// Iterate through each of the slaves...
	{
		
		// Write the slave ID associated with this packet.
		usart_write_uint8( slave_ptr->slave[k1].slave_ID, stream );
		
		// Advance the check sum.
		check_sum += slave_ptr->slave[k1].slave_ID;
		
		
		// Convert the first pressure sensor value into its constituent bytes.
		uint162byte_array( slave_ptr->slave[k1].pressure_sensor_value1, write_array );
		
		// Write the first pressure sensor value bytes to Matlab.
		usart_write_uint8_array( write_array, NUM_BYTES_PER_UINT16, stream );
		
		// Advance the check sum.
		check_sum += write_array[0] + write_array[1];
		
		
		// Convert the second pressure sensor value into its constituent bytes.
		uint162byte_array( slave_ptr->slave[k1].pressure_sensor_value2, write_array );
				
		// Write the second pressure sensor value bytes to Matlab.
		usart_write_uint8_array( write_array, NUM_BYTES_PER_UINT16, stream );
				
		// Advance the check sum.
		check_sum += write_array[0] + write_array[1];
		
		
		// Convert the joint value into its constituent bytes.
		uint162byte_array( slave_ptr->slave[k1].joint_value, write_array );
				
		// Write the joint value bytes to Matlab.
		usart_write_uint8_array( write_array, NUM_BYTES_PER_UINT16, stream );
				
		// Advance the check sum.
		check_sum += write_array[0] + write_array[1];
		
	}
	
	// Roll over the check sum.
	check_sum_mod = check_sum % 256;
		
	// Write out the check sum.
	usart_write_uint8( check_sum_mod, stream );
	
}

