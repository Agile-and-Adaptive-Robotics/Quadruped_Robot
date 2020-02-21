//Single Joint Testing: Header File

//Include necessary .h files.
#include <stdio.h>
#include <avr/io.h>
#include <avr/interrupt.h>

//Define the clock speed.
#define F_CPU 16000000UL // 16 MHz CPU Clock Frequency
#include <util/delay.h>   // Include the built in Delay Function

//Define pin setting and clearing functions.
#define sbi(var, mask)   ((var) |= (uint8_t)(1 << mask))
#define cbi(var, mask)   ((var) &= (uint8_t)~(1 << mask))

//Define SPIF value (used for SPI communication).
#define SPIF 7

//Define USART parameters.
#define FOSC F_CPU					//CPU Clock Frequency must be set correctly for the USART to work
#define BAUD 9600					//BAUD Rate.  Maximum appears to be 921600.
#define MYUBRR FOSC/16/BAUD-1

//Define the necessary function prototypes.
void uart_putchar(char c, FILE *stream);
unsigned char uart_getchar(void);

void set_pin_state( unsigned char * port_num, unsigned char pin_num, unsigned char pin_state);
void spi_write_read(unsigned char spi_data);

void serial_write_string2matlab(char mystring[]);
void serial_write_int2matlab( int myint );
void serial_write_int_array2matlab( int myint_array[], int array_length );
void serial_write_start_bytes( void );
void serial_write_end_bytes( void );
int * int2lowhighbytes(int myint);
unsigned int lowhighbytes2int(unsigned int low_byte, unsigned int high_byte);

void wait_for_start_sequence( void );
unsigned int serial_read_matlab_int( void );
struct int_array serial_read_matlab_int_array( void );

void SetupTimerInterrupts( void );
void SetupUSART( void );
void SetupSPI( void );
void SetupADC( void );
void SetupPins( void );
void SetupMicro( void );

void write2DAC(unsigned int value_to_write);
unsigned int readADC( unsigned int channel_num );
void set_multiplexer_channel_with_pins( unsigned char * port_num, unsigned char * pin_nums, unsigned char channel_num );
void set_multiplexer_channel( unsigned char channel_num );

//Define the necessary structures.
struct int_array 
{
	unsigned int * array;
	unsigned char length;
};


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
extern const unsigned char window_size;
extern const unsigned int num_adc_channels;
extern const unsigned char multiplexer_pins1[3];
extern const unsigned char multiplexer_pins2[3];
extern const unsigned char * multiplexer_port;
extern const unsigned char num_pressure_sensors;
extern const unsigned char num_potentiometers;

//Declare global variables.
extern unsigned int dac_data;									//[#] Value to send to dac.
extern unsigned int count;										//[#] Counter for the number of interrupt cycles.
extern unsigned char clock_pin_state;							//[T/F] Clock Pin State.
