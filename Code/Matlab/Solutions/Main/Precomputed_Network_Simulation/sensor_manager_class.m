classdef sensor_manager_class

    % This class contains properties and methods related to managing sensor data.

    % Define the class properties.
    properties
        muscle_IDs
        pressure_sensor_IDs
        encoder_IDs
        muscle_names
        joint_names
        muscle_lengths
        muscle_velocities
        muscle_pressures
        muscle_tensions
        joint_angles
    end
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = sensor_manager_class( muscle_IDs, pressure_sensor_IDs, encoder_IDs, muscle_names, joint_names, muscle_lengths, muscle_velocities, muscle_pressures, muscle_tensions, joint_angles )

            % Define the muscle tensions.
            if nargin <10, self.joint_angles = []; else, self.joint_angles = joint_angles; end
            if nargin < 9, self.muscle_tensions = []; else, self.muscle_tensions = muscle_tensions; end
            if nargin < 8, self.muscle_pressures = []; else, self.muscle_pressures = muscle_pressures; end
            if nargin < 7, self.muscle_velocities = []; else, self.muscle_velocities = muscle_velocities; end
            if nargin < 6, self.muscle_lengths = []; else, self.muscle_lengths = muscle_lengths; end
            if nargin < 5, self.joint_names = []; else, self.joint_names = joint_names; end
            if nargin < 4, self.muscle_names = []; else, self.muscle_names = muscle_names; end
            if nargin < 3, self.encoder_IDs = []; else, self.encoder_IDs = encoder_IDs; end
            if nargin < 2, self.pressure_sensor_IDs = []; else, self.pressure_sensor_IDs = pressure_sensor_IDs; end
            if nargin < 1, self.muscle_IDs = []; else, self.muscle_IDs = muscle_IDs; end

        end
        
        % Implement a function to initialize the sensor data.
        function self = initialize_sensor_data( self, num_timesteps )
        
            % Set the default number of time steps.
            if nargin < 2, num_timesteps = 1; end
            
            % Set the muscle lengths, velocities, pressures, and tensions to zero.
            [ self.muscle_lengths, self.muscle_velocities, self.muscle_pressures, self.muscle_tensions ] = deal( zeros( num_timesteps, length(self.muscle_IDs) ) );
            
            % Set the joint angles to zero.
            self.joint_angles = zeros( num_timesteps, length(self.encoder_IDs) );

        end
            
    end
end

