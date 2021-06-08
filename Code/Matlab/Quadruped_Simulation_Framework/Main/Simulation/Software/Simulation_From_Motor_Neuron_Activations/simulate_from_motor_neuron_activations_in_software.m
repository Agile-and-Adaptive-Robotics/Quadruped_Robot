%% Simulation From Motor Neuron Activations in Software

% This script performs a neuromechanical simulation in software from motor neuron activations.

% Clear Everything.
clear, close('all'), clc


%% Load Precomputed Simulation Data.

% State that we are starting a new operation.
fprintf( 'LOADING MOTOR NEURON ACTIVATION DATA. Please Wait...\n' )

% Start a timer.
tic

% Define the path to the directory that contains the robot data.
robot_data_load_path = 'C:\Users\USER\Documents\GitHub\Quadruped_Robot\Code\Matlab\Quadruped_Simulation_Framework\Utilities\Robot_Data';

% Create an instance of the data loader class.
data_loader = data_loader_class( robot_data_load_path );

% Define the name of the motor  neuron activations file.
file_name = 'motor_neuron_activations.xlsx';

% Define the maximum number of data points to load.
% max_num_data_points = 1000;
max_num_data_points = 100;

% Create an instance of the simulation data class.
precomputed_simulation_manager = precomputed_simulation_manager_class();

% Load the precomputed simulation data.
precomputed_simulation_manager = precomputed_simulation_manager.load_simulation_data( file_name, max_num_data_points );

% Retrieve the elapsed time.
elapsed_time = toc;

% State that we have finished this operation.
fprintf( 'LOADING MOTOR NEURON ACTIVATION DATA. Please Wait... Done. %0.3f [s] \n\n', elapsed_time )


%% Initialize the Neural Network.

% State that we are starting a new operation.
fprintf( 'INITIALIZING NEURAL NETWORK. Please Wait...\n' )

% Start a timer.
tic

% Define the number of neurons.
num_neurons = 4;

% Define the neuron IDs.
neuron_IDs = 1:num_neurons;

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
    neurons(k) = neuron_class( neuron_IDs(k), Cm, Gm, Er, R, Am, Sm, dEm, Ah, Sh, dEh, dEna, tauh_max, Gna );
    
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

% Retrieve the elapsed time.
elapsed_time = toc;

% State that we have finished this operation.
fprintf( 'INITIALIZING NEURAL NETWORK. Please Wait... Done. %0.3f [s] \n\n', elapsed_time )


%% Initialize the BPA Muscles.

% State that we are starting a new operation.
fprintf( 'INITIALIZING BPA MUSCLES. Please Wait...\n' )

% Start a timer.
tic

% Load the BPA muscle data.
[ muscle_IDs, muscle_names, desired_tensions, measured_tensions, desired_pressures, measured_pressures, max_pressures, muscle_lengths, resting_muscle_lengths, max_strains, velocities, yanks, c0s, c1s, c2s, c3s, c4s, c5s, c6s, ps, Js, muscle_types ] = data_loader.load_BPA_muscle_data( 'BPA_Muscle_Data.xlsx' );

% Define the number of BPA muscles.
num_BPA_muscles = length( muscle_IDs );

% Set the BPA muscle attachment point orientations.
Rs = repmat( eye( 3, 3 ), [ 1, 1, size( ps, 2 ) ] );

% Set the BPA muscle tendon length. (This is just a placeholder.  We will use the BPA attachment point locations in the resting position to infer the actual tendon length.)
tendon_length = 0;

% Preallocate an array of BPA muscles.
BPA_muscles = repmat( BPA_muscle_class(), 1, num_BPA_muscles );

% Create each BPA muscle object.
for k = 1:num_BPA_muscles               % Iterate through each of the BPA muscles...
    
    % Create this BPA muscle.
    BPA_muscles(k) = BPA_muscle_class( muscle_IDs(k), muscle_names{k}, desired_tensions(k), measured_tensions(k), desired_pressures(k), measured_pressures(k), max_pressures(k), muscle_lengths(k), resting_muscle_lengths(k), tendon_length, max_strains(k), velocities(k), yanks(k), ps(:, :, k), Rs, Js(:, k), c0s(k), c1s(k), c2s(k), c3s(k), c4s(k), c5s(k), c6s(k), muscle_types{k} );
    
end

% Retrieve the elapsed time.
elapsed_time = toc;

% State that we have finished this operation.
fprintf( 'INITIALIZING BPA MUSCLES. Please Wait... Done. %0.3f [s] \n\n', elapsed_time )


%% Initialize the Hill Muscles.

% State that we are starting a new operation.
fprintf( 'INITIALIZING HILL MUSCLES. Please Wait...\n' )

% Start a timer.
tic

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

% Retrieve the elapsed time.
elapsed_time = toc;

% State that we have finished this operation.
fprintf( 'INITIALIZING HILL MUSCLES. Please Wait... Done. %0.3f [s] \n\n', elapsed_time )


%% Initialize the Robot Body.

% State that we are starting a new operation.
fprintf( 'INITIALIZING ROBOT BODY. Please Wait...\n' )

% Start a timer.
tic

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

% Retrieve the elapsed time.
elapsed_time = toc;

% State that we have finished this operation.
fprintf( 'INITIALIZING ROBOT BODY. Please Wait... Done. %0.3f [s] \n\n', elapsed_time )


%% Initialize the Robot Links.

% State that we are starting a new operation.
fprintf( 'INITIALIZING ROBOT LINKS. Please Wait...\n' )

% Start a timer.
tic

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

% Retrieve the elapsed time.
elapsed_time = toc;

% State that we have finished this operation.
fprintf( 'INITIALIZING ROBOT LINKS. Please Wait... Done. %0.3f [s] \n\n', elapsed_time )


%% Initialize the Robot Joints.

% State that we are starting a new operation.
fprintf( 'INITIALIZING ROBOT JOINTS. Please Wait...\n' )

% Start a timer.
tic

% Load the joint data.
[ joint_IDs, joint_names, joint_parent_link_IDs, joint_child_link_IDs, joint_ps, joint_vs, joint_ws, joint_w_screws, joint_thetas, joint_domains, joint_orientations, joint_torques ] = data_loader.load_joint_data( 'Joint_Data.xlsx' );

% Define the number of joints.
num_joints = length(joint_IDs);

% Define the joint orientations.
joint_Rs = repmat( eye(3), [ 1, 1, num_joints ] );

% Preallocate an array of links.
joints = repmat( joint_class(), 1, num_joints );

% Create each joint object.
for k = 1:num_joints               % Iterate through each of the joints...
    
    % Create this joint.
    joints(k) = joint_class( joint_IDs(k), joint_names{k}, joint_parent_link_IDs(k), joint_child_link_IDs(k), joint_ps(:, k), joint_Rs(:, :, k), joint_vs(:, k), joint_ws(:, k), joint_w_screws(:, k), joint_thetas(k), joint_domains(:, k), joint_orientations{k}, joint_torques(k) );
    
end

% Retrieve the elapsed time.
elapsed_time = toc;

% State that we have finished this operation.
fprintf( 'INITIALIZING ROBOT JOINTS. Please Wait... Done. %0.3f [s] \n\n', elapsed_time )


%% Initialize the Robot Limbs.

% State that we are starting a new operation.
fprintf( 'INITIALIZING ROBOT LIMBS. Please Wait...\n' )

% Start a timer.
tic

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

% Retrieve the elapsed time.
elapsed_time = toc;

% State that we have finished this operation.
fprintf( 'INITIALIZING ROBOT LIMBS. Please Wait... Done. %0.3f [s] \n\n', elapsed_time )


%% Initialize USART Communication.

% State that we are starting a new operation.
fprintf( 'INITIALIZING USART MANAGER. Please Wait...\n' )

% Start a timer.
tic

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

% Retrieve the elapsed time.
elapsed_time = toc;

% State that we have finished this operation.
fprintf( 'INITIALIZING USART MANAGER. Please Wait... Done. %0.3f [s] \n\n', elapsed_time )


%% Initialize Slave Data Managers.

% State that we are starting a new operation.
fprintf( 'INITIALIZING SLAVE MANAGER. Please Wait...\n' )

% Start a timer.
tic

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

% Retrieve the elapsed time.
elapsed_time = toc;

% State that we have finished this operation.
fprintf( 'INITIALIZING SLAVE MANAGER. Please Wait... Done. %0.3f [s] \n\n', elapsed_time )


%% Initialize the Quadruped Robot.

% State that we are starting a new operation.
fprintf( 'INITIALIZING QUADRUPED ROBOT. Please Wait...\n' )

% Start a timer.
tic

% Create an instance of the neural subsystem class.
neural_subsystem = neural_subsystem_class( network, hill_muscle_manager );

% Create an instance of the mechanical subsystem class.
mechanical_subsystem = mechanical_subsystem_class( body, limb_manager );

% Create an instance of the electrical subsytem class.
electrical_subsystem = electrical_subsystem_class( usart_manager, slave_manager );

% Create an instance of the robot class.
robot_state0 = robot_class( neural_subsystem, mechanical_subsystem, electrical_subsystem );

% Retrieve the elapsed time.
elapsed_time = toc;

% State that we have finished this operation.
fprintf( 'INITIALIZING QUADRUPED ROBOT. Please Wait... Done. %0.3f [s] \n\n', elapsed_time )


%% Initialzize the Simulation Manager.

% State that we are starting a new operation.
fprintf( 'INITIALIZING SIMULATION MANAGER. Please Wait...\n' )

% Start a timer.
tic

% Set whether to simulate or use hardware.
bSimulateDynamics = true;

% Set whether to print debugging information.
bVerbose = false;

% Set the maximum number of robot states to record.
% max_states = 1000;
max_states = max_num_data_points;

% Define the gravity vector.
g = [0; -9.81; 0];                  % [m/s^2] Gravity Vector

% Set the initial hill muscle activations to match the precomputed network simulation. ( Precomputed Simulation -> Hill Muscle Activation )
robot_state0.neural_subsystem.hill_muscle_manager = robot_state0.neural_subsystem.hill_muscle_manager.set_muscle_property( precomputed_simulation_manager.muscle_IDs, precomputed_simulation_manager.activations(k, :), 'activation', true );

% Compute the initial hill muscle desired active tension to match the precomputed hill muscle activations. ( Hill Muscle Activation -> Hill Muscle Desired Active Tension )
robot_state0.neural_subsystem.hill_muscle_manager = robot_state0.neural_subsystem.hill_muscle_manager.call_muscle_method( 'all', 'activation2desired_active_tension' );

% Compute the initial hill muscle desired total and passive tension to match the hill muscle desired active tension. ( Hill Muscle Desired Active Tension -> Hill Muscle Desired Total Tension, Hill Muscle Desired Passive Tension )
robot_state0.neural_subsystem.hill_muscle_manager = robot_state0.neural_subsystem.hill_muscle_manager.call_muscle_method( 'all', 'desired_active_tension2desired_total_passive_tension' );

% Create an instance of the simulation manager class.
simulation_manager = simulation_manager_class( robot_state0, max_states, precomputed_simulation_manager.dt, bSimulateDynamics, bVerbose );

% Retrieve the elapsed time.
elapsed_time = toc;

% State that we have finished this operation.
fprintf( 'INITIALIZING SIMULATION MANAGER. Please Wait... Done. %0.3f [s] \n\n', elapsed_time )


%% ( Testing: Plotting Stuff )



fig = simulation_manager.robot_states(end).mechanical_subsystem.plot_mechanical_points(   );

% simulation_manager.robot_states(end).mechanical_subsystem.limb_manager.limbs(1) = simulation_manager.robot_states(end).mechanical_subsystem.limb_manager.limbs(1).BPA_muscle_tensions2joint_torques(  );


% % Print out BPA Muscle Tensions, Joint Torques, and Joint Angles.
% fprintf('BPA Muscle Tensions: [N]\n')
% disp( simulation_manager.robot_states(end).mechanical_subsystem.limb_manager.get_BPA_muscle_measured_tensions( 'all' ) )
%
% fprintf('Joint Torques: [Nm]\n')
% disp( simulation_manager.robot_states(end).mechanical_subsystem.limb_manager.get_joint_torques( 'all' ) )
%
% fprintf('Joint Angles: [rad]\n')
% disp( simulation_manager.robot_states(end).mechanical_subsystem.limb_manager.get_joint_angles( 'all' ) )
%
%
% % BPA Muscle Tensions -> Joint Torques
% simulation_manager.robot_states(end).mechanical_subsystem.limb_manager = simulation_manager.robot_states(end).mechanical_subsystem.limb_manager.BPA_muscle_tensions2joint_torques(  );
%
% % Joint Torques -> Joint Angles
% simulation_manager.robot_states(end).mechanical_subsystem.limb_manager = simulation_manager.robot_states(end).mechanical_subsystem.limb_manager.joint_torques2joint_angles( simulation_manager.dt, simulation_manager.robot_states(end).mechanical_subsystem.g );
%
% % Joint Angles -> Joint Torques
% simulation_manager.robot_states(end).mechanical_subsystem.limb_manager = simulation_manager.robot_states(end).mechanical_subsystem.limb_manager.joint_angles2joint_torques( simulation_manager.robot_states(end).mechanical_subsystem.g );
%
% % Print out BPA Muscle TEnsions, Joint Torques, and Joint Angles.
% fprintf('BPA Muscle Tensions: [N]\n')
% disp( simulation_manager.robot_states(end).mechanical_subsystem.limb_manager.get_BPA_muscle_measured_tensions( 'all' ) )
%
% fprintf('Joint Torques: [Nm]\n')
% disp( simulation_manager.robot_states(end).mechanical_subsystem.limb_manager.get_joint_torques( 'all' ) )
%
% fprintf('Joint Angles: [rad]\n')
% disp( simulation_manager.robot_states(end).mechanical_subsystem.limb_manager.get_joint_angles( 'all' ) )



% simulation_manager.robot_states(end).mechanical_subsystem.limb_manager.limbs(1).joint_manager = simulation_manager.robot_states(end).mechanical_subsystem.limb_manager.limbs(1).joint_manager.joint_configurations2joint_angles(  );


%% DEBUGGING: TESTING BPA MUSCLE MODEL

num_epsilons = 100;

P = 6894.76*90;
F_guess = 4.448221628250858*20;
epsilon_max = 0.16;
epsilons = linspace( 0, epsilon_max, num_epsilons );
S = 0;
c0 = 2.54e5;
c1 = 1.92e5;
c2 = 2.0265;
c3 = -0.461;
c4 = -3.31e-4;
c5 = 1.23e3;
c6 = 1.56e4;

Fs = zeros( 1, num_epsilons );

for k = 1:num_epsilons
    
    Fs( k ) = simulation_manager.robot_states(end).mechanical_subsystem.limb_manager.limbs(1).BPA_muscle_manager.BPA_muscles(1).forward_BPA_model( P, F_guess, epsilons( k ), epsilon_max, S, c0, c1, c2, c3, c4, c5, c6 );

end

figure( 'Color', 'w', 'Name', 'BPA Muscle: Force vs Strain' ), hold on, grid on, xlabel('Strain (Type I) [-]'), ylabel('Force [lb]'), title('BPA Muscle: Force vs Strain (Type I)'), plot( epsilons, 0.22480894244319*Fs, '-', 'Linewidth', 3 )



F = 0;
epsilon_max = 0.16;
epsilons = linspace( 0, epsilon_max, num_epsilons );

Ps = zeros( 1, num_epsilons );

for k = 1:num_epsilons

    Ps(k) = simulation_manager.robot_states(end).mechanical_subsystem.limb_manager.limbs(1).BPA_muscle_manager.BPA_muscles(1).inverse_BPA_model( F, epsilons(k), epsilon_max, S, c0, c1, c2, c3, c4, c5, c6 );

end

figure( 'Color', 'w', 'Name', 'BPA Muscle: Pressure vs Strain' ), hold on, grid on, xlabel('Strain (Type I) [-]'), ylabel('Pressure [psi]'), title('BPA Muscle: Pressure vs Strain (Type I)'), plot( epsilons, 0.000145038*Ps, '-', 'Linewidth', 3 )



num_epsilons = 100;
num_forces = 100;

fs = linspace( 0, 50, num_forces );
epsilons = linspace( 0, epsilon_max, num_epsilons );

[ Epsilons, Fs ] = meshgrid( epsilons, fs );

Ps = zeros( num_forces, num_epsilons );

for k1 = 1:num_forces
    for k2 = 1:num_epsilons
        
        Ps( k1, k2 ) = simulation_manager.robot_states(end).mechanical_subsystem.limb_manager.limbs(1).BPA_muscle_manager.BPA_muscles(1).inverse_BPA_model( Fs( k1, k2 ), Epsilons( k1, k2 ), epsilon_max, S, c0, c1, c2, c3, c4, c5, c6 );
        
    end
end

figure( 'Color', 'w', 'Name', 'BPA Muscle: Pressure vs Strain' ), hold on, grid on, xlabel('Strain (Type I) [-]'), ylabel('Force [lb]'), zlabel('Pressure [psi]'), title('BPA Muscle: Pressure vs Strain (Type I) & Force'), rotate3d on, xlim( [ 0, epsilon_max ] ), ylim( [ 0, max( max( 0.22480894244319*Fs ) ) ] )%, zlim( [ 0, 90 ] )
surf( Epsilons, 0.22480894244319*Fs, 0.000145038*Ps, 'Edgecolor', 'None' )





%% DEBUGGING: TESTING HILL MUSCLE MODEL

% NEED TO MAKE A TABLE OF THE BPA FORCE-PRESSURE-STRAIN RELATIONSHIP.  INTERPOLATE FROM THIS TABLE TO FIND GUESSES FOR FZERO.


num_timesteps = 100;
ts = linspace( 0, 1, num_timesteps );
active_tensions = 450*ones( 1, num_timesteps );
total_tensions = zeros( 1, num_timesteps );
passive_tensions = zeros( 1, num_timesteps );

total_tension0 = 0;
% total_tension0s = active_tensions;
delta_L0 = 0;
velocity = 0;
kse = 10;
kpe = 1;
% b = simulation_manager.dt*(kse + kpe)/2.2;
b = 1;
dt = simulation_manager.dt;
num_steps = 10;


total_tensions(1) = total_tension0;
passive_tensions(1) = total_tensions(1) - active_tensions(1);

for k = 1:num_timesteps - 1
    
    [ total_tensions(k + 1), passive_tensions(k + 1) ] = simulation_manager.robot_states(end).neural_subsystem.hill_muscle_manager.hill_muscles(1).active_tension2total_passive_tension( total_tensions(k), delta_L0, velocity, active_tensions(k), kse, kpe, b, dt, num_steps );
    %     [ total_tensions(k), passive_tensions(k) ] = simulation_manager.robot_states(end).neural_subsystem.hill_muscle_manager.hill_muscles(1).active_tension2total_passive_tension( total_tension0s(k), delta_L0, velocity, active_tensions(k), kse, kpe, b, dt, num_steps );
    
end

figure( 'Color', 'w' ), hold on, grid on, xlabel('Time [s]'), ylabel('Active Tension [N]'), title('Active Tension vs Time')
plot( ts, active_tensions, '-', 'Linewidth', 3 )

figure( 'Color', 'w' ), hold on, grid on, xlabel('Time [s]'), ylabel('Total Tension [N]'), title('Total Tension vs Time')
plot( ts, total_tensions, '-', 'Linewidth', 3 )

figure( 'Color', 'w' ), hold on, grid on, xlabel('Time [s]'), ylabel('Passive Tension [N]'), title('Passive Tension vs Time')
plot( ts, passive_tensions, '-', 'Linewidth', 3 )


%% Write Precomputed Simulation Data to the Master Microcontroller While Collecting Sensor Data

% State that we are starting a new operation.
fprintf( 'RUNNING SIMULATION. Please Wait...\n\n' )

% Start a timer.
simulation_timer = tic;

% Send each simulation data value to the master mircocontoller and collect the associated sensory feedback.
for k = 1:precomputed_simulation_manager.num_timesteps                  % Iterate through each simulation time step...
    
    %% Start a Timer.
    
    % Start a timer for this iteration.
    iteration_timer = tic;
    
    
    %% Initialize the Next Robot State.
    
    % Cycle the robot states.
    simulation_manager = simulation_manager.cycle_robot_states(  );
    
    
    %% DEBUGGING: PRINTING BPA MUSCLE PRESSURES
    
    %     BPA_muscle_desired_pressures = simulation_manager.robot_states(end).mechanical_subsystem.limb_manager.get_desired_pressure_from_all_BPA_muscles(  );
    %
    %     fprintf('BPA Muscle Desired Pressure:'), disp(BPA_muscle_desired_pressures)
    
    %% Perform a Single Step of the Forward Dynamics Simulation ( Either Via Hardware or Simulation ) ( BPA Muscle Desired Pressures -> BPA Muscle Measured Pressure & Joint Angles )
    
    % Perform a single step of the forward dynamics simulation. ( BPA Muscle Desired Pressures -> BPA Muscle Measured Pressure & Joint Angles )
    simulation_manager = simulation_manager.forward_dynamics_step(  );
    
    
    %% DEBUGGING: PRINTING BPA PRESSURES & TENSIONS
    %
    %     BPA_muscle_desired_pressures = simulation_manager.robot_states(end).mechanical_subsystem.limb_manager.get_desired_pressure_from_all_BPA_muscles(  );
    %     BPA_muscle_measured_pressures = simulation_manager.robot_states(end).mechanical_subsystem.limb_manager.get_measured_pressure_from_all_BPA_muscles(  );
    %
    %     fprintf( 'Pressure Match: %0.0f, ', all( BPA_muscle_desired_pressures == BPA_muscle_measured_pressures ) )
    %
    %     BPA_muscle_desired_tensions = simulation_manager.robot_states(end).mechanical_subsystem.limb_manager.get_desired_tension_from_all_BPA_muscles(  );
    %     BPA_muscle_measured_tensions = simulation_manager.robot_states(end).mechanical_subsystem.limb_manager.get_measured_tension_from_all_BPA_muscles(  );
    %
    %     fprintf( 'Tension Match: %0.0f\n', all( BPA_muscle_desired_tensions == BPA_muscle_measured_tensions ) )
    %
    %     fprintf('BPA Muscle Desired Pressure: \n'), disp(BPA_muscle_desired_pressures)
    %     fprintf('BPA Muscle Measured Pressure: \n'), disp(BPA_muscle_measured_pressures)
    %     fprintf('BPA Muscle Desired Tension: \n'), disp(BPA_muscle_desired_tensions)
    %     fprintf('BPA Muscle Measured Tension: \n'), disp(BPA_muscle_measured_tensions)
    
    
    %% DEBUGGING: PRINTING JOINT ANGLES
    
    %     thetas = simulation_manager.robot_states(end).mechanical_subsystem.limb_manager.get_angles_from_all_joints(  );
    %
    %     fprintf('Joint Angles:'), disp(thetas)
    
    
    %% Compute the Robot Configuration Given the Current Joint Angles (i.e., Forward Kinematics). ( Joint Angles -> Robot Configuration )
    
    % Compute the configuration of the body. ( ??? )
    
    % Compute the configuration of each limb. ( Joint Angles -> Limb Configuration )
    simulation_manager.robot_states(end).mechanical_subsystem.limb_manager = simulation_manager.robot_states(end).mechanical_subsystem.limb_manager.joint_angles2limb_configurations(  );
    
    
    %% Compute Derived BPA Muscle Properties. ( BPA Muscle Tension, BPA Muscle Yank, BPA Muscle Length, BPA Muscle Strain, BPA Muscle Velocity )
    
    % Update the BPA muscle properties (muscle tension, muscle length, muscle strain) to reflect the sensor data info ( muscle pressure, muscle attachment point position ). ( BPA Muscle Pressure -> BPA Muscle Tension; BPA Muscle Attachment Locations -> BPA Muscle Length, BPA Muscle Strain )
    simulation_manager.robot_states(end).mechanical_subsystem.limb_manager = simulation_manager.robot_states(end).mechanical_subsystem.limb_manager.update_BPA_muscle_properties(  );
    
    % Compute the BPA muscle property derivatives from the BPA muscle property histories. ( BPA Muscle Tension History -> BPA Muscle Yank; BPA Muscle Length History -> BPA Muscle Velocity )
    simulation_manager = simulation_manager.BPA_muscle_property_histories2BPA_muscle_property_derivatives(  );
    
    
    %% Compute Derived Hill Muscle Properties. ( Hill Muscle Tension, Hill Muscle Yank, Hill Muscle Length, Hill Muscle Strain, Hill Muscle Velocity, Hill Muscle Type Ia Feedback, Hill Muscle Type Ib Feedback, and Hill Muscle Type II Feedback )
    
    % Transfer the appropriate BPA muscle properties to the hill muscles. ( BPA Muscle Measured Tension, BPA Muscle Yank, BPA Muscle Muscle Length, BPA Muscle Muscle Strain, BPA Muscle Muscle Velocity -> Hill Muscle Measured Tension, Hill Muscle Yank, Hill Muscle Muscle Length, Hill Muscle Muscle Strain, Hill Muscle Muscle Velocity  )
    simulation_manager.robot_states(end) = simulation_manager.robot_states(end).BPA_muscle_properties2hill_muscle_properties(  );
    
    % Compute the hill muscle measured active and passive tension associated with the hill muscle measured total tension. ( Hill Muscle Measured Tension -> Hill Muscle Measured Active Tension, Hill Muscle Measured Passive Tension )
    simulation_manager.robot_states(end).neural_subsystem.hill_muscle_manager = simulation_manager.robot_states(end).neural_subsystem.hill_muscle_manager.measured_total_tensions2measured_active_passive_tensions( 'all' );
    
    % Compute the type Ia, type Ib, and type II feedback associated with the current hill muscle velocity, measured total tension, and length, respectively. ( Hill Muscle Velocity -> Hill Muscle Type Ia Feedback; Hill Muscle Measured Total Tension -> Hill Muscle Type Ib Feedback; Hill Muscle Length -> Hill Muscle Type II Feedback )
    simulation_manager.robot_states(end).neural_subsystem.hill_muscle_manager = simulation_manager.robot_states(end).neural_subsystem.hill_muscle_manager.muscle_properties2muscle_feedback(  );
    
    
    %% Compute the Network Properties & Hill Muscle Activation.
    
    % Store the simulation data into the muscle manager. ( Precomputed Simulation Data -> Hill Muscle Activation )
    simulation_manager.robot_states(end).neural_subsystem.hill_muscle_manager = simulation_manager.robot_states(end).neural_subsystem.hill_muscle_manager.set_muscle_property( precomputed_simulation_manager.muscle_IDs, precomputed_simulation_manager.activations(k, :), 'activation', true );
    
    
    %% Compute the Derived Hill Muscle Properties. ( Hill Muscle Desired Active Tension, Hill Muscle Desired Passive Tension, Hill Muscle Desired Total Tension )
    
    % Compute hill muscle desired total tension from the hill muscle activation. ( Hill Muscle Activation -> Hill Muscle Desired Active Tension )
    simulation_manager.robot_states(end).neural_subsystem.hill_muscle_manager = simulation_manager.robot_states(end).neural_subsystem.hill_muscle_manager.activations2desired_active_tensions( muscle_IDs );
    
    % Compute the hill muscle desired total and passive tensions from the hill muscle desired active tension. ( Hill Muscle Desired Active Tension -> Hill Muscle Desired Passive & Total Tensions )
    simulation_manager.robot_states(end).neural_subsystem.hill_muscle_manager = simulation_manager.robot_states(end).neural_subsystem.hill_muscle_manager.desired_active_tensions2desired_total_passive_tensions( muscle_IDs );
    
    
    %% DEBUGGING: PRINTING BPA PRESSURES & TENSIONS
    
    %     hill_muscle_desired_tensions = simulation_manager.robot_states(end).neural_subsystem.hill_muscle_manager.get_hill_muscle_desired_total_tension( 'all' );
    %     hill_muscle_measured_tensions = simulation_manager.robot_states(end).neural_subsystem.hill_muscle_manager.get_hill_muscle_measured_total_tension( 'all' );
    %
    %     BPA_muscle_desired_tensions = simulation_manager.robot_states(end).mechanical_subsystem.limb_manager.get_desired_tension_from_all_BPA_muscles(  );
    %     BPA_muscle_measured_tensions = simulation_manager.robot_states(end).mechanical_subsystem.limb_manager.get_measured_tension_from_all_BPA_muscles(  );
    %
    %     fprintf('Before Hill Muscle -> BPA Muscle Desired Tension Transfer')
    %     fprintf('Hill Muscle Desired Tension: \n'), disp(hill_muscle_desired_tensions)
    %     fprintf('Hill Muscle Measured Tension: \n'), disp(hill_muscle_measured_tensions)
    %     fprintf('BPA Muscle Desired Tension: \n'), disp(BPA_muscle_desired_tensions)
    %     fprintf('BPA Muscle Measured Tension: \n'), disp(BPA_muscle_measured_tensions)
    
    
    %% Compute the Derived BPA Muscle Properties. ( BPA Muscle Desired Tension, BPA Muscle Desired Pressure )
    
    % Transfer the hill muscle desired total tension to the BPA muscle desired total tension. ( Hill Muscle Desired Total Tension -> BPA Muscle Desired Tension )
    simulation_manager.robot_states(end) = simulation_manager.robot_states(end).hill_muscle_desired_tensions2BPA_muscle_desired_tensions(  );
    
    
    %     hill_muscle_desired_tensions = simulation_manager.robot_states(end).neural_subsystem.hill_muscle_manager.get_hill_muscle_desired_total_tension( 'all' );
    %     hill_muscle_measured_tensions = simulation_manager.robot_states(end).neural_subsystem.hill_muscle_manager.get_hill_muscle_measured_total_tension( 'all' );
    %
    %     BPA_muscle_desired_tensions = simulation_manager.robot_states(end).mechanical_subsystem.limb_manager.get_desired_tension_from_all_BPA_muscles(  );
    %     BPA_muscle_measured_tensions = simulation_manager.robot_states(end).mechanical_subsystem.limb_manager.get_measured_tension_from_all_BPA_muscles(  );
    %
    %     fprintf('After Hill Muscle -> BPA Muscle Desired Tension Transfer')
    %     fprintf('Hill Muscle Desired Tension: \n'), disp(hill_muscle_desired_tensions)
    %     fprintf('Hill Muscle Measured Tension: \n'), disp(hill_muscle_measured_tensions)
    %     fprintf('BPA Muscle Desired Tension: \n'), disp(BPA_muscle_desired_tensions)
    %     fprintf('BPA Muscle Measured Tension: \n'), disp(BPA_muscle_measured_tensions)
    
    
    % Compute the BPA muscle desired pressure from the BPA muscle desired tension. ( BPA Muscle Desired Tension -> BPA Muscle Desired Pressure )
    simulation_manager.robot_states(end).mechanical_subsystem.limb_manager = simulation_manager.robot_states(end).mechanical_subsystem.limb_manager.desired_tensions2desired_pressures( 'all' );
    
    
    %% Store the Desired BPA Muscle Pressure in the Slave Manager.
    
    % Transfer the BPA muscle desired pressure to the slave manager desired pressure. ( BPA Muscle Desired Pressure -> Slave Manager Desired Pressure )
    simulation_manager.robot_states(end) = simulation_manager.robot_states(end).BPA_desired_pressures2slave_desired_pressures(  );
    
    
    %% End the Timer.
    
    % End the timer for this iteration.
    iteration_duration = toc(iteration_timer);
    
    % Print out information for this iteration.
    fprintf( 'Iteration #%0.0f: %0.3f [s]\n', k, iteration_duration )
    
    
    %% DEBUGGING: PRINTING BPA MUSCLE PRESSURES
    
    hill_muscle_desired_passive_tensions = simulation_manager.robot_states(end).neural_subsystem.hill_muscle_manager.get_hill_muscle_desired_passive_tension( 'all' );
    hill_muscle_desired_active_tensions = simulation_manager.robot_states(end).neural_subsystem.hill_muscle_manager.get_hill_muscle_desired_active_tension( 'all' );
    hill_muscle_desired_total_tensions = simulation_manager.robot_states(end).neural_subsystem.hill_muscle_manager.get_hill_muscle_desired_total_tension( 'all' );
    
    fprintf('Hill Muscle Desired Passive Tension:'), disp(hill_muscle_desired_passive_tensions)
    fprintf('Hill Muscle Desired Active Tension:'), disp(hill_muscle_desired_active_tensions)
    fprintf('Hill Muscle Desired Total Tension:'), disp(hill_muscle_desired_total_tensions)
    
    hill_muscle_measured_passive_tensions = simulation_manager.robot_states(end).neural_subsystem.hill_muscle_manager.get_hill_muscle_desired_passive_tension( 'all' );
    hill_muscle_measured_active_tensions = simulation_manager.robot_states(end).neural_subsystem.hill_muscle_manager.get_hill_muscle_desired_active_tension( 'all' );
    hill_muscle_measured_total_tensions = simulation_manager.robot_states(end).neural_subsystem.hill_muscle_manager.get_hill_muscle_desired_total_tension( 'all' );
    
    fprintf('Hill Muscle Measured Passive Tension:'), disp(hill_muscle_measured_passive_tensions)
    fprintf('Hill Muscle Measured Active Tension:'), disp(hill_muscle_measured_active_tensions)
    fprintf('Hill Muscle Measured Total Tension:'), disp(hill_muscle_measured_total_tensions)
    
    BPA_muscle_desired_pressures = simulation_manager.robot_states(end).mechanical_subsystem.limb_manager.get_desired_pressure_from_all_BPA_muscles(  );
    BPA_muscle_measured_pressures = simulation_manager.robot_states(end).mechanical_subsystem.limb_manager.get_measured_pressure_from_all_BPA_muscles(  );
    BPA_muscle_desired_tensions = simulation_manager.robot_states(end).mechanical_subsystem.limb_manager.get_desired_tension_from_all_BPA_muscles(  );
    BPA_muscle_measured_tensions = simulation_manager.robot_states(end).mechanical_subsystem.limb_manager.get_measured_tension_from_all_BPA_muscles(  );

    fprintf('BPA Muscle Desired Pressure:'), disp(BPA_muscle_desired_pressures)
    fprintf('BPA Muscle Measured Pressure:'), disp(BPA_muscle_measured_pressures)
    fprintf('BPA Muscle Desired Tension:'), disp(BPA_muscle_desired_tensions)
    fprintf('BPA Muscle Measured Tension:'), disp(BPA_muscle_measured_tensions)    
    
    fprintf('\n\n')
    
end

% Retrieve the total simulation duration.
simulation_duration = toc(simulation_timer);

% State that we have finished this operation.
fprintf( '\nRUNNING SIMULATION. Please Wait... Done. %0.3f [s] \n\n', simulation_duration )


%% DEBUGGING: CHECKING BPA PRESSURE & TENSION HISTORY

% Get the BPA muscle desired pressures.
BPA_muscle_desired_pressures = simulation_manager.get_BPA_desired_pressure_history( 'all' );

% Get the BPA muscle desired tensions.
BPA_muscle_desired_tensions = simulation_manager.get_BPA_desired_tension_history( 'all' );


%% Plot Simulation Results.

% State that we are starting a new operation.
fprintf( 'PLOTTING SIMULATION RESULTS. Please Wait...\n' )

% Start a timer.
tic

% Plot the motor neuron activations.
fig_motor_activations = precomputed_simulation_manager.plot_activation();

% Plot the hill muscle activation history.
fig_hill_muscle_activation = simulation_manager.plot_hill_muscle_activation_history( 'all' );





% Plot the hill muscle desired passive tension history.
fig_hill_muscle_desired_passive_tension = simulation_manager.plot_hill_muscle_desired_passive_tension_history( 'all' );

% Plot the hill muscle desired active tension history.
fig_hill_muscle_desired_active_tension = simulation_manager.plot_hill_muscle_desired_active_tension_history( 'all' );

% Plot the hill muscle desired total tension history.
fig_hill_muscle_desired_total_tension = simulation_manager.plot_hill_muscle_desired_total_tension_history( 'all' );




% Plot the hill muscle measured passive tension history.
fig_hill_muscle_measured_passive_tension = simulation_manager.plot_hill_muscle_measured_passive_tension_history( 'all' );

% Plot the hill muscle measured active tension history.
fig_hill_muscle_measured_active_tension = simulation_manager.plot_hill_muscle_measured_active_tension_history( 'all' );

% Plot the hill muscle measured total tension history.
fig_hill_muscle_measured_total_tension = simulation_manager.plot_hill_muscle_measured_total_tension_history( 'all' );




% Plot the end effect joint kinematic history.
fig_joint_kinematics = simulation_manager.plot_joint_kinematic_history( 'all' );

% Plot the end effector path in the state space.
fig_end_effector_path = simulation_manager.plot_end_effector_path( 'all' );

% Plot the end effector position, velocity, and acceleration history.
fig_end_effector_position = simulation_manager.plot_end_effector_position_history( 'all' );
fig_end_effector_velocity = simulation_manager.plot_end_effector_velocity_history( 'all' );
fig_end_effector_acceleration = simulation_manager.plot_end_effector_acceleration_history( 'all' );

% Plot the BPA muscle pressure history.
fig_BPA_muscle_pressure = simulation_manager.plot_BPA_muscle_pressure_history( 'all' );

% Plot the BPA muscle tension history.
fig_BPA_muscle_tension = simulation_manager.plot_BPA_muscle_tension_history( 'all' );

% Plot the BPA muscle length history.
fig_BPA_muscle_length = simulation_manager.plot_BPA_muscle_length_history( 'all' );

% Plot the BPA muscle velocity history.
fig_BPA_muscle_velocity = simulation_manager.plot_BPA_muscle_velocity_history( 'all' );

% Plot the BPA muscle strain history.
fig_BPA_muscle_strain = simulation_manager.plot_BPA_muscle_strain_history( 'all' );


% Retrieve the elapsed time.
elapsed_time = toc;

% State that we have finished this operation.
fprintf( 'PLOTTING SIMULATION RESULTS. Please Wait... Done. %0.3f [s] \n\n', elapsed_time )


%% Terminate USART Communication.

% State that we are starting a new operation.
fprintf( 'TERMINATING USART MANAGER. Please Wait...\n' )

% Start a timer.
tic

% Terminate the USART serial ports.
usart_manager = usart_manager.terminate_serial_ports();

% Retrieve the elapsed time.
elapsed_time = toc;

% State that we have finished this operation.
fprintf( 'TERMINATING USART MANAGER. Please Wait... Done. %0.3f [s] \n\n', elapsed_time )


