//Animatlab - Matlab - Micro Serial Communication Main Script

//This script reads in command values from Animatlab via Matlab and outputs sensor values to Animatlab via Matlab.

//Include the associated header file.
#include "Animatlab_Matlab_Micro_Header.h"

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
const uint16_t activation_threshold = 5000;

//Define global variables.
unsigned int dac_data = 0;									//[#] Value to send to dac.
unsigned int count = 0;										//[#] Counter for the number of interrupt cycles.
unsigned char clock_pin_state = 0;							//[T/F] Clock Pin State.

//Implement the main function.
int main (void)
{
	
	//Setup the microcontroller.
	SetupMicro();
	
	//Define local variables.
	struct int_array_struct command_data;
	struct int_array_struct sensor_data;
	//volatile unsigned int myuint;

	//Create an empty loop.
	while(1)
	{
		
		//myuint = readADC( 0 );
				
		//Read from serial port.
		
		//Read the command uint16s from matlab.
		serial_read_matlab_muscle_command_ints( &command_data );

		//Update the muscle on/off states based on the command data.
		UpdateMuscleOnOffStates( &command_data );

		//Use the DAC as one of the muscle pins.
		UseDACAsMusclePin( &command_data );
		
		//Retrieve the latest sensor data.
		GetSensorData( &sensor_data );
		
		//Write to the serial port.

		//Write the sensor data uint16 values to matlab.
		serial_write_sensor_data_ints2matlab( &sensor_data );
		
	}

}

//Implement the first timer interrupt function.
ISR(TIMER1_COMPA_vect)
{

	////Define local variables.
	//struct int_array_struct command_data;
	//struct int_array_struct sensor_data;
	//
	////volatile unsigned char k2;
	//
	//////This code tests the microcontroller's ability to read information from matlab and pass it back.
	////struct int_array_struct my_int_array;
	////serial_read_matlab_muscle_command_ints( &my_int_array );
	////serial_write_sensor_data_ints2matlab( &my_int_array );
	//
	////Read from serial port.
	//
	////Read the command uint16s from matlab.
	//serial_read_matlab_muscle_command_ints( &command_data );
//
	////command_data.IDs[0] = 1;
	////command_data.IDs[1] = 3;
	////command_data.IDs[2] = 2;
////
	////command_data.values[0] = 1000;
	////command_data.values[1] = 60000;
	////command_data.values[2] = 30000;
////
	////command_data.length = 3;
//
	////Update the muscle on/off states based on the command data.
	//UpdateMuscleOnOffStates( &command_data );
//
	////Use the DAC as one of the muscle pins.
	//UseDACAsMusclePin( &command_data );
	//
	//
	////Retrieve the latest sensor data.
	//GetSensorData( &sensor_data );
//
//
	//////Write to the DAC.
	////
	//////Fix the dac value.
	////dac_data = 4095;
	////
	//////Write a value to the DAC.
	////write2DAC(dac_data);
	//
	//
	////Write to the serial port.
//
	////sensor_data = command_data;
//
	////Write the sensor data uint16 values to matlab.
	//serial_write_sensor_data_ints2matlab( &sensor_data );
	
}

