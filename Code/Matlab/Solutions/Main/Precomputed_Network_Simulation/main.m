%% Precomputed Network Simulation Main Script

% This script sends precomputed network simulation results to the quadruped robot hardware.

% Clear Everything.
clear, close('all'), clc


%% Load Precomputed Simulation Data.

% Define the path to the file we want to load.
load_path = 'C:\Users\USER\Documents\GitHub\Quadruped_Robot\Code\Matlab\Solutions\Main\Precomputed_Network_Simulation';
file_name = 'Precomputed_Network_Simulation_Data.xlsx';
file_path = [load_path, '\', file_name];

% Create an instance of the data loader class.
data_loader = data_loader_class( load_path );

% Define the maximum number of data points to load.
max_num_data_points = 1000;

% Create an instance of the simulation data class.
precomputed_simulation_manager = precomputed_simulation_manager_class();

% Load the precomputed simulation data.
precomputed_simulation_manager = precomputed_simulation_manager.load_simulation_data( file_path, max_num_data_points );


%% Initialize the Neural Network.

% Define the number of neurons.
num_neurons = 4;

% Define the neuron properties.
Cm = 5e-9;                                                                                          % [F] Membrane Capacitance.
Gm = 1e-6;                                                                                          % [S] Membrane Conductance.
Er = -60e-3;                                                                                        % [V] Membrane Resting (Equilibrium) Potential.
R = 20e-3;                                                                                          % [V] Biphasic Equilibrium Voltage Range.
Am = 1;                                                                                             % [-] Sodium Channel Activation Parameter A.
Sm = -50;                                                                                           % [-] Sodium Channel Activation Parametter S.
dEm = 2*R;                                                                                            % [V] Sodium Channel Activation Reversal Potential w.r.t. Equilibrium Potential.
Ah = 0.5;                                                                                             % [-] Sodium Channel Deactivation Parameter A.
Sh = 50;                                                                                            % [-] Sodium Channel Deactivation Parameter S.
dEh = 0;                                                                                            % [V] Sodium Channel Deactivation Reversal Potential  w.r.t. Equilibrium Potential.
dEna = 110e-3;                                                                                      % [V] Sodium Channel Reversal Potential With Respect to the Resting Potential.
tauh_max = 0.250;                                                                                   % [s] Maximum Sodium Channel Deactivation Time Constant.
Gna = 2e-6;                                                                                         % [S] Sodium Channel Conductance.

% Preallocate an array of neurons.
neurons = repmat( neuron_class(  ), 1, num_neurons );

% Create each neuron.
for k = 1:num_neurons               % Iterate through each neuron...
    
    % Create this neuron.
    neurons(k) = neuron_class( Cm, Gm, Er, R, Am, Sm, dEm, Ah, Sh, dEh, dEna, tauh_max, Gna );
    
end

% Create an instance of the neuron manager class.
neuron_manager = neuron_manager_class( neurons );

% Define the number of synapses.
num_synapses = 4;

% Define the synapse properties.
dEsyn = -40e-3;                 % [V] Synapse Reversal Potential.
gsyn_max = 1e-6;                % [S] Maximum Synaptic Conductance
from_neuron_ID = [ 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4 ];
to_neuron_ID = [ 2, 3, 4, 1, 3, 4, 1, 2, 4, 1, 2, 3 ];

% Preallocate the synapses.
synapses = repmat( synapse_class(  ), 1, num_synapses );

% Create each synapses.
for k = 1:num_synapses                  % Iterate through each synapse...
    
    % Create this synapse.
    synapses(k) = synapse_class( dEsyn, gsyn_max, from_neuron_ID(k), to_neuron_ID(k) );
    
end

% Create an instance of the synapse manager class.
synapse_manager = synapse_manager_class( synapses );

% Define the network integration step size.
network_dt = 1e-3;

% Create an instance of the network class.
network = network_class( neuron_manager, synapse_manager, network_dt );


%% Initialize the BPA Muscles.

% Load the BPA muscle data.
[ muscle_IDs, muscle_names, desired_tensions, measured_tensions, desired_pressures, measured_pressures, max_pressures, muscle_lengths, resting_muscle_lengths, max_strains, velocities, yanks, c0s, c1s, c2s, c3s, c4s, c5s, c6s, ps, Js ] = data_loader.load_BPA_muscle_data( 'BPA_Muscle_Data.xlsx' );

% Define the number of BPA muscles.
num_BPA_muscles = length( muscle_IDs );

% Set the BPA muscle attachment point orientations.
Rs = repmat( eye( 3, 3 ), [ 1, 1, size( ps, 2 ) ] );

% Preallocate an array of BPA muscles.
BPA_muscles = repmat( BPA_muscle_class(), 1, num_BPA_muscles );

% Create each BPA muscle object.
for k = 1:num_BPA_muscles               % Iterate through each of the BPA muscles...
    
    % Create this BPA muscle.
    BPA_muscles(k) = BPA_muscle_class( muscle_IDs(k), muscle_names{k}, desired_tensions(k), measured_tensions(k), desired_pressures(k), measured_pressures(k), max_pressures(k), muscle_lengths(k), resting_muscle_lengths(k), max_strains(k), velocities(k), yanks(k), ps(:, :, k), Rs, Js(k, :), c0s(k), c1s(k), c2s(k), c3s(k), c4s(k), c5s(k), c6s(k) );
    
end


%% Initialize the Hill Muscles.

% Load the hill muscle data.
[ muscle_IDs, muscle_names, activations, activation_domains, desired_active_tensions, measured_total_tensions, tension_domains, max_strains, muscle_lengths, resting_muscle_lengths, velocities, yanks, kses, kpes, bs ] = data_loader.load_hill_muscle_data( 'Hill_Muscle_Data.xlsx' );

% Define the number of muscles.
num_hill_muscles = length(muscle_IDs);

% Define the number of steps to perform per simulation time step when integrating the Hill Muscle Model.
num_int_steps = 10;

% Preallocate an array of hill muscles.
hill_muscles = repmat( hill_muscle_class(), 1, num_hill_muscles );

% Create each hill muscle object.
for k = 1:num_hill_muscles               % Iterate through each of the hill muscles...
    
    % Create this hill muscle.
    hill_muscles(k) = hill_muscle_class( muscle_IDs(k), muscle_names{k}, activations(k), activation_domains{k}, desired_active_tensions(k), measured_total_tensions(k), tension_domains{k}, muscle_lengths(k), resting_muscle_lengths(k), max_strains(k), velocities(k), yanks(k), kses(k), kpes(k), bs(k), network_dt, num_int_steps );

end

% Create an instance of the hill muscle manager class.
hill_muscle_manager = hill_muscle_manager_class( hill_muscles );


%% Initialize the Robot Body.

% Define the body ID.
body_ID = 1;

% Define the body name.
body_name = 'Spine';

% Define the body mass.
body_mass = 1;              % [kg] Body Mass (the spine / back of the robot).

% Define the body dimensions.
body_length = 0.0254*20.75;      % [m] Body Length.
body_width = 0.0254*4.125;          % [m] Body Width.
body_height = 0.0254*1.0;          % [m] Body Height.

% Define the center of mass properties.
body_p_cm = zeros( 3, 1 );
body_R_cm = eye( 3 );
body_v_cm = zeros( 3, 1 );
body_w_cm = zeros( 3, 1 );

% Define the body mesh type.
body_mesh_type = 'Cuboid';

% Create an instance of the body class.
body = body_class( body_ID, body_name, body_mass, body_length, body_width, body_height, body_p_cm, body_R_cm, body_v_cm, body_w_cm, body_mesh_type );


%% Initialize the Robot Links.

% Load the link data.
[ link_IDs, link_names, link_parent_joint_IDs, link_child_joint_IDs, link_ps_starts, link_ps_ends, link_ps_cms, link_lengths, link_widths, link_masses, link_vs_cms, link_ws_cms, link_mesh_types ] = data_loader.load_link_data( 'Link_Data.xlsx' );

% Retrieve the number of links.
num_links = length( link_IDs );

% Define the link orientations.
link_Rs = repmat( eye(3), [ 1, 1, num_links ] );

% Preallocate an array of links.
links = repmat( link_class(), 1, num_links );

% Create each link object.
for k = 1:num_links               % Iterate through each of the links...
    
    % Create this link.
    links(k) = link_class( link_IDs(k), link_names{k}, link_parent_joint_IDs(k), link_child_joint_IDs(k), link_ps_starts(:, k), link_ps_ends(:, k), link_lengths(k), link_widths(k), link_masses(k), link_ps_cms(:, k), link_vs_cms(:, k), link_ws_cms(:, k), link_Rs(:, :, k), link_mesh_types{k} );
    
end


%% Initialize the Robot Joints.

% Load the joint data.
[ joint_IDs, joint_names, joint_parent_link_IDs, joint_child_link_IDs, joint_ps, joint_vs, joint_ws, joint_w_screws, joint_thetas ] = data_loader.load_joint_data( 'Joint_Data.xlsx' );

% Define the number of joints.
num_joints = length(joint_IDs);

% Define the joint orientations.
joint_Rs = repmat( eye(3), [ 1, 1, num_joints ] );

% Preallocate an array of links.
joints = repmat( joint_class(), 1, num_joints );

% Create each joint object.
for k = 1:num_joints               % Iterate through each of the joints...
    
    % Create this joint.
    joints(k) = joint_class( joint_IDs(k), joint_names{k}, joint_parent_link_IDs(k), joint_child_link_IDs(k), joint_ps(:, k), joint_Rs(:, :, k), joint_vs(:, k), joint_ws(:, k), joint_w_screws(:, k), joint_thetas(k) );
    
end


%% Initialize the Robot Limbs.

% Define the number of limbs.
num_limbs = 4;

% Define the link, joint, and muscle indexes.
link_indexes = { 1:4, 5:7, 8:11, 12:14 };
joint_indexes = { 1:4, 5:7, 8:11, 12:14 };
BPA_muscle_indexes = { 1:6, 7:12, 13:18, 19:24 };

% Define the limb IDs.
limb_IDs = 1:4;

% Define the limb names.
limb_names = { 'Front Left Leg', 'Back Left Leg', 'Front Right Leg', 'Back Right Leg' };

% Define the limb origins.
limb_origins = [ -9.5625, 9.5625, -9.5625, 9.5625;
    1.25, -1.25, 1.25, -1.25;
    4.0625, 4.0625, -4.0625, -4.0625 ];

% Preallocate an array of limbs.
limbs = repmat( limb_class(), 1, num_limbs );

% Create each limb object.
for k = 1:num_limbs               % Iterate through each of the limbs...
        
    % Create this limb.
    limbs(k) = limb_class( limb_IDs(k), limb_names{k}, limb_origins(:, k), link_manager_class( links(link_indexes{k}) ), joint_manager_class( joints(joint_indexes{k}) ), BPA_muscle_manager_class( BPA_muscles(BPA_muscle_indexes{k}) ) );
    
end

% Create an instance of the limb manager class.
limb_manager = limb_manager_class( limbs );


%% Initialize USART Communication.

%Define the baud rates.
baud_rate_virtual_ports = 115200; baud_rate_physical_ports = 57600;             % The Master Port is the only physical port.  All other ports are virtual.

% Define the COM port names.
COM_port_names = { 'COM11', 'COM1', 'COM2', 'COM7', 'COM8', 'COM9', 'COM10' };                 % { Master Port, Matlab Input Port, Matlab Output Port, Animatlab Input Port, Animatlab Output Port }.

% Define the master microcontroller port type we would like to use.
master_port_type = 'virtual';                           % [-] Master Port Type.  Either 'virtual' or 'physical'.

% Define the number of start bytes.
num_start_bytes = 2;

% Create an instance of the USART manager class.
usart_manager = usart_manager_class( num_start_bytes, master_port_type );

% Initialize the USART serial ports.
usart_manager = usart_manager.initialize_serial_ports( COM_port_names, baud_rate_physical_ports, baud_rate_virtual_ports );


%% Initialize Slave Data Managers.

% Define the number of slaves.
num_slaves = 24;

% Define the slave IDs.
slave_IDs = 1:num_slaves;

% Define the ID of the first pressure sensor for each slave.
pressure_sensor_ID1s = 1:num_slaves;

% Define the ID of the second pressure sensor for each slave.
pressure_sensor_ID2s = zeros( 1, num_slaves ); pressure_sensor_ID2s(1:2:end) = 2:2:num_slaves; pressure_sensor_ID2s(2:2:end) = 1:2:num_slaves;

% Define the slave joint IDs.
slave_joint_IDs = [ 1, 1, 2, 2, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 11, 11, 12, 12, 13, 13, 14, 14 ];

% Define the ID of the joint associated with each slave.
encoder_IDs = reshape( repmat( (1:(num_slaves/2)), 2, 1 ), 1, num_slaves );

% Define the name of the joint associated with each slave.
encoder_names = { 'Front Left Scapula', 'Front Left Shoulder', 'Front Left Wrist', ...
    'Back Left Hip', 'Back Left Knee', 'Back Left Ankle', ...
    'Front Right Scapula', 'Front Right Shoulder', 'Front Right Wrist', ...
    'Back Right Hip', 'Back Right Knee', 'Back Right Ankle' };

encoder_names = reshape( repmat( encoder_names, 2, 1 ), 1, num_slaves );

% Set the measured pressure values for each slave to zero.
measured_pressure_value1s = zeros( 1, num_slaves );
measured_pressure_value2s = zeros( 1, num_slaves );

% Set the measured joint angle for each slave to zero.
measured_encoder_values = zeros( 1, num_slaves );

% Set the desired pressure for each slave to zero.
desired_pressures = zeros( 1, num_slaves );

% Preallocate an array of limbs.
slaves = repmat( slave_class(), 1, num_slaves );

% Create each slave object.
for k = 1:num_slaves               % Iterate through each of the slaves...
        
    % Create this slave.
    slaves(k) = slave_class( uint8( slave_IDs(k) ), uint8( muscle_IDs(k) ), muscle_names{k}, uint8( pressure_sensor_ID1s(k) ), uint8( pressure_sensor_ID2s(k) ), uint8( slave_joint_IDs(k) ), uint8( encoder_IDs(k) ), encoder_names{k}, uint16( measured_pressure_value1s(k) ), uint16( measured_pressure_value2s(k) ), uint16( measured_encoder_values(k) ), uint16( desired_pressures(k) ) );
    
end

% Create an instance of the slave manager class.
slave_manager = slave_manager_class( slaves );


%% Initialize the Quadruped Robot.

% Create an instance of the neural subsystem class.
neural_subsystem = neural_subsystem_class( network, hill_muscle_manager );

% Create an instance of the mechanical subsystem class.
mechanical_subsystem = mechanical_subsystem_class( body, limb_manager );

% Create an instance of the electrical subsytem class.
electrical_subsystem = electrical_subsystem_class( usart_manager, slave_manager );

% Create an instance of the robot class.
robot_state0 = robot_class( neural_subsystem, mechanical_subsystem, electrical_subsystem );


%% Initialize the Simulation Data Recorder.

% Create an instance of the simulation data recorder class.
simulation_data_recorder = simulation_data_recorder_class( muscle_IDs, joint_IDs, muscle_names, joint_names );

% Initialize the simulation data recorder values.
simulation_data_recorder = simulation_data_recorder.initialize_recorded_data( limb_manager, hill_muscle_manager, precomputed_simulation_manager.num_timesteps );


%% Initialzize the Simulation Manager.

% Set the maximum number of robot states to record.
max_states = 1000;

% Set the initial hill muscle activations to match the precomputed network simulation. ( Precomputed Simulation -> Hill Muscle Activation ) 
robot_state0.neural_subsystem.hill_muscle_manager = robot_state0.neural_subsystem.hill_muscle_manager.set_muscle_property( precomputed_simulation_manager.muscle_IDs, precomputed_simulation_manager.activations(k, :), 'activation', true );

% Compute the initial hill muscle desired active tension to match the precomputed hill muscle activations. ( Hill Muscle Activation -> Hill Muscle Desired Active Tension )
robot_state0.neural_subsystem.hill_muscle_manager = robot_state0.neural_subsystem.hill_muscle_manager.call_muscle_method( 'all', 'activation2desired_active_tension' );

% Compute the initial hill muscle desired total and passive tension to match the hill muscle desired active tension. ( Hill Muscle Desired Active Tension -> Hill Muscle Desired Total Tension, Hill Muscle Desired Passive Tension )
robot_state0.neural_subsystem.hill_muscle_manager = robot_state0.neural_subsystem.hill_muscle_manager.call_muscle_method( 'all', 'desired_active_tension2desired_total_passive_tension' );

% Create an instance of the simulation manager class.
simulation_manager = simulation_manager_class( robot_state0, max_states, precomputed_simulation_manager.dt );


%% ( Testing: Plotting Stuff )




fig = simulation_manager.robot_states(end).mechanical_subsystem.limb_manager.plot_limb_points(  );

fig = simulation_manager.robot_states(end).mechanical_subsystem.body.plot_body_com_point( fig );
fig = simulation_manager.robot_states(end).mechanical_subsystem.body.plot_body_mesh_points( fig );

% fig = simulation_manager.robot_states(end).mechanical_subsystem.body.plot_body_points( fig );

% fig = simulation_manager.robot_states(end).mechanical_subsystem.plot_mechanical_points( fig );


% fig = plot_limb_points( self, fig, plotting_options )

% fig = simulation_manager.robot_states(end).mechanical_subsystem.limb_manager.limbs(1).plot_limb_points(  );


% fig = plot_limb_points( self, fig, plotting_options )
% 
% fig = simulation_manager.robot_states(end).mechanical_subsystem.limb_manager.limbs(1).BPA_muscle_manager.plot_BPA_muscle_points(  );
% 
% fig = simulation_manager.robot_states(end).mechanical_subsystem.limb_manager.limbs(1).link_manager.plot_link_points( fig );
% 
% fig = simulation_manager.robot_states(end).mechanical_subsystem.limb_manager.limbs(1).joint_manager.plot_joint_points( fig );




%% Write Precomputed Simulation Data to the Master Microcontroller While Collecting Sensor Data

% Send each simulation data value to the master mircocontoller and collect the associated sensory feedback.
for k = 1:precomputed_simulation_manager.num_timesteps                  % Iterate through each simulation time step...
    
    %% Initialize the Next Robot State.
    
    % Set the next robot state to be the same as this robot state.
    simulation_manager = simulation_manager.cycle_robot_states(  );
    
    
    %% Write the Desired Muscle Pressures to and Read Measured Muscle Pressures and Joint Angles from the Master Microcontroller.
    
    % Write commands to the master microcontroller while reading sensor data from the master microcontroller. ( Slave Manager Desired Pressures -> Master Microcontroller -> Slave Manager Measured Pressures, Measured Joint Angles )
    simulation_manager = simulation_manager.write_commands_to_read_sensors_from_master(  );

    
    %% Transfer Slave Manager Sensor Data to Simulation Objects. ( Slave Manager Desired Pressure -> BPA Muscle Measured Pressure ), ( Slave Manager Joint Angle -> Joint Angle )
    
    % Transfer the slave measured pressure data to the BPA muscle measured pressure. ( Slave Measured Pressure -> BPA Muscle Measured Pressure )
    simulation_manager.robot_states(end) = simulation_manager.robot_states(end).slave_measured_pressures2BPA_measured_pressures(  );

    % Transfer the slave measured joint angle to the joint object angle. ( Slave Measured Angle -> Joint Angle )
    simulation_manager.robot_states(end) = simulation_manager.robot_states(end).slave_angle2joint_angle(  );
    
    
    %% Compute the Robot Configuration Given the Current Joint Angles (i.e., Forward Kinematics). ( Joint Angles -> Robot Configuration )
    
    % Compute the the configuration of the body. ( ??? )
    
    
%     % Compute the configuration of the end effectors. ( Joints Angles -> End Effector Configuration )
%     simulation_manager.robot_states(end).mechanical_subsystem.limb_manager = simulation_manager.robot_states(end).mechanical_subsystem.limb_manager.joint_angles2end_effector_configurations(  );
% 
%     % Compute the configuration of the joints. ( Joint Angles -> Joint Configuration )
%     simulation_manager.robot_states(end).mechanical_subsystem.limb_manager = simulation_manager.robot_states(end).mechanical_subsystem.limb_manager.joint_angles2joint_configurations(  );
% 
%     % Compute the configuration of the links. ( Joint Angles -> Link Configuration )
%     simulation_manager.robot_states(end).mechanical_subsystem.limb_manager = simulation_manager.robot_states(end).mechanical_subsystem.limb_manager.joint_angles2link_configurations(  );
%         
%     % Compute the configuration of the BPA Muscles. ( Joint Angles -> BPA Muscle Configutation )
%     simulation_manager.robot_states(end).mechanical_subsystem.limb_manager = simulation_manager.robot_states(end).mechanical_subsystem.limb_manager.joint_angles2BPA_muscle_configurations(  );

    % Compute the configuration of each limb. ( Joint Angles -> Limb Configuration )
    simulation_manager.robot_states(end).mechanical_subsystem.limb_manager = simulation_manager.robot_states(end).mechanical_subsystem.limb_manager.joint_angles2limb_configurations(  );
    
    
    %% Compute Robot Kinematic Properties.
    
    % Compute end effector velocities (linear and rotational).
    
    
    % Compute joint velocities (linear and rotational).
    
    
    % Compute link velocities (linear and rotational).
    
    
    % Compute BPA muscle velocities (linear and rotational).
    
    
    
    %% Compute Derived BPA Muscle Properties. ( BPA Muscle Tension, BPA Muscle Yank, BPA Muscle Length, BPA Muscle Strain, BPA Muscle Velocity )
    
    % Compute the BPA muscle measured tension associated with the BPA muscle measured pressure. ( BPA Muscle Measured Pressure -> BPA Muscle Measured Tension )
    simulation_manager.robot_states(k + 1).mechanical_subsystem.limb_manager = simulation_manager.robot_states(k + 1).mechanical_subsystem.limb_manager.call_BPA_muscle_method( 'all', 'measured_pressure2measured_tension' );
    
    % Compute the BPA muscle yank associated with the BPA muscle tension history. ( BPA Muscle Tension History -> BPA Muscle Yank )

    
    % Compute the BPA muscle length associated with the joint angles. ( Joint Angles & Robot Geometry -> BPA Muscle Length )
    
    
    % Compute the BPA muscle strain associated with the BPA muscle length. ( BPA Muscle Length -> BPA Muscle Strain )
    
    
    % Compute the BPA muscle velocity associated with the BPA muscle length history. ( BPA Musce Length History -> BPA Muscle Velocity )
    
    
    
    %% Compute Derived Hill Muscle Properties. ( Hill Muscle Tension, Hill Muscle Yank, Hill Muscle Length, Hill Muscle Strain, Hill Muscle Velocity, Hill Muscle Type Ia Feedback, Hill Muscle Type Ib Feedback, and Hill Muscle Type II Feedback )
    
    % Compute the hill muscle measured total tension associated with the BPA muscle measured tension. ( BPA Muscle Measured Tension -> Hill Muscle Measured Total Tension )
    simulation_manager.robot_states(k + 1) = simulation_manager.robot_states(k + 1).BPA_muscle_measured_tensions2hill_muscle_measured_tensions(  );
    
    % Compute the hill muscle measured active and passive tension associated with the hill muscle measured total tension. ( Hill Muscle Measured Tension -> Hill Muscle Measured Active Tension, Hill Muscle Measured Passive Tension )
    simulation_manager.robot_states(k + 1).neural_subsystem.hill_muscle_manager = simulation_manager.robot_states(k + 1).neural_subsystem.hill_muscle_manager.call_muscle_method( 'all', 'measured_total_tension2measured_active_passive_tension' );
    
    % Compute the hill muscle yank associated with the BPA muscle yank. ( BPA Muscle Yank -> Hill Muscle Yank )
    
    
    % Compute the hill muscle length associated with the BPA muscle length. ( BPA Muscle Length -> Hill Muscle Length )
    
    
    % Compute the hill muscle strain associated with the BPA muscle strain. ( BPA Muscle Strain -> Hill Muscle Strain )
    
    
    % Compute the hill muscle velocity associated with the BPA muscle velocity. ( BPA Muscle Velocity -> Hill Muscle Velocity )    
    
        
    % Compute the hill muscle Type Ia (muscle velocity) feedback from the hill muscle velocity. ( Hill Muscle Velocity -> Hill Muscle Type Ia (Velocity) Feedback )
    muscle_manager = muscle_manager.call_muscle_method( muscle_IDs, 'velocity2typeIa_feedback' );
    
    % Compute the hill muscle Type Ib (muscle tension) feedback from the hill muscle total tension. ( Hill Muscle Total Tension -> Hill Muscle Type Ib (Tension) Feedback )
    muscle_manager = muscle_manager.call_muscle_method( muscle_IDs, 'measured_total_tension2typeIb_feedback' );
    
    % Compute the hill muscle Type II (muscle velocity) feedback from the hill muscle length. ( Hill Muscle Length -> Hill Muscle Type II (Length) Feedback )
    muscle_manager = muscle_manager.call_muscle_method( muscle_IDs, 'length2typeII_feedback' );
    
    
    
    
    %% Compute the Network Properties & Hill Muscle Activation.
    
    % Store the simulation data into the muscle manager. ( Precomputed Simulation Data -> Hill Muscle Activation )
    simulation_manager.quadruped_robot.neural_subsystem.hill_muscle_manager = simulation_manager.quadruped_robot.neural_subsystem.hill_muscle_manager.set_muscle_property( precomputed_simulation_manager.muscle_IDs, precomputed_simulation_manager.activations(k, :), 'activation', true );
    
    
    %% Compute the Derived Hill Muscle Properties. ( Hill Muscle Desired Active Tension, Hill Muscle Desired Passive Tension, Hill Muscle Desired Total Tension )

    % Compute hill muscle desired total tension from the hill muscle activation. ( Hill Muscle Activation -> Hill Muscle Desired Active Tension )
    simulation_manager.quadruped_robot.neural_subsystem.hill_muscle_manager = simulation_manager.quadruped_robot.neural_subsystem.hill_muscle_manager.call_muscle_method( muscle_IDs, 'activation2desired_active_tension' );

    % Compute the hill muscle desired total and passive tensions from the hill muscle desired active tension. ( Hill Muscle Desired Active Tension -> Hill Muscle Desired Passive & Total Tensions )
    muscle_manager = muscle_manager.call_muscle_method( muscle_IDs, 'desired_active_tension2desired_total_passive_tension' );

    
    %% Compute the Derived BPA Muscle Properties. ( BPA Muscle Desired Tension, BPA Muscle Desired Pressure )
    
    % Transfer the hill muscle desired total tension to the BPA muscle desired total tension. ( Hill Muscle Desired Total Tension -> BPA Muscle Desired Tension ) 
    
    % Compute the BPA muscle desired pressure from the BPA muscle desired tension. ( BPA Muscle Desired Tension -> BPA Muscle Desired Pressure )
    muscle_manager = muscle_manager.call_muscle_method( muscle_IDs, 'desired_total_tension2desired_pressure' );

    
    %% Store the Desired BPA Muscle Pressure in the Slave Manager.
    
    % Transfer the BPA muscle desired pressure to the slave manager desired pressure. ( BPA Muscle Desired Pressure -> Slave Manager Desired Pressure )
    simulation_manager.robot_states(end) = simulation_manager.robot_states(end).BPA_desired_pressures2slave_desired_pressures(  );
    
    
    %% Record the Muscle & Slave Data for Plotting.
    
    % Store the sensor data into the sensor data manager.
    
    asdf = 1;
    
    
end


% %% Write Precomputed Simulation Data to the Master Microcontroller While Collecting Sensor Data
%
% % Send each simulation data value to the master mircocontoller and collect the associated sensory feedback.
% for k = 1:precomputed_simulation_manager.num_timesteps                  % Iterate through each simulation time step...
%
%     % Store the simulation data into the muscle manager.
%     muscle_manager = muscle_manager.set_muscle_activations( precomputed_simulation_manager.muscle_IDs, precomputed_simulation_manager.activations(k, :) );
%
%     % Compute the desired total muscle tensions associated with the current muscle activations.
%     muscle_manager = muscle_manager.call_muscle_method( muscle_IDs, 'activation2desired_active_tension' );
%
%     % Compute the desired active and desired passive muscle tensions associated with the current total muscle activations.
%     muscle_manager = muscle_manager.call_muscle_method( muscle_IDs, 'desired_active_tension2desired_total_passive_tension' );
%
%     % Compute the desired pressure for each muscle.
%     muscle_manager = muscle_manager.call_muscle_method( muscle_IDs, 'desired_total_tension2desired_pressure' );
%
%     % Delegate the desired BPA pressures to the appropriate slave in the slave manager.
%     slave_manager = slave_manager.set_desired_pressure( slave_IDs, muscle_manager );
%
%
%     % Stage the desired BPA pressures for USART transmission to the master microcontroller.
%     usart_manager = usart_manager.stage_desired_pressures( slave_manager );
%
%     % Write the desired BPA pressures to the master microcontroller.
%     usart_manager.write_bytes_to_master( master_port_type );
%
%     % Determine whether we need to emulate the master microcontroller behavior.
%     if strcmp(master_port_type, 'virtual') || strcmp(master_port_type, 'Virtual')                   % If we are using a virtual port for the master microcontroller...
%
%         % Emulate the master microcontroller reporting sensory information to Matlab.
%         usart_manager.emulate_master_read_write( slave_manager );
%
%     end
%
%     % Retrieve the sensor data from the master microcontroller via USART transmission.
%     usart_manager = usart_manager.read_bytes_from_master( slave_manager.SLAVE_PACKET_SIZE, master_port_type );
%
%
%     % Store the sensor data into the associated slave in the slave manager.
%     slave_manager = slave_manager.store_sensor_data( usart_manager );
%
%
%     % Store the muscle sensory data into the appropriate muscle in the muscle manager.
%     muscle_manager = muscle_manager.set_measured_pressures( slave_manager );
%
%     % Compute the measured total tension associated with the measured muscle pressure.
%     muscle_manager = muscle_manager.call_muscle_method( muscle_IDs, 'measured_pressure2measured_total_tension' );
%
%     % Compute the measured active and passive tension associated with the measured total tension.
%     muscle_manager = muscle_manager.call_muscle_method( muscle_IDs, 'measured_total_tension2measured_active_passive_tension' );
%
%
%     % Compute the Type Ia (muscle velocity) feedback.
%     muscle_manager = muscle_manager.call_muscle_method( muscle_IDs, 'velocity2typeIa_feedback' );
%
%     % Compute the Type Ib (muscle tension) feedback.
%     muscle_manager = muscle_manager.call_muscle_method( muscle_IDs, 'measured_total_tension2typeIb_feedback' );
%
%     % Compute the Type II (muscle velocity) feedback.
%     muscle_manager = muscle_manager.call_muscle_method( muscle_IDs, 'length2typeII_feedback' );
%
%
%     % Store the sensor data into the sensor data manager.
%
%     asdf = 1;
%
% end


%% Plot Simulation Results.

fig_motor_activations = precomputed_simulation_manager.plot_motor_neuron_activations();


%% Plot the Sensor Data.


%% Terminate USART Communication.

% Terminate the USART serial ports.
usart_manager = usart_manager.terminate_serial_ports();



