//Single Joint Testing.

//Include the associated header file.
#include "Serial_Communication_Testing_Header.h"

//Define global constants.
const float extensor_pressure_conversion = 5./951;			//[V/#] Bit to voltage conversion factor for extensor pressure readings.
const float flexor_pressure_conversion = 5./961;			//[V/#] Bit to voltage conversion factor for flexor pressure readings.
const float joint_angle_conversion = 5./991;				//[V/#] Bit to voltage conversion factor for joint angle readings.
const unsigned int extensor_pressure_offset = 0;			//[#] Bit offset for extensor pressure sensor.
const unsigned int flexor_pressure_offset = 23;				//[#] Bit offset for flexor pressure sensor.
const unsigned int joint_angle_offset = 0;					//[#] Bit offset for potentiometer.
const float dac_on_value = round((5./5.12)*4095);			//[#] Value to which the dac should be set when the valve manifold is turned on.
const unsigned char window_size = 4;						//[#] Define the size of the start sequence.
const unsigned int num_adc_channels = 2;					//[#] Define the number of adc channels.
const unsigned char multiplexer_pins1[3] = {2, 3, 4};
const unsigned char multiplexer_pins2[3] = {5, 6, 7};
const unsigned char * multiplexer_port = &PORTD;
const unsigned char num_pressure_sensors = 24;
const unsigned char num_potentiometers = 14;

//Define global variables.
unsigned int dac_data = 0;									//[#] Value to send to dac.
unsigned int count = 0;										//[#] Counter for the number of interrupt cycles.
unsigned char clock_pin_state = 0;							//[T/F] Clock Pin State.

//Implement the main function.
int main (void)
{
	
	//Setup the microcontroller.
	SetupMicro();
	
	//Create an empty loop.
	while(1){}

}

//Implement the first timer interrupt function.
ISR(TIMER1_COMPA_vect)
{

	//Define local variables.
	unsigned int			extensor_pressure_adc;
	unsigned int			flexor_pressure_adc;
	unsigned int			joint_angle_adc;
	unsigned int			array_length;
	unsigned int			pressure_array[num_pressure_sensors];
	unsigned int			joint_angle_array[num_potentiometers];
	struct int_array		serial_inputs;
	struct int_array		serial_outputs;
	float					extensor_pressure_voltage;
	float					flexor_pressure_voltage;
	float					joint_angle_voltage;
	
	
	//Read from serial port.
	serial_inputs = serial_read_matlab_int_array();
	
	
	//Read from the ADC Channels.

	//Read in from each multiplexer channel associated with a pressure sensor and store these values into an array.
	for (int i = 0; i < num_pressure_sensors; ++i)			//Iterate through each pressure sensor...
	{
		set_multiplexer_channel( i );						//Set the current multiplexer channel.
		//set_multiplexer_channel( 24 );					//Set the current multiplexer channel.
		_delay_ms(0.0005);
		pressure_array[i] = readADC( 0 );					//Read in from the current multiplexer channel.
	}
	
	//Read in from each multiplexer channel associated with a potentiometer and store these values into an array.
	for (int i = 0; i < num_potentiometers; ++i)					//Iterate through each potentiometer...
	{
		set_multiplexer_channel( i + num_pressure_sensors );		//Set the current multiplexer channel.
		//set_multiplexer_channel( 24 );							//Set the current multiplexer channel.
		_delay_ms(0.0005);
		joint_angle_array[i] = readADC( 0 );						//Read in the from the current multiplexer channel.
	}

	
	//Set Valve Pins.

	//Set the valve pins based on the serial input.
	set_pin_state(&PORTB, 2, serial_inputs.array[0]);				//Front Left Hip Extensor.
	set_pin_state(&PORTC, 3, serial_inputs.array[1]);				//Front Left Hip Flexor.
	set_pin_state(&PORTC, 1, serial_inputs.array[2]);				//Front Left Knee Extensor.
	set_pin_state(&PORTC, 4, serial_inputs.array[3]);				//Front Left Knee Flexor.
	set_pin_state(&PORTC, 2, serial_inputs.array[4]);				//Front Left Ankle Extensor.
	set_pin_state(&PORTC, 5, serial_inputs.array[5]);				//Front Left Ankle Flexor.


	//Write to the DAC.

	//Determine whether to set the DAC low or high.
	if (serial_inputs.array[0])
	{
		dac_data = dac_on_value;			//Set the dac value high.
	} 
	else
	{
		dac_data = 0;						//Set the dac value low.
	}

	//Write a value to the DAC.
	write2DAC(dac_data);
	
	
	//Print to the serial port.
	
	//Print out any required information for debugging.
	//printf("P_ext_adc = %d, P_ext_volt = %d, P_flx_adc = %d, P_flx_volt = %d, theta_adc = %d, theta_volt = %d\n", extensor_pressure_adc, (int)(extensor_pressure_voltage*100), flexor_pressure_adc, (int)(flexor_pressure_voltage*100), joint_angle_adc, (int)(joint_angle_voltage*100));
	
	//Write out the pressures.
	serial_write_int_array2matlab( pressure_array, num_pressure_sensors );

	//Write out the joint angles.
	//serial_write_int2matlab(joint_angle_array_output);
	serial_write_int_array2matlab( joint_angle_array, num_potentiometers );
	
	//Cycle the clock pin for reference.
	//clock_pin_state = !clock_pin_state;
	//set_pin_state(&PORTD, 7, clock_pin_state);
	
	//Advance the counter.
	//++count;
	
}

