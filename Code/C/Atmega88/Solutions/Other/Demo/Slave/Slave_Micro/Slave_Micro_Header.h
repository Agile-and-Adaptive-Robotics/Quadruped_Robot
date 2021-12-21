// Slave Micro Testing Header File

// This script includes the necessary c libraries, defines global constants, and initiates global functions.


// -------------------------------------------------------------------------------- INCLUDE LIBRARIES --------------------------------------------------------------------------------

// Include necessary .h files.
#include <stdio.h>
#include <avr/io.h>
#include <avr/interrupt.h>

// Define the clock speed.
#define F_CPU 16000000UL // 16 MHz CPU Clock Frequency
#include <util/delay.h>   // Include the built in Delay Function


// -------------------------------------------------------------------------------- DEFINE MACROS AND GLOBAL CONSTANTS --------------------------------------------------------------------------------

// Define pin setting and clearing macros.
#define sbi(var, mask)   ((var) |= (uint8_t)(1 << mask))
#define cbi(var, mask)   ((var) &= (uint8_t)~(1 << mask))
#define tbi(var, mask)   ((var)) ^= (uint8_t)(1 << mask)

// Define SPI Parameters.
#define SPIF 7						// SPIF value (used for SPI communication).
#define NUM_SPI_BYTES 2
#define SINGLE_SENSOR_MESSAGE_LENGTH 4
#define ALL_SENSORS_MESSAGE_LENGTH 8

// Define USART Parameters.
#define FOSC F_CPU					//CPU Clock Frequency must be set correctly for the USART to work
#define BAUD 57600					//BAUD Rate.  Maximum appears to be 921600.
#define MYUBRR FOSC/16/BAUD-1

// Define the robot parameters.
#define NUM_SENSORS 3

// Define Conversion Parameters.
#define NUM_BYTES_PER_FLOAT 4
#define NUM_BYTES_PER_UINT16 2
#define NUM_BYTES_PER_UINT8 1
#define MAX_VOLTAGE 5.0
#define PRESSURE_SENSOR_MAX_VOLTAGE 4.3
#define MAX_PRESSURE 90.0
#define MAX_UINT16_VALUE 65535.0
#define MAX_UINT12_VALUE 4095.0
#define MAX_UINT10_VALUE 1023.0
#define MAX_UINT8_VALUE 255.0

// Define SPI Parameters.
#define NUM_SPI_BYTES_TO_SEND 6

// Define Encoder Parameters.
#define ENCODER_PORT PORTD				// PD6 = Encoder Pin A, PD7 = Encoder Pin B
#define MAX_ENCODER_VALUE 8191			// [#] PPR = Pulses Per Revolution (Max PPR = 2048). [#] CPR = Counts Per Revolution (Max CPR = 8192) (CPR = 4*PPR).  MAX_ENCODER_VALUE = CPR - 1;
#define ENCODER_INDEX 5					// Encoder Index Bit (Bit 5 of the ENCODER_PORT).
#define ENCODER_REFERENCE_VALUE 0


// -------------------------------------------------------------------------------- DEFINE CUSTOM DATA STRUCTURES --------------------------------------------------------------------------------

// Implement a structure to store the command data.
struct  command_data_struct
{
	// Note: It is obviously unnecessary to create a structure to store only a single uint16 value.  This structure is created in case we want to expand the slave code to include multiple possible command values (such as for Multi-input Multi-output control) and to enforce "symmetry" between the command data and sensor data (i.e., so that both are structures).
	
	uint16_t desired_pressure;						// [0-65535] Desired Pressure Value.
};

// Implement a structure to store the sensor data.
struct sensor_data_struct
{
	uint16_t pressure_sensor_value1;				// [0-65535] Pressure Sensor 1 Value.
	uint16_t pressure_sensor_value2;				// [0-65535] Pressure Sensor 2 Value.
	uint16_t joint_value;							// [0-65535] Joint Angle.
};

// Implement a structure to store the SPI data.
struct SPI_data_struct
{
	uint8_t spi_index;
	uint8_t max_spi_index;
	uint8_t spi_bytes_received[NUM_BYTES_PER_UINT16];
	uint8_t spi_bytes_to_send[NUM_SPI_BYTES_TO_SEND];
	uint8_t command_ID;
	uint8_t sensor_ID;
};


// -------------------------------------------------------------------------------- DEFINE CUSTOM FUNCTIONS --------------------------------------------------------------------------------

// Define Pin Functions.
void set_pin_state( unsigned char * port_num, uint8_t pin_num, uint8_t pin_state );
void toggle_pin( unsigned char * port_num, uint8_t pin_num );

// Define Conversion Functions.
uint16_t byte_array2uint16( uint8_t byte_array[] );
void uint162byte_array( uint16_t my_int, uint8_t byte_array[] );
float byte_array2float( uint8_t byte_array[] );
void float2byte_array( float my_float, uint8_t byte_array[] );
uint16_t uint102uint12( uint16_t my_uint10 );
uint16_t uint122uint10( uint16_t my_uint12 );
uint16_t uint102uint16( uint16_t my_uint10 );
uint16_t uint162uint10( uint16_t my_uint16 );
uint16_t uint122uint16( uint16_t my_uint12 );
uint16_t uint162uint12( uint16_t my_uint16 );
float volt_uint162volt_float( uint16_t volt_uint16 );
uint16_t volt_float2volt_uint16( float volt_float );
float desired_pressure_uint162desired_pressure_float( uint16_t desired_pressure_uint16 );
float volt_float2desired_pressure_float( float volt_float );
float volt_float2measured_pressure_float( float volt_float );

// Define ADC and DAC Functions.
uint16_t ADC2DAC( uint16_t adc_value );
uint16_t readADC( uint8_t channel_num );
void read_analog_sensors( struct sensor_data_struct * sensor_data_ptr );

// Define SPI Functions.
void initialize_spi_bytes_to_send( struct SPI_data_struct * SPI_manager_ptr );
void stage_first_pressure_sensor_value( struct sensor_data_struct * sensor_data_ptr, struct SPI_data_struct * SPI_manager_ptr );
void stage_second_pressure_sensor_value( struct sensor_data_struct * sensor_data_ptr, struct SPI_data_struct * SPI_manager_ptr );
void stage_joint_angle_sensor_value( struct sensor_data_struct * sensor_data_ptr, struct SPI_data_struct * SPI_manager_ptr );
void stage_sensor_values( struct sensor_data_struct * sensor_data_ptr, struct SPI_data_struct * SPI_manager_ptr );
void store_command_value( struct command_data_struct * command_data_ptr, struct SPI_data_struct * SPI_manager_ptr );
void stage_command_value( uint8_t spi_byte, struct command_data_struct * command_data_ptr, struct SPI_data_struct * SPI_manager_ptr );

// Define USART Functions.
uint8_t usart_read_uint8( void );
void usart_write_uint8( uint8_t write_value, FILE * stream );
void usart_read_uint8_array( uint8_t read_array[], uint8_t num_uint8s_to_read );
void usart_write_uint8_array( uint8_t write_array[], uint8_t num_uint8s_to_write, FILE * stream );
uint16_t usart_read_uint16( void );
void usart_write_uint16( uint16_t write_value, FILE * stream );

// Define Encoder Functions.
int8_t get_encoder_increment( void );
void apply_encoder_increment( struct sensor_data_struct * sensor_data_ptr, int8_t encoder_increment );
void reset_encoder_value( struct sensor_data_struct * sensor_data_ptr );

// Define Control Functions.
void on_off_threshold_control( uint16_t activation_level );
void bang_bang_pressure_control( float p_desired, float p_actual );

// Setup Functions.
void setup_pins( void );
void setup_ADC( void );
void setup_SPI( void );
void setup_timer_interrupts( void );
void setup_pin_change_interrupts( void );
void setup_USART( void );
void setup_micro( void );


// -------------------------------------------------------------------------------- DEFINE GLOBAL VARIABLES --------------------------------------------------------------------------------

// Define the the standard output.
static FILE mystdout = FDEV_SETUP_STREAM( usart_write_uint8, NULL, _FDEV_SETUP_WRITE );

// Declare global constants.
extern const uint16_t activation_threshold;
extern const float p_threshold;

