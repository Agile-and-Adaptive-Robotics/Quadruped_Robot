%% Write Predefined Animatlab Commands to the Microcontroller from Matlab.

%Clear Everything.
clear, close('all'), clc

%% Setup for Serial Port Communication.

%Define the baud rates.
baud_rate_animatlab = 115200; baud_rate_micro = 57600;

%Open the animatlab output and input serial ports.
serial_port_animatlab_output = OpenAtmegaSerialPort( 'COM9', baud_rate_animatlab ); serial_port_animatlab_input = OpenAtmegaSerialPort( 'COM11', baud_rate_animatlab );

%Open the serial ports.
serial_port_matlab_input = OpenAtmegaSerialPort( 'COM10', baud_rate_animatlab ); serial_port_matlab_output = OpenAtmegaSerialPort( 'COM13', baud_rate_animatlab );
% serial_port_micro_input_output = OpenAtmegaSerialPort( 'COM6', baud_rate_micro );
serial_port_micro_input_output = OpenAtmegaSerialPort( 'COM4', baud_rate_micro );

%Set whether to print debug information.
bDebugPrint = false;

%Set whether to print sensor information.
bVerbose = false;

%Define the minimum number of bytes per sentence from animatlab.
min_num_bytes_per_sentence_animatlab = 12;

%Define the minimum number of bytes per sentence from the microcontroller.
min_num_bytes_per_sentence_micro = 8;

%Define the number of muscle pairs to simulate.
num_muscle_pairs = 3;

% Define the number of front & back and left & right states.
num_front_back_states = 2; num_left_right_states = 2;

% Define the front & back and left & right state names.
front_back_state_names = {'Front', 'Back'}; left_right_state_names = {'Left', 'Right'};

% Define the number of front and back joints.
num_front_joints = 4; num_back_joints = 3; num_front_back_joints = [num_front_joints num_back_joints];

% Define the number of sensors.
num_sensors = 38;

% Define the sensor IDs.
sensor_IDs_crit = 1:38;

%% Read in Command Data From Previous Animatlab Simulations.

% %Read in Animatlab muscle data.
% % animatlab_muscle_data = dlmread('C:\Users\USER\Documents\Coursework\MSME\Thesis\Animatlab\Simple_Quadruped\Simple_Quadruped\Front Left Leg Muscle Data.txt', '', 1, 0);
% animatlab_muscle_data = dlmread('C:\Users\USER\Documents\Graduate_School\Thesis\Animatlab\Simple_Quadruped\Simple_Quadruped\Front Left Leg Muscle Data.txt', '', 1, 0);
%
% %Retrieve the animatlab time vector.
% ts_animatlab = animatlab_muscle_data(:, 1);
%
% %Retrieve the muscle tension values.
% animatlab_muscle_tensions = animatlab_muscle_data(:, 3:2:end);
%
% %Permute the columns of the animatlab muscle tensions so that the commands are ordered: hip, knee, ankle.
% animatlab_muscle_tensions(:, :) = animatlab_muscle_tensions(:, [3 4 5 6 1 2]);
%
% %Subsample the animatlab muscle tension data.
% animatlab_muscle_tensions = animatlab_muscle_tensions(1:60:end, :);
%
% %Define the number of commands to be sent.
% num_commands = size(animatlab_muscle_tensions, 1);
%
% %Define a time vector for data collection and simulation.
% ts = 1:num_commands;


%% Generate Muscle Commands Using Square Waves.

% % Define the On/Off muscle command parameters.
% num_muscles = 24;               % [#] Number of Muscles.
% num_cycles = 2;                 % [#] Number of Cycles to Generate.
% num_per_cycle = 300;            % [#] Number of Points per Cycle.
% on_value = 450;                 % [-] Value that Micros will recognize as a high value.
% 
% % Generate the On/Off muscle commands.
% [animatlab_muscle_tensions, ts, num_commands] = GenerateSquareCommands(num_muscles, num_cycles, num_per_cycle, on_value);



%% Generate Muscle Commands Using Sine Waves.

% Define the sinusoidal muscle command parameters.
num_muscles = 24;               % [#] Number of Muscles.
num_cycles = 2;                 % [#] Number of Cycles to Generate.
num_per_cycle = 300;            % [#] Number of Points per Cycle.
on_value = 450;                 % [-] Value that Micros will recognize as a high value.
%  on_value = 225;                 % [-] Value that Micros will recognize as a high value.
 offset = 0;                   % [-] Value to offset the bottom of the sine wave.
% offset = 125;                   % [-] Value to offset the bottom of the sine wave.
 
% Generate the sinusoidal muscle commands.
[animatlab_muscle_tensions, ts, num_commands] = GenerateSinusoidalCommands(num_muscles, num_cycles, num_per_cycle, on_value, offset);



% Front left leg only.
animatlab_muscle_tensions(:, 7:end) = 0;
% animatlab_muscle_tensions(:, 2:end) = 0;

% % Back left leg only.
% animatlab_muscle_tensions(:, 1:6) = 0; animatlab_muscle_tensions(:, 13:end) = 0;

% % Front right leg only.
% animatlab_muscle_tensions(:, 1:12) = 0; animatlab_muscle_tensions(:, 19:end) = 0;

% % Back right leg only.
% animatlab_muscle_tensions(:, 1:18) = 0;


% Front left ankle only.
% animatlab_muscle_tensions(:, 3:end) = 0;
% animatlab_muscle_tensions(:, 13:end) = 0;

% % Front left ankle only.
% animatlab_muscle_tensions(:, 1:4) = 0; animatlab_muscle_tensions(:, 7:end) = 0;

% % Back right ankle only.
% animatlab_muscle_tensions(:, 1:end-2) = 0;





%% Pass Information Between Animatlab & the Micro Controller.

%Preallocate variables to store the reported front leg pressures and angles.
front_left_leg_pressures = zeros(6, num_commands); front_left_leg_angles = zeros(4, num_commands);
back_left_leg_pressures = zeros(6, num_commands); back_left_leg_angles = zeros(3, num_commands);
front_right_leg_pressures = zeros(6, num_commands); front_right_leg_angles = zeros(4, num_commands);
back_right_leg_pressures = zeros(6, num_commands); back_right_leg_angles = zeros(3, num_commands);

%Define the muscle IDs of interest.
% muscle_ID_crits = 39:44;
muscle_ID_crits = 39:62;

%Preallocate a variable to store the received muscle commands from animatlab.
received_muscle_commands = zeros(length(muscle_ID_crits), num_commands);

%Initialize the old muscle and sensor value integers to be zero.
muscle_value_ints_old = zeros(1, length(muscle_ID_crits)); sensor_value_ints_old = zeros(1, num_sensors);

%Continuous pass information between animatlab & the micro controller.
for k = 1:num_commands
    
    %Start the timer.
    tic
    
    %Simulate animatlab data by writing to the animatlab output serial port.  Use this for testing the Matlab & Micro code with known input from Animatlab.
    serial_write_sensor_data2animatlab(serial_port_animatlab_output, animatlab_muscle_tensions(k, :), muscle_ID_crits )
    
    %Wait until animatlab sends a sentence to matlab.
    while (serial_port_matlab_input.BytesAvailable < min_num_bytes_per_sentence_animatlab), if bDebugPrint, fprintf('Waiting for Animatlab to Send Value: Bytes Available = %0.0f.\n', serial_port_matlab_input.BytesAvailable), end, end
    
    %Read in the animatlab sentence.
    [ muscle_values, muscle_IDs ] = ReadSentenceFromAnimatlab( serial_port_matlab_input );
    
    %Convert the muscle values to integers.
    muscle_value_ints = ConvertMuscleSingles2Integers( muscle_values );
    
    %Retrieve the animatlab command values associated with muscles with specific IDs.
    received_muscle_commands(:, k) = GetSpecificMuscleValues( muscle_IDs, muscle_value_ints_old, muscle_value_ints, muscle_ID_crits )';
    
    %Write the commands as ints to the microcontroller.
    serial_write_command_data_ints2micro(serial_port_micro_input_output, muscle_value_ints, muscle_IDs )
    
    %Wait until the microcontroller sends a sentence to matlab.
    while (serial_port_micro_input_output.BytesAvailable < min_num_bytes_per_sentence_micro), if bDebugPrint, fprintf('Waiting for Micro to Send Value. Bytes Available = %0.0f.\n', serial_port_micro_input_output.BytesAvailable), end, end
    
    %Read in the sensor data as ints from the microcontroller.
    [ sensor_value_ints, sensor_IDs ] = serial_read_micro_sensor_data_ints( serial_port_micro_input_output );
    
    %Determine where there was a check sum error and respond appropriately.
    if isempty(sensor_value_ints)                                                       %If there was a check sum error...
        sensor_value_ints = sensor_value_ints_old; sensor_IDs = sensor_IDs_crit;        %Replace the invalid sensor value integers and IDs with those from the previous reading.
    end
    
    %     disp(sensor_value_ints(1:6))
    
    %Convert the sensor data integers into doubles that are intelligible by Matlab.
    [sensor_value_doubles, sensor_voltages] = ConvertSensorInts2Doubles(sensor_value_ints);
    
    %     disp(sensor_value_doubles(25))
    %     disp(sensor_voltages(1:6))
    %     fprintf('Pot25 Angle = %0.5f, Pot25 Voltage = %0.5f\n\n', sensor_value_doubles(25), sensor_voltages(25))
    fprintf('Pressure Sensor Voltages: '), disp(sensor_voltages(1:24))
    fprintf('Pressure Sensor Pressures: '), disp(sensor_value_doubles(1:24))
    fprintf('Potentiometer Voltages: '), disp(sensor_voltages(25:38))
    fprintf('Potentiometer Angles: '), disp(sensor_value_doubles(25:38))
    fprintf('\n\n')
    
    %Retrieve the sensor values associated with the front left leg.
    front_left_leg_pressures(:, k) = sensor_value_doubles(1:6)'; front_left_leg_angles(:, k) = sensor_value_doubles(25:28)';
    back_left_leg_pressures(:, k) = sensor_value_doubles(7:12)'; back_left_leg_angles(:, k) = sensor_value_doubles(29:31)';
    front_right_leg_pressures(:, k) = sensor_value_doubles(13:18)'; front_right_leg_angles(:, k) = sensor_value_doubles(32:35)';
    back_right_leg_pressures(:, k) = sensor_value_doubles(19:24)'; back_right_leg_angles(:, k) = sensor_value_doubles(36:38)';
    
    %Print out the front leg sensor values if desired.
    if bVerbose, fprintf('Front Leg Pressures: '), disp(front_left_leg_pressures(:, k)'), fprintf('Front Leg Angles: '), disp(front_left_leg_angles(:, k)'), end
    
    %Write the sensor data to animatlab.
    %     serial_write_sensor_data2animatlab(serial_port_matlab_output, values, IDs )
    
    %Update the old muscle value integers with the new muscle value integers.
    muscle_value_ints_old = muscle_value_ints; sensor_value_ints_old = sensor_value_ints;
    
    %Stop the timer.
    toc
    
end

% Store the muscle pressures and limb angles into cells.
muscle_pressure_cell = {front_left_leg_pressures, front_right_leg_pressures; back_left_leg_pressures, back_right_leg_pressures};
limb_angle_cell = {front_left_leg_angles, front_right_leg_angles; back_left_leg_angles, back_right_leg_angles};


%% Plot the Muscle Commands Recieved from Animatlab.

% Create a figure to store the muscle commands recieved from Animatlab.
fig = figure('Name', 'Animatlab Muscle Commands', 'Color', 'w');

%Plot the muscle commands recieved from animatlab for the front left leg.
subplot(2, 2, 1), hold on, grid on, xlabel('Command Number [#]'), ylabel('Muscle Command [0-65535]'), title('Animatlab Muscle Commands: Front Left Leg'), plot(1:num_commands, received_muscle_commands(1:6, :))
legend('Front Left Hip Extensor', 'Front Left Hip Flexor', 'Front Left Knee Extensor', 'Front Left Knee Flexor', 'Front Left Ankle Extensor', 'Front Left Ankle Flexor', 'Location', 'Best')

%Plot the muscle commands recieved from animatlab for the back left leg.
subplot(2, 2, 2), hold on, grid on, xlabel('Command Number [#]'), ylabel('Muscle Command [0-65535]'), title('Animatlab Muscle Commands: Back Left Leg'), plot(1:num_commands, received_muscle_commands(7:12, :))
legend('Back Left Hip Extensor', 'Back Left Hip Flexor', 'Back Left Knee Extensor', 'Back Left Knee Flexor', 'Back Left Ankle Extensor', 'Back Left Ankle Flexor', 'Location', 'Best')

%Plot the muscle commands recieved from animatlab for the front right leg.
subplot(2, 2, 3), hold on, grid on, xlabel('Command Number [#]'), ylabel('Muscle Command [0-65535]'), title('Animatlab Muscle Commands: Front Right Leg'), plot(1:num_commands, received_muscle_commands(13:18, :))
legend('Front Right Hip Extensor', 'Front Right Hip Flexor', 'Front Right Knee Extensor', 'Front Right Knee Flexor', 'Front Right Ankle Extensor', 'Front Right Ankle Flexor', 'Location', 'Best')

%Plot the muscle commands recieved from animatlab for the back right leg.
subplot(2, 2, 4), hold on, grid on, xlabel('Command Number [#]'), ylabel('Muscle Command [0-65535]'), title('Animatlab Muscle Commands: Back Right Leg'), plot(1:num_commands, received_muscle_commands(19:24, :))
legend('Back Right Hip Extensor', 'Back Right Hip Flexor', 'Back Right Knee Extensor', 'Back Right Knee Flexor', 'Back Right Ankle Extensor', 'Back Right Ankle Flexor', 'Location', 'Best')



%% Plot the Muscle Pressure Data.

%Create a cell array to store the names of the muscle extensor/flexor pairs, front & back states, and left & right states.
muscle_pair_names = {'Hip', 'Knee', 'Ankle'};
front_back_names = {'Front', 'Back'};
left_right_names = {'Left', 'Right'};

%Define a column vector of RGB triplets to define the plot colors.
colors = [0 0 1; 0.5 0.5 1; 0 1 0; 0.75 1 0.75; 1 0 0; 1 0.5 0.5];

for k1 = 1:num_front_back_states                            % Iterate through the front and back states...
    for k2 = 1:num_left_right_states                        % Iterate through the left and right states...
        
        % Compute the figure name.
        fig_name = [front_back_names{k1}, ' ', left_right_names{k2}, ' Muscle Pressures'];
        
        %Create a figure to store the muscle pressure vs iteration number plot.
        fig = figure('Name', fig_name, 'Color', 'w');
        
        % Retrieve the relevant muscle pressures.
        muscle_pressures = muscle_pressure_cell{k1, k2};
        
        % Initialize a counter variable.
        k4 = -1;
        
        %Cycle through each muscle pair.
        for k3 = 1:num_muscle_pairs                                                                          %Iterate through each muscle pair...
            
            % Advance this counter variable.
            k4 = k4 + 2;
            
            %Create a subplot for this muscle extensor/flexor pair.
            subplot(3, 1, k3), hold on, grid on, xlabel('Iteration Number [#]'), ylabel('Pressure [psi]'), title([muscle_pair_names{k3} ': Muscle Pressure vs Iteration Number'])
            
            %Plot the extensor for this muscle pair.
            %             plot(ts, front_left_leg_pressures(k3, :), '.-', 'Color', colors(2*k3 - 1, :), 'Markersize', 20)
            %             plot(ts, muscle_pressures(k3, :), '.-', 'Color', colors(2*k3 - 1, :), 'Markersize', 20)
            plot(ts, muscle_pressures(k4, :), '.-', 'Color', colors(2*k3 - 1, :), 'Markersize', 20)
            
            %Plot the flexor for this muscle pair.
            %             plot(ts, front_left_leg_pressures(k3 + 1, :), '.-', 'Color', colors(2*k3, :), 'Markersize', 20)
            %             plot(ts, muscle_pressures(k3 + 1, :), '.-', 'Color', colors(2*k3, :), 'Markersize', 20)
            plot(ts, muscle_pressures(k4 + 1, :), '.-', 'Color', colors(2*k3, :), 'Markersize', 20)
            
            %Add a legend to the plot.
            legend('Extensor', 'Flexor', 'Location', 'Best')
            
        end
        
    end
end


%% Plot the Joint Angle Data.

% Create cell arrays to store the joint names for the front and back limbs.
front_joint_names = {'Scapula', 'Shoulder', 'Elbow', 'Wrist'};
back_joint_names = {'Hip', 'Knee', 'Ankle'};

% Collect the joint names for the front and back limbs into a single cell array.
joint_names = {front_joint_names back_joint_names};

% Create figures for the joint angles associated with each leg.
for k1 = 1:num_front_back_states                    % Iterate through the front and back states...
    
    % Retrieve the joint names associated with this limb.
    limb_joint_names = joint_names{k1};
    
    % Determine the number of joints associated with this limb.
    num_joints = length(limb_joint_names);
    
    % Compute the number of subplots to include on the upcoming figures.
    [ num_subplot_rows, num_subplot_cols ] = GetSubplotRCs( num_joints, false );
    
    for k2 = 1:num_left_right_states                % Iterate through the left and right states...
        
        % Create the name of this figure.
        fig_name = [front_back_state_names{k1}, ' ', left_right_state_names{k2}, ' Joint Angles'];
        
        % Create a figure for the joint angles associated with this leg.
        fig = figure('Name', fig_name, 'Color', 'w');
        
        % Add the data for each joint to this figure.
        for k3 = 1:num_joints                   % Iterate through the joints associated with this limb...
            
            % Generate the title for this subplot.
            subplot_title = [limb_joint_names{k3}, ': Joint Angle vs Iteration Number'];
            
            % Create the subplot that will store the joint angle data associated with this limb.
            subplot(num_subplot_rows, num_subplot_cols, k3), hold on, grid on, xlabel('Iteration Number [#]'), ylabel('Joint Angle [deg]'), title(subplot_title)
            
            % Plot the joint angle data associated with this limb on the current subplot.
            plot(ts, limb_angle_cell{k1, k2}(k3, :), '.-', 'Markersize', 20)
            
        end
        
    end
end




%% Close All of the Serial Ports.

%Close the animatlab serial ports.
CloseSerialPort(serial_port_animatlab_output), CloseSerialPort(serial_port_animatlab_input)

%Close matlab's serial ports.
CloseSerialPort(serial_port_matlab_output), CloseSerialPort(serial_port_matlab_input)

%Close the microcontroller serial port.
CloseSerialPort(serial_port_micro_input_output)

