classdef simulation_data_recorder_class

    % This class contains properties and methods related to recording simulation data.

    % Define the class properties.
    properties
        
        muscle_IDs
        joint_IDs
        muscle_names
        joint_names
        
        muscle_activations
        
        muscle_desired_pressures
        muscle_measured_pressures
        
        muscle_desired_total_tensions
        muscle_desired_active_tensions
        muscle_desired_passive_tensions

        muscle_measured_total_tensions
        muscle_measured_active_tensions
        muscle_measured_passive_tensions
        
        muscle_lengths
        muscle_strains
        muscle_velocities
        muscle_yanks
        
        muscle_typeIa_feedbacks                 % [V] Velocity Feedback
        muscle_typeIb_feedbacks                 % [V] Tension Feedback
        muscle_typeII_feedbacks                 % [V] Length Feedback
        
        joint_angles

    end
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = simulation_data_recorder_class( muscle_IDs, joint_IDs, muscle_names, joint_names, muscle_activations, muscle_desired_pressures, muscle_measured_pressures, muscle_desired_total_tensions, muscle_desired_active_tensions, muscle_desired_passive_tensions, muscle_measured_total_tensions, muscle_measured_active_tensions, muscle_measured_passive_tensions, muscle_lengths, muscle_strains, muscle_velocities, muscle_yanks, muscle_typeIa_feedbacks, muscle_typeIb_feedbacks, muscle_typeII_feedbacks, joint_angles )
            
            % Define the muscle tensions.
            if nargin < 21, self.joint_angles = []; else, self.joint_angles = joint_angles; end
            if nargin < 20, self.muscle_typeII_feedbacks = []; else, self.muscle_typeII_feedbacks = muscle_typeII_feedbacks; end
            if nargin < 19, self.muscle_typeIb_feedbacks = []; else, self.muscle_typeIb_feedbacks = muscle_typeIb_feedbacks; end
            if nargin < 18, self.muscle_typeIa_feedbacks = []; else, self.muscle_typeIa_feedbacks = muscle_typeIa_feedbacks; end
            if nargin < 17, self.muscle_yanks = []; else, self.muscle_yanks = muscle_yanks; end
            if nargin < 16, self.muscle_velocities = []; else, self.muscle_velocities = muscle_velocities; end
            if nargin < 15, self.muscle_strains = []; else, self.muscle_strains = muscle_strains; end
            if nargin < 14, self.muscle_lengths = []; else, self.muscle_lengths = muscle_lengths; end
            if nargin < 13, self.muscle_measured_passive_tensions = []; else, self.muscle_measured_passive_tensions = muscle_measured_passive_tensions; end
            if nargin < 12, self.muscle_measured_active_tensions = []; else, self.muscle_measured_active_tensions = muscle_measured_active_tensions; end
            if nargin < 11, self.muscle_measured_total_tensions = []; else, self.muscle_measured_total_tensions = muscle_measured_total_tensions; end
            if nargin < 10, self.muscle_desired_passive_tensions = []; else, self.muscle_desired_passive_tensions = muscle_desired_passive_tensions; end
            if nargin < 9, self.muscle_desired_active_tensions = []; else, self.muscle_desired_active_tensions = muscle_desired_active_tensions; end
            if nargin < 8, self.muscle_desired_total_tensions = []; else, self.muscle_desired_total_tensions = muscle_desired_total_tensions; end
            if nargin < 7, self.muscle_measured_pressures = []; else, self.muscle_measured_pressures = muscle_measured_pressures; end
            if nargin < 6, self.muscle_desired_pressures = []; else, self.muscle_desired_pressures = muscle_desired_pressures; end
            if nargin < 5, self.muscle_activations = []; else, self.muscle_activations = muscle_activations; end
            if nargin < 4, self.joint_names = []; else, self.joint_names = joint_names; end
            if nargin < 3, self.muscle_names = []; else, self.muscle_names = muscle_names; end
            if nargin < 2, self.joint_IDs = []; else, self.joint_IDs = joint_IDs; end
            if nargin < 1, self.muscle_IDs = []; else, self.muscle_IDs = muscle_IDs; end

        end
        
        % Implement a function to initialize the sensor data.
        function self = initialize_recorded_data( self, limb_manager, hill_muscle_manager, num_timesteps )
        
            % Set the default number of time steps.
            if nargin < 4, num_timesteps = 1; end
            
            % Retrieve the total number of joints.
            num_joints = limb_manager.get_number_of_joints(  );
            
            % Set the muscle properties record to zero.
            [ self.muscle_activations, self.muscle_desired_pressures, self.muscle_measured_pressures, self.muscle_desired_total_tensions, self.muscle_desired_active_tensions, self.muscle_desired_passive_tensions, self.muscle_measured_total_tensions, self.muscle_measured_active_tensions, self.muscle_measured_passive_tensions, self.muscle_lengths, self.muscle_strains, self.muscle_velocities, self.muscle_yanks, self.muscle_typeIa_feedbacks, self.muscle_typeIb_feedbacks, self.muscle_typeII_feedbacks ] = deal( zeros( num_timesteps, hill_muscle_manager.num_hill_muscles ) );
                        
            % Set the joint angles record to zero.
            self.joint_angles = zeros( num_timesteps, num_joints );
            
            % Define the hill muscle property value.
            self.muscle_activations(1, :) = hill_muscle_manager.get_muscle_property( 'all', 'activation' );
            self.muscle_desired_total_tensions(1, :) = hill_muscle_manager.get_muscle_property( 'all', 'desired_total_tension' );
            self.muscle_desired_active_tensions(1, :) = hill_muscle_manager.get_muscle_property( 'all', 'desired_active_tension' );
            self.muscle_desired_passive_tensions(1, :) = hill_muscle_manager.get_muscle_property( 'all', 'desired_passive_tension' );
            self.muscle_measured_total_tensions(1, :) = hill_muscle_manager.get_muscle_property( 'all', 'measured_total_tension' );
            self.muscle_measured_active_tensions(1, :) = hill_muscle_manager.get_muscle_property( 'all', 'measured_active_tension' );
            self.muscle_measured_passive_tensions(1, :) = hill_muscle_manager.get_muscle_property( 'all', 'measured_passive_tension' );
            self.muscle_lengths(1, :) = hill_muscle_manager.get_muscle_property( 'all', 'length' );
            self.muscle_strains(1, :) = hill_muscle_manager.get_muscle_property( 'all', 'strain' );
            self.muscle_velocities(1, :) = hill_muscle_manager.get_muscle_property( 'all', 'velocity' );
            self.muscle_yanks(1, :) = hill_muscle_manager.get_muscle_property( 'all', 'yank' );
            self.muscle_typeIa_feedbacks(1, :) = hill_muscle_manager.get_muscle_property( 'all', 'typeIa_feedback' );
            self.muscle_typeIb_feedbacks(1, :) = hill_muscle_manager.get_muscle_property( 'all', 'typeIb_feedback' );
            self.muscle_typeII_feedbacks(1, :) = hill_muscle_manager.get_muscle_property( 'all', 'typeII_feedback' );
            
            % Define the BPA muscle property values.
            self.muscle_desired_pressures(1, :) = limb_manager.get_BPA_muscle_property( 'all', 'desired_pressure' );
            self.muscle_measured_pressures(1, :) = limb_manager.get_BPA_muscle_property( 'all', 'measured_pressure' );

            % Define the joint property values.
            self.joint_angles(1, :) = limb_manager.get_joint_property( 'all', 'theta' );

        end
            
    end
end

