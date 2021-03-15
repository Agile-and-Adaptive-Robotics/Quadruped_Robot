// Control Functions.

// This file implements functions related to performing BPA pressure control.

// Include the associated header file.
#include "Slave_Micro_Header.h"

// Implement a function that causes the appropriate valve to open when the activation level is above a set threshold and close when the activation level is below this same threshold.
void on_off_threshold_control( uint16_t activation_level )
{
	
	// Determine whether to open or close the valve.
	if (activation_level >= activation_threshold)			// If the activation level is greater than or equal to the activation threshold...
	{
		// Open the valve.
		PORTB |= (1 << 1);
	}
	else
	{
		// Close the valve.
		PORTB &= ~(1 << 1);
	}

}


// Implement a function that controls the pressure in the BPA using a bang-bang control technique with a threshold.
void bang_bang_pressure_control( float p_desired, float p_actual )
{
	
	// Define local variables.
	float p_lower;
	float p_upper;
	
	// Compute the lower and upper pressure bounds.
	p_lower = p_desired - p_threshold;
	p_upper = p_desired + p_threshold;

	// Determine whether to open or close the valve.
	if (p_actual > p_upper)				// If the current pressure is above the upper pressure limit...
	{
		// Close the valve to exhaust air.
		PORTB &= ~(1 << 1);
	}
	else if (p_actual < p_lower)		// If the current pressure is below the lower pressure limit...
	{
		// Open the valve to add air.
		PORTB |= (1 << 1);
	}
	
}


