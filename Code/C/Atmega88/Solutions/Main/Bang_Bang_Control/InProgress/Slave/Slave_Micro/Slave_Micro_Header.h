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

// Define SPI Parameters.
#define SPIF 7						// SPIF value (used for SPI communication).
#define NUM_SPI_BYTES 2

// Define USART Parameters.
#define FOSC F_CPU					//CPU Clock Frequency must be set correctly for the USART to work
#define BAUD 57600					//BAUD Rate.  Maximum appears to be 921600.
#define MYUBRR FOSC/16/BAUD-1

// Define Conversion Parameters.
#define NUM_BYTES_PER_FLOAT 4
#define NUM_BYTES_PER_UINT16 2
#define NUM_BYTES_PER_UINT8 1

// Type Conversion Functions.
uint8_t * int2lowhighbytes( uint16_t myint );
uint16_t lowhighbytes2int( uint8_t low_byte, uint8_t high_byte );
uint16_t byte_array2int( uint8_t byte_array[] );
float byte_array2float( uint8_t byte_array[] );
void int2byte_array( uint16_t my_int, uint8_t byte_array[] );
void float2byte_array( float my_float, uint8_t byte_array[] );
uint16_t ADC2uint16( uint16_t ADC_value );
uint16_t uint162ADC( uint16_t uint16_value );
float ADC2Voltage( uint16_t ADC_value );
uint16_t voltage2uint16( float voltage );
uint16_t ScaleADC( uint16_t ADC_value );

// Low Level SPI functions.
void spi_write( uint8_t spi_data );
uint8_t spi_read( void );
uint8_t spi_read_write( uint8_t spi_data );

// Low Level Pin State Setting Function.
void set_pin_state( unsigned char * port_num, uint8_t pin_num, uint8_t pin_state );
void toggle_pin( unsigned char * port_num, uint8_t pin_num );

// Setup Functions.
void SetupTimerInterrupts( void );
void SetupUSART( void );
void SetupSPI( void );
void SetupADC( void );
void SetupPins( void );
void SetupMicro( void );

// ADC / DAC Functions.
uint16_t readADC( uint8_t channel_num );																					// Medium Level ADC Reading Function.

// Control Functions.
void on_off_threshold_control( uint16_t activation_level );
void bang_bang_pressure_control( float p_desired, float p_actual );

// Define the the standard output.
static FILE mystdout = FDEV_SETUP_STREAM(uart_putchar, NULL, _FDEV_SETUP_WRITE);

// Declare global constants.
extern const uint16_t activation_threshold;
extern const float p_threshold;

// Declare global variables.
extern volatile uint8_t spi_bytes[NUM_BYTES_PER_UINT16];		//[#] Bytes of uint16 received over SPI.
extern volatile uint8_t spi_bytes_to_send[NUM_BYTES_PER_UINT16];
extern volatile uint8_t spi_index;
