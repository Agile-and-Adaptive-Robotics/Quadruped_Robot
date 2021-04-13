classdef usart_manager_class
    
    % This class contains properties and methods related to managing USART communication.
    
    % Define the class properties.
    properties
        
        read_from_animatlab_bytes
        write_to_master_bytes
        read_from_master_bytes
        write_to_animatlab_bytes
        
        master_physical_serial_port
        
        master_input_virtual_serial_port
        master_output_virtual_serial_port
        
        matlab_input_serial_port
        matlab_output_serial_port
        
        animatlab_input_serial_port
        animatlab_output_serial_port
        
        num_start_bytes
        
    end
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = usart_manager_class( master_physical_serial_port, master_input_virtual_serial_port, master_output_virtual_serial_port, matlab_input_serial_port, matlab_output_serial_port, animatlab_input_serial_port, animatlab_output_serial_port, num_start_bytes, write_to_animatlab_bytes, read_from_master_bytes, write_to_master_bytes, read_from_animatlab_bytes )
            
            % Define the bytes that have been read from animatlab.
            if nargin < 12, self.read_from_animatlab_bytes = 0; else, self.read_from_animatlab_bytes = read_from_animatlab_bytes; end
            
            % Define the bytes to write to the master microcontroller.
            if nargin < 11, self.write_to_master_bytes = 0; else, self.write_to_master_bytes = write_to_master_bytes; end
            
            % Define the bytes that have beenb read from the master microcontroller.
            if nargin < 10, self.read_from_master_bytes = 0; else, self.read_from_master_bytes = read_from_master_bytes; end
            
            % Define the bytes to write to animatlab.
            if nargin < 9, self.write_to_animatlab_bytes = 0; else, self.write_to_animatlab_bytes = write_to_animatlab_bytes; end
            
            % Define the number of start bytes to write at the beginning of USART transmissions to the master microcontroller.
            if nargin < 8, self.num_start_bytes = 2; else, self.num_start_bytes = num_start_bytes; end
            
            % Define the animatlab output serial port.
            if nargin < 7, self.animatlab_output_serial_port = 0; else, self.animatlab_output_serial_port = animatlab_output_serial_port; end
            
            % Define the animatlab input serial port.
            if nargin < 6, self.animatlab_input_serial_port = 0; else, self.animatlab_input_serial_port = animatlab_input_serial_port; end
            
            % Define the matlab input serial port.
            if nargin < 5, self.matlab_output_serial_port = 0; else, self.matlab_output_serial_port = matlab_output_serial_port; end
            
            % Define the matlab input serial port.
            if nargin < 4, self.matlab_input_serial_port = 0; else, self.matlab_input_serial_port = matlab_input_serial_port; end
            
            % Define the virtual master microcontoller serial port output.
            if nargin < 3, self.master_output_virtual_serial_port = 0; else, self.master_output_virtual_serial_port = master_output_virtual_serial_port; end
            
            % Define the virtual master microcontoller serial port input.
            if nargin < 2, self.master_input_virtual_serial_port = 0; else, self.master_input_virtual_serial_port = master_input_virtual_serial_port; end
            
            % Define the physical master microcontroller serial port.
            if nargin < 1, self.master_physical_serial_port = 0; else, self.master_physical_serial_port = master_physical_serial_port; end
            
        end
        
        
        % Implement a function to close serial ports.
        function close_serial_port( ~, serial_port, bVerbose )
            
            % Set the default input arguments.
            if nargin < 3, bVerbose = false; end
            
            % State that we are closing the serial port.
            if bVerbose, fprintf('\nCLOSING SERIAL PORT. Please Wait...\n'), end
            
            % Clear any existing commands in the serial port.
            flush(serial_port)
            
            % Close the Serial Port.
            delete(serial_port);
            
            % State that the serial port is closed.
            if bVerbose, fprintf('CLOSING SERIAL PORT. Please Wait... Done.\n\n'), end
            
        end
        
        
        % Implement a function to open serial ports.
        function serial_port = open_serial_port( self, Port, BaudRate, bVerbose )
            
            % Set the default input arguments.
            if nargin < 4, bVerbose = false; end
            
            % Retrieve any open ports with the specified name.
            open_port = instrfind( {'Port', 'Status'}, {Port, 'open'} );
            
            % Ensure that the serial port is closed before attempting to open it.
            if ~isempty(open_port)                  %If this serial port is already in use...
                self.close_serial_port(open_port);         %Close the serial port before proceeding...
            end
            
            %State that we are opening the serial port.
            if bVerbose, fprintf('\nOPENING SERIAL PORT. Please Wait...\n'), end
            
            %Define the serial port.
            serial_port = serialport(Port, BaudRate);
            
            %Clear any existing commands in the serial port.f
            flush(serial_port)
            
            %State that the serial port is open.
            if bVerbose, fprintf('OPENING SERIAL PORT. Done.\n\n'), end
            
        end
        
        
        % Implement a function to initialize the serial ports.
        function self = initialize_serial_ports( self, COM_port_names, baud_rate_physical_ports, baud_rate_virtual_ports, bVerbose )
            
            % Set the default input arguments.
            if nargin < 5, bVerbose = false; end
            
            % Open the physical master microcontroller serial port.
            self.master_physical_serial_port = self.open_serial_port( COM_port_names{1}, baud_rate_physical_ports, bVerbose );
            
            % Open the virtual master microcontroller input serial port.
            self.master_input_virtual_serial_port = self.open_serial_port( COM_port_names{2}, baud_rate_virtual_ports, bVerbose );
            
            % Open the virtual master microcontroller output serial port.
            self.master_output_virtual_serial_port = self.open_serial_port( COM_port_names{3}, baud_rate_virtual_ports, bVerbose );
            
            % Open the Matlab input serial port.
            self.matlab_input_serial_port = self.open_serial_port( COM_port_names{4}, baud_rate_virtual_ports, bVerbose );
            
            % Open the Matlab output serial port.
            self.matlab_output_serial_port = self.open_serial_port( COM_port_names{5}, baud_rate_virtual_ports, bVerbose );
            
            % Open the Animatlab input serial port.
            self.animatlab_input_serial_port = self.open_serial_port( COM_port_names{6}, baud_rate_virtual_ports, bVerbose );
            
            % Open the Animatlab output serial port.
            self.animatlab_output_serial_port = self.open_serial_port( COM_port_names{7}, baud_rate_virtual_ports, bVerbose );
            
        end
        
        
        % Implement a function to terminate the serial ports.
        function self = terminate_serial_ports( self )
            
            % Close the physical master microcontoller serial port.
            self.close_serial_port( self.master_physical_serial_port ); self.master_physical_serial_port = [];
            
            % Close the virtual master microcontoller input serial port.
            self.close_serial_port( self.master_input_virtual_serial_port ); self.master_input_virtual_serial_port = [];
            
            % Close the virtual master microcontoller output serial port.
            self.close_serial_port( self.master_output_virtual_serial_port ); self.master_output_virtual_serial_port = [];
            
            % Close the matlab input serial port.
            self.close_serial_port( self.matlab_input_serial_port ); self.matlab_input_serial_port = [];
            
            % Close the matlab output serial port.
            self.close_serial_port( self.matlab_output_serial_port ); self.matlab_output_serial_port = [];
            
            % Close the animatlab input serial port.
            self.close_serial_port( self.animatlab_input_serial_port ); self.animatlab_input_serial_port = [];
            
            % Close the animatlab output serial port.
            self.close_serial_port( self.animatlab_output_serial_port ); self.animatlab_output_serial_port = [];
            
        end
        
        
        % Implement a function to validate the check sum.
        function bsuccess = validate_check_sum( ~, bytes_to_validate, bverbose )
           
            % Set the default level of verbosity.
            if nargin < 3, bverbose = false; end
            
            % Retrieve the check sum that we were sent in this byte array.
            check_sum_desired = bytes_to_validate(end);
            
            % Compute the check sum of this byte array.
            check_sum_actual = mod( sum( bytes_to_validate( 1:(end - 1) ) ), 256 );
            
            % Determine whether to throw a warning.
            if check_sum_desired ~= check_sum_actual            % If the check sums do not agree...
               
                % Set the check sum success flag to false.
                bsuccess = false;
                
                % Throw a check sum warning.
                if bverbose, warning('Check sum error detected!'), end
                
            else
                
                % Set the check sum success flag to true.
                bsuccess = true;
                
            end
            
        end
        
        
        % Implement a function to stage desired pressures for USART transmission to the master microcontroller.
        function self = stage_desired_pressures( self, slave_manager )
            
            % Retrieve the number of commands that we want to send to the master microcontroller.
            num_commands = slave_manager.num_slaves;
            
            % Preallocate the write bytes.
            write_bytes = uint8(zeros( 1, self.num_start_bytes + 1 + 3*num_commands + 1 ));
            
            % Initialize the check sum.
            check_sum = 0;
            
            % Initialize the byte index.
            byte_index = 1;
            
            % Add the number of start bytes to the write bytes array.
            for k = 1:self.num_start_bytes                  % Iterate through each of the start bytes...
                
                % Add this start byte to the write bytes array.
                write_bytes(byte_index) = uint8( 255 );
                check_sum = check_sum + double( write_bytes(byte_index) );
                byte_index = byte_index + 1;
                
            end
            
            % Add the number of commands to the write bytes.
            write_bytes(byte_index) = uint8( num_commands );
            check_sum = check_sum + double( write_bytes(byte_index) );
            byte_index = byte_index + 1;
            
            % Add each command packet to the write bytes.
            for k = 1:num_commands                     % Iterate through each command packet...
                
                % Get the lower and upper bytes of the desired pressure associated with this slave.
                desired_pressure_bytes = typecast( slave_manager.slaves(k).desired_pressure, 'uint8' );
                
                % Add the muscle ID for this packet to the write array.
                write_bytes(byte_index) = uint8( slave_manager.slaves(k).muscle_ID );
                check_sum = check_sum + double( write_bytes(byte_index) );
                byte_index = byte_index + 1;
                
                % Add the lower desired pressure command byte to the write array.
                write_bytes(byte_index) = desired_pressure_bytes(1);
                check_sum = check_sum + double( write_bytes(byte_index) );
                byte_index = byte_index + 1;
                
                % Add the upper desired pressure command byte to the write array.
                write_bytes(byte_index) = desired_pressure_bytes(2);
                check_sum = check_sum + double( write_bytes(byte_index) );
                byte_index = byte_index + 1;
                
            end
            
            % Roll over the check sum.
            check_sum = mod( check_sum, 256 );
            
            % Add the check sum byte to the write bytes.
            write_bytes(byte_index) = uint8( check_sum );
            
            % Stage the bytes to write.
            self.write_to_master_bytes = write_bytes;
            
        end
        
        
        % Implement a function to wait for the start sequence.
        function wait_for_start_sequence( self, serial_port, bverbose )
            
            % Set the default input arguments.
            if nargin < 3, bverbose = false; end
            
            % Wait for there to be enough information to fill up the window.
            while (serial_port.NumBytesAvailable < (self.num_start_bytes + 2))                      % Determine whether there are enough bytes for the start sequence...
                
                % Determine whether to print the status message.
                if bverbose, fprintf('Not enough bytes for start sequence. %0.0f of %0.0f bytes detected.\n', serial_port.NumBytesAvailable, (self.num_start_bytes + 2)), end
                
            end
            
            % Preallocate the previous read bytes to zeros.
            byte_window = zeros(1, self.num_start_bytes);
            
            % Preallocate the sequence detected flag to false.
            bStartSequenceDetected = 0;
            
            % Search for the starting sequence.
            while (serial_port.NumBytesAvailable > 0) && (~bStartSequenceDetected)                      % While there is still data to read and the start sequence has not been detected...
                
                % Determine whether to print the status message.
                if bverbose, fprintf('Waiting for start sequence. Current window: '), disp(byte_window), end
                
                % Shift the byte window over.
                byte_window = [ read( serial_port, 1, 'uint8' ) byte_window( 1:(self.num_start_bytes - 1) ) ];
                
                % Determine whether the start sequence has been detected.
                bStartSequenceDetected = all( byte_window == 255 );
                
            end
            
        end
        
        
        % Implement a function to write the staged bytes to the master microcontoller.
        function write_bytes_to_master( self, master_port_type )
            
            % Define the default master port type.
            if nargin < 2, master_port_type = 'virtual'; end
            
            % Determine how to write the staged bytes.
            if strcmp(master_port_type, 'virtual') || strcmp(master_port_type, 'Virtual')                   % If we want to write to the virtual port...
                
                % Write the staged bytes to the virtual master port.
                write( self.master_input_virtual_serial_port, self.write_to_master_bytes, 'uint8' );
                
            else                                                                                            % Otherwise... (If we want to write to the physical port...)
                
                % Write the staged bytes to the physical master port.
                write( self.master_physical_serial_port, self.write_to_master_bytes, 'uint8' );
                
            end
            
        end
        
        
        % Implement a function to write the staged bytes to Animatlab.
        function write_bytes_to_animatlab( self )
            
            % Write the staged bytes to Animatlab.
            write( self.matlab_output_serial_port, self.write_to_animatlab_bytes, 'uint8' );
            
        end
        
        
        % Implement a function to read the bytes from the master microcontoller.
        function self = read_bytes_from_master( self, slave_packet_size, master_port_type, bverbose )
            
            % Define the default input arguments.
            if nargin < 4, bverbose = false; end
            if nargin < 3, master_port_type = 'virtual'; end
            if nargin < 2, slave_packet_size = 7; end

            % Define the serial port from which we want to read.
            if strcmp(master_port_type, 'virtual') || strcmp(master_port_type, 'Virtual')                   % If we want to write to the virtual port...
                
                % Retrieve the virtual master input serial port.
                serial_port = self.master_input_virtual_serial_port;
                
            else
                
                % Retrieve the physical master serial port.
                serial_port = self.master_physical_serial_port;
                
            end
            
            % Wait for the start sequence.
            self.wait_for_start_sequence( serial_port, bverbose );
            
            % Read in the number of slaves to expect.
            num_slaves = read( serial_port, 1, 'uint8' );
            
            % Compute the total number of bytes in this message.
            total_bytes = self.num_start_bytes + 1 + slave_packet_size*num_slaves + 1;
            
            % Preallocate the read from master bytes.
            read_bytes = uint8( zeros( 1, total_bytes ) );
            
            % Set the first several of the read from master bytes.
            read_bytes(1:self.num_start_bytes) = uint8( 255*ones(1, self.num_start_bytes) ); read_bytes(self.num_start_bytes + 1) = uint8( num_slaves );
            
            % Set the rest of the bytes.
            read_bytes(4:end) = read( serial_port, total_bytes - 3, 'uint8' );
            
            % Validate the check sum.
            bValidCheckSum = self.validate_check_sum( read_bytes, true );
            
            % Determine whether to store the read bytes.
            if bValidCheckSum                       % If the check sum is valid...
            
                % Store the read bytes.
                self.read_from_master_bytes = read_bytes;                
                
            end
                
        end
        
        
        % Implement a function to read the bytes from Animatlab.
        function self = read_bytes_from_animatlab( self )
            
            
            
        end
        
        
        % Implement a function to emulate the master microcontoller reading and writing commands to the virtual master serial port.
        function emulate_master_read_write( self, slave_manager, write_value )
            
            % Determine whether we need to set the default write value.
            if nargin < 3               % If we were not given a write value...
                
                % Set the sensor value bytes to be random.
                sensor_value_bytes = uint8( randi(255, 1, (slave_manager.slave_packet_size - 1)) );
                
            else                        % Otherwise...
                
                % Validate the write value.
                if (write_value >= 0) && (write_value <= 255)           % If the write value is valid...
                    
                    % Set the sensor value bytes to be the specified write value.
                    sensor_value_bytes = uint8( write_value*ones(1, slave_manager.slave_packet_size - 1) );
                    
                else                                                    % Otherwise...
                    
                    % Throw an error.
                    error('write_value must be in the domain [0, 255].')
                    
                end
                
            end
                
            % Emulate the master microcontroller reading the bytes sent from Matlab.
            temp = read( self.master_output_virtual_serial_port, self.master_output_virtual_serial_port.NumBytesAvailable, 'uint8' );
            
            % Create an array of bytes that we will emulate the master microcontroller writing.
            write_bytes = uint8( zeros( 1, self.num_start_bytes + 1 + slave_manager.slave_packet_size*slave_manager.num_slaves + 1 ) );
            
            % Define the first several write bytes.
            write_bytes(1:self.num_start_bytes) = uint8( 255*ones( 1, self.num_start_bytes ) ); write_bytes(self.num_start_bytes + 1) = uint8( slave_manager.num_slaves );

            % Initialize the byte index.
            byte_index = self.num_start_bytes + 2;
            
            % Define the sensor data bytes.
            for k = 1:slave_manager.num_slaves                      % Iterate through each of the slaves...
                
                % Add the slave ID of this packet to the write bytes.
               write_bytes(byte_index) = uint8( k );
               
               % Add the sensor value bytes for each sensor.
%                write_bytes(byte_index + (1:(slave_manager.slave_packet_size - 1))) = uint8( randi(255, 1, (slave_manager.slave_packet_size - 1)) );
               write_bytes(byte_index + (1:(slave_manager.slave_packet_size - 1))) = sensor_value_bytes;

               % Advance the byte index.
               byte_index = byte_index + slave_manager.slave_packet_size;
               
            end
            
            % Add the check sum index to the write bytes.
            write_bytes(end) = uint8( mod( sum( write_bytes ), 256 ) );
            
            % Emulate the master microcontroller writing these bytes to Matlab.
            write( self.master_output_virtual_serial_port, write_bytes, 'uint8' )
            
        end
        
        
    end
end

