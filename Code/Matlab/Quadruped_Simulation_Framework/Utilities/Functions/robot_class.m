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
        
        
        %% Slave-BPA Functions

        % Implement a function to transfer slave manager measured pressures to BPA muscle manager measured pressures. ( Slave Measured Pressure -> BPA Measured Pressure )
        function self = slave_measured_pressures2BPA_measured_pressures( self )
                    
            % Retrieve the IDs of each pressure sensor.
            pressure_IDs1 = cell2mat( self.electrical_subsystem.slave_manager.get_slave_property( 'all', 'pressure_sensor_ID1' ) );
            pressure_IDs2 = cell2mat( self.electrical_subsystem.slave_manager.get_slave_property( 'all', 'pressure_sensor_ID2' ) );

            % Retrieve only the unique pressure sensor IDs.
            pressure_IDs = unique( [ pressure_IDs1, pressure_IDs2 ] );
            
            % Determine the number of pressure sensors.
            num_pressure_sensors = length( pressure_IDs );
            
            % Preallocate an array to store the pressures.
            pressures = cell( 1, num_pressure_sensors );
            
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
                max_pressure = cell2mat( self.mechanical_subsystem.limb_manager.get_BPA_muscle_property( BPA_muscle_ID, 'max_pressure' ) );
                
                % Convert the measured pressure values from uint16s to doubles.
                pressure_value1 = self.conversion_manager.uint162double( pressure_value1_uint16, [0, max_pressure] );
                pressure_value2 = self.conversion_manager.uint162double( pressure_value2_uint16, [0, max_pressure] );

                % Take the average pressure sensor reading from all of the pressure readings across possibly many slaves.
                pressures{k} = mean( [ pressure_value1, pressure_value2 ] );
                
                % Store the measured muscle pressure.                
                self.mechanical_subsystem.limb_manager = self.mechanical_subsystem.limb_manager.set_BPA_muscle_property( BPA_muscle_ID, pressures(k), 'measured_pressure' );
                
            end
            
        end
        
        
        % Implement a function to transfer BPA muscle manager desired pressures to slave manager desired pressures. ( BPA Desired Pressure -> Slave Desired Pressure )
        function self = BPA_desired_pressures2slave_desired_pressures( self )
            
            % Retrieve the number of slaves.
            num_slaves = self.electrical_subsystem.slave_manager.num_slaves;
           
            % Retrieve the BPA muscle IDs and BPA muscle desired pressures
            BPA_muscle_IDs = cell2mat( self.mechanical_subsystem.limb_manager.get_property_from_all_BPA_muscles( 'ID' ) );
            BPA_muscle_desired_pressures = cell2mat( self.mechanical_subsystem.limb_manager.get_property_from_all_BPA_muscles( 'desired_pressure' ) );
            BPA_muscle_max_pressures = cell2mat( self.mechanical_subsystem.limb_manager.get_property_from_all_BPA_muscles( 'max_pressure' ) );

            % Set the desired pressure of each slave.
            for k = 1:num_slaves                % Iterate through each slave...
                
                % Retrieve the BPA muscle ID associated with this slave.
                BPA_muscle_ID = self.electrical_subsystem.slave_manager.slaves(k).muscle_ID;
                
                % Retrieve the BPA muscle index associated with this BPA muscle ID.
                BPA_muscle_index = find( BPA_muscle_ID == BPA_muscle_IDs, 1 );
                
                % Set the desired pressure of this slave.
                if ~isempty(BPA_muscle_index)               % If we found a BPA muscle associated with this slave...
                
                    % Set the desired pressure of this slave.                
                    self.electrical_subsystem.slave_manager.slaves(k).desired_pressure = self.conversion_manager.double2uint16( BPA_muscle_desired_pressures(BPA_muscle_index), [0, BPA_muscle_max_pressures(BPA_muscle_index)] );
                    
                end
                
            end
            
        end
        
        
        %% Slave-Joint Functions
        
        % Implement a function to transfer slave manager joint angles to joint manager joint angles. ( Slave Angle -> Joint Angle )
        function self = slave_angle2joint_angle( self )

            % Retrieve the encoder IDs.
            encoder_IDs = cell2mat( self.electrical_subsystem.slave_manager.get_slave_property( 'all', 'joint_ID' ) );
            
            % Retrieve the encoder uint16s.
            encoder_uint16s = cell2mat( self.electrical_subsystem.slave_manager.get_slave_property( 'all', 'measured_encoder_value' ) );
            
            % Retrieve the encoder doubles.
            encoder_doubles = self.conversion_manager.uint162double( encoder_uint16s, [0, 2*pi] );
            
            % Retrieve the total number of joints.
            num_joints = self.mechanical_subsystem.limb_manager.get_number_of_joints(  );
            
            % Retrieve the joint IDs.
            joint_IDs = cell2mat( self.mechanical_subsystem.limb_manager.get_property_from_all_joints( 'ID' ) );
            
            % Preallocate an array to store the joint angles.
            joint_angles = zeros( 1, num_joints );
            
            % Set the joint angle for each joint.
            for k = 1:num_joints                % Iterate through each joint...
            
                % Retrieve the encoder indexes associated with this joint.
                encoder_indexes = joint_IDs(k) == encoder_IDs;
                
                % Determine whether to set the joint angle associated with this joint.
                if any( encoder_indexes )              % If we found a joint that matches any of the encoders...
                    
                    % Store the average joint angle reported by each slaves that measure encoders for this joint.
                    joint_angles(k) = mean( encoder_doubles(encoder_indexes) );
                    
                elseif ( k == 3 ) || ( k == 10 )        % If the current joint is one of the pantograph joints...
                    
                    % Flip the sign of the previous joint.
                    joint_angles(k) = -joint_angles(k - 1);
                    
                end
                
            end
                
            % Set the joint angle of each joint.
            self.mechanical_subsystem.limb_manager = self.mechanical_subsystem.limb_manager.set_joint_property( joint_IDs, num2cell( joint_angles ), 'theta' );
            
        end

        
        %% BPA Muscle - Hill Muscle Functions
        
        % Implement a function to transfer BPA muscle measured tension values to hill muscle measured total tension values.
        function self = BPA_muscle_measured_tensions2hill_muscle_measured_tensions( self )
            
            % Retrieve the BPA muscle IDs and measured tensions.
            BPA_muscle_IDs = self.mechanical_subsystem.limb_manager.get_ID_from_all_BPA_muscles(  );
            BPA_muscle_measured_tensions = self.mechanical_subsystem.limb_manager.get_measured_tension_from_all_BPA_muscles(  );
            
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
            BPA_muscle_IDs = self.mechanical_subsystem.limb_manager.get_ID_from_all_BPA_muscles(  );
            hill_muscle_IDs = self.neural_subsystem.hill_muscle_manager.validate_hill_muscle_IDs( 'all' );
            
            % Preallocate a variable to store the BPA muscle tensions that we want to set.
            BPA_muscle_measured_tensions = zeros( 1, num_BPA_muscles );
            
            % Set each BPA muscle measured tension to match the measured total tension of its associated hill muscle.
            for k = 1:num_BPA_muscles                    % Iterate through each BPA muscle...
            
                % Determine the index of the BPA muscle associated with this hill muscle.
                hill_muscle_index = find( BPA_muscle_IDs(k) == hill_muscle_IDs, 1 );
                
                % Determine whether to set the measured tension of this BPA muscle.
                if ~isempty(hill_muscle_index)                   % If we found a hill muscle with the same ID as this BPA muscle...
                    
                    % Store the hill muscle measured total tension associated with this BPA muscle.
                   BPA_muscle_measured_tensions(k) = self.neural_subsystem.hill_muscle_manager.hill_muscles(hill_muscle_index).measured_total_tension;
                                      
                end
                
            end
                            
            % Set the measured tension of each BPA muscle to match the tensions that we have collected from the associated hill muscles.
            self.mechanical_subsystem.limb_manager.set_BPA_muscle_measured_tensions( BPA_muscle_IDs, BPA_muscle_measured_tensions );
            
        end
                
        
        % Implement a function to transfer BPA muscle desired tension to hill muscle desired total tension.
        function self = BPA_muscle_desired_tensions2hill_muscle_desired_tensions( self )
            
            % Retrieve the BPA muscle IDs and desired tensions.
            BPA_muscle_IDs = self.mechanical_subsystem.limb_manager.get_ID_from_all_BPA_muscles(  );
            BPA_muscle_desired_tensions = self.mechanical_subsystem.limb_manager.get_desired_tension_from_all_BPA_muscles(  );
            
            % Set each hill muscle desired total tension to match the desired tension of its associated BPA muscle.
            for k = 1:self.neural_subsystem.hill_muscle_manager.num_hill_muscles                    % Iterate through each hill muscle...
                
                % Determine the index of the BPA muscle associated with this hill muscle.
                BPA_muscle_index = find( self.neural_subsystem.hill_muscle_manager.hill_muscles(k).ID == BPA_muscle_IDs, 1 );
                
                % Determine whether to set the desired total tension of this hill muscle.
                if ~isempty(BPA_muscle_index)                   % If we found a BPA muscle with the same ID as this hill muscle...
                    
                    % Set the hill muscle to have the same desired total tension as the BPA muscle.
                    self.neural_subsystem.hill_muscle_manager.hill_muscles(k).desired_total_tension = BPA_muscle_desired_tensions(BPA_muscle_index);
                    
                end
                
            end
            
        end
        
        
        % Implement a function to transfer hill muscle desired total tension to BPA muscle desired tension.
        function self = hill_muscle_desired_tensions2BPA_muscle_desired_tensions( self )
            
            % Retrieve the number of BPA muscles.
            num_BPA_muscles = self.mechanical_subsystem.limb_manager.get_number_of_BPA_muscles(  );
            
            % Retrieve the BPA and hill muscle IDs.
            BPA_muscle_IDs = self.mechanical_subsystem.limb_manager.get_ID_from_all_BPA_muscles(  );
            hill_muscle_IDs = self.neural_subsystem.hill_muscle_manager.validate_hill_muscle_IDs( 'all' );
            
            % Preallocate a variable to store the BPA muscle tensions that we want to set.
            BPA_muscle_desired_tensions = zeros( 1, num_BPA_muscles );
            
            % Set each BPA muscle desired tension to match the desired total tension of its associated hill muscle.
            for k = 1:num_BPA_muscles                    % Iterate through each BPA muscle...
                
                % Determine the index of the BPA muscle associated with this hill muscle.
                hill_muscle_index = find( BPA_muscle_IDs(k) == hill_muscle_IDs, 1 );
                
                % Determine whether to set the desired tension of this BPA muscle.
                if ~isempty(hill_muscle_index)                   % If we found a hill muscle with the same ID as this BPA muscle...
                    
                    % Store the hill muscle desired total tension associated with this BPA muscle.
                    BPA_muscle_desired_tensions(k) = self.neural_subsystem.hill_muscle_manager.hill_muscles(hill_muscle_index).desired_total_tension;
                    
                end
                
            end
            
            % Set the measured tension of each BPA muscle to match the tensions that we have collected from the associated hill muscles.
%             self.mechanical_subsystem.limb_manager.set_BPA_muscle_property( BPA_muscle_IDs, BPA_muscle_tensions, 'desired_tension' );
            self.mechanical_subsystem.limb_manager = self.mechanical_subsystem.limb_manager.set_BPA_muscle_desired_tensions( BPA_muscle_IDs, BPA_muscle_desired_tensions );

        end
        
        
        % Implement a function to transfer BPA muscle yank values to hill muscle yank values.
        function self = BPA_muscle_yank2hill_muscle_yank( self )
            
            % Retrieve the BPA muscle IDs and yanks.
            BPA_muscle_IDs = self.mechanical_subsystem.limb_manager.get_ID_from_all_BPA_muscles(  );
            BPA_muscle_yanks = self.mechanical_subsystem.limb_manager.get_yank_from_all_BPA_muscles(  );

            % Set each hill muscle yank to match the yank of its associated BPA muscle.
            for k = 1:self.neural_subsystem.hill_muscle_manager.num_hill_muscles                    % Iterate through each hill muscle...
            
                % Determine the index of the BPA muscle associated with this hill muscle.
                BPA_muscle_index = find( self.neural_subsystem.hill_muscle_manager.hill_muscles(k).ID == BPA_muscle_IDs, 1 );
                
                % Determine whether to set the measured total tension of this hill muscle.
                if ~isempty(BPA_muscle_index)                   % If we found a BPA muscle with the same ID as this hill muscle...
                    
                    % Set the hill muscle to have the same yank as the BPA muscle.
                   self.neural_subsystem.hill_muscle_manager.hill_muscles(k).yank = BPA_muscle_yanks(BPA_muscle_index);
                    
                end
                
            end
                            
        end
        
        
        % Implement a function to transfer hill muscle yank values to BPA muscle yank values.
        function self = hill_muscle_yank2BPA_muscle_yank( self )
            
            % Retrieve the number of BPA muscles.
            num_BPA_muscles = self.mechanical_subsystem.limb_manager.get_number_of_BPA_muscles(  );
            
            % Retrieve the BPA and hill muscle IDs.
            BPA_muscle_IDs = self.mechanical_subsystem.limb_manager.get_ID_from_all_BPA_muscles(  );
            hill_muscle_IDs = self.neural_subsystem.hill_muscle_manager.validate_hill_muscle_IDs( 'all' );
            
            % Preallocate a variable to store the BPA muscle yanks that we want to set.
            BPA_muscle_yanks = zeros( 1, num_BPA_muscles );
            
            % Set each BPA muscle measured tension to match the measured total tension of its associated hill muscle.
            for k = 1:num_BPA_muscles                    % Iterate through each BPA muscle...
            
                % Determine the index of the BPA muscle associated with this hill muscle.
                hill_muscle_index = find( BPA_muscle_IDs(k) == hill_muscle_IDs, 1 );
                
                % Determine whether to set the yank of this BPA muscle.
                if ~isempty(hill_muscle_index)                   % If we found a hill muscle with the same ID as this BPA muscle...
                    
                    % Store the hill muscle yank associated with this BPA muscle.
                   BPA_muscle_yanks(k) = self.neural_subsystem.hill_muscle_manager.hill_muscles(hill_muscle_index).yank;
                   
                end
                
            end
                            
            % Set the yank of each BPA muscle to match the tensions that we have collected from the associated hill muscles.
            self.mechanical_subsystem.limb_manager.set_BPA_muscle_yanks( BPA_muscle_IDs, BPA_muscle_yanks );
            
        end
        
        
        % Implement a function to transfer the BPA muscle lengths to hill muscle lengths.
        function self = BPA_muscle_length2hill_muscle_length( self )
            
            % Retrieve the BPA muscle IDs and yanks.
            BPA_muscle_IDs = self.mechanical_subsystem.limb_manager.get_ID_from_all_BPA_muscles(  );
            BPA_muscle_lengths = self.mechanical_subsystem.limb_manager.get_length_from_all_BPA_muscles(  );

            % Set each hill muscle yank to match the yank of its associated BPA muscle.
            for k = 1:self.neural_subsystem.hill_muscle_manager.num_hill_muscles                    % Iterate through each hill muscle...
            
                % Determine the index of the BPA muscle associated with this hill muscle.
                BPA_muscle_index = find( self.neural_subsystem.hill_muscle_manager.hill_muscles(k).ID == BPA_muscle_IDs, 1 );
                
                % Determine whether to set the measured total tension of this hill muscle.
                if ~isempty(BPA_muscle_index)                   % If we found a BPA muscle with the same ID as this hill muscle...
                    
                    % Set the hill muscle to have the same length as the BPA muscle.
                   self.neural_subsystem.hill_muscle_manager.hill_muscles(k).muscle_length = BPA_muscle_lengths(BPA_muscle_index);
                    
                end
                
            end
                            
        end
        
        
        % Implement a function to transfer the BPA muscle strains to hill muscle strains.
        function self = BPA_muscle_strain2hill_muscle_strain( self )
            
            % Retrieve the BPA muscle IDs and strains.
            BPA_muscle_IDs = self.mechanical_subsystem.limb_manager.get_ID_from_all_BPA_muscles(  );
            BPA_muscle_strains = self.mechanical_subsystem.limb_manager.get_strain_from_all_BPA_muscles(  );

            % Set each hill muscle yank to match the yank of its associated BPA muscle.
            for k = 1:self.neural_subsystem.hill_muscle_manager.num_hill_muscles                    % Iterate through each hill muscle...
            
                % Determine the index of the BPA muscle associated with this hill muscle.
                BPA_muscle_index = find( self.neural_subsystem.hill_muscle_manager.hill_muscles(k).ID == BPA_muscle_IDs, 1 );
                
                % Determine whether to set the measured total tension of this hill muscle.
                if ~isempty(BPA_muscle_index)                   % If we found a BPA muscle with the same ID as this hill muscle...
                    
                    % Set the hill muscle to have the same strain as the BPA muscle.
                   self.neural_subsystem.hill_muscle_manager.hill_muscles(k).muscle_strain = BPA_muscle_strains(BPA_muscle_index);
                    
                end
                
            end
                            
        end
        
        
        % Implement a function to transfer the BPA muscle velocities to hill muscle velocities.
        function self = BPA_muscle_velocity2hill_muscle_velocity( self )
            
            % Retrieve the BPA muscle IDs and strains.
            BPA_muscle_IDs = self.mechanical_subsystem.limb_manager.get_ID_from_all_BPA_muscles(  );
            BPA_muscle_velocities = self.mechanical_subsystem.limb_manager.get_velocity_from_all_BPA_muscles(  );

            % Set each hill muscle yank to match the yank of its associated BPA muscle.
            for k = 1:self.neural_subsystem.hill_muscle_manager.num_hill_muscles                    % Iterate through each hill muscle...
            
                % Determine the index of the BPA muscle associated with this hill muscle.
                BPA_muscle_index = find( self.neural_subsystem.hill_muscle_manager.hill_muscles(k).ID == BPA_muscle_IDs, 1 );
                
                % Determine whether to set the measured total tension of this hill muscle.
                if ~isempty(BPA_muscle_index)                   % If we found a BPA muscle with the same ID as this hill muscle...
                    
                    % Set the hill muscle to have the same strain as the BPA muscle.
                   self.neural_subsystem.hill_muscle_manager.hill_muscles(k).velocity = BPA_muscle_velocities(BPA_muscle_index);
                    
                end
                
            end
                            
        end
        
        
        
        % Implement a function to transfer a property from a BPA muscle to a Hill muscle.
        function self = BPA_muscle_property2hill_muscle_property( self, muscle_property )
            
            % Determine how to transfer this BPA muscle property to the associated hill muscle property.
            if strcmp( muscle_property, 'muscle_tension' )          % If we want to set the hill muscle tension...
                
                % Transfer the BPA muscle measured tension to hill muscle measured total tension.
                self = self.BPA_muscle_measured_tensions2hill_muscle_measured_tensions;
                
            else                                                    % Otherwise...
                
                % Retrieve the BPA muscle IDs and yanks.
                BPA_muscle_IDs = cell2mat( self.mechanical_subsystem.limb_manager.get_BPA_muscle_property( 'all', 'ID' ) );
                BPA_muscle_values = cell2mat( self.mechanical_subsystem.limb_manager.get_BPA_muscle_property( 'all', muscle_property ) );
                
                % Set each hill muscle yank to match the yank of its associated BPA muscle.
                for k = 1:self.neural_subsystem.hill_muscle_manager.num_hill_muscles                    % Iterate through each hill muscle...
                    
                    % Determine the index of the BPA muscle associated with this hill muscle.
                    BPA_muscle_index = find( self.neural_subsystem.hill_muscle_manager.hill_muscles(k).ID == BPA_muscle_IDs, 1 );
                    
                    % Determine whether to set the property of this hill muscle.
                    if ~isempty(BPA_muscle_index)                   % If we found a BPA muscle with the same ID as this hill muscle...
                        
                        % Create a string that, when evaluated, sets the Hill muscle to have the same property value as the associated BPA muscle.
                        eval_str = sprintf( 'self.neural_subsystem.hill_muscle_manager.hill_muscles(k).%s = BPA_muscle_values(BPA_muscle_index);', muscle_property );
                        
                        % Evaluate the string.
                        eval(eval_str)
                        
                    end
                    
                end
                
            end
            
        end
        
        
        % Implement a function to transfer a property value from a Hill muscle to a BPA muscle.
        function self = hill_muscle_property2BPA_muscle_property( self, muscle_property )
            
            % Retrieve the number of BPA muscles.
            num_BPA_muscles = self.mechanical_subsystem.limb_manager.get_number_of_BPA_muscles(  );
            
            % Retrieve the BPA and hill muscle IDs.
            BPA_muscle_IDs = self.mechanical_subsystem.limb_manager.get_BPA_muscle_property( 'all', 'ID' );
            hill_muscle_IDs = self.neural_subsystem.hill_muscle_manager.get_muscle_property( 'all', 'ID' );
            
            % Preallocate a variable to store the BPA muscle property values that we want to set.
            BPA_muscle_values = cell( 1, num_BPA_muscles );
            
            % Set each BPA muscle property value to match the property value of its associated hill muscle.
            for k = 1:num_BPA_muscles                    % Iterate through each BPA muscle...
            
                % Determine the index of the BPA muscle associated with this hill muscle.
                hill_muscle_index = find( BPA_muscle_IDs(k) == hill_muscle_IDs, 1 );
                
                % Determine whether to set the property of this BPA muscle.
                if ~isempty(hill_muscle_index)                   % If we found a hill muscle with the same ID as this BPA muscle...
                    
                    % Create a string that, when evaluated, stores the hill  muscle property value associated with this BPA muscle.
                    eval_str = sprintf( 'BPA_muscle_values{k} = self.neural_subsystem.hill_muscle_manager.hill_muscles(hill_muscle_index).%s;', muscle_property );
                    
                    % Evaluate the string.
                    eval(eval_str)
                                        
                end
                
            end
                            
            % Set the yank of each BPA muscle to match the tensions that we have collected from the associated hill muscles.
            self.mechanical_subsystem.limb_manager.set_BPA_muscle_property( BPA_muscle_IDs, BPA_muscle_values, muscle_property );
            
        end
        
        
        % Implement a function to transfer all of the required properties from the BPA muscles to the Hill muscles.
        function self = BPA_muscle_properties2hill_muscle_properties( self )
            
            % Compute the hill muscle measured total tension associated with the BPA muscle measured tension. ( BPA Muscle Measured Tension -> Hill Muscle Measured Total Tension )
            self = self.BPA_muscle_measured_tensions2hill_muscle_measured_tensions(  );
            
            % Compute the hill muscle yank associated with the BPA muscle yank. ( BPA Muscle Yank -> Hill Muscle Yank )
            self = self.BPA_muscle_yank2hill_muscle_yank(  );
            
            % Compute the hill muscle length associated with the BPA muscle length. ( BPA Muscle Length -> Hill Muscle Length )
            self = self.BPA_muscle_length2hill_muscle_length(  );
            
            % Compute the hill muscle strain associated with the BPA muscle strain. ( BPA Muscle Strain -> Hill Muscle Strain )
            self = self.BPA_muscle_strain2hill_muscle_strain(  );
            
            % Compute the hill muscle velocity associated with the BPA muscle velocity. ( BPA Muscle Velocity -> Hill Muscle Velocity )
            self = self.BPA_muscle_velocity2hill_muscle_velocity(  );
            
        end
        
        
    end
end

