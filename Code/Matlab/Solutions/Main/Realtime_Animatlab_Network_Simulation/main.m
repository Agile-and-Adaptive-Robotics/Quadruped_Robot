%% Matlab Microcontroller Communication Main Script

% Clear Everything.
clear, close('all'), clc


%% Initialize Slave, Muscle, Physics, and USART Data Managers.

% Create an instance of the slave manager class.
slave_manager = slave_manager_class();

% Initialize the slave class array within the slave manager class.
slave_manager = slave_manager.initialize_slaves();


% Create an instance of the muscle manager class.
muscle_manager = muscle_manager_class();

% Initialize the muscle class array within the muscle manager class.
muscle_manager = muscle_manager.initialize_muscles();


%% Initialize USART Communication.

%Define the baud rates.
baud_rate_virtual_ports = 115200; baud_rate_physical_ports = 57600;

% Define the COM port names.
COM_port_names = { 'COM6', 'COM10', 'COM13', 'COM11', 'COM9' };                 % { Master Port, Matlab Input Port, Matlab Output Port, Animatlab Input Port, Animatlab Output Port }. 

% Create an instance of the USART manager class.
usart_manager = usart_manager_class();

% Initialize the USART serial ports.
usart_manager = usart_manager.initialize_serial_ports( COM_port_names, baud_rate_physical_ports, baud_rate_virtual_ports );


%%


%% Terminate USART Communication.

% Terminate the USART serial ports.
usart_manager = usart_manager.terminate_serial_ports();



