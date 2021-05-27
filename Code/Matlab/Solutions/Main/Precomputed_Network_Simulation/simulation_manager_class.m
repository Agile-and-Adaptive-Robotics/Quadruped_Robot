classdef simulation_manager_class
    
    % This class contains properties and methods related to the managing simulations.
    
    %% SIMULATION MANAGER PROPERTIES
    
    % Define the class properties.
    properties
        robot_states
        max_states
        dt
        ts
        plotting_utilities
    end
    
    
    %% SIMULATION MANAGER METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = simulation_manager_class( robot_state0, max_states, dt )
            
            % Create an instance of the plotting utilities class.
            self.plotting_utilities = plotting_utilities_class(  );
            
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
        
        
        %% General Get History Functions
        
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
        function body_property_history = get_body_property_history( self, body_property )
            
           % Preallocate a variable to store the body property history.
           body_property_history = cell( 1, self.max_states );
            
           % Retrieve the body property values associated with each robot state.
           for k = 1:self.max_states                    % Iterate through each robot state...
               
               % Define an string that, when evaluated, retrieves the body property for this robot state.
               eval_str = sprintf( 'body_property_history{k} = self.robot_states(k).mechanical_subsystem.body.%s', body_property );
               
               % Evaluate the evaluation string.
               eval(eval_str)
               
           end
           
        end
        
        
        % Implement a function to retrieve the history of a Hill muscle property.
        function hill_muscle_property_history = get_hill_muscle_property_history( self, hill_muscle_IDs, hill_muscle_property )
        
            % Preallocate a variable to store the hill muscle property history.
            hill_muscle_property_history = cell( 1, self.max_states );
            
            % Retrieve the hill muscle property values associated with each robot state.
            for k = 1:self.max_states                   % Iterate through each robot state...
                
                % Retrieve the hill muscle property values for this robot state.
                hill_muscle_property_history{k} = self.robot_states(k).neural_subsystem.hill_muscle_manager.get_muscle_property( hill_muscle_IDs, hill_muscle_property );

            end
            
        end  
        
        
        % Implement a funciton to retrieve the history of a slave property.
        function slave_property_history = get_slave_property_history( self, slave_IDs, slave_property )
                    
            % Preallocate a variable to store the slave property history.
            slave_property_history = cell( 1, self.max_states );
            
            % Retrieve the slave property values associated with each robot state.
            for k = 1:self.max_states               % Iterate through each robot state...
                
                % Retrieve the slave property values for this robot state.
               slave_property_history{k} = self.robot_state(k).electrical_subsystem.slave_manager.get_slave_property( slave_IDs, slave_property );
                
            end
            
        end
        
        
        % Implement a function to retrieve the history of a neuron property.
        function neuron_property_history = get_neuron_property_history( self, neuron_IDs, neuron_property )
                    
            % Preallocate a variable to store the neuron property history.
            neuron_property_history = cell( 1, self.max_states );
            
            % Retrieve the neuron property values associated with each robot state.
            for k = 1:self.max_states               % Iterate through each robot state...
                
                % Retrieve the neuron property values for this robot state.
               neuron_property_history{k} = self.robot_state(k).neural_subsystem.network.neuron_manager.get_neuron_property( neuron_IDs, neuron_property );
                
            end
            
        end
        
        
        % Implement a function to retrieve the history of a synapse property.
        function synapse_property_history = get_synapse_property_history( self, synapse_IDs, synapse_property )
                    
            % Preallocate a variable to store the synapse property history.
            synapse_property_history = cell( 1, self.max_states );
            
            % Retrieve the neuron property values associated with each robot state.
            for k = 1:self.max_states               % Iterate through each robot state...
                
                % Retrieve the neuron property values for this robot state.
               synapse_property_history{k} = self.robot_state(k).neural_subsystem.network.synapse_manager.get_synapse_property( synapse_IDs, synapse_property );
                
            end
            
        end
        
        
        %% Specific Object IDs to Number of Objects Functions
        
        % Implement a function to compute the number of joints associated with a joint IDs array.
        function num_joints = joint_IDs2num_joints( self, joint_IDs )
            
            % Retrieve the number of joints.
            if isa( joint_IDs, 'char' )                                                     % If the joint IDs have been specified as a string...
                
                % Determine how to set the total number of joints
                if strcmp( joint_IDs, 'all' ) || strcmp( joint_IDs, 'All' )                 % If the joint IDs is set to all...
                    
                    % Retrieve the total number of joints.
                    num_joints = self.robot_states(end).mechanical_subsystem.limb_manager.get_number_of_joints(  );
            
                else                                                                        % Otherwise...
                   
                    % Throw an error.
                    error( 'Joint IDs string %s not recognized.', joint_IDs )
                    
                end
            
            else                                                                            % Otherwise...
                
                % Set the number of joints.
                num_joints = length( joint_IDs );
            
            end
            
        end

        
        % Implement a function to compute the number of limbs associated with a limb IDs array.
        function num_limbs = limb_IDs2num_limbs( self, limb_IDs )
            
            % Retrieve the number of limbs.
            if isa( limb_IDs, 'char' )                                                     % If the limb IDs have been specified as a string...
                
                % Determine how to set the total number of joints
                if strcmp( limb_IDs, 'all' ) || strcmp( limb_IDs, 'All' )                 % If the limb IDs is set to all...
                    
                    % Retrieve the total number of joints.
                    num_limbs = self.robot_states(end).mechanical_subsystem.limb_manager.num_limbs;
            
                else                                                                        % Otherwise...
                   
                    % Throw an error.
                    error( 'Limb IDs string %s not recognized.', limb_IDs )
                    
                end
            
            else                                                                            % Otherwise...
                
                % Set the number of limbs.
                num_limbs = length( limb_IDs );
            
            end
            
        end
        
        
        % Implement a function to compute the number of limbs associated with a an array of BPA muscle IDs.
        function num_BPA_muscles = BPA_muscle_IDs2num_BPA_muscles( self, BPA_muscle_IDs )
            
            % Retrieve the number of BPA muscles.
            if isa( BPA_muscle_IDs, 'char' )                                                     % If the BPA muscles IDs have been specified as a string...
                
                % Determine how to set the total number of BPA muscles.
                if strcmp( BPA_muscle_IDs, 'all' ) || strcmp( BPA_muscle_IDs, 'All' )                 % If the BPA muscles IDs is set to all...
                    
                    % Retrieve the total number of BPA muscles.
                    num_BPA_muscles = self.robot_states(end).mechanical_subsystem.limb_manager.get_number_of_BPA_muscles(  );
            
                else                                                                        % Otherwise...
                   
                    % Throw an error.
                    error( 'BPA muscles IDs string %s not recognized.', BPA_muscle_IDs )
                    
                end
            
            else                                                                            % Otherwise...
                
                % Set the number of limbs.
                num_BPA_muscles = length( BPA_muscle_IDs );
            
            end
            
        end
        
        
        % Implement a function to compute the number of hill muscles associated with a an array of hill muscle IDs.
        function num_hill_muscles = hill_muscle_IDs2num_hill_muscles( self, hill_muscle_IDs )
            
            % Retrieve the number of BPA muscles.
            if isa( hill_muscle_IDs, 'char' )                                                     % If the BPA muscles IDs have been specified as a string...
                
                % Determine how to set the total number of BPA muscles.
                if strcmp( hill_muscle_IDs, 'all' ) || strcmp( hill_muscle_IDs, 'All' )                 % If the BPA muscles IDs is set to all...
                    
                    % Retrieve the total number of BPA muscles.
                    num_hill_muscles = self.robot_states(end).neural_subsystem.hill_muscle_manager.num_hill_muscles;
            
                else                                                                        % Otherwise...
                   
                    % Throw an error.
                    error( 'Hill muscles IDs string %s not recognized.', hill_muscle_IDs )
                    
                end
            
            else                                                                            % Otherwise...
                
                % Set the number of limbs.
                num_hill_muscles = length( hill_muscle_IDs );
            
            end
            
        end
        
        
        %% Specific Get History Functions
                
        % Implement a function to retrieve the history of the angles of specified joints.
        function joint_angle_history = get_joint_angle_history( self, joint_IDs )

            % Determine the number of joints.
            num_joints = self.joint_IDs2num_joints( joint_IDs );

            % Preallocate a variable to store the joint property history.
            joint_angle_history = zeros( num_joints, self.max_states );
            
            % Retrieve the joint property values associated with each robot state.
            for k = 1:self.max_states                   % Iterate through each robot state...
                
                % Retrieve the joint property values for this robot state.
                joint_angle_history( :, k) = self.robot_states(k).mechanical_subsystem.limb_manager.get_joint_angles( joint_IDs )';
                
            end
            
        end
        
                
        % Implement a function to retrieve the history of the end effector path.
        function end_effector_position_history = get_end_effector_position_history( self, limb_IDs )
            
            % Retrieve the number of limbs from which we want to retrieve end effector positions.
            num_limbs = self.limb_IDs2num_limbs( limb_IDs );
            
            % Preallocate a variable to store the end effector position histories.
            end_effector_position_history = zeros( 3, num_limbs, self.max_states );
            
            % Retrieve the end effector position history.
            for k = 1:self.max_states                   % Iterate through each robot state...
                
                % Retrieve the end effector positions associated with this robot state.
                end_effector_position_history( :, :, k ) = self.robot_states(k).mechanical_subsystem.limb_manager.get_end_effector_positions( limb_IDs );
            
            end
            
        end
        
        
        % Implement a function to retireve the BPA desired pressure history.
        function BPA_desired_pressure_history = get_BPA_desired_pressure_history( self, BPA_muscle_IDs )
        
            % Determine the number of BPA from which we want to retrieve the desired pressure history.
            num_BPAs = self.BPA_muscle_IDs2num_BPA_muscles( BPA_muscle_IDs );

            % Preallocate a variable to store the joint property history.
            BPA_desired_pressure_history = zeros( num_BPAs, self.max_states );
            
            % Retrieve the joint property values associated with each robot state.
            for k = 1:self.max_states                   % Iterate through each robot state...
                
                % Retrieve the joint property values for this robot state.
                BPA_desired_pressure_history( :, k ) = self.robot_states(k).mechanical_subsystem.limb_manager.get_BPA_muscle_desired_pressures( BPA_muscle_IDs )';
                
            end
            
        end
        
                
        % Implement a function to retireve the BPA desired pressure history.
        function BPA_measured_pressure_history = get_BPA_measured_pressure_history( self, BPA_muscle_IDs )
        
            % Determine the number of BPA from which we want to retrieve the measured pressure history.
            num_BPAs = self.BPA_muscle_IDs2num_BPA_muscles( BPA_muscle_IDs );

            % Preallocate a variable to store the BPA muscle property history.
            BPA_measured_pressure_history = zeros( num_BPAs, self.max_states );
            
            % Retrieve the BPA muscle measured pressure associated with each robot state.
            for k = 1:self.max_states                   % Iterate through each robot state...
                
                % Retrieve the BPa muscle measured pressure values for this robot state.
                BPA_measured_pressure_history( :, k ) = self.robot_states(k).mechanical_subsystem.limb_manager.get_BPA_muscle_measured_pressures( BPA_muscle_IDs )';
                
            end
            
        end
        
        
        % Implement a function to retireve the BPA desired tension history.
        function BPA_desired_tension_history = get_BPA_desired_tension_history( self, BPA_muscle_IDs )
        
            % Determine the number of BPA from which we want to retrieve the desired tension history.
            num_BPAs = self.BPA_muscle_IDs2num_BPA_muscles( BPA_muscle_IDs );

            % Preallocate a variable to store the BPA muscle desired tension.
            BPA_desired_tension_history = zeros( num_BPAs, self.max_states );
            
            % Retrieve the BPA muscle desired tension associated with each robot state.
            for k = 1:self.max_states                   % Iterate through each robot state...
                
                % Retrieve the BPA muscle desired tension for this robot state.
                BPA_desired_tension_history( :, k ) = self.robot_states(k).mechanical_subsystem.limb_manager.get_BPA_muscle_desired_tensions( BPA_muscle_IDs )';
                
            end
            
        end
        
                
        % Implement a function to retireve the BPA desired tension history.
        function BPA_measured_tension_history = get_BPA_measured_tension_history( self, BPA_muscle_IDs )
        
            % Determine the number of BPA from which we want to retrieve the measured tension history.
            num_BPAs = self.BPA_muscle_IDs2num_BPA_muscles( BPA_muscle_IDs );

            % Preallocate a variable to store the BPA muscle tension history.
            BPA_measured_tension_history = zeros( num_BPAs, self.max_states );
            
            % Retrieve the BPA muscle measured tension associated with each robot state.
            for k = 1:self.max_states                   % Iterate through each robot state...
                
                % Retrieve the BPa muscle measured tension values for this robot state.
                BPA_measured_tension_history( :, k ) = self.robot_states(k).mechanical_subsystem.limb_manager.get_BPA_muscle_measured_tensions( BPA_muscle_IDs )';
                
            end
            
        end
        
        
        % Implement a function to get the BPA muscle length history associated with specific BPA muscle IDs.
        function BPA_muscle_length_history = get_BPA_muscle_length_history( self, BPA_muscle_IDs )
            
            % Determine the number of BPA from which we want to retrieve the measured tension history.
            num_BPA_muscles = self.BPA_muscle_IDs2num_BPA_muscles( BPA_muscle_IDs );

            % Preallocate a variable to store the BPA muscle tension history.
            BPA_muscle_length_history = zeros( num_BPA_muscles, self.max_states );
            
            % Retrieve the BPA muscle measured tension associated with each robot state.
            for k = 1:self.max_states                   % Iterate through each robot state...
                
                % Retrieve the BPa muscle measured tension values for this robot state.
                BPA_muscle_length_history( :, k ) = self.robot_states(k).mechanical_subsystem.limb_manager.get_BPA_muscle_lengths( BPA_muscle_IDs )';
                
            end
            
        end
        
        
        % Implement a function to get the BPA muscle velocity history associated with specific BPA muscle IDs.
        function BPA_muscle_velocity_history = get_BPA_muscle_velocity_history( self, BPA_muscle_IDs )
            
            % Determine the number of BPA from which we want to retrieve the muscle velocity history.
            num_BPA_muscles = self.BPA_muscle_IDs2num_BPA_muscles( BPA_muscle_IDs );

            % Preallocate a variable to store the BPA muscle velocity history.
            BPA_muscle_velocity_history = zeros( num_BPA_muscles, self.max_states );
            
            % Retrieve the BPA muscle velocity associated with each robot state.
            for k = 1:self.max_states                   % Iterate through each robot state...
                
                % Retrieve the BPa muscle measured tension values for this robot state.
                BPA_muscle_velocity_history( :, k ) = self.robot_states(k).mechanical_subsystem.limb_manager.get_BPA_muscle_velocities( BPA_muscle_IDs )';
                
            end
            
        end
        
        
        % Implement a function to get the BPA muscle strain (Type I) history associated with specific BPA muscle IDs.
        function BPA_muscle_strain_history = get_BPA_muscle_strain_history( self, BPA_muscle_IDs )
            
           % Determine the number of BPA from which we want to retrieve the muscle strain history.
            num_BPA_muscles = self.BPA_muscle_IDs2num_BPA_muscles( BPA_muscle_IDs );

            % Preallocate a variable to store the BPA muscle strain history.
            BPA_muscle_strain_history = zeros( num_BPA_muscles, self.max_states );
            
            % Retrieve the BPA muscle strain associated with each robot state.
            for k = 1:self.max_states                   % Iterate through each robot state...
                
                % Retrieve the BPa muscle strain values for this robot state.
                BPA_muscle_strain_history( :, k ) = self.robot_states(k).mechanical_subsystem.limb_manager.get_BPA_muscle_strains( BPA_muscle_IDs )';
                
            end
            
        end
        
        
        % Implement a function to get the hill muscle activation history associated with specific BPA muscle IDs.
        function hill_muscle_activations = get_hill_muscle_activations( self, hill_muscle_IDs )
           
           % Determine the number of hill muscles from which we want to retrieve the activation history.
            num_hill_muscles = self.hill_muscle_IDs2num_hill_muscles( hill_muscle_IDs );

            % Preallocate a variable to store the BPA muscle strain history.
            hill_muscle_activations = zeros( num_hill_muscles, self.max_states );
            
            % Retrieve the BPA muscle strain associated with each robot state.
            for k = 1:self.max_states                   % Iterate through each robot state...
                
                % Retrieve the hill muscle activations for this robot state.
                hill_muscle_activations( :, k ) = self.robot_states(k).neural_subsystem.hill_muscle_manager.get_hill_muscle_activations( hill_muscle_IDs )';
                
            end
            
        end
        
        
        %% BPA History Functions
        
        % Implement a function to compute the BPA muscle yank associated with the BPA muscle tension history. ( BPA Muscle Tension History -> BPA Muscle Yank )
        function self = BPA_muscle_tension_history2BPA_muscle_yank( self )
            
            % Retrieve the BPA muscle tension history.
            BPA_muscle_measured_tension_history = self.get_BPA_muscle_property_history( 'all', 'measured_tension' );
            
            % Compute the yank associated with each BPA muscle.
            yanks = ( cell2mat( BPA_muscle_measured_tension_history{end} ) - cell2mat( BPA_muscle_measured_tension_history{end - 1} ) ) / self.dt;
            
            % Store the BPA muscle yanks.
            self.robot_states(end).mechanical_subsystem.limb_manager = self.robot_states(end).mechanical_subsystem.limb_manager.set_BPA_muscle_property( 'all', num2cell( yanks ), 'yank' );
                        
        end
        
        
        % Implement a function to compute the BPA muscle velocity associated with the BPA muscle length history. ( BPA Muscle Length History -> BPA Muscle Velocity )
        function self = BPA_muscle_length_history2BPA_muscle_velocity( self )
            
            % Retrieve the BPA muscle length history.
            BPA_muscle_length_history = self.get_BPA_muscle_property_history( 'all', 'muscle_length' );
            
            % Compute the velocity associated with each BPA muscle.
            velocities = ( cell2mat( BPA_muscle_length_history{end} ) - cell2mat( BPA_muscle_length_history{end - 1} ) ) / self.dt;
            
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
        
        % Implement a function to plot the joint angle history.
        function fig = plot_joint_angle_history( self, joint_IDs, fig, plotting_options )
            
            % Determine whether to specify default plotting options.
            if ( ( nargin < 4 ) || isempty( plotting_options ) ), plotting_options = { '-', 'Linewidth', 3 }; end
            
            % Determine whether we want to add the mechanical subsystem points to an existing plot or create a new plot.
            if ( nargin < 3 ) || ( isempty(fig) )
                
                % Create a figure to store the body mesh points.
                fig = figure( 'Color', 'w' ); hold on, grid on, xlabel('Time [s]'), ylabel('Joint Angle [rad]'), title('Joint Angle vs Time')
                
            end
            
            % Set the default joint IDs.
            if nargin < 2, joint_IDs = 'all'; end
            
            % Validate the joint IDs.
            joint_IDs = self.robot_states(end).mechanical_subsystem.limb_manager.limbs(1).joint_manager.validate_joint_IDs( joint_IDs );
            
            % Retrieve the joint property history.
            thetas = self.get_joint_angle_history( joint_IDs );
            
            % Plot the joint property history.
            plot( self.ts, thetas, plotting_options{:} );
                        
        end
        

        % Implement a function to plot the joint angle, velocity, and acceleration history.
        function fig = plot_joint_kinematic_history( self, joint_IDs, fig )
            
            % Determine whether we want to add the mechanical subsystem points to an existing plot or create a new plot.
            if ( nargin < 3 ) || ( isempty(fig) )
                
                % Create a figure to store the body mesh points.
                fig = figure( 'Color', 'w', 'Name', 'Joint Kinematic History' ); 
                
            end
            
            % Set the default joint IDs.
            if nargin < 2, joint_IDs = 'all'; end
            
            % Retrieve the joint property history.
            thetas = self.get_joint_angle_history( joint_IDs );
            
            % Compute the joint velocity.
            dthetas = gradient( thetas, self.dt );
            
            % Compute the joint acceleration.
            ddthetas = gradient( dthetas, self.dt );

            % Plot the joint kinematic data.
            subplot(3, 2, 1), hold on, grid on, xlabel('Time [s]'), ylabel('Joint Angle [rad]'), title('Joint Angle vs Time (Metric)'), plot( self.ts, thetas, '-', 'Linewidth', 3 )
            subplot(3, 2, 2), hold on, grid on, xlabel('Time [s]'), ylabel('Joint Angle [deg]'), title('Joint Angle vs Time (Imperial)'), plot( self.ts, (180/pi)*thetas, '-', 'Linewidth', 3 )
            subplot(3, 2, 3), hold on, grid on, xlabel('Time [s]'), ylabel('Joint Velocity [rad/s]'), title('Joint Velocity vs Time (Metric)'), plot( self.ts, dthetas, '-', 'Linewidth', 3 )
            subplot(3, 2, 4), hold on, grid on, xlabel('Time [s]'), ylabel('Joint Velocity [deg/s]'), title('Joint Velocity vs Time (Imperial)'), plot( self.ts, (180/pi)*dthetas, '-', 'Linewidth', 3 )
            subplot(3, 2, 5), hold on, grid on, xlabel('Time [s]'), ylabel('Joint Acceleration [rad/s^2]'), title('Joint Acceleration vs Time (Metric)'), plot( self.ts, ddthetas, '-', 'Linewidth', 3 )
            subplot(3, 2, 6), hold on, grid on, xlabel('Time [s]'), ylabel('Joint Acceleration [deg/s^2]'), title('Joint Acceleration vs Time (Imperial)'), plot( self.ts, (180/pi)*ddthetas, '-', 'Linewidth', 3 )
            
        end
        
        
        % Implement a function to plot the end effector path.
        function fig = plot_end_effector_path( self, limb_IDs, fig, plotting_options )
            
            % Determine whether to specify default plotting options.
            if ( ( nargin < 4 ) || isempty( plotting_options ) ), plotting_options = { '-', 'Linewidth', 3 }; end
            
            % Determine whether we want to create a new figure.
            if ( nargin < 3 ) || ( isempty(fig) )
                
                % Create a figure to store the body mesh points.
                fig = figure( 'Color', 'w', 'Name', 'End Effector Position History' ); hold on, grid on, xlabel('x [in]'), ylabel('y [in]'), zlabel('z [in]'), title('End Effector Position History'), rotate3d on
                
            end
            
            % Set the default limb IDs.
            if nargin < 2, limb_IDs = 'all'; end
            
            % Validate the limb IDs.
            limb_IDs = self.robot_states(end).mechanical_subsystem.limb_manager.validate_limb_IDs( limb_IDs );
            
            % Retrieve the number of limbs from which we want to retrieve the end effector position history.
            num_limbs = self.limb_IDs2num_limbs( limb_IDs );
            
            % Retrieve the end effector paths.
            end_effector_position_history = self.get_end_effector_position_history( limb_IDs );            
            
            % Preallocate an array to store legend entries.
            leg_str = cell( 1, num_limbs );
            
            % Plot the end effector position history of each limb.
            for k = 1:num_limbs                                 % Iterate through each limb...
                
                % Retrieve the end effector position history of this limb.
                limb_end_effector_position_history = 39.3701*squeeze( end_effector_position_history( :, k, : ) );               % [in] Converting from meters to inches.
                
                % Plot the end effector position history.
                plot3( limb_end_effector_position_history( 1, : ), limb_end_effector_position_history( 2, : ), limb_end_effector_position_history( 3, : ), plotting_options{:} )
                
                % Store a legend entry for this limb.
                leg_str{k} = sprintf( 'Limb %0.0f', k );
                
            end
            
            % Create a legend for this plot.
            legend( leg_str )

        end
        
        
        % Implement a function to plot the end effector position history.
        function fig = plot_end_effector_position_history( self, limb_IDs, fig, plotting_options )
            
            % Determine whether to specify default plotting options.
            if ( ( nargin < 4 ) || isempty( plotting_options ) ), plotting_options = { '-', 'Linewidth', 3 }; end
            
            % Determine whether we want to create a new figure.
            if ( nargin < 3 ) || ( isempty(fig) )
                
                % Create a figure to store the body mesh points.
                fig = figure( 'Color', 'w', 'Name', 'End Effector Position History' ); 
                
            end
            
            % Set the default limb IDs.
            if nargin < 2, limb_IDs = 'all'; end
            
            % Validate the limb IDs.
            limb_IDs = self.robot_states(end).mechanical_subsystem.limb_manager.validate_limb_IDs( limb_IDs );
            
            % Retrieve the number of limbs from which we want to retrieve the end effector position history.
            num_limbs = self.limb_IDs2num_limbs( limb_IDs );
            
            % Retrieve the end effector paths.
            end_effector_position_history = self.get_end_effector_position_history( limb_IDs );            
                        
            % Determine the number of subplot rows and columns to create.
            [ num_rows, num_cols ] = self.plotting_utilities.get_subplot_rows_columns( num_limbs );
                        
            % Plot the end effector position history of each limb.
            for k1 = 1:num_limbs                                 % Iterate through each limb...                
                
                % Retrieve the end effector position history of this limb.
                limb_end_effector_position_history = 39.3701*squeeze( end_effector_position_history( :, k1, : ) );               % [in] Converting from meters to inches.
                
                % Plot the end effector position history of this limb.
                subplot( num_rows, num_cols, k1 ), hold on, grid on, xlabel('Time [s]'), ylabel('End Effector Position [in]'), title( [ 'Limb ', num2str(k1), ': End Effector Position vs Time' ] )
                
                % Define the number of spatial dimensions.
                num_spatial_dims = 3;
                
                % Plot each dimension of the end effector path of this limb.
                for k2 = 1:num_spatial_dims                 % Iterate through each spatial dimension...
                    
                    % Plot the spatial dimension of the end effector path of this limb.
                    plot( self.ts, limb_end_effector_position_history( k2, : ), plotting_options{:} )
                                        
                end
                
                % Create a legend for this subplot.
                legend( { 'x', 'y', 'z' }, 'Location', 'South', 'Orientation', 'Horizontal' )
                
            end
            
        end
            
        
        % Implement a function to plot the end effector velocity history.
        function fig = plot_end_effector_velocity_history( self, limb_IDs, fig, plotting_options )
            
            % Determine whether to specify default plotting options.
            if ( ( nargin < 4 ) || isempty( plotting_options ) ), plotting_options = { '-', 'Linewidth', 3 }; end
            
            % Determine whether we want to create a new figure.
            if ( nargin < 3 ) || ( isempty(fig) )
                
                % Create a figure to store the body mesh points.
                fig = figure( 'Color', 'w', 'Name', 'End Effector Velocity History' );
                
            end
            
            % Set the default limb IDs.
            if nargin < 2, limb_IDs = 'all'; end
            
            % Validate the limb IDs.
            limb_IDs = self.robot_states(end).mechanical_subsystem.limb_manager.validate_limb_IDs( limb_IDs );
            
            % Retrieve the number of limbs from which we want to retrieve the end effector velocity history.
            num_limbs = self.limb_IDs2num_limbs( limb_IDs );
            
            % Retrieve the end effector paths.
            end_effector_position_history = self.get_end_effector_position_history( limb_IDs );
            
            % Determine the number of subplot rows and columns to create.
            [ num_rows, num_cols ] = self.plotting_utilities.get_subplot_rows_columns( num_limbs );
            
            % Plot the end effector velocity history of each limb.
            for k1 = 1:num_limbs                                 % Iterate through each limb...
                
                % Retrieve the end effector position history of this limb.
                limb_end_effector_position_history = 39.3701*squeeze( end_effector_position_history( :, k1, : ) );               % [in] Converting from meters to inches.
                
                % Compute the end effector velocity history of this limb.
                limb_end_effector_velocity_history = gradient( limb_end_effector_position_history );
                
                % Plot the end effector velocity history of this limb.
                subplot( num_rows, num_cols, k1 ), hold on, grid on, xlabel('Time [s]'), ylabel('End Effector Velocity [in/s]'), title( [ 'Limb ', num2str(k1), ': End Effector Velocity vs Time' ] )
                
                % Define the number of spatial dimensions.
                num_spatial_dims = 3;
                
                % Plot each dimension of the end effector velocity of this limb.
                for k2 = 1:num_spatial_dims                 % Iterate through each spatial dimension...
                    
                    % Plot the spatial dimension of the end effector velocity of this limb.
                    plot( self.ts, limb_end_effector_velocity_history( k2, : ), plotting_options{:} )
                    
                end
                
                % Create a legend for this subplot.
                legend( { 'x', 'y', 'z' }, 'Location', 'South', 'Orientation', 'Horizontal' )
                
            end
            
        end
        
        
        % Implement a function to plot the end effector acceleration history.
        function fig = plot_end_effector_acceleration_history( self, limb_IDs, fig, plotting_options )
            
            % Determine whether to specify default plotting options.
            if ( ( nargin < 4 ) || isempty( plotting_options ) ), plotting_options = { '-', 'Linewidth', 3 }; end
            
            % Determine whether we want to create a new figure.
            if ( nargin < 3 ) || ( isempty(fig) )
                
                % Create a figure to store the body mesh points.
                fig = figure( 'Color', 'w', 'Name', 'End Effector Velocity History' );
                
            end
            
            % Set the default limb IDs.
            if nargin < 2, limb_IDs = 'all'; end
            
            % Validate the limb IDs.
            limb_IDs = self.robot_states(end).mechanical_subsystem.limb_manager.validate_limb_IDs( limb_IDs );
            
            % Retrieve the number of limbs from which we want to retrieve the end effector acceleration history.
            num_limbs = self.limb_IDs2num_limbs( limb_IDs );
            
            % Retrieve the end effector paths.
            end_effector_position_history = self.get_end_effector_position_history( limb_IDs );
            
            % Determine the number of subplot rows and columns to create.
            [ num_rows, num_cols ] = self.plotting_utilities.get_subplot_rows_columns( num_limbs );
            
            % Plot the end effector acceleration history of each limb.
            for k1 = 1:num_limbs                                 % Iterate through each limb...
                
                % Retrieve the end effector position history of this limb.
                limb_end_effector_position_history = 39.3701*squeeze( end_effector_position_history( :, k1, : ) );               % [in] Converting from meters to inches.
                
                % Compute the end effector velocity history of this limb.
                limb_end_effector_velocity_history = gradient( limb_end_effector_position_history );
                
                % Compute the end effector acceleration history of this limb.
                limb_end_effector_acceleration_history = gradient( limb_end_effector_velocity_history );
                
                % Plot the end effector acceleration history of this limb.
                subplot( num_rows, num_cols, k1 ), hold on, grid on, xlabel('Time [s]'), ylabel('End Effector Acceleration [in/s^2]'), title( [ 'Limb ', num2str(k1), ': End Effector Acceleration vs Time' ] )
                
                % Define the number of spatial dimensions.
                num_spatial_dims = 3;
                
                % Plot each dimension of the end effector acceleration of this limb.
                for k2 = 1:num_spatial_dims                 % Iterate through each spatial dimension...
                    
                    % Plot the spatial dimension of the end effector acceleration of this limb.
                    plot( self.ts, limb_end_effector_acceleration_history( k2, : ), plotting_options{:} )
                    
                end
                
                % Create a legend for this subplot.
                legend( { 'x', 'y', 'z' }, 'Location', 'South', 'Orientation', 'Horizontal' )
                
            end
            
        end
        
        
        % Implement a function to plot the BPA muscle desired and measured pressure history.
        function fig = plot_BPA_muscle_pressure_history( self, BPA_muscle_IDs, fig, plotting_options )
        
            % Determine whether to specify default plotting options.
            if ( ( nargin < 4 ) || isempty( plotting_options ) ), plotting_options = { '-', 'Linewidth', 3 }; end
            
            % Determine whether we want to add the mechanical subsystem points to an existing plot or create a new plot.
            if ( nargin < 3 ) || ( isempty(fig) )
                
                % Create a figure to store the body mesh points.
                fig = figure( 'Color', 'w' ); hold on, grid on, xlabel('Time [s]'), ylabel('BPA Pressure [psi]'), title('BPA Pressure vs Time')
                
            end
            
            % Set the default joint IDs.
            if nargin < 2, BPA_muscle_IDs = 'all'; end
            
            % Validate the BPA muscle IDs.
            BPA_muscle_IDs = self.robot_states(end).mechanical_subsystem.limb_manager.validate_BPA_muscle_IDs( BPA_muscle_IDs );
            
            % Retrieve the number of BPAs whose pressure history we want to plot.
            num_BPAs = length( BPA_muscle_IDs );

            % Retrieve the joint property history.
            BPA_muscle_names = self.robot_states(end).mechanical_subsystem.limb_manager.get_BPA_muscle_names( BPA_muscle_IDs );
            BPA_muscle_desired_pressures = self.get_BPA_desired_pressure_history( BPA_muscle_IDs );
            BPA_muscle_measured_pressures = self.get_BPA_measured_pressure_history( BPA_muscle_IDs );

            % Preallocate a variable to store the legend entries.
            leg_str = cell( 1, 2*num_BPAs );
            
            % Initialize a legend index.
            legend_index = 1;
            
            % Plot the desired and measured pressure associated with each BPA.
            for k = 1:num_BPAs                  % Iterate through each of the BPAs...
               
                % Plot the desired pressure history associated with this BPA.
                line_element = plot( self.ts, 0.000145038*BPA_muscle_desired_pressures( k, : ), plotting_options{:} );
                
                % Add the desired pressure history of this BPA to the legend string.
                leg_str{legend_index} = [ BPA_muscle_names{k}, ' (Desired)' ];
                
                % Advance the legend index.
                legend_index = legend_index + 1;
                
                % Plot the measured pressure history associated with this BPA.
                plot( self.ts, 0.000145038*BPA_muscle_measured_pressures( k, : ), '--', 'Linewidth', line_element.LineWidth, 'Color', line_element.Color )
               
                % Add the measured pressure history of this BPA to the legend string.
                leg_str{legend_index} = [ BPA_muscle_names{k}, ' (Measured)' ];
                
                % Advance the legend index.
                legend_index = legend_index + 1;
                
            end
            
            % Create the legend for this plot.
            legend( leg_str )
            
        end
        
        
        % Implement a function to plot the BPA muscle desired and measured tension history.
        function fig = plot_BPA_muscle_tension_history( self, BPA_muscle_IDs, fig, plotting_options )
        
            % Determine whether to specify default plotting options.
            if ( ( nargin < 4 ) || isempty( plotting_options ) ), plotting_options = { '-', 'Linewidth', 3 }; end
            
            % Determine whether we want to add the mechanical subsystem points to an existing plot or create a new plot.
            if ( nargin < 3 ) || ( isempty(fig) )
                
                % Create a figure to store the body mesh points.
                fig = figure( 'Color', 'w' ); hold on, grid on, xlabel('Time [s]'), ylabel('BPA Tension [lbs]'), title('BPA Tension vs Time')
                
            end
            
            % Set the default joint IDs.
            if nargin < 2, BPA_muscle_IDs = 'all'; end
            
            % Validate the BPA muscle IDs.
            BPA_muscle_IDs = self.robot_states(end).mechanical_subsystem.limb_manager.validate_BPA_muscle_IDs( BPA_muscle_IDs );
            
            % Retrieve the number of BPAs whose pressure history we want to plot.
            num_BPAs = length( BPA_muscle_IDs );
            
            % Retrieve the BPA muscle desired and measured tensions.
            BPA_muscle_names = self.robot_states(end).mechanical_subsystem.limb_manager.get_BPA_muscle_names( BPA_muscle_IDs );
            BPA_muscle_desired_tensions = self.get_BPA_desired_tension_history( BPA_muscle_IDs );
            BPA_muscle_measured_tensions = self.get_BPA_measured_tension_history( BPA_muscle_IDs );

            % Preallocate a variable to store the legend entries.
            leg_str = cell( 1, 2*num_BPAs );
            
            % Initialize a legend index.
            legend_index = 1;
            
            % Plot the desired and measured tension associated with each BPA.
            for k = 1:num_BPAs                  % Iterate through each of the BPAs...
               
                % Plot the desired pressure history associated with this BPA.
                line_element = plot( self.ts, 0.224809*BPA_muscle_desired_tensions( k, : ), plotting_options{:} );
                
                % Add the desired pressure history of this BPA to the legend string.
                leg_str{legend_index} = [ BPA_muscle_names{k}, ' (Desired)' ];
                
                % Advance the legend index.
                legend_index = legend_index + 1;
                
                % Plot the measured pressure history associated with this BPA.
                plot( self.ts, 0.224809*BPA_muscle_measured_tensions( k, : ), '--', 'Linewidth', line_element.LineWidth, 'Color', line_element.Color )
               
                % Add the measured pressure history of this BPA to the legend string.
                leg_str{legend_index} = [ BPA_muscle_names{k}, ' (Measured)' ];
                
                % Advance the legend index.
                legend_index = legend_index + 1;
                
            end
            
            % Create the legend for this plot.
            legend( leg_str )
            
        end
        
        
        % Implement a function to plot the BPA muscle length.
        function fig = plot_BPA_muscle_length_history( self, BPA_muscle_IDs, fig, plotting_options )
        
            % Determine whether to specify default plotting options.
            if ( ( nargin < 4 ) || isempty( plotting_options ) ), plotting_options = { '-', 'Linewidth', 3 }; end
            
            % Determine whether we want to add the mechanical subsystem points to an existing plot or create a new plot.
            if ( nargin < 3 ) || ( isempty(fig) )
                
                % Create a figure to store the body mesh points.
                fig = figure( 'Color', 'w' ); hold on, grid on, xlabel('Time [s]'), ylabel('BPA Muscle Length [in]'), title('BPA Muscle Length vs Time')
                
            end
            
            % Set the default BPA muscle IDs.
            if nargin < 2, BPA_muscle_IDs = 'all'; end
            
            % Validate the BPA muscle IDs.
            BPA_muscle_IDs = self.robot_states(end).mechanical_subsystem.limb_manager.validate_BPA_muscle_IDs( BPA_muscle_IDs );

            % Retrieve the number of BPAs whose pressure history we want to plot.
            num_BPA_muscles = length( BPA_muscle_IDs );
            
            % Retrieve the joint property history.
            BPA_muscle_names = self.robot_states(end).mechanical_subsystem.limb_manager.get_BPA_muscle_names( BPA_muscle_IDs );
            BPA_muscle_lengths = self.get_BPA_muscle_length_history( BPA_muscle_IDs );
            
            % Plot the desired and measured pressure associated with each BPA.
            for k = 1:num_BPA_muscles                  % Iterate through each of the BPAs...
               
                % Plot the desired pressure history associated with this BPA.
                plot( self.ts, 39.3701*BPA_muscle_lengths( k, : ), plotting_options{:} );
                
            end
            
            % Create the legend for this plot.
            legend( BPA_muscle_names )
            
        end
        
        
        % Implement a function to plot the BPA muscle velocity.
        function fig = plot_BPA_muscle_velocity_history( self, BPA_muscle_IDs, fig, plotting_options )
        
            % Determine whether to specify default plotting options.
            if ( ( nargin < 4 ) || isempty( plotting_options ) ), plotting_options = { '-', 'Linewidth', 3 }; end
            
            % Determine whether we want to add the mechanical subsystem points to an existing plot or create a new plot.
            if ( nargin < 3 ) || ( isempty(fig) )
                
                % Create a figure to store the body mesh points.
                fig = figure( 'Color', 'w' ); hold on, grid on, xlabel('Time [s]'), ylabel('BPA Muscle Velocity [in/s]'), title('BPA Muscle Velocity vs Time')
                
            end
            
            % Set the default BPA muscle IDs.
            if nargin < 2, BPA_muscle_IDs = 'all'; end
            
            % Validate the BPA muscle IDs.
            BPA_muscle_IDs = self.robot_states(end).mechanical_subsystem.limb_manager.validate_BPA_muscle_IDs( BPA_muscle_IDs );
            
            % Retrieve the number of BPAs whose pressure history we want to plot.
            num_BPA_muscles = length( BPA_muscle_IDs );
            
            % Retrieve the joint property history.
            BPA_muscle_names = self.robot_states(end).mechanical_subsystem.limb_manager.get_BPA_muscle_names( BPA_muscle_IDs );
            BPA_muscle_velocities = self.get_BPA_muscle_velocity_history( BPA_muscle_IDs );
            
            % Plot the desired and measured pressure associated with each BPA.
            for k = 1:num_BPA_muscles                  % Iterate through each of the BPAs...
               
                % Plot the desired pressure history associated with this BPA.
                plot( self.ts, 39.3701*BPA_muscle_velocities( k, : ), plotting_options{:} );
                
            end
            
            % Create the legend for this plot.
            legend( BPA_muscle_names )
            
        end
        
        
        % Implement a function to plot the BPA muscle strain history.
        function fig = plot_BPA_muscle_strain_history( self, BPA_muscle_IDs, fig, plotting_options )
        
            % Determine whether to specify default plotting options.
            if ( ( nargin < 4 ) || isempty( plotting_options ) ), plotting_options = { '-', 'Linewidth', 3 }; end
            
            % Determine whether we want to add the mechanical subsystem points to an existing plot or create a new plot.
            if ( nargin < 3 ) || ( isempty(fig) )
                
                % Create a figure to store the body mesh points.
                fig = figure( 'Color', 'w' ); hold on, grid on, xlabel('Time [s]'), ylabel('BPA Muscle Strain (Type I) [-]'), title('BPA Muscle Strain (Type I) vs Time')
                
            end
            
            % Set the default BPA muscle IDs.
            if nargin < 2, BPA_muscle_IDs = 'all'; end
            
            % Validate the BPA muscle IDs.
            BPA_muscle_IDs = self.robot_states(end).mechanical_subsystem.limb_manager.validate_BPA_muscle_IDs( BPA_muscle_IDs );

            % Retrieve the number of BPAs whose pressure history we want to plot.
            num_BPA_muscles = length( BPA_muscle_IDs );
            
            % Retrieve the BPA muscle property history.
            BPA_muscle_names = self.robot_states(end).mechanical_subsystem.limb_manager.get_BPA_muscle_names( BPA_muscle_IDs );
            BPA_muscle_strains = self.get_BPA_muscle_strain_history( BPA_muscle_IDs );
            
            % Plot the desired and measured pressure associated with each BPA.
            for k = 1:num_BPA_muscles                  % Iterate through each of the BPAs...
               
                % Plot the strain history associated with this BPA.
                plot( self.ts, BPA_muscle_strains( k, : ), plotting_options{:} );
                
            end
            
            % Create the legend for this plot.
            legend( BPA_muscle_names )
            
        end
        
        
        % Implement a function to plot the hill muscle activation history.
        function fig = plot_hill_muscle_activation_history( self, hill_muscle_IDs, fig, plotting_options )
            
            % Determine whether to specify default plotting options.
            if ( ( nargin < 4 ) || isempty( plotting_options ) ), plotting_options = { '-', 'Linewidth', 3 }; end
            
            % Determine whether we want to add the mechanical subsystem points to an existing plot or create a new plot.
            if ( nargin < 3 ) || ( isempty(fig) )
                
                % Create a figure to store the body mesh points.
                fig = figure( 'Color', 'w' ); hold on, grid on, xlabel('Time [s]'), ylabel('Hill Muscle Activation [V]'), title('Hill Muscle Activation vs Time')
                
            end
            
            % Set the default hill muscle IDs.
            if nargin < 2, hill_muscle_IDs = 'all'; end
            
            % Validate the hill muscle IDs.
            hill_muscle_IDs = self.robot_states(end).neural_subsystem.hill_muscle_manager.validate_hill_muscle_IDs( hill_muscle_IDs );

            % Retrieve the number of BPAs whose pressure history we want to plot.
            num_hill_muscles = length( hill_muscle_IDs );
            
            % Retrieve the BPA muscle property history.
            hill_muscle_names = self.robot_states(end).neural_subsystem.hill_muscle_manager.get_hill_muscle_names( hill_muscle_IDs );
            hill_muscle_activations = self.get_hill_muscle_activations( hill_muscle_IDs );
            
            % Plot the desired and measured pressure associated with each BPA.
            for k = 1:num_hill_muscles                  % Iterate through each of the BPAs...
               
                % Plot the strain history associated with this BPA.
                plot( self.ts, hill_muscle_activations( k, : ), plotting_options{:} );
                
            end
            
            % Create the legend for this plot.
            legend( hill_muscle_names )
            
        end

        
    end
end

