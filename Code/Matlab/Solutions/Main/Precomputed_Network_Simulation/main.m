%% Precomputed Network Simulation Main Script

% This script sends precomputed network simulation results to the quadruped robot hardware.

% Clear Everything.
clear, close('all'), clc


%% Load Precomputed Simulation Data.

% Define the path to the file we want to load.
load_path = 'C:\Users\USER\Documents\GitHub\Quadruped_Robot\Code\Matlab\Solutions\Main\Precomputed_Network_Simulation';
file_name = 'Precomputed_Network_Simulation_Data.xlsx';
file_path = [load_path, '\', file_name];

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


%% Initialize the Hill Muscles.

% Define the number of muscles.
num_muscles = 24;

% Define the muscle IDs.
muscle_IDs = linspace2(39, 1, num_muscles);

% Define the muscle names.
muscle_names = { 'Front Left Scapula Extensor', 'Front Left Scapula Flexor', 'Front Left Shoulder Extensor', 'Front Left Shoulder Flexor', 'Front Left Wrist Extensor', 'Front Left Wrist Flexor', ...
    'Back Left Hip Extensor', 'Back Left Hip Flexor', 'Back Left Knee Extensor', 'Back Left Knee Flexor', 'Back Left Ankle Extensor', 'Back Left Ankle Flexor', ...
    'Front Right Scapula Extensor', 'Front Right Scapula Flexor', 'Front Right Shoulder Extensor', 'Front Right Shoulder Flexor', 'Front Right Wrist Extensor', 'Front Right Wrist Flexor', ...
    'Back Right Hip Extensor', 'Back Right Hip Flexor', 'Back Right Knee Extensor', 'Back Right Knee Flexor', 'Back Right Ankle Extensor', 'Back Right Ankle Flexor' };

% Define the muscle activations.
activation = -0.050;                                                    % [V] Motor Neuron Activation.
activation_domain = [-0.050, -0.019];                            % [V] Motor Neuron Activation Domain.

% Define the initial desired muscle tensions.
desired_total_tension = 0;                                         % [N] Desired Total Muscle Tension.  The "total" muscle tension is the real muscle tension that would be observed in the muscle if measured.  This tension is relevant to both BPA muscles and real muscles.
desired_active_tension = 0;                                        % [N] Desired Active Muscle Tension.  The "active" muscle tension is the tension in the muscle that is developed due to motor neuron activation.  This tension is only relevant to real muscles (not BPAs).
desired_passive_tension = 0;                                       % [N] Desired Passive Muscle Tension.  The "passive" muscle tension is the tension in the muscle that is developed naturally due to the internal dynamics of the muscle.  This tension is only relevant to real muscles (not BPAs).

% Define the initial measured muscle tensions.
measured_total_tension = 0;                                        % [N] Measured Total Muscle Tension.
measured_active_tension = 0;                                       % [N] Measured Active Muscle Tension.  The "measured" active tension is inferred active muscle tension that would result from the measured total muscle tension.
measured_passive_tension = 0;                                      % [N] Measured Passive Muscle Tension.  The "measured" passive tension is the inferred passive muscle tension that would result from the measured total muscle tension.

% Define the tension domain.
tension_domain = [0, 450];                                       % [N] Total Muscle Tension Domain.

% Define the desired and measured pressures.
desired_pressure = 0;
measured_pressure = 0;
% pressure_domain = [0, 6894.76*90];
max_pressure = 6894.76*90;

% Define the resting muscle lengths.
muscle_lengths = 0.0254*[ 13, 13, 5.125, 5.125, 6.5, 5, ...         % [m] Muscle Lengths.
    13, 13, 5.125, 5.125, 6.5, 5, ...
    13, 13, 7.25, 7.25, 5, 6, ...
    13, 13, 7.25, 7.25, 5, 6 ];

muscle_resting_lengths = muscle_lengths;

% Define the maximum muscle strains.
max_strain = 0.16;

% Define the initial muscle velocities.
velocity = 0;                                                     % [m/s] Muscle Velocity.

% Define the initial muscle yanks.
yank = 0;                                                          % [N/s] Muscle Yank (Derivative of Total Muscle Tension with Respect to Time).

% Define the hill muscle parameters.
kse = 30;                                                          % [N/m] Hill Muscle Model Series Stiffness.
kpe = 30;                                                          % [N/m] Hill Muscle Model Parallel Stiffness.
b = 1;                                                             % [Ns/m] Hill Muscle Model Damping Coefficient.

% Define the BPA muscle parameters.
c0 = 254.3e3;                       % [Pa] Model Parameter 0
c1 = 192e3;                         % [Pa] Model Parameter 1
c2 = 2.0265;                        % [-] Model Parameter 2
c3 = -0.461;                        % [-] Model Parameter 3
c4 = -0.331e-3;                     % [1/N] Model Parameter 4
c5 = 1.23e3;                        % [Pa/N] Model Parameter 5
c6 = 15.6e3;                        % [Pa] Model Parameter 6

% Define the number of steps to perform per simulation time step when integrating the Hill Muscle Model.
num_int_steps = 10;

% Preallocate an array of hill and BPA muscles.
hill_muscles = repmat( hill_muscle_class(), 1, num_muscles );
BPA_muscles = repmat( BPA_muscle_class(), 1, num_muscles );

% Create each hill and BPA muscle object.
for k = 1:num_muscles               % Iterate through each of the hill and BPA muscles...
    
    % Create this hill muscle.
    hill_muscles(k) = hill_muscle_class( muscle_IDs(k), muscle_names{k}, activation, activation_domain, desired_total_tension, desired_active_tension, desired_passive_tension, measured_total_tension, measured_active_tension, measured_passive_tension, tension_domain, muscle_lengths(k), muscle_resting_lengths(k), max_strain, velocity, yank, kse, kpe, b, network_dt, num_int_steps );
    
    % Create this BPA muscle.
    BPA_muscles(k) = BPA_muscle_class( muscle_IDs(k), muscle_names{k}, desired_total_tension, measured_total_tension, desired_pressure, measured_pressure, max_pressure, muscle_lengths(k), muscle_resting_lengths(k), max_strain, velocity, yank, c0, c1, c2, c3, c4, c5, c6 );

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
body_R_cm = eye(3);
body_v_cm = zeros( 3, 1 );
body_w_cm = zeros( 3, 1 );

% Define the body mesh type.
body_mesh_type = 'Cuboid';

% Create an instance of the body class.
body = body_class( body_ID, body_name, body_mass, body_length, body_width, body_height, body_p_cm, body_R_cm, body_v_cm, body_w_cm, body_mesh_type );


%% Initialize the Robot Links.

% Define the number of links.
num_links = 14;

% Define the link IDs.
link_IDs = [ 1, 2, 3, 4, ...
    5, 6, 7, ...
    8, 9, 10, 11, ...
    12, 13, 14 ];

% Define the link names.
link_names = { 'Front Left Scapula', 'Front Left Humerous', 'Front Left Radius Ulna', 'Front Left Hand', ...
    'Back Left Femur', 'Back Left Tibia Fibula', 'Back Left Foot', ...
    'Front Right Scapula', 'Front Right Humerous', 'Front Right Radius Ulna', 'Front Right Hand', ...
    'Back Right Femur', 'Back Right Tibia Fibula', 'Back Right Foot' };

% Define the link parent joint IDs.
link_parent_joint_IDs = [ 1, 2, 3, 4, ...
    5, 6, 7, ...
    8, 9, 10, 11, ...
    12, 13, 14 ];

% Define the link child joint IDs.
link_child_joint_IDs = [ 2, 3, 4, -1, ...
    6, 7, -1, ...
    9, 10, 11, -1, ...
    13, 14, -1 ];

% Define the link start points.
link_ps_starts = [ -9.5625, -9.5625, -9.5625, -9.5625, 9.5625, 9.5625, 9.5625, -9.5625, -9.5625, -9.5625, -9.5625, 9.5625, 9.5625, 9.5625;
    1.25, -5.1875, -12.6875, -21, -1.25, -9.875, -18.5, 1.25, -5.1875, -12.6875, -21, -1.25, -9.875, -18.5;
    4.0625, 4.0625, 4.0625, 4.0625, 4.0625, 4.0625, 4.0625, -4.0625, -4.0625, -4.0625, -4.0625, -4.0625, -4.0625, -4.0625 ];

% Define the link end points.
link_ps_ends = [ -9.5625, -9.5625, -9.5625, -9.5625, 9.5625, 9.5625, 9.5625, -9.5625, -9.5625, -9.5625, -9.5625, 9.5625, 9.5625, 9.5625;
    -5.1875, -12.6875, -21, -25.625, -9.875, -18.5, -24.75, -5.1875, -12.6875, -21, -25.625, -9.875, -18.5, -24.75;
    4.0625, 4.0625, 3.0625, 4.0625, 4.0625, 4.0625, 4.0625, -4.0625, -4.0625, -4.0625, -4.0625, -4.0625, -4.0625, -4.0625 ];

% Define the link lengths.
link_lengths = vecnorm( link_ps_ends - link_ps_starts, 2, 1);

% Define the link widths.
link_widths = 1.125*ones( 1, num_links );

% Define the link masses.
link_masses = ones( 1, num_links );

% Define the link center of mass locations.
link_ps_cms = [ -9.5625, -9.5625, -9.5625, -9.5625, 9.5625, 9.5625, 9.5625, -9.5625, -9.5625, -9.5625, -9.5625, 9.5625, 9.5625, 9.5625;
    -1.96875, -8.9375, -16.84375, -23.3125, -5.5625, -14.1875, -21.625, -1.96875, -8.9375, -16.84375, -23.3125, -5.5625, -14.1875, -21.625;
    4.0625, 4.0625, 4.0625, 4.0625, 4.0625, 4.0625, 4.0625, -4.0625, -4.0625, -4.0625, -4.0625, -4.0625, -4.0625, -4.0625 ];

% Define the link center of mass translational velocities.
link_vs_cms = zeros( 3, num_links );

% Define the link center of mass rotational velocities.
link_ws_cms = zeros( 3, num_links );

% Define the link orientations.
link_Rs = repmat( eye(3), [ 1, 1, num_links ] );

% Define the link mesh types.
link_mesh_types = repmat( {'Cuboid'}, [ 1, num_links ] );

% Preallocate an array of links.
links = repmat( link_class(), 1, num_links );

% Create each link object.
for k = 1:num_links               % Iterate through each of the links...
    
    % Create this link.
    links(k) = link_class( link_IDs(k), link_names{k}, link_parent_joint_IDs(k), link_child_joint_IDs(k), link_ps_starts(:, k), link_ps_ends(:, k), link_lengths(:, k), link_widths(:, k), link_masses(k), link_ps_cms(:, k), link_vs_cms(:, k), link_ws_cms(:, k), link_Rs(:, :, k), link_mesh_types{k} );
    
end


%% Initialize the Robot Joints.

% Define the number of joints.
num_joints = 14;

% Define the ID of the joint associated with each slave.
joint_IDs = 1:num_joints;

% Define the name of the joint associated with each slave.
joint_names = { 'Front Left Scapula', 'Front Left Shoulder', 'Front Left Elbow', 'Front Left Wrist', ...
    'Back Left Hip', 'Back Left Knee', 'Back Left Ankle', ...
    'Front Right Scapula', 'Front Right Shoulder', 'Front Right Elbow', 'Front Right Wrist', ...
    'Back Right Hip', 'Back Right Knee', 'Back Right Ankle' };

% Define the parent link IDs.
joint_parent_link_IDs = [ 0, 1, 2, 3, ...
    0, 5, 6, ...
    0, 8, 9, 10, ...
    0, 12, 13 ];

% Define the child link IDs.
joint_child_link_IDs = [ 1, 2, 3, 4, ...
    5, 6, 7, ...
    8, 9, 10, 11, ...
    12, 13, 14 ];

% Define the joint locations.
joint_ps = [ -9.5625, -9.5625, -9.5625, -9.5625, 9.5625, 9.5625, 9.5625, -9.5625, -9.5625, -9.5625, -9.5625, 9.5625, 9.5625, 9.5625;
    1.25, -5.1875, -12.6875, -21, -1.25, -9.875, -18.5, 1.25, -5.1875, -12.6875, -21, -1.25, -9.875, -18.5;
    4.0625, 4.0625, 4.0625, 4.0625, 4.0625, 4.0625, 4.0625, -4.0625, -4.0625, -4.0625, -4.0625, -4.0625, -4.0625, -4.0625 ];

% Define the joint orientations.
joint_Rs = repmat( eye(3), [ 1, 1, num_joints ] );

% Define the joint translational velocities.
joint_vs = zeros( 3, num_joints );

% Define the joint rotational velocities.
joint_ws = zeros( 3, num_joints );

% Define the joint axes of rotation.
joint_w_screws = repmat( [ 0; 0; 1 ], [ 1, num_joints ] );

% Define the joint angles.
joint_thetas = zeros( 1, num_joints );

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
    slaves(k) = slave_class( uint8( slave_IDs(k) ), uint8( muscle_IDs(k) ), muscle_names{k}, uint8( pressure_sensor_ID1s(k) ), uint8( pressure_sensor_ID2s(k) ), uint8( encoder_IDs(k) ), encoder_names{k}, uint16( measured_pressure_value1s(k) ), uint16( measured_pressure_value2s(k) ), uint16( measured_encoder_values(k) ), uint16( desired_pressures(k) ) );
    
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
robot_state0.neural_subsystem.hill_muscle_manager = simulation_manager.quadruped_robot.neural_subsystem.hill_muscle_manager.set_muscle_property( precomputed_simulation_manager.muscle_IDs, precomputed_simulation_manager.activations(k, :), 'activation', true );

% Compute the initial hill muscle desired active tension to match the precomputed hill muscle activations. ( Hill Muscle Activation -> Hill Muscle Desired Active Tension )
robot_state0.neural_subsystem.hill_muscle_manager = simulation_manager.quadruped_robot.neural_subsystem.hill_muscle_manager.call_muscle_method( 'all', 'activation2desired_active_tension' );

% Compute the initial hill muscle desired total and passive tension to match the hill muscle desired active tension. ( Hill Muscle Desired Active Tension -> Hill Muscle Desired Total Tension, Hill Muscle Desired Passive Tension )
robot_state0.neural_subsystem.hill_muscle_manager = simulation_manager.quadruped_robot.neural_subsystem.hill_muscle_manager.call_muscle_method( 'all', 'desired_active_tension2desired_total_passive_tension' );

% Create an instance of the simulation manager class.
simulation_manager = simulation_manager_class( robot_state0, max_states, precomputed_simulation_manager.dt );


%% Write Precomputed Simulation Data to the Master Microcontroller While Collecting Sensor Data


% Send each simulation data value to the master mircocontoller and collect the associated sensory feedback.
for k = 1:precomputed_simulation_manager.num_timesteps                  % Iterate through each simulation time step...
    
    %% Initialize the Next Robot State.
    
    % Set the next robot state to be the same as this robot state.
%     simulation_manager.robot_states(k + 1) = simulation_manager.robot_states(k);
    simulation_manager = simulation_manager.cycle_robot_states(  );
    
    %% Write the Desired Muscle Pressures to the Master Microcontroller & Read Sensor Data.
    
    % CREATE A SIMULATION MANAGER FUNCTION "READ WRITE FROM ROBOT" USING THE TWO HIGHER LEVEL FUNCTIONS BELOW.
   
    % Write the desired pressures stored in the slave manager to the master microcontroller ( Slave Manager Desired Pressures -> Master Microcontroller ( Real or Virtual ) Serial Port )
    simulation_manager.robot_states(end - 1).electrical_subsystem = simulation_manager.robot_states(end - 1).electrical_subsystem.write_desired_pressures_to_master(  );

    % Read the sensor data from the master microcontroller ( Master Microcontroller BPA Pressures & Joint Angles -> Slave Manager Manager )
    simulation_manager.robot_states(end).electrical_subsystem = simulation_manager.robot_states(end).electrical_subsystem.read_sensor_data_from_master(  );

    
    %% Store the Sensor Data Received From the Master Microcontroller.
        
    
    % Transfer the slave measured pressure data to the BPA muscle measured pressure. (Slave Measured Pressure -> BPA Muscle Measured Pressure)
    simulation_manager.robot_states(k + 1) = simulation_manager.robot_states(k + 1).slave_measured_pressures2BPA_measured_pressures(  );

    % Compute the BPA muscle measured tension associated with the BPA muscle measured pressure. (BPA Muscle Measured Pressure -> BPA Muscle Measured Tension)
    simulation_manager.robot_states(k + 1).mechanical_subsystem.limb_manager = simulation_manager.robot_states(k + 1).mechanical_subsystem.limb_manager.call_BPA_muscle_method( 'all', 'measured_pressure2measured_tension' );
    
    % Compute the hill muscle measured total tension associated with the BPA muscle measured tension. (BPA Muscle Measured Tension -> Hill Muscle Measured Tension)
    simulation_manager.robot_states(k + 1) = simulation_manager.robot_states(k + 1).BPA_muscle_measured_tensions2hill_muscle_measured_tensions(  );
    
    % Compute the hill muscle measured active and passive tension associated with the hill muscle measured total tension. (Hill Muscle Measured Tension -> Hill Muscle Measured Active Tension, Hill Muscle Measured Passive Tension)
    simulation_manager.robot_states(k + 1).neural_subsystem.hill_muscle_manager = simulation_manager.robot_states(k + 1).neural_subsystem.hill_muscle_manager.call_muscle_method( 'all', 'measured_total_tension2measured_active_passive_tension' );
    
    
    
    
    %% Compute Derived Muscle Properties (Length, Strain, Velocity, Yank) for the Next Iteration.
    
    
    
    
    %% Compute the Muscle Feedback Properties (Type Ia, Type Ib, and Type II Feedback) for the Next Iteration.
    
    % Compute the Type Ia (muscle velocity) feedback.
    muscle_manager = muscle_manager.call_muscle_method( muscle_IDs, 'velocity2typeIa_feedback' );
    
    % Compute the Type Ib (muscle tension) feedback.
    muscle_manager = muscle_manager.call_muscle_method( muscle_IDs, 'measured_total_tension2typeIb_feedback' );
    
    % Compute the Type II (muscle velocity) feedback.
    muscle_manager = muscle_manager.call_muscle_method( muscle_IDs, 'length2typeII_feedback' );
    
    
    %% Compute the Desired Total Muscle Tensions and Desired Pressures for the Next Iteration.
    
    % Compute the desired total muscle tension associated with the current active muscle tension.
    muscle_manager = muscle_manager.call_muscle_method( muscle_IDs, 'desired_active_tension2desired_total_passive_tension' );
    
    % Compute the desired pressure for each muscle.
    muscle_manager = muscle_manager.call_muscle_method( muscle_IDs, 'desired_total_tension2desired_pressure' );
    
    % Delegate the desired BPA pressures to the appropriate slave in the slave manager.
    slave_manager = slave_manager.set_desired_pressure( slave_IDs, muscle_manager );
    
    
    %% Retrieve the Precomputed Network Simulation Data For This Iteration.
    
    % Store the simulation data into the muscle manager.    
    simulation_manager.quadruped_robot.neural_subsystem.hill_muscle_manager = simulation_manager.quadruped_robot.neural_subsystem.hill_muscle_manager.set_muscle_property( precomputed_simulation_manager.muscle_IDs, precomputed_simulation_manager.activations(k, :), 'activation', true );
    
    % Compute the desired total muscle tensions associated with the current muscle activations.
    simulation_manager.quadruped_robot.neural_subsystem.hill_muscle_manager = simulation_manager.quadruped_robot.neural_subsystem.hill_muscle_manager.call_muscle_method( muscle_IDs, 'activation2desired_active_tension' );

    
    
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



