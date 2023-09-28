classdef electrical_subsystem_class
    
    % This class contains properties and methods related to the electrical subsystem.
    
    %% ELECTRICAL SUBSYSTEM PROPERTIES
    
    % Define the class properties.
    properties
        usart_manager
        slave_manager
    end
    
    
    %% ELECTRICAL SUBSYSTEM METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = electrical_subsystem_class( usart_manager, slave_manager )
            
            % Set the default electrical subsystem properties.
            if nargin < 2, self.slave_manager = slave_manager_class(); else, self.slave_manager = slave_manager; end
            if nargin < 1, self.usart_manager = usart_manager_class(); else, self.usart_manager = usart_manager; end
            
        end
        
        
        % Implement a funciton to transfer sensor data from the USART manager to the slave manager.
        function self = usart_sensor_data2slave_manager_data( self )
            
            % Retrieve the read bytes.
            read_bytes = self.usart_manager.read_from_master_bytes;
            
            % Initialize the byte index.
            byte_index = self.usart_manager.num_start_bytes + 1;
            
            % Retrieve the number of sensor data packets received.
            num_packets = read_bytes(byte_index);
            
            % Advance the byte index.
            byte_index = byte_index + 1;
            
            % Store the sensor data associated with each slave.
            for k = 1:num_packets                    % Iterate through each sensor data packet...
                
                % Retrieve the slave ID associated with this sensor data packet.
                slave_ID = read_bytes(byte_index);
                
                % Retrieve the slave index associated with this slave ID.
                slave_index = self.slave_manager.get_slave_index( slave_ID );
                
                % Retrieve the first pressure sensor value.
                self.slave_manager.slaves(slave_index).measured_pressure_value1 = typecast( read_bytes( (byte_index + 1):(byte_index + 2) ), 'uint16' );
                
                % Retrieve the second pressure sensor value.
                self.slave_manager.slaves(slave_index).measured_pressure_value2 = typecast( read_bytes( (byte_index + 3):(byte_index + 4) ), 'uint16' );
                
                % Retrieve the joint value.
                self.slave_manager.slaves(slave_index).measured_encoder_value = typecast( read_bytes( (byte_index + 5):(byte_index + 6) ), 'uint16' );
                
                % Advance the byte index.
                byte_index = byte_index + self.slave_manager.SLAVE_PACKET_SIZE;
                
            end
            
        end
        
        
        % Implement a function to stage desired pressures for USART transmission to the master microcontroller.
        function self = stage_desired_pressures( self )
            
            % Retrieve the number of commands that we want to send to the master microcontroller.
            num_commands = self.slave_manager.num_slaves;
            
            % Preallocate the write bytes.
            write_bytes = uint8(zeros( 1, self.usart_manager.num_start_bytes + 1 + 3*num_commands + 1 ));
            
            % Initialize the check sum.
            check_sum = 0;
            
            % Initialize the byte index.
            byte_index = 1;
            
            % Add the number of start bytes to the write bytes array.
            for k = 1:self.usart_manager.num_start_bytes                  % Iterate through each of the start bytes...
                
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
                desired_pressure_bytes = typecast( self.slave_manager.slaves(k).desired_pressure, 'uint8' );
                
                % Add the muscle ID for this packet to the write array.
                write_bytes(byte_index) = uint8( self.slave_manager.slaves(k).muscle_ID );
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
            self.usart_manager.write_to_master_bytes = write_bytes;
            
        end
        
        
        % Implement a function to emulate the master microcontoller reading and writing commands to the virtual master serial port.
        function self = emulate_master_read_write( self, write_value )
            
            % Determine whether we need to set the default write value.
            if nargin < 2               % If we were not given a write value...
                
                % Set the sensor value bytes to be random.
                sensor_value_bytes = uint8( randi(255, 1, (self.slave_manager.SLAVE_PACKET_SIZE - 1)) );
                
            else                        % Otherwise...
                
                % Validate the write value.
                if (write_value >= 0) && (write_value <= 255)           % If the write value is valid...
                    
                    % Set the sensor value bytes to be the specified write value.
                    sensor_value_bytes = uint8( write_value*ones(1, self.slave_manager.SLAVE_PACKET_SIZE - 1) );
                    
                else                                                    % Otherwise...
                    
                    % Throw an error.
                    error('write_value must be in the domain [0, 255].')
                    
                end
                
            end
                        
            % Ensure that there are items in the buffer before attempting to read.
            while self.usart_manager.master_output_virtual_serial_port.NumBytesAvailable == 0, end
            
            % Emulate the master microcontroller reading the bytes sent from Matlab.
            temp = read( self.usart_manager.master_output_virtual_serial_port, self.usart_manager.master_output_virtual_serial_port.NumBytesAvailable, 'uint8' );
            
            % Create an array of bytes that we will emulate the master microcontroller writing.
            write_bytes = uint8( zeros( 1, self.usart_manager.num_start_bytes + 1 + self.slave_manager.SLAVE_PACKET_SIZE*self.slave_manager.num_slaves + 1 ) );
            
            % Define the first several write bytes.
            write_bytes(1:self.usart_manager.num_start_bytes) = uint8( 255*ones( 1, self.usart_manager.num_start_bytes ) ); write_bytes(self.usart_manager.num_start_bytes + 1) = uint8( self.slave_manager.num_slaves );
            
            % Initialize the byte index.
            byte_index = self.usart_manager.num_start_bytes + 2;
            
            % Define the sensor data bytes.
            for k = 1:self.slave_manager.num_slaves                      % Iterate through each of the slaves...
                
                % Add the slave ID of this packet to the write bytes.
                write_bytes(byte_index) = uint8( k );
                
                % Add the sensor value bytes for each sensor.
                %                write_bytes(byte_index + (1:(self.slave_manager.SLAVE_PACKET_SIZE - 1))) = uint8( randi(255, 1, (slave_manager.SLAVE_PACKET_SIZE - 1)) );
                write_bytes(byte_index + (1:(self.slave_manager.SLAVE_PACKET_SIZE - 1))) = sensor_value_bytes;
                
                % Advance the byte index.
                byte_index = byte_index + self.slave_manager.SLAVE_PACKET_SIZE;
                
            end
            
            % Add the check sum index to the write bytes.
            write_bytes(end) = uint8( mod( sum( write_bytes ), 256 ) );
            
            % Emulate the master microcontroller writing these bytes to Matlab.
            write( self.usart_manager.master_output_virtual_serial_port, write_bytes, 'uint8' )
            
        end
        
        
        % Implement a function to write the desired pressures store the in the slave manager to the master microcontroller. ( Slave Manager Desired Pressures -> Master Microcontroller )
        function self = write_desired_pressures_to_master( self )
            
            % Stage the desired BPA pressures for USART transmission to the master microcontroller.  ( Slave Manager Desired Pressures -> USART Write To Master Bytes )
            self = self.stage_desired_pressures(  );
            
            % Write the desired BPA pressures to the master microcontroller. ( USART Write To Master Bytes -> Master Microcontroller ( Real or Virtual ) Serial Port )
            self.usart_manager.write_bytes_to_master( );
            
        end
        
        
        % Implement a function to read sensor data (muscle pressures and joint angles) from the master microcontroller. ( Master Microcontroller BPA Pressures & Joint Angles -> Slave Manager )
        function self = read_sensor_data_from_master( self )
            
            % Determine whether we need to emulate the master microcontroller behavior. ( Master Microcontroller ( Real or Virtual ) Serial Port -> Desktop Serial Port )
            if strcmp( self.usart_manager.master_port_type, 'virtual' ) || strcmp( self.usart_manager.master_port_type, 'Virtual' )                   % If we are using a virtual port for the master microcontroller...
                
                % Emulate the master microcontroller reporting sensory information to Matlab.
                self = self.emulate_master_read_write(  );
                
            end
            
            % Retrieve the sensor data from the master microcontroller via USART transmission. ( Desktop Serial Port -> USART Manager )
            self.usart_manager = self.usart_manager.read_bytes_from_master(  );
            
            % Transfer data from the usart manager to the slave manager. ( USART Manager Data -> Slave Manager Data )
            self = self.usart_sensor_data2slave_manager_data(  );
            
        end
        
        
        
    end
end

