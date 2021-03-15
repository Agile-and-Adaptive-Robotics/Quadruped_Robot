// ADC & DAC Functions.
// This script implements functions for ADC and DAC.

// Include the associated header file.
#include "Slave_Micro_Header.h"

// Implement the SPI write function.
void spi_write( uint8_t spi_data )
{
	SPDR = spi_data;
	while ((SPSR & (1<<SPIF))==0);	// Wait until the data transfer is complete.
}

// Implement the SPI read function.
uint8_t spi_read( void )
{
	// Create a variable to store the SPI data.
	unsigned char spi_data;
	
	// Wait for a SPI data transfer to be complete.
	while (!(SPSR & (1<<SPIF)));
	
	// Read in the SPI data.
	spi_data = SPDR;
	
	// Return the SPI data.
	return spi_data;
	
}

// Implement a function to perform SPI read and write.
uint8_t spi_read_write( uint8_t spi_data )
{
	
	// Write the SPI data.
	SPDR = spi_data;
	
	// Wait for a SPI data transfer to be complete.
	while (!(SPSR & (1<<SPIF)));
	
	// Read in the SPI data.
	spi_data = SPDR;
	
	// Return the SPI data.
	return spi_data;

}

// Implement a function to read from an ADC channel.
uint16_t readADC( uint8_t channel_num )
{
	// Determine the correct bit pattern to send to the ADMUX register based on the desired channel number.
	switch ( channel_num )
	{
	case 0 :
		ADMUX  = 0b00000000;
		break;
	case 1 :
		ADMUX  = 0b00000001;
		break;
	case 2 :
		ADMUX  = 0b00000010;
		break;
	case 3 :
		ADMUX  = 0b00000011;
		break;
	case 4 :
		ADMUX  = 0b00000100;	
		break;
	case 5 :
		ADMUX  = 0b00000101;
		break;
	case 6 :
		ADMUX  = 0b00000110;	
		break;
	case 7 :
		ADMUX  = 0b00000111;	
		break;
	}
	
	// Retrieve the current ADC value at the specified channel.
	ADCSRA = ADCSRA | 0b01000000;						// Start AD conversion.  Sets bit 7 to 1 and leaves all other bits the same.
	while ((ADCSRA & 0b01000000) == 0b01000000);		// Wait while AD conversion is executed.  Waits until bit 7 is set to 1.
	return ADCW;										// [0-1023] ADC value.
	
}

	