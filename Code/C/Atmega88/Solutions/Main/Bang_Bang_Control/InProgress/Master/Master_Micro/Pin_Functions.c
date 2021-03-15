// Pin Functions.
// This script implements miscellaneous functions that control microcontroller pins.

// Include the associated header file.
#include "Master_Micro_Header.h"

// Implement a function to set a pin state.
void set_pin_state( unsigned char * port_num, uint8_t pin_num, uint8_t pin_state )
{
	// Determine whether to set the pin low or high.
	if (pin_state)										// If the desired pin state is high...
	{
		sbi(*port_num, pin_num);							// Set the pin state high.
	}
	else
	{
		cbi(*port_num, pin_num);							// Set the pin state low.
	}

}

// Implement a function to toggle a pin.
void toggle_pin( unsigned char * port_num, uint8_t pin_num )
{
	
	// Toggle the state of the specified pin.
	*port_num ^= (1 << pin_num);
	
}