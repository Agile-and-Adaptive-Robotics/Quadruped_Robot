#!/usr/bin/python3

# Serial communication with the microcontroller of the Puppy
# Somewhat close to Cody's MATLAB code
# Run write_predefined() or uncomment __main__()
# If on Linux, add running user to group 'dialout' to address USB permissions

import serial # pip install pyserial
import csv
#from collections import defaultdict
from struct import *

micro_USB_port = '/dev/ttyUSB0' # on Windows this would be COM5 or something 
micro_baud_rate = 57600
micro_data_bits = serial.EIGHTBITS
micro_byte_order = 'little'
micro_parity = serial.PARITY_NONE
micro_stopbits = serial.STOPBITS_ONE

start_sequence_pattern = 'ff' # 255
end_sequence_pattern   = '00' # 0

stimulus_file = 'my_stim.csv'#'front_left_leg_stimulus_tensions.csv'

def write_predefined():
    serial_port_micro = open_serial() #open('comm.log', 'wb')
    print("Port opened")
    serial_port_animatlab = 0 #open_serial()

    animatlab_sentences = read_sentence_from_animatlab(serial_port_animatlab) 
    print("csv file read")

    for muscle_value in animatlab_sentences['muscle_values'][1:]:
        muscle_value_int = convert_muscle_singles_to_ints(muscle_value)
        print("writing")
        print(muscle_value_int)
        serial_write_command_data_ints2micro(serial_port_micro, 
                                             muscle_value_int,
                                             animatlab_sentences['muscle_ids'])
    
    serial_port_micro.close();

def read_sentence_from_animatlab(port):
    ### Testing implementation that reads from a csv file of muscle stimuli
    d = []
    ids = [43, 44, 39, 40, 41, 42] # ids of muscles as found in the csv file
    with open(stimulus_file, newline='') as f:
        #reader = csv.DictReader(f, delimiter=',')
        #d = defaultdict(list)
        #for row in reader:
        #    for k,v in row.items():
        #        d[k].append(v)

        reader = csv.reader(f, delimiter=',')
        for row in reader:
            d.append(row[1:]) # cutting time column off

    muscles = {'muscle_values' : d, 'muscle_ids' : ids}
    return muscles
        

def convert_muscle_singles_to_ints(muscles):
    return [round(remap(float(x), 0, 450, 0, 65535)) for x in muscles]


def remap(x, in_min, in_max, out_min, out_max):
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min


def uint16_to_uint8(x):
    bitstring = bin(x)[2:]
    if len(bitstring) < 16: # 0 pad at the front
        bitstring = '0' * (16 - len(bitstring)) + bitstring
    left = int(bitstring[:8],2)
    right = int(bitstring[8:],2)
    return [left, right]


def flatten_list(x):
    return [item for sublist in x for item in sublist]


def write_start_sequence(port, window_size=2):
    for i in range(window_size):
        port.write(bytes.fromhex(start_sequence_pattern))


def write_end_sequence(port):
    port.write(bytes.fromhex(end_sequence_pattern))


def serial_write_command_data_ints2micro(port, muscle_values, muscle_ids):
    byte_array = flatten_list([uint16_to_uint8(x) for x in muscle_values])
    #print(byte_array)

    num_commands = len(muscle_values)
    num_bytes_per_int = 2

    write_start_sequence(port)

    port.write(num_commands.to_bytes((num_commands.bit_length() + 7) // 8, micro_byte_order))

    for k in range(num_commands):
        loc = k * num_bytes_per_int;
        
        port.write((muscle_ids[k]).to_bytes(1,micro_byte_order)) 
        port.write(byte_array[loc].to_bytes(1,micro_byte_order))
        port.write(byte_array[loc+1].to_bytes(1,micro_byte_order))

    write_end_sequence(port)


def open_serial():
    return serial.Serial(micro_USB_port,
            baudrate=micro_baud_rate,
            bytesize=micro_data_bits,
            parity=micro_parity,
            stopbits=micro_stopbits)


#if __name__ == "__main__":
#    write_predefined()
