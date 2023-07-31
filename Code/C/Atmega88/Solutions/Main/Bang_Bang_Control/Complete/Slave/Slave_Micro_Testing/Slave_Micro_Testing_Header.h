//Slave Micro Testing Header File

//Include necessary .h files.
#include <stdio.h>
#include <avr/io.h>
#include <avr/interrupt.h>

//Define the clock speed.
#define F_CPU 16000000UL // 16 MHz CPU Clock Frequency
#include <util/delay.h>   // Include the built in Delay Function

//Define pin setting and clearing macros.
#define sbi(var, mask)   ((var) |= (uint8_t)(1 << mask))
#define cbi(var, mask)   ((var) &= (uint8_t)~(1 << mask))

// Define SPI Parameters.
#define SPIF 7						// SPIF value (used for SPI communication).
#define NUM_SPI_BYTES 2

//Define USART Parameters.
#define FOSC F_CPU					//CPU Clock Frequency must be set correctly for the USART to work
//#define BAUD 9600					//BAUD Rate.  Maximum appears to be 921600.
#define BAUD 57600					//BAUD Rate.  Maximum appears to be 921600.
#define MYUBRR FOSC/16/BAUD-1

//Define Robot Parameters.
#define NUM_TOTAL_MUSCLES 24
#define NUM_FRONT_LEG_MUSCLES 6
#define NUM_MULTIPLEXER_PINS 3

//Define Conversion Parameters.
#define NUM_BYTES_PER_FLOAT 4
#define NUM_BYTES_PER_UINT16 2

//Define the necessary structures.
struct int_struct
{
	unsigned int * array;
	unsigned char length;
};

struct float_struct
{
	float * array;
	unsigned char length;
};

struct single_array_struct
{
	unsigned char IDs[38];				//This assumes that there will be <255 muscles, or the ID variable will overflow.
	float values[38];
	unsigned char length;				//This assumes that there will be <255 muscles, or the length variable will overflow.
};

struct int_array_struct
{
	unsigned char IDs[38];				//This assumes that there will be <255 muscles, or the ID variable will overflow.
	uint16_t values[38];			//This assumes that the muscle activation value will be in the range [0, 65535].
	unsigned char length;				//This assumes that there will be <255 muscles, or the length variable will overflow.
};

struct muscle_info_struct 
{
	unsigned char ID;
	unsigned char * port;
	unsigned char pin;
};


//Type Conversion Functions.
int * int2lowhighbytes(int myint);
unsigned int lowhighbytes2int(unsigned int low_byte, unsigned int high_byte);
uint16_t byte_array2int(unsigned char byte_array[]);
float byte_array2float(unsigned char byte_array[]);
void int2byte_array(uint16_t my_int, unsigned char byte_array[]);
void float2byte_array(float my_float, unsigned char byte_array[]);
float muscle_int2muscle_volt(unsigned int muscle_int);
unsigned int sensor_volt2sensor_int(unsigned int sensor_volt);
uint16_t ADC2uint16( unsigned int ADC_value );
unsigned int uint162ADC( uint16_t uint16_value );
float ADC2Voltage( unsigned int ADC_value );
uint16_t voltage2uint16( float voltage );
uint16_t ScaleADC( uint16_t ADC_value );

//Low Level UART Functions.
void uart_putchar(char c, FILE *stream);
unsigned char uart_getchar(void);

//Low Level SPI functions.
void spi_write(unsigned char spi_data);
unsigned char spi_read( void );
unsigned char spi_read_write(unsigned char spi_data);

//Low Level Pin State Setting Function.
void set_pin_state( unsigned char * port_num, unsigned char pin_num, unsigned char pin_state);

//High Level Serial Write Functions.
void serial_write_start_bytes( void );
void serial_write_end_bytes( void );
void serial_write_string2matlab(char mystring[]);
void serial_write_int2matlab( int myint );
void serial_write_int_array2matlab( int myint_array[], int array_length );
void serial_write_single_array2matlab( float myfloat_array[], int array_length );
void serial_write_sensor_data_ints2matlab( struct int_array_struct * sensor_data_ptr );
void serial_write_sensor_data_singles2matlab( struct single_array_struct * sensor_data_ptr );

//High Level Serial Read Functions.
void wait_for_start_sequence( void );
unsigned int serial_read_matlab_int( void );
struct int_struct serial_read_matlab_int_array( void );
struct float_struct serial_read_matlab_single_array( void );
void serial_read_matlab_muscle_command_ints( struct int_array_struct * command_data_ptr );
void serial_read_matlab_muscle_command_singles( struct single_array_struct * single_array_struct_ptr );

//Setup Functions.
void SetupTimerInterrupts( void );
void SetupUSART( void );
void SetupSPI( void );
void SetupADC( void );
void SetupPins( void );
void SetupMicro( void );

//ADC / DAC Functions.
void write2DAC(unsigned int value_to_write);																						//Medium Level DAC Writing Function.
unsigned int readADC( unsigned int channel_num );																					//Medium Level ADC Reading Function.
void set_multiplexer_channel_with_pins( unsigned char * port_num, unsigned char * pin_nums, unsigned char channel_num );			//Medium Level Multiplexer Channel Setting Function.
void set_multiplexer_channel( unsigned char channel_num );																			//High Level Multiplexer Channel Setting Function.
void GetSensorData( struct int_array_struct * sensor_data_ptr );
unsigned char GetMuscleInfoIndex( unsigned char muscle_ID );
void UpdateMuscleOnOffStates( struct int_array_struct * command_data_ptr);
void UseDACAsMusclePin(struct int_array_struct * command_data_ptr);

// Control Functions.
void on_off_threshold_control( uint16_t activation_level );
void bang_bang_pressure_control( float p_desired, float p_actual );

//Define the the standard output.
static FILE mystdout = FDEV_SETUP_STREAM(uart_putchar, NULL, _FDEV_SETUP_WRITE);

//Declare global constants.
extern const float extensor_pressure_conversion;		//[V/#] Bit to voltage conversion factor for extensor pressure readings.
extern const float flexor_pressure_conversion;			//[V/#] Bit to voltage conversion factor for flexor pressure readings.
extern const float joint_angle_conversion;				//[V/#] Bit to voltage conversion factor for joint angle readings.
extern const unsigned int extensor_pressure_offset;		//[#] Bit offset for extensor pressure sensor.
extern const unsigned int flexor_pressure_offset;		//[#] Bit offset for flexor pressure sensor.
extern const unsigned int joint_angle_offset;			//[#] Bit offset for potentiometer.
extern const float dac_on_value;						//[#] Value to which the dac should be set when the valve manifold is turned on.
extern const unsigned int dac_off_value;
extern const unsigned char window_size;
extern const unsigned int num_adc_channels;
extern const unsigned char multiplexer_pins1[NUM_MULTIPLEXER_PINS];
extern const unsigned char multiplexer_pins2[NUM_MULTIPLEXER_PINS];
extern const unsigned char * multiplexer_port;
extern const unsigned char num_pressure_sensors;
extern const unsigned char num_potentiometers;
extern const unsigned char num_sensors_total;
extern const struct muscle_info_struct muscle_info[NUM_FRONT_LEG_MUSCLES];
extern const uint16_t activation_threshold;
extern const float p_threshold;

//Declare global variables.
extern unsigned int dac_data;										//[#] Value to send to dac.
extern unsigned int count;											//[#] Counter for the number of interrupt cycles.
extern unsigned char clock_pin_state;								//[T/F] Clock Pin State.
extern volatile unsigned char spi_bytes[NUM_BYTES_PER_UINT16];		//[#] Bytes of uint16 received over SPI.
extern volatile unsigned char spi_bytes_to_send[NUM_BYTES_PER_UINT16];
extern volatile uint8_t spi_index;
