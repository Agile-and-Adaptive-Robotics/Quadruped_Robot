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
        
        
        % Implement a function to write command data to the robot while reading sensor data from the robot. ( Slave Manager Desired Pressures -> Master Microcontroller ( Real or Virtual ) Serial Port ) -> ( Master Microcontroller BPA Pressures & Joint Angles -> Slave Manager )
        function self = write_commands_to_read_sensors_from_master( self )
            
           % Write the desired pressures stored in the slave manager to the master microcontroller ( Slave Manager Desired Pressures -> Master Microcontroller ( Real or Virtual ) Serial Port )
            self.robot_states(end - 1).electrical_subsystem = self.robot_states(end - 1).electrical_subsystem.write_desired_pressures_to_master(  );

            % Read the sensor data from the master microcontroller ( Master Microcontroller BPA Pressures & Joint Angles -> Slave Manager )
            self.robot_states(end).electrical_subsystem = self.robot_states(end).electrical_subsystem.read_sensor_data_from_master(  );

        end
        
        
        
    end
end

