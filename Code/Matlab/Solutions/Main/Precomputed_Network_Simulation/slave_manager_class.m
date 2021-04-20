classdef slave_manager_class
    
    % This class contains properties and methods related to managing the slave microcontrollers.
    
    % Define the class properties.
    properties
        slaves
        num_slaves
        slave_packet_size
        conversion_manager
    end
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = slave_manager_class( slave_IDs, muscle_IDs, muscle_names, pressure_sensor_ID1s, pressure_sensor_ID2s, encoder_IDs, encoder_names, measured_pressure_value1s, measured_pressure_value2s, measured_encoder_values, desired_pressures )
            
            % Define the default class properties.
            if nargin < 11, desired_pressures = uint16( 0 ); end
            if nargin < 10, measured_encoder_values = uint16( 0 ); end
            if nargin < 9, measured_pressure_value2s = uint16( 0 ); end
            if nargin < 8, measured_pressure_value1s = uint16( 0 ); end
            if nargin < 7, encoder_names = {''}; end
            if nargin < 6, encoder_IDs = uint8( 0 ); end
            if nargin < 5, pressure_sensor_ID2s = uint8( 0 ); end
            if nargin < 4, pressure_sensor_ID1s = uint8( 0 ); end
            if nargin < 3, muscle_names = {''}; end
            if nargin < 2, muscle_IDs = uint8( 0 ); end
            if nargin < 1, slave_IDs = uint8( 0 ); end
            
            % Determine the number of slaves that we want to create.
            self.num_slaves = length(slave_IDs);
            
            % Ensure that we have the correct number of properties for each slave.
            slave_IDs = self.validate_property( slave_IDs, 'slave_IDs' );
            muscle_IDs = self.validate_property( muscle_IDs, 'muscle_IDs' );
            muscle_names = self.validate_property( muscle_names, 'muscle_names' );
            pressure_sensor_ID1s = self.validate_property( pressure_sensor_ID1s, 'pressure_sensor_ID1s' );
            pressure_sensor_ID2s = self.validate_property( pressure_sensor_ID2s, 'pressure_sensor_ID2s' );
            encoder_IDs = self.validate_property( encoder_IDs, 'encoder_IDs' );
            encoder_names = self.validate_property( encoder_names, 'encoder_names' );
            measured_pressure_value1s = self.validate_property( measured_pressure_value1s, 'measured_pressure_value1s' );
            measured_pressure_value2s = self.validate_property( measured_pressure_value2s, 'measured_pressure_value2s' );
            measured_encoder_values = self.validate_property( measured_encoder_values, 'measured_encoder_values' );
            desired_pressures = self.validate_property( desired_pressures, 'desired_pressures' );
            
            % Preallocate an array of muscles.
            self.slaves = repmat( slave_class(), 1, self.num_slaves );
            
            % Create each slave object.
            for k = 1:self.num_slaves              % Iterate through each slave...
                
                % Create this slave.
                self.slaves(k) = slave_class( slave_IDs(k), muscle_IDs(k), muscle_names{k}, pressure_sensor_ID1s(k), pressure_sensor_ID2s(k), encoder_IDs(k), encoder_names{k}, measured_pressure_value1s(k), measured_pressure_value2s(k), measured_encoder_values(k), desired_pressures(k) );
                
            end
            
            % Set the slave packet size to seven.
            self.slave_packet_size = 7;
            
            % Set the conversion manager.
            self.conversion_manager = conversion_manager_class();
            
        end
        
        
        % Implement a function to validate the input properties.
        function x = validate_property( self, x, var_name )
            
            % Set the default variable name.
            if nargin < 3, var_name = 'properties'; end
            
            % Determine whether we need to repeat this property for each muscle.
            if length(x) ~= self.num_slaves                % If the number of instances of this property do not agree with the number of slaves...
                
                % Determine whether to repeat this property for each muscle.
                if length(x) == 1                               % If only one slave property was provided...
                    
                    % Repeat the slave property.
                    x = repmat( x, 1, self.num_slaves );
                    
                else                                            % Otherwise...
                    
                    % Throw an error.
                    error( 'The number of provided %s must match the number of slaves being created.', var_name )
                    
                end
                
            end
            
        end
        
        
        
        % Implement a function to retrieve the index associated with a given slave ID.
        function slave_index = get_slave_index( self, slave_ID )
            
            % Set a flag variable to indicate whether a matching slave index has been found.
            bMatchFound = false;
            
            % Initialize the slave index.
            slave_index = 0;
            
            while (slave_index < self.num_slaves) && (~bMatchFound)
                
                % Advance the slave index.
                slave_index = slave_index + 1;
                
                % Check whether this slave index is a match.
                if self.slaves(slave_index).slave_ID == slave_ID                       % If this slave has the correct slave ID...
                    
                    % Set the match found flag to true.
                    bMatchFound = true;
                    
                end
                
            end
            
            % Determine whether a match was found.
            if ~bMatchFound                     % If a match was not found...
                
                % Throw an error.
                error('No slave with slave ID %0.0f', slave_ID)
                
            end
            
        end
        
        
        % Implement a function to retrieve the properties of specific slaves.
        function xs = get_slave_property( self, slave_IDs, slave_property )
            
            % Determine whether we want get the desired slave property from all of the slaves.
            if isa(slave_IDs, 'char')                                                      % If the slave IDs variable is a character array instead of an integer srray...
                
                % Determine whether this is a valid character array.
                if  strcmp(slave_IDs, 'all') || strcmp(slave_IDs, 'All')                  % If the character array is either 'all' or 'All'...
                    
                    % Preallocate an array to store the slave IDs.
                    slave_IDs = zeros(1, self.num_slaves);
                    
                    % Retrieve the slave ID associated with each slave.
                    for k = 1:self.num_slaves                   % Iterate through each slave...
                        
                        % Store the slave ID associated with the current slave ID.
                        slave_IDs(k) = self.slaves(k).slave_ID;
                        
                    end
                    
                else                                                                        % Otherwise...
                    
                    % Throw an error.
                    error('Slave_IDs must be either an array of valid slave IDs or one of the strings: ''all'' or ''All''.')
                    
                end
                
            end
            
            % Determine how many muscles to which we are going to apply the given method.
            num_properties_to_get = length(slave_IDs);
            
            % Preallocate a variable to store the slave properties.
            xs = zeros(1, num_properties_to_get);
            
            % Retrieve the given slave property for each slave.
            for k = 1:num_properties_to_get
                
                % Retrieve the index associated with this slave ID.
                slave_index = self.get_slave_index( slave_IDs(k) );
                
                % Define the eval string.
                eval_str = sprintf( 'xs(k) = self.slaves(%0.0f).%s;', slave_index, slave_property );
                
                % Evaluate the given muscle property.
                eval(eval_str);
                
            end
            
        end
        
        
        
        % Implement a function to set the desired pressure of each slave by retrieving the desired pressure for the associated muscle.
        function self = set_desired_pressure( self, slave_IDs, muscle_manager )
            
            % Determine how many slaves we want to set.
            num_slaves_to_set = length(slave_IDs);
            
            % Set the desired pressure for each of the given slaves.
            for k = 1:num_slaves_to_set                     % Iterate through each of the slaves we want to set...
                
                % Retrieve the index associated with this slave.
                slave_index = self.get_slave_index( slave_IDs(k) );
                
                % Retrieve the muscel ID associated with this slave.
                muscle_ID = self.slaves(slave_index).muscle_ID;
                
                % Retrieve the index associated with this slave's muscle.
                muscle_index = muscle_manager.get_muscle_index( muscle_ID );
                
                % Determine how to set this slave's desired pressure.
                if muscle_manager.muscles(muscle_index).desired_pressure < muscle_manager.muscles(muscle_index).pressure_domain(1)              % If the desired pressure for this muscle is less than the minimum acceptable pressure...
                    
                    % Set the desired pressure for this slave to be the minimum acceptable pressure.
                    desired_pressure = muscle_manager.muscles(muscle_index).pressure_domain(1);
                    
                elseif muscle_manager.muscles(muscle_index).desired_pressure > muscle_manager.muscles(muscle_index).pressure_domain(2)          % If the desired pressure for this muscle is greater than the maximum acceptable pressure...
                    
                    % Set the deisred pressure for this slave to be the maximum acceptable pressure.
                    desired_pressure = muscle_manager.muscles(muscle_index).pressure_domain(2);
                    
                else                                                                                                                            % Otherwise...
                    
                    % Set the desired pressure of this slave to be the desired pressure of its associated muscle.
                    desired_pressure = muscle_manager.muscles(muscle_index).desired_pressure;
                    
                end
                
                % Convert the desired pressure double to a uint16.
                self.slaves(k).desired_pressure = self.conversion_manager.double2uint16( desired_pressure, muscle_manager.muscles(muscle_index).pressure_domain );
                
            end
            
        end
        
        
        % Implement a function to store the sensor data into the slave manager.
        function self = store_sensor_data( self, usart_manager )
            
            % Retrieve the read bytes.
            read_bytes = usart_manager.read_from_master_bytes;
            
            % Initialize the byte index.
            byte_index = usart_manager.num_start_bytes + 1;
            
            % Retrieve the number of sensor data packets received.
            num_packets = read_bytes(byte_index);
            
            % Advance the byte index.
            byte_index = byte_index + 1;
            
            % Store the sensor data associated with each slave.
            for k = 1:num_packets                    % Iterate through each sensor data packet...
                
                % Retrieve the slave ID associated with this sensor data packet.
                slave_ID = read_bytes(byte_index);
                
                % Retrieve the slave index associated with this slave ID.
                slave_index = self.get_slave_index( slave_ID );
                
                % Retrieve the first pressure sensor value.
                self.slaves(slave_index).measured_pressure_value1 = typecast( read_bytes( (byte_index + 1):(byte_index + 2) ), 'uint16' );
                
                % Retrieve the second pressure sensor value.
                self.slaves(slave_index).measured_pressure_value2 = typecast( read_bytes( (byte_index + 3):(byte_index + 4) ), 'uint16' );
                
                % Retrieve the joint value.
                self.slaves(slave_index).measured_joint_value = typecast( read_bytes( (byte_index + 5):(byte_index + 6) ), 'uint16' );
                
                % Advance the byte index.
                byte_index = byte_index + self.slave_packet_size;
                
            end
            
            
        end
        
        
    end
end

