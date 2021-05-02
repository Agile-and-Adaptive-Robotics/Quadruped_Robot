classdef robot_class

    % This class contains properties and methods related to the robot.
    
    %% ROBOT PROPERTIES
    
    % Define the class properties.
    properties
        neural_subsystem
        mechanical_subsystem
        electrical_subsystem
        conversion_manager
    end
    
    
    %% ROBOT METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = robot_class( neural_subsystem, mechanical_subsystem, electrical_subsystem )

            % Create an instance of the conversion manager class.
            self.conversion_manager = conversion_manager_class(  );
            
            % Set the default quadruped robot properties.
            if nargin < 3, self.electrical_subsystem = electrical_subsystem_class(); else, self.electrical_subsystem = electrical_subsystem; end
            if nargin < 2, self.mechanical_subsystem = mechanical_subsystem_class(); else, self.mechanical_subsystem = mechanical_subsystem; end
            if nargin < 1, self.neural_subsystem = neural_subsystem_class(); else, self.neural_subsystem = neural_subsystem; end

        end
        

        % Implement a function to transfer slave manager data to BPA muscle manager data (i.e., measured pressure from slave to BPA manager).
        function self = slave_measured_pressures2BPA_measured_pressures( self )
                    
            % Retrieve the IDs of each pressure sensor.
            pressure_IDs1 = self.electrical_subsystem.slave_manager.get_slave_property( 'all', 'pressure_sensor_ID1' );
            pressure_IDs2 = self.electrical_subsystem.slave_manager.get_slave_property( 'all', 'pressure_sensor_ID2' );

            % Retrieve only the unique pressure sensor IDs.
            pressure_IDs = unique( [ pressure_IDs1, pressure_IDs2 ] );
            
            % Determine the number of pressure sensors.
            num_pressure_sensors = length( pressure_IDs );
            
            % Preallocate an array to store the pressures.
            pressures = zeros(1, num_pressure_sensors);
            
            % Compute the pressure associated with each pressure sensor.
            for k = 1:num_pressure_sensors                              % Iterate through each pressure sensor.
                
                % Retrieve the indexes of the slaves that read this pressure sensor.
                slave_index1 = find( pressure_IDs1 == pressure_IDs(k) );
                slave_index2 = find( pressure_IDs2 == pressure_IDs(k) );

                % Retrieve the muscle ID associated with each of the slaves that read this pressure sensor.
                BPA_muscle_ID = self.electrical_subsystem.slave_manager.slaves(slave_index1).muscle_ID;
                
                % Retrieve the measured pressure values for this pressure sensor.
                pressure_value1_uint16 = self.electrical_subsystem.slave_manager.slaves(slave_index1).measured_pressure_value1;
                pressure_value2_uint16 = self.electrical_subsystem.slave_manager.slaves(slave_index2).measured_pressure_value2;

                % Retrieve the maximum pressure associated with this slave's BOA muscle.
                max_pressure = self.mechanical_subsystem.limb_manager.get_BPA_muscle_property( BPA_muscle_ID, 'max_pressure' );
                
                % Convert the measured pressure values from uint16s to doubles.
                pressure_value1 = self.conversion_manager.uint162double( pressure_value1_uint16, [0, max_pressure] );
                pressure_value2 = self.conversion_manager.uint162double( pressure_value2_uint16, [0, max_pressure] );

                % Take the average pressure sensor reading from all of the pressure readings across possibly many slaves.
                pressures(k) = mean( [ pressure_value1, pressure_value2 ] );
                
                % Store the measured muscle pressure.                
                self.mechanical_subsystem.limb_manager = self.mechanical_subsystem.limb_manager.set_BPA_muscle_property( BPA_muscle_ID, pressures(k), 'measured_pressure' );
                
            end
            
        end
        
        

        % Implement a function to transfer BPA muscle measured tension values to hill muscle measured total tension values.
        function self = BPA_muscle_measured_tensions2hill_muscle_measured_tensions( self )
            
            % Retrieve the BPA muscle IDs and measured tensions.
            BPA_muscle_IDs = self.mechanical_subsystem.limb_manager.get_BPA_muscle_property( 'all', 'ID' );
            BPA_muscle_measured_tensions = self.mechanical_subsystem.limb_manager.get_BPA_muscle_property( 'all', 'measured_tension' );

            % Set each hill muscle measured total tension to match the measured tension of its associated BPA muscle.
            for k = 1:self.neural_subsystem.hill_muscle_manager.num_hill_muscles                    % Iterate through each hill muscle...
            
                % Determine the index of the BPA muscle associated with this hill muscle.
                BPA_muscle_index = find( self.neural_subsystem.hill_muscle_manager.hill_muscles(k).ID == BPA_muscle_IDs, 1 );
                
                % Determine whether to set the measured total tension of this hill muscle.
                if ~isempty(BPA_muscle_index)                   % If we found a BPA muscle with the same ID as this hill muscle...
                    
                    % Set the hill muscle to have the same measured total tension as the BPA muscle.
                   self.neural_subsystem.hill_muscle_manager.hill_muscles(k).measured_total_tension = BPA_muscle_measured_tensions(BPA_muscle_index);
                    
                end
                
            end
                            
        end
        
        
        
        % Implement a function to transfer hill muscle measured total tension values to BPA muscle measured tension values.
        function self = hill_muscle_measured_tensions2BPA_muscle_measured_tensions( self )
            
            % Retrieve the number of BPA muscles.
            num_BPA_muscles = self.mechanical_subsystem.limb_manager.get_number_of_BPA_muscles(  );
            
            % Retrieve the BPA and hill muscle IDs.
            BPA_muscle_IDs = self.mechanical_subsystem.limb_manager.get_BPA_muscle_property( 'all', 'ID' );
            hill_muscle_IDs = self.neural_subsystem.hill_muscle_manager.get_muscle_property( 'all', 'ID' );
            
            % Preallocate a variable to store the BPA muscle tensions that we want to set.
            BPA_muscle_tensions = zeros( 1, num_BPA_muscles );
            
            % Set each BPA muscle measured tension to match the measured total tension of its associated hill muscle.
            for k = 1:num_BPA_muscles                    % Iterate through each BPA muscle...
            
                % Determine the index of the BPA muscle associated with this hill muscle.
                hill_muscle_index = find( BPA_muscle_IDs(k) == hill_muscle_IDs, 1 );
                
                % Determine whether to set the measured tension of this BPA muscle.
                if ~isempty(hill_muscle_index)                   % If we found a hill muscle with the same ID as this BPA muscle...
                    
                    % Store the hill muscle measured total tension associated with this BPA muscle.
                   BPA_muscle_tensions(k) = self.neural_subsystem.hill_muscle_manager.hill_muscles(hill_muscle_index).measured_total_tension;
                   
                end
                
            end
                            
            % Set the measured tension of each BPA muscle to match the tensions that we have collected from the associated hill muscles.
            self.mechanical_subsystem.limb_manager.set_BPA_muscle_property( BPA_muscle_IDs, BPA_muscle_tensions, 'muscle_tension' );
            
            
        end
        
        
    end
end

