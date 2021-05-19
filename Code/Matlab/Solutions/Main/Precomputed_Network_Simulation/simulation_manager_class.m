classdef simulation_manager_class
    
    % This class contains properties and methods related to the managing simulations.
    
    %% SIMULATION MANAGER PROPERTIES
    
    % Define the class properties.
    properties
        robot_states
        max_states
        dt
        ts
    end
    
    
    %% SIMULATION MANAGER METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = simulation_manager_class( robot_state0, max_states, dt )
            
            % Set the default simulation manager properties.
            if nargin < 3, self.dt = 1e-3; else, self.dt = dt; end
            if nargin < 2, self.max_states = 1e3; else, self.max_states = max_states; end
            if nargin < 1, robot_state0 = quadruped_robot_class(); end
            
            % Preallocate an array to store the robot states.
            self.robot_states = repmat( robot_class(), 1, self.max_states );
            
            % Set the initial robot state.
            self.robot_states(end) = robot_state0;
            
            % Create a dummy time vector.
            self.ts = zeros( 1, self.max_states );
            
        end
        
        
        % Implement a function to cycle the robot states.
        function self = cycle_robot_states( self )
            
            % Move all of the robot states in the robot states array to the left.
            self.robot_states(1:end - 1) = self.robot_states(2:end);
            self.ts(1:end - 1) = self.ts(2:end);
            
            % Initialize the last robot state to be equal to the robot state immediately before it.
            self.robot_states(end) = self.robot_states(end - 1);
            self.ts(end) = self.ts(end - 1) + self.dt;
            
        end
        
        
        %% IO Functions
        
        % Implement a function to write command data to the robot while reading sensor data from the robot. ( Slave Manager Desired Pressures -> Master Microcontroller ( Real or Virtual ) Serial Port ) -> ( Master Microcontroller BPA Pressures & Joint Angles -> Slave Manager )
        function self = write_commands_to_read_sensors_from_master( self )
            
           % Write the desired pressures stored in the slave manager to the master microcontroller ( Slave Manager Desired Pressures -> Master Microcontroller ( Real or Virtual ) Serial Port )
            self.robot_states(end - 1).electrical_subsystem = self.robot_states(end - 1).electrical_subsystem.write_desired_pressures_to_master(  );

            % Read the sensor data from the master microcontroller ( Master Microcontroller BPA Pressures & Joint Angles -> Slave Manager )
            self.robot_states(end).electrical_subsystem = self.robot_states(end).electrical_subsystem.read_sensor_data_from_master(  );

        end
        
        
        %% Get History Functions
        
        % Implement a function to retrieve the history of a joint property.
        function joint_property_history = get_joint_property_history( self, joint_IDs, joint_property )
        
            % Preallocate a variable to store the joint property history.
            joint_property_history = cell( 1, self.max_states );
            
            % Retrieve the joint property values associated with each robot state.
            for k = 1:self.max_states                   % Iterate through each robot state...
                
                % Retrieve the joint property values for this robot state.
                joint_property_history{k} = self.robot_states(k).mechanical_subsystem.limb_manager.get_joint_property( joint_IDs, joint_property );
                
            end
            
        end

        
        % Implement a function to retrieve the history of a link property.
        function link_property_history = get_link_property_history( self, link_IDs, link_property )
        
            % Preallocate a variable to store the link property history.
            link_property_history = cell( 1, self.max_states );
            
            % Retrieve the link property values associated with each robot state.
            for k = 1:self.max_states                   % Iterate through each robot state...
                
                % Retrieve the link property values for this robot state.
                link_property_history{k} = self.robot_states(k).mechanical_subsystem.limb_manager.get_link_property( link_IDs, link_property );
                
            end
            
        end
        
        
        % Implement a function to retrieve the history of a BPA muscle property.
        function BPA_muscle_property_history = get_BPA_muscle_property_history( self, BPA_muscle_IDs, BPA_muscle_property )
        
            % Preallocate a variable to store the BPA muscle property history.
            BPA_muscle_property_history = cell( 1, self.max_states );
            
            % Retrieve the BPA muscle property values associated with each robot state.
            for k = 1:self.max_states                   % Iterate through each robot state...
                
                % Retrieve the BPA muscle property values for this robot state.
                BPA_muscle_property_history{k} = self.robot_states(k).mechanical_subsystem.limb_manager.get_BPA_muscle_property( BPA_muscle_IDs, BPA_muscle_property );
                
            end
            
        end      
        
        
        % Implement a function to retrieve the history of a body property.
        
        
        % Implement a function to retireve the history of a Hill muscle property.
        
        
        % Implement a funciton to retrieve the history of a slave property.
        
        
        % Implement a function to retrieve the history of a neuron property.
        
        
        % Implement a function to retrieve the history of a synapse property.
        
        
        %% BPA History Functions
        
        % Implement a function to compute the BPA muscle yank associated with the BPA muscle tension history. ( BPA Muscle Tension History -> BPA Muscle Yank )
        function self = BPA_muscle_tension_history2BPA_muscle_yank( self )
            
            % Retrieve the BPA muscle tension history.
            BPA_muscle_measured_tension_history = self.get_BPA_muscle_property_history( 'all', 'measured_tension' );
            
            % Compute the yank associated with each BPA muscle.
            yanks = ( BPA_muscle_measured_tension_history{end} - BPA_muscle_measured_tension_history{end - 1} ) / self.dt;
            
            % Store the BPA muscle yanks.
            self.robot_states(end).mechanical_subsystem.limb_manager = self.robot_states(end).mechanical_subsystem.limb_manager.set_BPA_muscle_property( 'all', num2cell( yanks ), 'yank' );
                        
        end
        
        
        % Implement a function to compute the BPA muscle velocity associated with the BPA muscle length history. ( BPA Muscle Length History -> BPA Muscle Velocity )
        function self = BPA_muscle_length_history2BPA_muscle_velocity( self )
            
            % Retrieve the BPA muscle length history.
            BPA_muscle_length_history = self.get_BPA_muscle_property_history( 'all', 'muscle_length' );
            
            % Compute the velocity associated with each BPA muscle.
            velocities = ( BPA_muscle_length_history{end} - BPA_muscle_length_history{end - 1} ) / self.dt;
            
            % Store the BPA muscle velocities.
            self.robot_states(end).mechanical_subsystem.limb_manager = self.robot_states(end).mechanical_subsystem.limb_manager.set_BPA_muscle_property( 'all', num2cell( velocities ), 'velocity' );
                        
        end
        
        
        % Implement a function to compute all BPA muscle property derivatives from their histories. ( BPA Muscle Tension History -> BPA Muscle Yank; BPA Muscle Length History -> BPA Muscle Velocity )
        function self = BPA_muscle_property_histories2BPA_muscle_property_derivatives( self )
        
            % Compute the BPA muscle yank from the BPA muscle tension history.
            self = self.BPA_muscle_tension_history2BPA_muscle_yank(  );
            
            % Compute the BPA muscle velocity from the BPA muscle length history.
            self = self.BPA_muscle_length_history2BPA_muscle_velocity(  );
            
        end
        
        
        %% Plotting Functions
        
        % Implement a function to plot the joint angle, velocity, and acceleration history.
        
        
        % Implement a function to plot the end effector path, velocity, and acceleration history in the state space.
        
        
        % Implement a function to plot the BPA muscle desired and measured pressure history.
        
        
        % Implement a function to plot the BPA muscle desired and measured tension and yank history.
        
        
        % Implement a function to plot the BPA muscle length and velocity history.
        
        
        % Implement a function to plot the BPA muscle strain and strain rate history.
        
        
        % Implement a function to plot the hill muscle activation history.
        
        
        % Implement a function to plot the network neuron voltage history.
        
        
        
        
    end
end

