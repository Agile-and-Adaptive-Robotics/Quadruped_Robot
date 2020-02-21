%% Circuit Component Calculation.

%Clear Everything
clear, close('all'), clc


%% Define Available Resistor & Capacitor Values.

%Define the available resistors.
rs_available = dlmread('C:\Users\USER\Documents\MATLAB\MyFunctions\Controls\ResistorKitValues.txt');

%Define the available capacitors.
cs_available = dlmread('C:\Users\USER\Documents\MATLAB\MyFunctions\Controls\CapacitorKitValues.txt');


%% Define the Filtered Voltage Ranges for the Potentiometers & Pressure Sensors.

%Define the supply voltage.
V_supply = 5;                         %[V] Supply Voltage.

%Define the desired microcontroller voltage range.
Vs_micro = [0 5];                 %[V] Acceptable voltage range for the microcontroller.

% Define the potentiometer voltage ranges.
Vs_pots = [9.4 16.6; 12.6 19.8; 3.4 10.6; 3.8 11.8; 9.53 17.4; 11.4 19.4; 3.4 10.6; 7.85 14.4; 0.6 8.2; 12 20; 11 19.4; 5.8 13.6; 2.93 10.6; 12.6 19.4];

% Define the pressure sensor voltage ranges.
Vs_psens = [0.24 4.28; 0.24 4.28; 0.24 4.28; 0.24 4.28; 0.24 4.28; 0.24 4.28; 0.19 4.20; 0.18 4.15; 0.21 4.20; 0.21 4.20; 0.20 4.20; 0.20 4.20; 0.20 4.20; 0.20 4.20; 0.20 4.20; 0.20 4.20; 0.20 4.20; 0.20 4.20; 0.20 4.20; 0.20 4.20; 0.20 4.20; 0.20 4.20; 0.20 4.20; 0.20 4.20];

% Retrieve the number of potentiometers and pressure sensors.
n_pots = size(Vs_pots, 1); n_psens = size(Vs_psens, 1);


%% Compute the Required Gains & Offsets to Map Each Filtered Circuit to 0-5V.

% Preallocate arrays to store the potentiometer gains and offsets.
ks_pots = zeros(n_pots, 2); vs_pots_offset = zeros(n_pots, 1);

% Preallocate a cell to store the circuit component structures.
Rs_full_pots = cell(n_pots, 2); Rs_partial_pots = cell(n_pots, 2);

% Compute the bipolar to single ended gains and voltage offsets for the potentiometers.
for k1 = 1:n_pots            % Iterate through each of the potentiometers...
    
    % Compute the bipolar to single ended gains and voltage offsets for this potentiometer.
    [ ks_pots(k1, :), vs_pots_offset(k1) ] = GetBipolar2SingleEndedGains( Vs_pots(k1, :), Vs_micro, V_supply );
    
    % Compute the circuit components associated with the gains for this potentiometer.
    for k2 = 1:size(Rs_partial_pots, 2)                % Iterate through the gains for this potentiometer...
        
        % Print out a header for this information.
        fprintf('\n\nPOTENTIOMETER %0.0f, GAIN %0.0f\n', k1, k2)
        
        % Compute the circuit components to achieve this gain.
        [ Rs_full_pots{k1, k2}, Rs_partial_pots{k1, k2} ] = GetOpAmpRValues( ks_pots(k1, k2), rs_available, true, false, true );
    
    end
    
end

% Preallocate arrays to store the pressure sensor gains and offsets.
ks_psens = zeros(n_pots, 2); vs_psens_offset = zeros(n_psens, 1);

% Preallocate a cell to store the circuit component structures.
Rs_full_psens = cell(n_psens, 2); Rs_partial_psens = cell(n_psens, 2);

% Compute the bipolar to single ended gains and voltage offsets for the pressure sensors.
for k1 = 1:n_psens           % Iterate through each of the pressure sensors...
    
    % Compute the bipolar to single ended gains and voltage offsets for this pressure sensor.
    [ ks_psens(k1, :), vs_psens_offset(k1) ] = GetBipolar2SingleEndedGains( Vs_psens(k1, :), Vs_micro, V_supply );
    
    % Compute the circuit components associated with the gains for this pressure sensor.
    for k2 = 1:size(Rs_partial_psens, 2)                % Iterate through the gains for this pressure sensor...
        
        % Print out a header for this information.
        fprintf('\n\nPRESSURE SENSOR %0.0f, GAIN %0.0f\n', k1, k2)
        
        % Compute the circuit components to achieve this gain.
        [ Rs_full_psens{k1, k2}, Rs_partial_psens{k1, k2} ] = GetOpAmpRValues( ks_psens(k1, k2), rs_available, true, false, true );
    
    end
    
end




