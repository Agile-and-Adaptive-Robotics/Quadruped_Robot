%% Masuda Muscle Properties Definition

% This script defines muscle properties for the Masuda neural network.

% Clear Everything.
clear, close('all'), clc

%% Define the Masdua Network Neuron Properties.

% Define the minimum and maximum Masuda muscle lengths.  These were obtained by running an Animatlab simulation with the limb position at its extreme positions.
Ls_min = [0.4106344; 0.4106326; 0.2419636; 0.2438596; 0.1814436; 0.2058291];
Ls_max = [0.4254683; 0.4254416; 0.2613189; 0.2590533; 0.2003621; 0.2206545];
% Ls_min = [0.4106344; 0.4106326; 0.2419636; 0.2438596; 0.1814436; 0.2058291];
% Ls_max = [0.4254683; 0.4254416; 0.258; 0.2590533; 0.2003621; 0.2206545];

% Retrieve the number of muscles.
num_muscles = size(Ls_min, 1);

% Compute the muscle widths.
Ls_width = (Ls_max - Ls_min)./2; 

% Compute the muscle resting lengths.
Ls_resting = Ls_width + Ls_min;

% Define the desired length-tension factor at the muscle width.
ks_width = [0.75; 0.75; 0.75; 0.75; 0.75; 0.75];

% Compute the muscle root widths.
Ls_width0 = GetMuscleRootWidth(Ls_width, ks_width);

% Define the critical length percentages.
plow = 0.1; phigh = 0.9;

% Create a variable to store the critical lengths.
Ls_low = zeros(num_muscles, 1); Ls_high = zeros(num_muscles, 1);

% Create a variable to store the fitted polynomials.
polys = zeros(num_muscles, 2);

% Compute each critical length.
for k = 1:num_muscles               % Iterate through each of the muscles...

    % Compute some critical lengths.
    Ls_low(k) = interp1([0, 1], [Ls_min(k), Ls_max(k)], plow);
    Ls_high(k) = interp1([0, 1], [Ls_min(k), Ls_max(k)], phigh);

    % Retrieve the polynomial associated with this muscle..
    polys(k, :) = polyfit([Ls_min(k), Ls_max(k)], [0 20e-9], 1);
    
    fprintf('Muscle %0.0f: m = %0.16f [nA/m], b = %0.16f [nA]\n', k, polys(k, 1)*10^9, polys(k, 2)*10^9)
    
end

% Store the data into a matrix.
M = [Ls_min Ls_max Ls_resting Ls_width ks_width Ls_width0 Ls_low Ls_high];

% Define the row names.
RowNames = {'Hip Extensor', 'Hip Flexor', 'Knee Extensor', 'Knee Flexor', 'Ankle Extensor', 'Ankle Flexor'};

% Define the column names.
ColumnNames = {'Minmum Length [m]', 'Maximum Length [m]', 'Resting Length [m]', 'Width [m]', 'Length-Tension Factor @ Width [-]', 'Root Width [m]', 'Low Length [m]', 'High Length [m]'};

% Create a table of these values.
T = array2table(M, 'RowNames', RowNames, 'VariableNames', ColumnNames);

% Write out the muscle data table.
writetable(T, 'MasudaMuscleDataTable.txt');

fprintf('\n')
format long g
disp(T)

% fprintf('%0.16f\n', (20e-9)/300)
