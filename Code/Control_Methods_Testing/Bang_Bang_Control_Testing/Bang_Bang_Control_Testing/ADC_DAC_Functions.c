//ADC & DAC Functions.
//This script implements functions for ADC and DAC.

//Include the associated header file.
#include "Bang_Bang_Control_Testing_Header.h"

//Implement a function to set a pin state.
void set_pin_state( unsigned char * port_num, unsigned char pin_num, unsigned char pin_state)
{
	//Determine whether to set the pin low or high.
	if (pin_state)										//If the desired pin state is high...
	{
		sbi(*port_num, pin_num);							//Set the pin state high.
	}
	else
	{
		cbi(*port_num, pin_num);							//Set the pin state low.
	}

}

//Implement the SPI write_read function.
void spi_write_read(unsigned char spi_data)
{
	SPDR = spi_data;
	while ((SPSR & (1<<SPIF))==0);	//Wait until the data transfer is complete.
}

//Implement a function to read from an ADC channel.
unsigned int readADC( unsigned int channel_num )
{
	//Determine the correct bit pattern to send to the ADMUX register based on the desired channel number.
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
	
	//Retrieve the current ADC value at the specified channel.
	ADCSRA = ADCSRA | 0b01000000;						// Start AD conversion.  Sets bit 7 to 1 and leaves all other bits the same.
	while ((ADCSRA & 0b01000000) == 0b01000000);		// Wait while AD conversion is executed.  Waits until bit 7 is set to 1.
	return ADCW;										//[0-1023] ADC value.
	
}

//Implement a function to write to the DAC.
void write2DAC(unsigned int value_to_write)
{
	
	//Define local variables.
	unsigned char			spi_data_0;
	unsigned char			spi_data_1;
	
	//Convert the ADC data to a form that the DAC will recognize.
	spi_data_0 = 0x00;										//Zero spi_data_0.
	spi_data_0 = (value_to_write & 0x0F00) >> 8;			//Set up the first byte to write by mapping bits 8-11 to the lower 4 bit positions.
	spi_data_0 = spi_data_0 + 0b00110000;					//Now add the upper 4 DAC control bits.
	spi_data_1 = (value_to_write & 0xFF);					//Setup the second byte to write by mapping bits 0-7 to the lower 8 bit positions.

	//Write the ADC data to the DAC.
	cbi(PORTB,0);								// Activate the chip - set chip select to zero
	spi_write_read(spi_data_0);					// Write/Read first byte
	spi_write_read(spi_data_1);  				// Write/Read second byte
	sbi(PORTB,0);								// Release the chip  - set chip select to one
		
	//Cycle the LDAC.
	cbi(PORTB,1);			//Set the LDAC low.
	_delay_ms(0.0001);		//Wait the specified LDAC duration.
	sbi(PORTB,1);			//Set the LDAC high.
	
}

//Implement a function to set the channel of an 8 channel multiplexer on an arbitrary port with arbitrary pins.
void set_multiplexer_channel_with_pins( unsigned char * port_num, unsigned char * pin_nums, unsigned char channel_num )
{
	
	//Determine the correct pin pattern to set to achieve this channel.
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

//Implement a function to set the channel of a 64 channel multiplexer on the specified pins.
void set_multiplexer_channel( unsigned char channel_num )
{
	
	//Define local variables.
	unsigned char channel_num_lower;
	unsigned char channel_num_upper;
	
	//Determine which channel on the multiplexer to set.
	channel_num_lower = channel_num % 8;
	
	//Determine which multiplexer to select.
	channel_num_upper = floor(channel_num/8);
	
	//Set the multiplexer channel.
	set_multiplexer_channel_with_pins( multiplexer_port, multiplexer_pins1, channel_num_upper );
	set_multiplexer_channel_with_pins( multiplexer_port, multiplexer_pins2, channel_num_lower );
	
}

void GetSensorData( struct int_array_struct * sensor_data_ptr )
{
	
	//Create a variable to temporarily store the ADC reads.
	volatile unsigned int adc_int_temp;
	volatile uint16_t adc_uint16_temp;
	
	//Initialize the sensor data structure length to zero.
	sensor_data_ptr->length = 0;
	
	//Read in from each multiplexer channel associated with a pressure sensor and store these values into an array.
	for (int i = 0; i < num_sensors_total; ++i)							//Iterate through each sensor...
	{
		//Set the multiplexer channel.
		set_multiplexer_channel( i );										//Set the current multiplexer channel.
		//set_multiplexer_channel( 0 );										//Set the current multiplexer channel.
		
		//Wait a short amount of time to ensure that the multiplexer channel switched successfully.
		_delay_ms(0.0005);													//Short delay to ensure that the multiplexer channel has time to switch before proceeding.
		//_delay_ms(5);													//Short delay to ensure that the multiplexer channel has time to switch before proceeding.
		
		//Read from the ADC into a temporary integer.
		adc_int_temp = readADC( 0 );
		
		//if (adc_int_temp > 1023)
		//{
			//sensor_data_ptr->length = 1;
		//}
		
		//Convert the ADC integer value into a temporary uint16.
		adc_uint16_temp = ADC2uint16( adc_int_temp );
		
		//Store the sensor data ID, sensor data ADC uint16 value, and sensor data length values.
		sensor_data_ptr->IDs[i] = i + 1;									//Set the sensor data ID.
		sensor_data_ptr->values[i] = adc_uint16_temp;			//Read in from the current multiplexer channel.
		++sensor_data_ptr->length;											//Increase the sensor data array length counter by one.
	}
	
}

//Implement a function to retrieve the index associated with a specific muscle ID with the constant muscle info structure.
unsigned char GetMuscleInfoIndex( unsigned char muscle_ID )
{
	//Create a variable to store the associated muscle index.
	unsigned char k = 0;
	
	//Iterate through each of the muscles in the muscle info structure searching for a matching ID.
	while ( (k < NUM_FRONT_LEG_MUSCLES) && (!(muscle_ID == muscle_info[k].ID)) )
	{
		++k;
	}
	
	//Determine whether a matching index was found.
	if ( (k >= NUM_FRONT_LEG_MUSCLES) )
	{
		k = 255;
	}
	
	//Return the associated index.
	return k;
	
}

//Implement a function to update the muscle states on/off based on the associated command values.
void UpdateMuscleOnOffStates( struct int_array_struct * command_data_ptr)
{
	
	//Define a variable to store the muscle info index associated with each command muscle id.
	unsigned char k2;
	
	//Set each of the muscle pin states on/off according to whether the command value exceeds a certain threshold.
	for (int k1 = 0; k1 < command_data_ptr->length; ++k1)						//Iterate through each of the commands...
	{
		//Retrieve the muscle info index associated with this command.
		k2 = GetMuscleInfoIndex( command_data_ptr->IDs[k1] );
		
		//Determine whether a matching muscle index was found.
		if (!(k2 == 255))																//If a matching muscle index was found...
		{
			//Determine whether to set the pin associated with this muscle high or low based on whether the associated command value exceeds a certain threshold.
			if (command_data_ptr->values[k1] > activation_threshold)				//If the command value for this muscle exceeds the activation threshold...
			{
				sbi(*(muscle_info[k2].port), muscle_info[k2].pin);					//Set the pin associated with this muscle high...
			}
			else
			{
				cbi(*(muscle_info[k2].port), muscle_info[k2].pin);					//Set the pin associated with this muscle low...
			}
		}
	}
	
}

//Implement a temporary function to use the DAC as one of the muscle pins.
void UseDACAsMusclePin(struct int_array_struct * command_data_ptr)
{

	unsigned char bCriticalMuscleFound = 0;
	unsigned char k = 0;

	while ( (k < command_data_ptr->length) && (!bCriticalMuscleFound))
	{
		if (command_data_ptr->IDs[k] == 39)
		{
			bCriticalMuscleFound = 1;
		}
		
		++k;
	}
		
	--k;
		
	if ((bCriticalMuscleFound) && (command_data_ptr->values[k] > activation_threshold))
	{
		write2DAC(dac_on_value);
	}
	else
	{
		write2DAC(dac_off_value);
	}
	
}
	