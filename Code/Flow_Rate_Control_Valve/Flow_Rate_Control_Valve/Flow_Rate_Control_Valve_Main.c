//Master Micro Testing Main Script

//This script serves to test the functionality of individual master microcontroller modules.

//Include the associated header file.
#include "Flow_Rate_Control_Valve_Header.h"

//Define global constants.
const uint16_t dac_off_value = 0;							//[#] Value to which the dac should be set when the valve manifold is turned off.
const uint16_t dac_on_value = 4095;							//[#] Value to which the dac should be set when the valve manifold is turned on.
const uint8_t window_size = 2;								//[#] Define the size of the start sequence.
const uint8_t multiplexer_pins1[3] = {2, 3, 4};
const uint8_t multiplexer_pins2[3] = {5, 6, 7};
const uint8_t * multiplexer_port = &PORTD;
const struct muscle_info_struct muscle_info[NUM_FRONT_LEG_MUSCLES] = { {39, &PORTB, 2}, {40, &PORTC, 3}, {41, &PORTC, 1}, {42, &PORTC, 4}, {43, &PORTC, 2}, {44, &PORTC, 5} };
//const struct slave_info_struct slave_info[NUM_FRONT_LEG_MUSCLES] = { {39, 1}, {40, 1}, {41, 2}, {42, 2}, {43, 3}, {44, 3} };		// Used with old PCB boards or breadboard solution.
//const struct slave_info_struct slave_info[NUM_FRONT_LEG_MUSCLES] = { {39, 1}, {40, 2}, {41, 3}, {42, 4}, {43, 5}, {44, 6} };		// Used with new PCB boards.  Back Right Leg.
//const struct slave_info_struct slave_info[NUM_FRONT_LEG_MUSCLES] = { {39, 7}, {40, 8}, {41, 9}, {42, 10}, {43, 11}, {44, 12} };	// Used with new PCB boards.  Front Right Leg.
//const struct slave_info_struct slave_info[NUM_FRONT_LEG_MUSCLES] = { {39, 13}, {40, 14}, {41, 15}, {42, 16}, {43, 17}, {44, 18} };	// Used with new PCB boards.  Back Left Leg.
//const struct slave_info_struct slave_info[NUM_FRONT_LEG_MUSCLES] = { {39, 19}, {40, 20}, {41, 21}, {42, 22}, {43, 23}, {44, 24} };	// Used with new PCB boards.  Front Left Leg.
const struct slave_info_struct slave_info[NUM_TOTAL_MUSCLES] = { {39, 24}, {40, 23}, {41, 22}, {42, 21}, {43, 20}, {44, 19}, {45, 18}, {46, 17}, {47, 16}, {48, 15}, {49, 14}, {50, 13}, {51, 12}, {52, 11}, {53, 10}, {54, 9}, {55, 8}, {56, 7}, {57, 6}, {58, 5}, {59, 4}, {60, 3}, {61, 2}, {62, 1}  };	// Used with new PCB boards.

//const uint16_t activation_threshold = 32767;
const uint16_t activation_threshold = 5000;
//const uint16_t activation_threshold = 10;

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
		
	//Read in from the ADC.
	adc_value = readADC( 0 );
	
	//Convert the ADC value to a DAC value.
	dac_value = ADC2DAC( adc_value );

	////Write a value to the DAC.
	write2DAC( dac_value );
	//write2DAC( 4095 );

}

