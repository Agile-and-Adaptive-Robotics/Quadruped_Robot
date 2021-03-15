// Slave Micro Testing Header File

// Include necessary .h files.
#include <stdio.h>
#include <avr/io.h>
#include <avr/interrupt.h>

// Define the clock speed.
#define F_CPU 16000000UL // 16 MHz CPU Clock Frequency
#include <util/delay.h>   // Include the built in Delay Function

// Define pin setting and clearing macros.
#define sbi(var, mask)   ((var) |= (uint8_t)(1 << mask))
#define cbi(var, mask)   ((var) &= (uint8_t)~(1 << mask))

// Define SPIF value (used for SPI communication).
#define SPIF 7

// Define USART parameters.
#define FOSC F_CPU					// CPU Clock Frequency must be set correctly for the USART to work
// #define BAUD 9600					// BAUD Rate.  Maximum appears to be 921600.
#define BAUD 57600					// BAUD Rate.  Maximum appears to be 921600.
#define MYUBRR FOSC/16/BAUD-1
#define WINDOW_SIZE 2

// Define robot parameters.
#define NUM_TOTAL_MUSCLES 24
#define NUM_FRONT_LEG_MUSCLES 6
#define NUM_MULTIPLEXER_PINS 3
#define NUM_PRESSURE_SENSORS 24
#define NUM_POTENTIOMETERS 14
#define NUM_SENSORS_TOTAL 38

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

// Define the necessary structures.
struct int_struct
{
	uint16_t * array;
	uint8_t length;
};

struct float_struct
{
	float * array;
	uint8_t length;
};

struct single_array_struct
{
	uint8_t IDs[38];				// This assumes that there will be <255 muscles, or the ID variable will overflow.
	float values[38];
	uint8_t length;				// This assumes that there will be <255 muscles, or the length variable will overflow.
};

struct int_array_struct
{
	uint8_t IDs[38];				// This assumes that there will be <255 muscles, or the ID variable will overflow.
	uint16_t values[38];			// This assumes that the muscle activation value will be in the range [0, 65535].
	uint8_t length;				// This assumes that there will be <255 muscles, or the length variable will overflow.
};

struct muscle_info_struct 
{
	uint8_t ID;
	uint8_t * port;
	uint8_t pin;
};

struct slave_info_struct
{
	uint8_t muscle_ID;
	uint8_t slave_num;
};


// Type Conversion Functions.
uint8_t * uint162lowhighbytes( uint16_t myint );
uint16_t lowhighbytes2uint16( uint8_t low_byte, uint8_t high_byte );
uint16_t byte_array2uint16( uint8_t byte_array[] );
void uint162byte_array( uint16_t my_int, uint8_t byte_array[] );
float byte_array2float( uint8_t byte_array[] );
void float2byte_array( float my_float, uint8_t byte_array[] );
uint16_t uint102uint16( uint16_t uint10 );
uint16_t uint162uint10( uint16_t uint16 );
uint16_t uint122uint16( uint16_t uint12 );
uint16_t uint162uint12( uint16_t uint16 );
float volt_uint162volt_float( uint16_t muscle_int );
uint16_t volt_float2volt_uint16( float sensor_volt );
char get_char_bits( char mychar, char no_of_bits );

// Low Level UART Functions.
void uart_putchar( char c, FILE *stream) ;
unsigned char uart_getchar( void );

// Low Level SPI Functions.
void spi_write_uint8( uint8_t spi_data );
uint8_t spi_read_uint8( void );
uint8_t spi_read_write_uint8( uint8_t spi_data );

// High Level SPI Functions.
void spi_write_uint162slave( uint16_t value_to_write, uint8_t slave_num );
uint16_t spi_read_write_uint16( uint16_t value_to_write, uint8_t slave_num );
void WriteCommandData2Slaves( struct int_array_struct * command_data_ptr );
void SwapMasterSlaveData( struct int_array_struct * command_data_ptr, struct int_array_struct * sensor_data_ptr );

// Low Level Pin State Setting Function.
void set_pin_state( unsigned char * port_num, uint8_t pin_num, uint8_t pin_state);

// High Level Serial Write Functions.
void serial_write_start_bytes( void );
void serial_write_end_bytes( void );
void serial_write_string2matlab( char mystring[] );
void serial_write_int2matlab( uint16_t myint );
void serial_write_int_array2matlab( uint16_t myint_array[], uint8_t array_length );
void serial_write_single_array2matlab( float myfloat_array[], uint8_t array_length );
void serial_write_sensor_data_ints2matlab( struct int_array_struct * sensor_data_ptr );
void serial_write_sensor_data_singles2matlab( struct single_array_struct * sensor_data_ptr );

// High Level Serial Read Functions.
void wait_for_start_sequence( void );
unsigned int serial_read_matlab_int( void );
struct int_struct serial_read_matlab_int_array( void );
struct float_struct serial_read_matlab_single_array( void );
void serial_read_matlab_muscle_command_ints( struct int_array_struct * command_data_ptr );
void serial_read_matlab_muscle_command_singles( struct single_array_struct * single_array_struct_ptr );

// Setup Functions.
void SetupTimerInterrupts( void );
void SetupUSART( void );
void SetupSPI( void );
void SetupADC( void );
void SetupPins( void );
void SetupMicro( void );

// ADC-DAC Functions.
uint16_t ADC2DAC( uint16_t adc_value );
void write2DAC( uint16_t value_to_write );																						// Medium Level DAC Writing Function.
uint16_t readADC( uint8_t channel_num );																					// Medium Level ADC Reading Function.
void set_multiplexer_channel_with_pins( unsigned char * port_num, uint8_t * pin_nums, uint8_t channel_num );			// Medium Level Multiplexer Channel Setting Function.
void set_multiplexer_channel( uint8_t channel_num );																			// High Level Multiplexer Channel Setting Function.
void get_sensor_data( struct int_array_struct * sensor_data_ptr );
unsigned char get_muscle_index( unsigned char muscle_ID );
uint8_t get_slave_index( uint8_t muscle_ID_target );
void update_muscle_on_off_states( struct int_array_struct * command_data_ptr );
void use_dac_as_muscle_pin( struct int_array_struct * command_data_ptr );


// Define the the standard output.
static FILE mystdout = FDEV_SETUP_STREAM( uart_putchar, NULL, _FDEV_SETUP_WRITE );

// Declare global constants.
extern const uint8_t multiplexer_pins1[NUM_MULTIPLEXER_PINS];
extern const uint8_t multiplexer_pins2[NUM_MULTIPLEXER_PINS];
extern const uint8_t * multiplexer_port;
extern const struct muscle_info_struct muscle_info[NUM_FRONT_LEG_MUSCLES];
// extern const struct slave_info_struct slave_info[NUM_FRONT_LEG_MUSCLES];
extern const struct slave_info_struct slave_info[NUM_TOTAL_MUSCLES];

extern const uint16_t activation_threshold;

