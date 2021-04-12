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
simulation_manager = simulation_manager_class();

% Load the precomputed simulation data.
simulation_manager = simulation_manager.load_simulation_data( file_path, max_num_data_points );


%% Initialize Slave Data Managers.

% Define the number of slaves.
num_slaves = 24;

% Define the slave IDs.
slave_IDs = 1:num_slaves;

% Define the muscle IDs.
muscle_IDs = linspace2(39, 1, num_slaves);

% Define the muscle names.
muscle_names = { 'Front Left Scapula Extensor', 'Front Left Scapula Flexor', 'Front Left Shoulder Extensor', 'Front Left Shoulder Flexor', 'Front Left Wrist Extensor', 'Front Left Wrist Flexor', ...
                 'Back Left Hip Extensor', 'Back Left Hip Flexor', 'Back Left Knee Extensor', 'Back Left Knee Flexor', 'Back Left Ankle Extensor', 'Back Left Ankle Flexor', ...
                 'Front Right Scapula Extensor', 'Front Right Scapula Flexor', 'Front Right Shoulder Extensor', 'Front Right Shoulder Flexor', 'Front Right Wrist Extensor', 'Front Right Wrist Flexor', ...
                 'Back Right Hip Extensor', 'Back Right Hip Flexor', 'Back Right Knee Extensor', 'Back Right Knee Flexor', 'Back Right Ankle Extensor', 'Back Right Ankle Flexor' };

% Define the ID of the first pressure sensor for each slave.
pressure_sensor_ID1s = 1:num_slaves;

% Define the ID of the second pressure sensor for each slave.
pressure_sensor_ID2s = zeros(1, num_slaves); pressure_sensor_ID2s(1:2:end) = 2:2:num_slaves; pressure_sensor_ID2s(2:2:end) = 1:2:num_slaves;

% Define the ID of the joint associated with each slave.
joint_IDs = reshape(repmat((1:(num_slaves/2)), 2, 1), 1, num_slaves);

% Define the name of the joint associated with each slave.
joint_names = { 'Front Left Scapula', 'Front Left Shoulder', 'Front Left Wrist', ...
                'Back Left Hip', 'Back Left Knee', 'Back Left Ankle', ...
                'Front Right Scapula', 'Front Right Shoulder', 'Front Right Wrist', ...
                'Back Right Hip', 'Back Right Knee', 'Back Right Ankle' };

joint_names = reshape( repmat( joint_names, 2, 1 ), 1, num_slaves );
                 
% Set the measured pressure values for each slave to zero.
measured_pressure_value1s = 0;
measured_pressure_value2s = 0;

% Set the measured joint angle for each slave to zero.
measured_joint_values = 0;
          
% Set the desired pressure for each slave to zero.
desired_pressures = 0;

% Create an instance of the slave manager class.
slave_manager = slave_manager_class( slave_IDs, muscle_IDs, muscle_names, pressure_sensor_ID1s, pressure_sensor_ID2s, joint_IDs, joint_names, measured_pressure_value1s, measured_pressure_value2s, measured_joint_values, desired_pressures );


%% Initialize the Muscle Manager.

% Define the muscle IDs.
muscle_IDs = linspace2( 39, 1, 24 );

% Define the muscle names.
muscle_names = { 'Front Left Scapula Extensor', 'Front Left Scapula Flexor', 'Front Left Shoulder Extensor', 'Front Left Shoulder Flexor', 'Front Left Wrist Extensor', 'Front Left Wrist Flexor', ...
                 'Back Left Hip Extensor', 'Back Left Hip Flexor', 'Back Left Knee Extensor', 'Back Left Knee Flexor', 'Back Left Ankle Extensor', 'Back Left Ankle Flexor', ...
                 'Front Right Scapula Extensor', 'Front Right Scapula Flexor', 'Front Right Shoulder Extensor', 'Front Right Shoulder Flexor', 'Front Right Wrist Extensor', 'Front Right Wrist Flexor', ...
                 'Back Right Hip Extensor', 'Back Right Hip Flexor', 'Back Right Knee Extensor', 'Back Right Knee Flexor', 'Back Right Ankle Extensor', 'Back Right Ankle Flexor' };

% Define the muscle activations.
activations = 0;                                                    % [V] Motor Neuron Activation.
activation_domains = {[-0.050, -0.019]};                            % [V] Motor Neuron Activation Domain.

% Define the initial desired muscle tensions.
desired_total_tensions = 0;                                         % [N] Desired Total Muscle Tension.  The "total" muscle tension is the real muscle tension that would be observed in the muscle if measured.  This tension is relevant to both BPA muscles and real muscles.
desired_active_tensions = 0;                                        % [N] Desired Active Muscle Tension.  The "active" muscle tension is the tension in the muscle that is developed due to motor neuron activation.  This tension is only relevant to real muscles (not BPAs).
desired_passive_tensions = 0;                                       % [N] Desired Passive Muscle Tension.  The "passive" muscle tension is the tension in the muscle that is developed naturally due to the internal dynamics of the muscle.  This tension is only relevant to real muscles (not BPAs).

% Define the initial measured muscle tensions.
measured_total_tensions = 0;                                        % [N] Measured Total Muscle Tension.
measured_active_tensions = 0;                                       % [N] Measured Active Muscle Tension.  The "measured" active tension is inferred active muscle tension that would result from the measured total muscle tension.
measured_passive_tensions = 0;                                      % [N] Measured Passive Muscle Tension.  The "measured" passive tension is the inferred passive muscle tension that would result from the measured total muscle tension.

% Define the tension domain.
tension_domains = {[0, 450]};                                       % [N] Total Muscle Tension Domain.

% Define the initial desired and measured muscle pressures.
desired_pressures = 0;
measured_pressures = 0;

% Define the pressure domains.
pressure_domains = {[0, 620528]};

% Define the resting muscle lengths.
muscle_lengths = 0.0254*[ 13, 13, 5.125, 5.125, 6.5, 5, ...         % [m] Muscle Lengths.
                          13, 13, 5.125, 5.125, 6.5, 5, ...
                          13, 13, 7.25, 7.25, 5, 6, ...
                          13, 13, 7.25, 7.25, 5, 6 ];

muscle_resting_lengths = muscle_lengths;                      
            
% Define the starting muscle strains.
strains = 0;

% Define the maximum muscle strains.
max_strains = 0.16;

% Define the initial muscle velocities.                      
velocities = 0;                                                     % [m/s] Muscle Velocity.

% Define the initial muscle yanks.
yanks = 0;                                                          % [N/s] Muscle Yank (Derivative of Total Muscle Tension with Respect to Time).

% Define the initial muscle feedback sources.
typeIa_feedbacks = 0;                                               % [V] Velocity Feedback
typeIb_feedbacks = 0;                                               % [V] Tension Feedback
typeII_feedbacks = 0;                                               % [V] Length Feedback

% Define the hill muscle parameters.
kses = 30;                                                          % [N/m] Hill Muscle Model Series Stiffness.
kpes = 30;                                                          % [N/m] Hill Muscle Model Parallel Stiffness.
bs = 1;                                                             % [Ns/m] Hill Muscle Model Damping Coefficient.

% Definet the BPA muscle parameters.
c0s = 254.3e3;                       % [Pa] Model Parameter 0
c1s = 192e3;                         % [Pa] Model Parameter 1
c2s = 2.0265;                        % [-] Model Parameter 2
c3s = -0.461;                        % [-] Model Parameter 3
c4s = -0.331e-3;                     % [1/N] Model Parameter 4
c5s = 1.23e3;                        % [Pa/N] Model Parameter 5
c6s = 15.6e3;                        % [Pa] Model Parameter 6

% Define the number of steps to perform per simulation time step when integrating the Hill Muscle Model.
num_int_steps = 10;

% Create an instance of the muscle manager class.
muscle_manager = muscle_manager_class( muscle_IDs, muscle_names, activations, activation_domains, desired_total_tensions, desired_active_tensions, desired_passive_tensions, measured_total_tensions, measured_active_tensions, measured_passive_tensions, tension_domains, desired_pressures, measured_pressures, pressure_domains, muscle_lengths, muscle_resting_lengths, strains, max_strains, velocities, yanks, typeIa_feedbacks, typeIb_feedbacks, typeII_feedbacks, kses, kpes, bs, c0s, c1s, c2s, c3s, c4s, c5s, c6s, simulation_manager.dt, num_int_steps );


%% Initialize USART Communication.

%Define the baud rates.
baud_rate_virtual_ports = 115200; baud_rate_physical_ports = 57600;             % The Master Port is the only physical port.  All other ports are virtual.

% Define the COM port names.
COM_port_names = { 'COM11', 'COM1', 'COM2', 'COM7', 'COM8', 'COM9', 'COM10' };                 % { Master Port, Matlab Input Port, Matlab Output Port, Animatlab Input Port, Animatlab Output Port }. 

% Define the master microcontroller port type we would like to use.
master_port_type = 'virtual';                           % [-] Master Port Type.  Either 'virtual' or 'physical'.

% Create an instance of the USART manager class.
usart_manager = usart_manager_class();

% Initialize the USART serial ports.
usart_manager = usart_manager.initialize_serial_ports( COM_port_names, baud_rate_physical_ports, baud_rate_virtual_ports );


%% Initialize Sensor Data Manager.

% Define the muscle IDs to use in the sensor data manager.
muscle_IDs = linspace2(39, 1, 24);

% Define the pressrue sensor IDs to use in the sensor data manager.
pressure_sensor_IDs = 1:24;

% Define the encoder IDs to use in the sensor data manager.
encoder_IDs = 1:12;

% Define the muscle names to use in the sensor data manager.
muscle_names = { 'Front Left Scapula Extensor', 'Front Left Scapula Flexor', 'Front Left Shoulder Extensor', 'Front Left Shoulder Flexor', 'Front Left Wrist Extensor', 'Front Left Wrist Flexor', ...
                 'Back Left Hip Extensor', 'Back Left Hip Flexor', 'Back Left Knee Extensor', 'Back Left Knee Flexor', 'Back Left Ankle Extensor', 'Back Left Ankle Flexor', ...
                 'Front Right Scapula Extensor', 'Front Right Scapula Flexor', 'Front Right Shoulder Extensor', 'Front Right Shoulder Flexor', 'Front Right Wrist Extensor', 'Front Right Wrist Flexor', ...
                 'Back Right Hip Extensor', 'Back Right Hip Flexor', 'Back Right Knee Extensor', 'Back Right Knee Flexor', 'Back Right Ankle Extensor', 'Back Right Ankle Flexor' };

% Define the joint names to use in the sensor data manager.
joint_names = { 'Front Left Scapula', 'Front Left Shoulder', 'Front Left Wrist', ...
                'Back Left Hip', 'Back Left Knee', 'Back Left Ankle', ...
                'Front Right Scapula', 'Front Right Shoulder', 'Front Right Wrist', ...
                'Back Right Hip', 'Back Right Knee', 'Back Right Ankle' };

% Create an instance of the sensor data class.
sensor_manager = sensor_manager_class( muscle_IDs, pressure_sensor_IDs, encoder_IDs, muscle_names, joint_names );

% Initialize the sensor data values to be zero.
sensor_manager = sensor_manager.initialize_sensor_data( simulation_manager.num_timesteps );


%% Write Precomputed Simulation Data to the Master Microcontroller While Collecting Sensor Data

% Send each simulation data value to the master mircocontoller and collect the associated sensory feedback.
for k = 1:simulation_manager.num_timesteps                  % Iterate through each simulation time step...
    
    %% Retrieve Network Simulation Data For This Iteration.
    
    % Store the simulation data into the muscle manager.
    muscle_manager = muscle_manager.set_muscle_activations( simulation_manager.muscle_IDs, simulation_manager.activations(k, :) );
    
    % Compute the desired total muscle tensions associated with the current muscle activations.
    muscle_manager = muscle_manager.call_muscle_method( muscle_IDs, 'activation2desired_active_tension' );
    

    %% Write the Desired Muscle Pressures to the Master Microcontroller & Read Sensor Data.
    
    % Stage the desired BPA pressures for USART transmission to the master microcontroller.
    usart_manager = usart_manager.stage_desired_pressures( slave_manager );
    
    % Write the desired BPA pressures to the master microcontroller.
    usart_manager.write_bytes_to_master( master_port_type );
    
    % Determine whether we need to emulate the master microcontroller behavior.
    if strcmp(master_port_type, 'virtual') || strcmp(master_port_type, 'Virtual')                   % If we are using a virtual port for the master microcontroller...
    
        % Emulate the master microcontroller reporting sensory information to Matlab.
        usart_manager.emulate_master_read_write( slave_manager );
    
    end
    
    % Retrieve the sensor data from the master microcontroller via USART transmission.
    usart_manager = usart_manager.read_bytes_from_master( slave_manager.slave_packet_size, master_port_type );
    
    
    %% Store the Sensor Data Received From the Master Microcontroller.
    
    % Store the sensor data into the associated slave in the slave manager.
    slave_manager = slave_manager.store_sensor_data( usart_manager );
    
    
    % Store the muscle sensory data into the appropriate muscle in the muscle manager.
    muscle_manager = muscle_manager.set_measured_pressures( slave_manager );
    
    % Compute the measured total tension associated with the measured muscle pressure.
    muscle_manager = muscle_manager.call_muscle_method( muscle_IDs, 'measured_pressure2measured_total_tension' );

    % Compute the measured active and passive tension associated with the measured total tension.
    muscle_manager = muscle_manager.call_muscle_method( muscle_IDs, 'measured_total_tension2measured_active_passive_tension' );

    
    %% Compute the Derived Muscle Properties From the Sensory Information.
    
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
    
    
    %% Record the Command & Sensor Data For Plotting.
    
    % Store the sensor data into the sensor data manager.
    
    asdf = 1;
    
end


% %% Write Precomputed Simulation Data to the Master Microcontroller While Collecting Sensor Data
% 
% % Send each simulation data value to the master mircocontoller and collect the associated sensory feedback.
% for k = 1:simulation_manager.num_timesteps                  % Iterate through each simulation time step...
%     
%     % Store the simulation data into the muscle manager.
%     muscle_manager = muscle_manager.set_muscle_activations( simulation_manager.muscle_IDs, simulation_manager.activations(k, :) );
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
%     usart_manager = usart_manager.read_bytes_from_master( slave_manager.slave_packet_size, master_port_type );
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

fig_motor_activations = simulation_manager.plot_motor_neuron_activations();


%% Plot the Sensor Data.


%% Terminate USART Communication.

% Terminate the USART serial ports.
usart_manager = usart_manager.terminate_serial_ports();



