//SPI Functions.
//This script implements functions for SPI communication.

//Include the associated header file.
#include "Master_Micro_Testing_Header.h"

//Implement the SPI write function.
void spi_write(unsigned char spi_data)
{
	SPDR = spi_data;
	while ((SPSR & (1<<SPIF))==0);	//Wait until the data transfer is complete.
}

//Implement the SPI read function.
unsigned char spi_read( void )
{
	//Create a variable to store the SPI data.
	unsigned char spi_data;
	
	//Wait for a SPI data transfer to be complete.
	while (!(SPSR & (1<<SPIF)));
	
	//Read in the SPI data.
	spi_data = SPDR;
	
	//Return the SPI data.
	return spi_data;
	
}

//Implement a function to perform SPI read and write.
unsigned char spi_read_write(unsigned char spi_data)
{
	
	//Write the SPI data.
	SPDR = spi_data;
	
	//Wait for a SPI data transfer to be complete.
	while (!(SPSR & (1<<SPIF)));
	
	//Read in the SPI data.
	spi_data = SPDR;
	
	//Return the SPI data.
	return spi_data;

}

//Implement a function to pass an integer from the Master microcontroller to a Slave microcontroller via SPI.
void write2slave( uint16_t value_to_write, uint8_t slave_num )
{
	
	//Define local variables.
	uint8_t spi_byte_low;
	uint8_t spi_byte_high;
	uint8_t dummy_spi_byte;
	
	//Convert the ADC value to SPI bytes.
	spi_byte_low = (value_to_write & 0xFF);					//Retrieve the lower byte from the value to write.
	spi_byte_high = (value_to_write & 0x0F00) >> 8;			//Retrieve the upper byte from the value to write.

	//Set the multiplexer channel so that we can perform a slave select for Micro-Micro SPI.
	set_multiplexer_channel( slave_num + 37 );

	//Re-establish control over the slave select pin.
	DDRB |= (1 << 0);						//Ensure the the SS pin is set to output.

	//Pull the slave select pin low to initiate SPI communication.
	cbi(PORTB, 0);
		
	//Write the SPI byte to the slave.
	//dummy_spi_byte = spi_read_write(0);
	//dummy_spi_byte = spi_read_write(255);
	dummy_spi_byte = spi_read_write(spi_byte_low);
	dummy_spi_byte = spi_read_write(spi_byte_high);
		
	//Pull the slave select pin high to end SPI communication.
	sbi(PORTB, 0);
		
	//Relinquish control of the slave select pin.
	DDRB &= ~(1 << 0);					//Set the SS pin to input.
	
}

void WriteCommandData2Slaves( struct int_array_struct * command_data_ptr )
{

	//Define local variables.
	uint8_t k2;						//Index in the slave info structure array associated with the current muscle ID.

	//Write the command data to the appropriate slave microcontroller.
	for (uint8_t k1; k1 < command_data_ptr->length; ++k1)
	{
		
		//Retrieve the muscle index.
		k2 = GetMuscleIndex( command_data_ptr->IDs[k1] );
		
		//Write to the appropriate slave.
		if (!(k2 == 255))																	//If we detected a valid muscle ID...
		{
			
			//Write the corresponding value to the associated slave microcontroller.
			write2slave( command_data_ptr->values[k1], slave_info[k2].slave_num );

		}
		
	}
	
}

