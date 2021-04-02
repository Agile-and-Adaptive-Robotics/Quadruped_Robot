classdef usart_manager_class

    % This class contains properties and methods related to managing USART communication.
    
    % Define the class properties.
    properties
        
        read_from_animatlab_bytes
        write_to_master_bytes
        read_from_master_bytes
        write_to_animatlab_bytes
        
        master_serial_port
        
        matlab_input_serial_port
        matlab_output_serial_port
        
        animatlab_input_serial_port
        animatlab_output_serial_port
        
    end
    
    % Define the class methods.
    methods

        % Implement the class constructor.
        function self = usart_manager_class( master_serial_port, matlab_input_serial_port, matlab_output_serial_port, animatlab_input_serial_port, animatlab_output_serial_port, write_to_animatlab_bytes, read_from_master_bytes, write_to_master_bytes, read_from_animatlab_bytes )

            % Define the bytes that have been read from animatlab.
            if nargin < 9, self.read_from_animatlab_bytes = 0; else, self.read_from_animatlab_bytes = read_from_animatlab_bytes; end

            % Define the bytes to write to the master microcontroller.
            if nargin < 8, self.write_to_master_bytes = 0; else, self.write_to_master_bytes = write_to_master_bytes; end

            % Define the bytes that have beenb read from the master microcontroller.
            if nargin < 7, self.read_from_master_bytes = 0; else, self.read_from_master_bytes = read_from_master_bytes; end
            
            % Define the bytes to write to animatlab.
            if nargin < 6, self.write_to_animatlab_bytes = 0; else, self.write_to_animatlab_bytes = write_to_animatlab_bytes; end
            
            % Define the animatlab output serial port.
            if nargin < 5, self.animatlab_output_serial_port = 0; else, self.animatlab_output_serial_port = animatlab_output_serial_port; end
            
            % Define the animatlab input serial port.
            if nargin < 4, self.animatlab_input_serial_port = 0; else, self.animatlab_input_serial_port = animatlab_input_serial_port; end
            
            % Define the matlab input serial port.
            if nargin < 3, self.matlab_output_serial_port = 0; else, self.matlab_output_serial_port = matlab_output_serial_port; end
            
            % Define the matlab input serial port.
            if nargin < 2, self.matlab_input_serial_port = 0; else, self.matlab_input_serial_port = matlab_input_serial_port; end
            
            % Define the master microcontroller serial port.
            if nargin < 1, self.master_serial_port = 0; else, self.master_serial_port = master_serial_port; end
            
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
            
            % Open the master microcontroller serial port.
            self.master_serial_port = self.open_serial_port( COM_port_names{1}, baud_rate_physical_ports, bVerbose );

            % Open the Matlab input serial port.
            self.matlab_input_serial_port = self.open_serial_port( COM_port_names{2}, baud_rate_virtual_ports, bVerbose );
            
            % Open the Matlab output serial port.
            self.matlab_output_serial_port = self.open_serial_port( COM_port_names{3}, baud_rate_virtual_ports, bVerbose );
            
            % Open the Animatlab input serial port.
            self.animatlab_input_serial_port = self.open_serial_port( COM_port_names{4}, baud_rate_virtual_ports, bVerbose );
            
            % Open the Animatlab output serial port.
            self.animatlab_output_serial_port = self.open_serial_port( COM_port_names{5}, baud_rate_virtual_ports, bVerbose );
            
        end
        
        
        % Implement a function to terminate the serial ports.
        function self = terminate_serial_ports( self )
        
            % Close the master microcontoller serial port.
            self.close_serial_port( self.master_serial_port ); self.master_serial_port = [];
            
            % Close the matlab input serial port.
            self.close_serial_port( self.matlab_input_serial_port ); self.matlab_input_serial_port = [];

            % Close the matlab output serial port.
            self.close_serial_port( self.matlab_output_serial_port ); self.matlab_output_serial_port = [];

            % Close the animatlab input serial port.
            self.close_serial_port( self.animatlab_input_serial_port ); self.animatlab_input_serial_port = [];

            % Close the animatlab output serial port.
            self.close_serial_port( self.animatlab_output_serial_port ); self.animatlab_output_serial_port = [];
            
        end
        
        
    end
end

