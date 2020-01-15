//Bang-Bang Control Testing Main Script

//This script reads in command values from Animatlab via Matlab and outputs sensor values to Animatlab via Matlab.

//Include the associated header file.
#include "Bang_Bang_Control_Testing_Header.h"

//Define global constants.
const float extensor_pressure_conversion = 5./951;			//[V/#] Bit to voltage conversion factor for extensor pressure readings.
const float flexor_pressure_conversion = 5./961;			//[V/#] Bit to voltage conversion factor for flexor pressure readings.
const float joint_angle_conversion = 5./991;				//[V/#] Bit to voltage conversion factor for joint angle readings.
const unsigned int extensor_pressure_offset = 0;			//[#] Bit offset for extensor pressure sensor.
const unsigned int flexor_pressure_offset = 23;				//[#] Bit offset for flexor pressure sensor.
const unsigned int joint_angle_offset = 0;					//[#] Bit offset for potentiometer.
const float dac_on_value = round((5./5.12)*4095);			//[#] Value to which the dac should be set when the valve manifold is turned on.
const unsigned int dac_off_value = 0;
const unsigned char window_size = 2;						//[#] Define the size of the start sequence.
const unsigned int num_adc_channels = 2;					//[#] Define the number of adc channels.
const unsigned char multiplexer_pins1[3] = {2, 3, 4};
const unsigned char multiplexer_pins2[3] = {5, 6, 7};
const unsigned char * multiplexer_port = &PORTD;
const unsigned char num_pressure_sensors = 24;
const unsigned char num_potentiometers = 14;
const unsigned char num_sensors_total = 38;
const struct muscle_info_struct muscle_info[NUM_FRONT_LEG_MUSCLES] = { {39, &PORTB, 2}, {40, &PORTC, 3}, {41, &PORTC, 1}, {42, &PORTC, 4}, {43, &PORTC, 2}, {44, &PORTC, 5} };
//const uint16_t activation_threshold = 32767;
const uint16_t activation_threshold = 5000;
//const uint16_t bang_bang_threshold = 100;					//About 500 mV tolerance.
const uint16_t bang_bang_threshold = 50;					//About 250 mV tolerance.
//const uint16_t bang_bang_threshold = 1;					//About 5 mV tolerance.

//Define global variables.
unsigned int count = 0;										//[#] Counter for the number of interrupt cycles.
unsigned char clock_pin_state = 0;							//[T/F] Clock Pin State.
volatile uint16_t dac_data;

//Implement the main function.
int main (void)
{
	
	//Setup the microcontroller.
	SetupMicro();
	
	////Define local variables.
	//struct int_array_struct command_data;
	//struct int_array_struct sensor_data;
	//volatile unsigned int myuint;

	dac_data = dac_off_value;

	//Create an empty loop.
	while(1)
	{
		
		////myuint = readADC( 0 );
				//
		////Read from serial port.
		//
		////Read the command uint16s from matlab.
		//serial_read_matlab_muscle_command_ints( &command_data );
//
		////Update the muscle on/off states based on the command data.
		//UpdateMuscleOnOffStates( &command_data );
//
		////Use the DAC as one of the muscle pins.
		//UseDACAsMusclePin( &command_data );
		//
		////Retrieve the latest sensor data.
		//GetSensorData( &sensor_data );
		//
		////Write to the serial port.
//
		////Write the sensor data uint16 values to matlab.
		//serial_write_sensor_data_ints2matlab( &sensor_data );
		
		
	}

}

//Implement the first timer interrupt function.
ISR(TIMER1_COMPA_vect)
{

	//Declare local variables.
	volatile uint16_t p_desired;
	volatile uint16_t p_actual;
	//volatile uint16_t dac_data = dac_off_value;
	volatile uint16_t lower_bound;
	volatile uint16_t upper_bound;

	sbi(PORTD, 7);

	////Read in the actual pressure.
	//set_multiplexer_channel( 0 );
	//_delay_ms(0.0005);
	//p_actual = readADC( 0 );
	p_actual = readADC( 0 );

	////Read in the desired pressure.
	//set_multiplexer_channel( 63 );
	//_delay_ms(0.0005);
	//p_desired = readADC( 0 );
	p_desired = readADC( 1 );
	
	////Compute the lower pressure bound.
	//lower_bound = p_desired - bang_bang_threshold;
	//
	////Constrain the lower bound to the range 0-1023.
	//if (lower_bound < 0)
	//{
		//lower_bound = 0;
	//}
	//else if (lower_bound > 1023)
	//{
		//lower_bound = 1023;
	//}
	//
	////Compute the upper pressure bound.
	//upper_bound = p_desired + bang_bang_threshold;
	//
	////Constrain the upper bound to the range 0-1023.
	//if (upper_bound < 0)
	//{
		//upper_bound = 0;
	//}
	//else if (upper_bound > 1023)
	//{
		//upper_bound = 1023;
	//}
		
	//Compute the lower pressure bound.
	if (p_desired > bang_bang_threshold)
	{
		lower_bound = p_desired - bang_bang_threshold;
	}
	else
	{
		lower_bound = 0;
	}
			
	//Compute the upper pressure bound.
	upper_bound = p_desired + bang_bang_threshold;
			
	//Constrain the upper bound to the range 0-1023.
	if (upper_bound > 1023)
	{
		upper_bound = 1023;
	}

	//Determine whether to open or close the valve.
	if (p_actual < lower_bound)
	{
		dac_data = dac_on_value;
	}
	else if (p_actual > upper_bound)
	{
		dac_data = dac_off_value;
	}
	
	//Send the appropriate signal to the DAC.
	write2DAC(dac_data);
	
	cbi(PORTD, 7);
	
}

