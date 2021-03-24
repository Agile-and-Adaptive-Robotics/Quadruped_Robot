// ADC & DAC Functions.

// This script implements functions for ADC and DAC.

// Include the associated header file.
#include "Master_Micro_Header.h"


// Implement a function to convert from a ADC value to a DAC value.
uint16_t ADC2DAC( uint16_t adc_value )
{
	
	// Define local variables.
	uint16_t dac_value;
	
	// Convert the ADC value to a DAC value.
	dac_value = uint102uint12( adc_value );
	
	// Constrain the DAC value to the desired range.
	if (dac_value > 4095)				// If the DAC value is greater than the maximum acceptable value...
	{
		dac_value = 4095;				// Set the DAC value to the maximum acceptable value.
	}
	else if (dac_value < 0)				// If the DAC value is less than the minimum acceptable value... 
	{
		dac_value = 0;					// Set the DAC value to the minimum acceptable value.
	}
	
	// Return the constrained DAC value.
	return dac_value;
	
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


// Implement a function to write to the DAC.
void write2DAC( uint16_t value_to_write )
{
	
	// Define local variables.
	uint8_t spi_data_0;
	uint8_t spi_data_1;
	
	// Convert the ADC data to a form that the DAC will recognize.
	spi_data_0 = 0x00;										// Zero spi_data_0.
	spi_data_0 = (value_to_write & 0x0F00) >> 8;			// Set up the first byte to write by mapping bits 8-11 to the lower 4 bit positions.
	spi_data_0 = spi_data_0 + 0b00110000;					// Now add the upper 4 DAC control bits.
	spi_data_1 = (value_to_write & 0xFF);					// Setup the second byte to write by mapping bits 0-7 to the lower 8 bit positions.

	// Write the ADC data to the DAC.
	cbi(PORTB, 2);								// Activate the chip - set chip select to zero.
	spi_write_uint8(spi_data_0);				// Write the first byte.
	spi_write_uint8(spi_data_1);  				// Write the second byte.
	sbi(PORTB, 2);								// Release the chip  - set chip select to one.
		
	// Cycle the LDAC.
	cbi(PORTB, 1);			// Set the LDAC low.
	_delay_ms(LDAC_DELAY);		// Wait the specified LDAC duration.
	sbi(PORTB, 1);			// Set the LDAC high.
	
}


// Implement a function to set the channel of an 8 channel multiplexer on an arbitrary port with arbitrary pins.
void set_multiplexer_channel_with_pins( unsigned char * port_num, uint8_t * pin_nums, uint8_t channel_num )
{
	
	// Determine the correct pin pattern to set to achieve this channel.
	switch ( channel_num )
	{
		case 0 :
			set_pin_state(port_num, pin_nums[0], 0);
			set_pin_state(port_num, pin_nums[1], 0);
			set_pin_state(port_num, pin_nums[2], 0);
			break;
		case 1 :
			set_pin_state(port_num, pin_nums[0], 1);
			set_pin_state(port_num, pin_nums[1], 0);
			set_pin_state(port_num, pin_nums[2], 0);
			break;
		case 2 :
			set_pin_state(port_num, pin_nums[0], 0);
			set_pin_state(port_num, pin_nums[1], 1);
			set_pin_state(port_num, pin_nums[2], 0);
			break;
		case 3 :
			set_pin_state(port_num, pin_nums[0], 1);
			set_pin_state(port_num, pin_nums[1], 1);
			set_pin_state(port_num, pin_nums[2], 0);
			break;
		case 4 :
			set_pin_state(port_num, pin_nums[0], 0);
			set_pin_state(port_num, pin_nums[1], 0);
			set_pin_state(port_num, pin_nums[2], 1);
			break;
		case 5 :
			set_pin_state(port_num, pin_nums[0], 1);
			set_pin_state(port_num, pin_nums[1], 0);
			set_pin_state(port_num, pin_nums[2], 1);
			break;
		case 6 :
			set_pin_state(port_num, pin_nums[0], 0);
			set_pin_state(port_num, pin_nums[1], 1);
			set_pin_state(port_num, pin_nums[2], 1);
			break;
		case 7 :
			set_pin_state(port_num, pin_nums[0], 1);
			set_pin_state(port_num, pin_nums[1], 1);
			set_pin_state(port_num, pin_nums[2], 1);
			break;
	}
	
}


// Implement a function to set the channel of a 64 channel multiplexer on the specified pins.
void set_multiplexer_channel( uint8_t channel_num )
{
	
	// Define local variables.
	uint8_t channel_num_lower;
	uint8_t channel_num_upper;
	
	// Determine which channel on the multiplexer to set.
	channel_num_lower = channel_num % 8;
	
	// Determine which multiplexer to select.
	channel_num_upper = floor(channel_num/8);
	
	// Set the multiplexer channel.
	set_multiplexer_channel_with_pins( multiplexer_port, multiplexer_pins1, channel_num_upper );
	set_multiplexer_channel_with_pins( multiplexer_port, multiplexer_pins2, channel_num_lower );
	
	// Sort delay to ensure that MUX is able to fully switch channels.
	_delay_ms(MUX_DELAY);
	
}

	
// Implement a function to determine the slave index associated with a specific muscle ID.
uint8_t get_slave_index_from_muscle_ID( struct slave_struct_array * slave_ptr, uint8_t muscle_ID )
{
	
	// Create a variable to store the slave index.
	uint8_t k = 0;
		
	// Determine which slave has a muscle ID that matches the muscle ID we want.
	while ( (k < slave_ptr->num_slaves) && (!(muscle_ID == slave_ptr->slave[k].muscle_ID)) )			// While we haven't gone through all of the slaves and we haven't found a match...
	{
		
		// Advance to the next slave.
		++k;
		
	}
		
	// Determine whether to set the slave index to an error value.
	if ( (k >= slave_ptr->num_slaves) )				// If the slave index number is greater than or equal to the number of slaves...
	{
		
		// Set the slave index to be 255.  We interpret this as an error value.
		k = 255;
		
	}
		
	// Return the slave index.
	return k;
	
}


// Implement a function to determine the slave index associated with a specific slave ID.
uint8_t get_slave_index_from_slave_ID( struct slave_struct_array * slave_ptr, uint8_t slave_ID )
{
	
	// Create a variable to store the slave index.
	uint8_t k = 0;
	
	// Determine which slave has a slave ID that matches the slave ID we want.
	while ( (k < slave_ptr->num_slaves) && (!(slave_ID == slave_ptr->slave[k].slave_ID)) )			// While we haven't gone through all of the slaves and we haven't found a match...
	{
		
		// Advance to the next slave.
		++k;
		
	}
	
	// Determine whether to set the slave index to an error value.
	if ( (k >= slave_ptr->num_slaves) )				// If the slave index number is greater than or equal to the number of slaves...
	{
		
		// Set the slave index to be 255.  We interpret this as an error value.
		k = 255;
		
	}
	
	// Return the slave index.
	return k;
	
}

