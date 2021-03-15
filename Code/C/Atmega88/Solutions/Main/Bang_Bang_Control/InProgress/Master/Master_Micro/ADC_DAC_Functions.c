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


void get_sensor_data( struct int_array_struct * sensor_data_ptr )
{
	
	// Create a variable to temporarily store the ADC reads.
	volatile uint16_t adc_uint10_temp;
	volatile uint16_t adc_uint16_temp;
	
	// Initialize the sensor data structure length to zero.
	sensor_data_ptr->length = 0;
	
	// Read in from each multiplexer channel associated with a pressure sensor and store these values into an array.
	for (uint8_t i = 0; i < NUM_SENSORS_TOTAL; ++i)							// Iterate through each sensor...
	{
		// Set the multiplexer channel.
		set_multiplexer_channel( i );										// Set the current multiplexer channel.

		// Read from the ADC into a temporary integer.
		adc_uint10_temp = readADC( 0 );
		
		// Convert the ADC integer value into a temporary uint16.
		adc_uint16_temp = uint102uint16( adc_uint10_temp );
		
		// Store the sensor data ID, sensor data ADC uint16 value, and sensor data length values.
		sensor_data_ptr->IDs[i] = i + 1;									// Set the sensor data ID.
		sensor_data_ptr->values[i] = adc_uint16_temp;			// Read in from the current multiplexer channel.
		++sensor_data_ptr->length;											// Increase the sensor data array length counter by one.
	}
	
}


// Implement a function to retrieve the muscle index associated with a specific muscle ID.
uint8_t get_muscle_index( uint8_t muscle_ID )
{
	
	// Create a variable to store the associated muscle index.
	uint8_t k = 0;
	
	// Iterate through each of the muscles in the muscle info structure searching for a matching ID.
	while ( (k < NUM_FRONT_LEG_MUSCLES) && (!(muscle_ID == muscle_info[k].ID)) )
	{
		++k;
	}
	
	// Determine whether a matching index was found.
	if ( (k >= NUM_FRONT_LEG_MUSCLES) )
	{
		k = 255;
	}
	
	// Return the associated index.
	return k;
	
}


// Implement a function to update the muscle states on/off based on the associated command values.
void update_muscle_on_off_states( struct int_array_struct * command_data_ptr)
{
	
	// Define a variable to store the muscle info index associated with each command muscle id.
	uint8_t k2;
	
	// Set each of the muscle pin states on/off according to whether the command value exceeds a certain threshold.
	for (uint8_t k1 = 0; k1 < command_data_ptr->length; ++k1)						// Iterate through each of the commands...
	{
		// Retrieve the muscle info index associated with this command.
		k2 = get_muscle_index( command_data_ptr->IDs[k1] );
		
		// Determine whether a matching muscle index was found.
		if (!(k2 == 255))																// If a matching muscle index was found...
		{
			// Determine whether to set the pin associated with this muscle high or low based on whether the associated command value exceeds a certain threshold.
			if (command_data_ptr->values[k1] > activation_threshold)				// If the command value for this muscle exceeds the activation threshold...
			{
				
				// Set the pin state to high.
				//sbi(*(muscle_info[k2].port), muscle_info[k2].pin);					// Set the pin associated with this muscle high...
				set_pin_state( muscle_info[k2].port, muscle_info[k2].pin, 1 )
				
			}
			else
			{
				
				// Set the pin state to low.
				//cbi(*(muscle_info[k2].port), muscle_info[k2].pin);					// Set the pin associated with this muscle low...
				set_pin_state( muscle_info[k2].port, muscle_info[k2].pin, 0 )
				
			}
		}
	}
	
}


// Implement a temporary function to use the DAC as one of the muscle pins.
void use_dac_as_muscle_pin( struct int_array_struct * command_data_ptr )
{

	// Define local variables.
	uint8_t bCriticalMuscleFound = 0;
	uint8_t k = 0;

	// Determine whether the critical muscle is included in the command data.
	while ( (k < command_data_ptr->length) && (!bCriticalMuscleFound))
	{
		
		// If the command data matches the critical command data index.
		if (command_data_ptr->IDs[k] == 39)
		{
			
			// Set the critical muscle found flag to true.
			bCriticalMuscleFound = 1;
			
		}
		
		// Advance the counter variable.
		++k;
		
	}
		
	// Decrease the counter variable by one.
	--k;
	
	// Determine whether to write the dac low or high.
	if ((bCriticalMuscleFound) && (command_data_ptr->values[k] > activation_threshold))
	{
		
		// Turn the dac on to its maximum value.
		write2DAC(DAC_ON_VALUE);
		
	}
	else
	{
		
		// Turn the dac on to its minimum value.
		write2DAC(DAC_OFF_VALUE);
		
	}
	
}
	
	
// Implement a function to retrieve the slave index associated with a specific muscle ID.
uint8_t get_slave_index( uint8_t muscle_ID )
{
	
	// Create a variable to store the associated muscle index.
	uint8_t k = 0;
			
	// Iterate through each of the muscles in the muscle info structure searching for a matching ID.
	while ( (k < NUM_TOTAL_MUSCLES) && (!(muscle_ID == slave_info[k].muscle_ID)) )
	{
		++k;
	}
			
	// Determine whether a matching index was found.
	if ( (k >= NUM_TOTAL_MUSCLES) )
	{
		k = 255;
	}
			
	// Return the associated index.
	return k;
		
}

	