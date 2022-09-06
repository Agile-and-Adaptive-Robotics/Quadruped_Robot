// Slave Micro Testing Header File

// This script includes the necessary c libraries, defines global constants, and initiates custom functions.


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
#define sbi( var, mask )   ((var) |= (uint8_t)(1 << mask))
#define cbi( var, mask )   ((var) &= (uint8_t)~(1 << mask))

// Define SPIF value (used for SPI communication).
#define SPIF 7

// Define USART parameters.
#define FOSC F_CPU					// CPU Clock Frequency must be set correctly for the USART to work
// #define BAUD 9600					// BAUD Rate.  Maximum appears to be 921600.
#define BAUD 57600					// BAUD Rate.  Maximum appears to be 921600.
#define MYUBRR FOSC/16/BAUD-1
#define START_WINDOW_SIZE 2
#define END_WINDOW_SIZE 1

// Define robot parameters.
#define NUM_TOTAL_MUSCLES 24
#define NUM_FRONT_LEG_MUSCLES 6
#define NUM_MULTIPLEXER_PINS 3
#define NUM_PRESSURE_SENSORS 24
#define NUM_ENCODERS 12
#define NUM_SENSORS_TOTAL 36
#define NUM_SENSOR_PER_SLAVE 3
#define NUM_SLAVES 24

// Define conversion parameters.
#define NUM_BYTES_PER_FLOAT 4
#define NUM_BYTES_PER_UINT16 2

// Define delay parameters.
#define LDAC_DELAY 0.0001
#define MUX_DELAY 0.0005
#define SPI_DELAY 1.0

// Define the DAC parameters.
#define DAC_ON_VALUE 4095
#define DAC_OFF_VALUE 0

// Define SPI parameters.
#define SINGLE_SENSOR_MESSAGE_LENGTH 4
#define ALL_SENSORS_MESSAGE_LENGTH 8


// -------------------------------------------------------------------------------- DEFINE CUSTOM DATA STRUCTURES --------------------------------------------------------------------------------

// Implement the slave structure to store data related to each slave microcontroller.
struct slave_struct
{
	uint8_t slave_ID;								// [0-1023] Unique ID of this slave.
	uint8_t muscle_ID;								// [0-1023] Unique ID of the muscle associated with this slave.
	uint8_t pressure_sensor_ID1;					// [0-1023] Unique ID of the first pressure sensor monitored by this slave.
	uint8_t pressure_sensor_ID2;					// [0-1023] Unique ID of the second pressure sensor monitored by this slave.
	uint8_t joint_ID;								// [0-1023] Unique ID of the joint angle monitored by this slave.
	uint16_t pressure_sensor_value1;				// [0-65565] Pressure Sensor 1 Value.
	uint16_t pressure_sensor_value2;				// [0-65565] Pressure Sensor 2 Value.
	uint16_t joint_value;							// [0-65565] Joint Angle.
	uint16_t desired_pressure;						// [0-65565] Desired Pressure.
};

// Implement a slave array structure to store an array of slave structures and the number of such slave structures.
struct slave_struct_array
{
	struct slave_struct slave[NUM_SLAVES];
	uint8_t num_slaves;
};


// -------------------------------------------------------------------------------- DEFINE PIN FUNCTIONS --------------------------------------------------------------------------------

// Low Level Pin State Setting Function.
void set_pin_state( unsigned char * port_num, uint8_t pin_num, uint8_t pin_state);
void toggle_pin( unsigned char * port_num, uint8_t pin_num );


// -------------------------------------------------------------------------------- DEFINE DATA CONVERSION FUNCTIONS --------------------------------------------------------------------------------

// Type Conversion Functions.
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


// -------------------------------------------------------------------------------- DEFINE ADC & DAC FUNCTIONS --------------------------------------------------------------------------------

// ADC-DAC Functions.
uint16_t ADC2DAC( uint16_t adc_value );
uint16_t readADC( uint8_t channel_num );																					// Medium Level ADC Reading Function.
void write2DAC( uint16_t value_to_write );																						// Medium Level DAC Writing Function.
void set_multiplexer_channel_with_pins( unsigned char * port_num, uint8_t * pin_nums, uint8_t channel_num );			// Medium Level Multiplexer Channel Setting Function.
void set_multiplexer_channel( uint8_t channel_num );																			// High Level Multiplexer Channel Setting Function.

uint8_t get_slave_index_from_muscle_ID( struct slave_struct_array * slave_ptr, uint8_t muscle_ID );
uint8_t get_slave_index_from_slave_ID( struct slave_struct_array * slave_ptr, uint8_t slave_ID );


// -------------------------------------------------------------------------------- DEFINE SPI FUNCTIONS --------------------------------------------------------------------------------

// Low Level SPI Functions.
uint8_t spi_read_uint8( void );
void spi_write_uint8( uint8_t spi_data );
uint8_t spi_read_write_uint8( uint8_t spi_data );
void initiate_SPI( uint8_t slave_index );
void terminate_SPI( void );

// Medium Level SPI Functions.
uint16_t spi_read_uint16( void );
void spi_write_uint16( uint16_t value_to_write );
uint16_t spi_read_write_uint16( uint16_t value_to_write );

void spi_read_uint8_array( uint8_t read_array[], uint8_t num_uint8s_to_read );
void spi_write_uint8_array( uint8_t write_array[], uint8_t num_uint8s_to_write );
void spi_read_write_uint8_array( uint8_t write_array[], uint8_t read_array[], uint8_t num_uint8s_to_read_write );

uint8_t spi_read_slave_uint8( uint8_t slave_index );
void spi_write_slave_uint8( uint8_t value_to_write, uint8_t slave_index );
uint8_t spi_read_write_slave_uint8( uint8_t value_to_write, uint8_t slave_index );

uint16_t spi_read_slave_uint16( uint8_t slave_index );
void spi_write_slave_uint16( uint16_t value_to_write, uint8_t slave_index );
uint16_t spi_read_write_slave_uint16( uint16_t value_to_write, uint8_t slave_index );

void spi_read_slave_uint8_array( uint8_t read_array[], uint8_t num_uint8s_to_read, uint8_t slave_index );
void spi_write_slave_uint8_array( uint8_t write_array[], uint8_t num_uint8s_to_write, uint8_t slave_index );
void spi_read_write_slave_uint8_array( uint8_t write_array[], uint8_t read_array[], uint8_t num_uint8s_to_read_write, uint8_t slave_index );

// High Level SPI Functions.
void spi_read_specific_slave_specific_sensor( struct slave_struct_array * slave_ptr, uint8_t slave_ID, uint8_t sensor_ID );
void spi_read_specific_slave_all_sensors( struct slave_struct_array * slave_ptr, uint8_t slave_ID );
void spi_read_specific_slave_sensor( struct slave_struct_array * slave_ptr, uint8_t slave_ID, uint8_t sensor_ID );
void spi_write_specific_slave_specific_command( struct slave_struct_array * slave_ptr, uint8_t slave_ID, uint8_t command_ID );
void spi_read_write_specific_slave_specific_sensor_specific_command( struct slave_struct_array * slave_ptr, uint8_t slave_ID, uint8_t command_ID, uint8_t sensor_ID );
void spi_read_write_specific_slave_all_sensors_specific_command( struct slave_struct_array * slave_ptr, uint8_t slave_ID, uint8_t command_ID );
void spi_read_write_specific_slave_sensor_specific_command( struct slave_struct_array * slave_ptr, uint8_t slave_ID, uint8_t command_ID, uint8_t sensor_ID );

void spi_read_all_slaves_sensor( struct slave_struct_array * slave_ptr, uint8_t sensor_ID );
void spi_read_slave_sensor( struct slave_struct_array * slave_ptr, uint8_t slave_ID, uint8_t sensor_ID );
void spi_write_all_slaves_specific_command( struct slave_struct_array * slave_ptr, uint8_t command_ID );
void spi_write_slave_specific_command( struct slave_struct_array * slave_ptr, uint8_t slave_ID, uint8_t command_ID );
void spi_read_write_all_slaves_sensor_specific_command( struct slave_struct_array * slave_ptr, uint8_t command_ID, uint8_t sensor_ID );
void spi_read_write_slave_sensor_specific_command( struct slave_struct_array * slave_ptr, uint8_t slave_ID, uint8_t command_ID, uint8_t sensor_ID );


// -------------------------------------------------------------------------------- DEFINE USART FUNCTIONS --------------------------------------------------------------------------------

// Low Level USART Functions.
uint8_t usart_read_uint8( void );
void usart_write_uint8( uint8_t write_value, FILE * stream );

// Medium Level USART Functions.
void usart_read_uint8_array( uint8_t read_array[], uint8_t num_uint8s_to_read );
void usart_write_uint8_array( uint8_t write_array[], uint8_t num_uint8s_to_write, FILE * stream );

uint16_t usart_read_uint16( void );
void usart_write_uint16( uint16_t write_value, FILE * stream );

void usart_write_start_bytes( FILE * stream );
void usart_write_end_bytes( FILE * stream );
void wait_for_start_sequence( void );

// High Level USART Functions.
void usart_read_matlab_desired_pressures( struct slave_struct_array * slave_ptr );
void usart_write_matlab_sensor_data( struct slave_struct_array * slave_ptr, FILE * stream );


// -------------------------------------------------------------------------------- DEFINE SETUP FUNCTIONS --------------------------------------------------------------------------------

// Setup Functions.
void setup_timer_interrupts( void );
void setup_usart( void );
void setup_spi( void );
void setup_adc( void );
void setup_pins( void );
void setup_micro( void );
void initialize_slave_manager( struct slave_struct_array * slave_ptr );


// -------------------------------------------------------------------------------- DEFINE GLOBAL VARIABLES --------------------------------------------------------------------------------

// Define the the standard output.
static FILE mystdout = FDEV_SETUP_STREAM( usart_write_uint8, NULL, _FDEV_SETUP_WRITE );

// Declare global constants.
extern const uint8_t multiplexer_pins1[NUM_MULTIPLEXER_PINS];
extern const uint8_t multiplexer_pins2[NUM_MULTIPLEXER_PINS];
extern const uint8_t * multiplexer_port;

