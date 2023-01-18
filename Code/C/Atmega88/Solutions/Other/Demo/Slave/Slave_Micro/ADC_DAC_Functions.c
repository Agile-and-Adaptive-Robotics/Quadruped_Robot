// ADC & DAC Functions.

// This script implements functions for ADC and DAC.

// Include the associated header file.
#include "Slave_Micro_Header.h"


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


// Implement a function to retrieve data from all of the sensors.
void read_analog_sensors( struct sensor_data_struct * sensor_data_ptr )
{
	
	// Read in the first pressure sensor value.
	sensor_data_ptr->pressure_sensor_value1 = uint102uint16( readADC( 0 ) );
	
	// Read in the second pressure sensor value.
	sensor_data_ptr->pressure_sensor_value2 = uint102uint16( readADC( 1 ) );
	
}