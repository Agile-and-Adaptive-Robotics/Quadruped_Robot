//Master Micro Testing Main Script

//This script serves to test the functionality of individual master microcontroller modules.

//Include the associated header file.
#include "Master_Micro_Testing_Header.h"

//Define global constants.
const uint16_t dac_off_value = 0;							//[#] Value to which the dac should be set when the valve manifold is turned off.
const uint16_t dac_on_value = 4095;							//[#] Value to which the dac should be set when the valve manifold is turned on.
const uint8_t window_size = 2;								//[#] Define the size of the start sequence.
const uint8_t multiplexer_pins1[3] = {2, 3, 4};
const uint8_t multiplexer_pins2[3] = {5, 6, 7};
const uint8_t * multiplexer_port = &PORTD;
const struct muscle_info_struct muscle_info[NUM_FRONT_LEG_MUSCLES] = { {39, &PORTB, 2}, {40, &PORTC, 3}, {41, &PORTC, 1}, {42, &PORTC, 4}, {43, &PORTC, 2}, {44, &PORTC, 5} };
const struct slave_info_struct slave_info[NUM_FRONT_LEG_MUSCLES] = { {39, 1}, {40, 1}, {41, 2}, {42, 2}, {43, 3}, {44, 3} };
//const uint16_t activation_threshold = 32767;
const uint16_t activation_threshold = 5000;

//Implement the main function.
int main (void)
{
	
	//Setup the microcontroller.
	SetupMicro();

	//Create an empty loop.
	while(1)
	{

	}

}

//Implement the first timer interrupt function.
ISR(TIMER1_COMPA_vect)
{
	
	//Define local variables.
	uint16_t adc_value;
	uint16_t dac_value;
	struct int_array_struct command_data;
	struct int_array_struct sensor_data;
			
	//Read the command uint16s from matlab.
	serial_read_matlab_muscle_command_ints( &command_data );
	
	//Write the command data to the slaves.
	WriteCommandData2Slaves( &command_data );
		
	//Relinquish control of the slave select pin.
	DDRB &= ~(1 << 0);					//Set the SS pin to input.
		
	//Retrieve the latest sensor data.
	GetSensorData( &sensor_data );
				
	//Write to the serial port.

	//Write the sensor data uint16 values to matlab.
	serial_write_sensor_data_ints2matlab( &sensor_data );
		
		
		
		
		
	////Define local variables.
	//uint16_t adc_value;
	//uint16_t dac_value;
		//
	////Relinquish control of the slave select pin.
	//DDRB &= ~(1 << 0);					//Set the SS pin to input.
//
	////Switch the multiplexer channel so that we can perform an ADC read.
	//set_multiplexer_channel( 63 );
//
	////Read in from the ADC.
	//adc_value = readADC( 0 );
	//
	////Convert the ADC value to a DAC value.
	//dac_value = ADC2DAC( adc_value );
//
	////Write a value to the DAC.
	//write2DAC( dac_value );
	////write2DAC( 4095 );
//
	//write2slave( adc_value, 1 );
	//write2slave( adc_value, 2 );
	//write2slave( adc_value, 3 );
	//write2slave( adc_value, 4 );
	//write2slave( adc_value, 5 );
	//write2slave( adc_value, 6 );
	//write2slave( adc_value, 7 );
	//write2slave( adc_value, 8 );
	//write2slave( adc_value, 9 );
	//write2slave( adc_value, 10 );
	//write2slave( adc_value, 11 );
	//write2slave( adc_value, 12 );
	//write2slave( adc_value, 13 );
	//write2slave( adc_value, 14 );
	//write2slave( adc_value, 15 );
	//write2slave( adc_value, 16 );
	//write2slave( adc_value, 17 );
	//write2slave( adc_value, 18 );
	//write2slave( adc_value, 19 );
	//write2slave( adc_value, 20 );
	//write2slave( adc_value, 21 );
	//write2slave( adc_value, 22 );
	//write2slave( adc_value, 23 );
	//write2slave( adc_value, 24 );
//
	//////Write a value to a slave micro.
	////write2slave( 1023, 1 );
	////write2slave( 1023, 2 );
	////write2slave( 1023, 3 );
	////write2slave( 1023, 4 );
	////write2slave( 1023, 5 );
	////write2slave( 1023, 6 );
	////write2slave( 1023, 7 );
	////write2slave( 1023, 8 );
	////write2slave( 1023, 9 );
	////write2slave( 1023, 10 );
	////write2slave( 1023, 11 );
	////write2slave( 1023, 12 );
	////write2slave( 1023, 13 );
	////write2slave( 1023, 14 );
	////write2slave( 1023, 15 );
	////write2slave( 1023, 16 );
	////write2slave( 1023, 17 );
	////write2slave( 1023, 18 );
	////write2slave( 1023, 19 );
	////write2slave( 1023, 20 );
	////write2slave( 1023, 21 );
	////write2slave( 1023, 22 );
	////write2slave( 1023, 23 );
	////write2slave( 1023, 24 );

}

