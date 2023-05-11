%% Mechanical properties of rat and dog systems 

% This program is meant to save sets of geometrical and mass properties of
% a leg as structures to be easily switched out durign optimization

clear, close('all'), clc

%% Rat hind leg properties

% Define the mechanical properties of link 1.
m1_value = 0.001 * 13.26;                   % [kg]                 
R1_value = 0.01 * 1.305;                    % [m]
L1_value = 0.01 * 2.9;                      % [m]

% Define the mechanical properties of link 2.
m2_value = 0.001 * 9.06;                    % [kg]
R2_value = 0.01 * 1.558;                    % [m]
L2_value = 0.01 * 4.1;                      % [m]

% Define the mechanical properties of link 3.
m3_value = 0.001 * 1.7;                     % [kg]
R3_value = 0.01 * 1.6;                      % [m]
L3_value = 0.01 * 3.3;                      % [m]

% Save the data as a structure
save('MechPropRat.mat', 'm1_value', 'R1_value', 'L1_value', ...
                        'm2_value','R2_value', 'L2_value', ...
                        'm3_value', 'R3_value', 'L3_value');
                    
                    
%% Dog hind leg properties
clear;

% Define the mechanical properties of link 1.
m1_value = 0.001 * 222;         % [kg]                 
R1_value = 0.01 * 8;            % [m]
L1_value = 0.01 * 22.2;         % [m]

% Define the mechanical properties of link 2.
m2_value = 0.001 * 207;         % [kg]
R2_value = 0.01 * 7.5;          % [m]
L2_value = 0.01 * 22;           % [m]

% Define the mechanical properties of link 3.
m3_value = 0.001 * 90;          % [kg]
R3_value = 0.01 * 3;            % [m]
L3_value = 0.01 * 16;           % [m]

% Save the data as a structure
save('MechPropDog.mat', 'm1_value', 'R1_value', 'L1_value', ...
                        'm2_value','R2_value', 'L2_value', ...
                        'm3_value', 'R3_value', 'L3_value');
                    
            
%% Dog UPDATED hind leg properties (with dampers)
clear;

% Define the mechanical properties of link 1.
m1_value = 0.001 * 179.3;         % [kg]                 
R1_value = 0.01 * 15.5;            % [m]
L1_value = 0.01 * 22;         % [m]

% Define the mechanical properties of link 2.
m2_value = 0.001 * 122.3;         % [kg]
R2_value = 0.01 * 15.5;          % [m]
L2_value = 0.01 * 22.5;           % [m]

% Define the mechanical properties of link 3.
m3_value = 0.001 * 43.9;          % [kg]
R3_value = 0.01 * 5;            % [m]
L3_value = 0.01 * 16;           % [m]

% Save the data as a structure
save('MechPropDog2.mat', 'm1_value', 'R1_value', 'L1_value', ...
                        'm2_value','R2_value', 'L2_value', ...
                        'm3_value', 'R3_value', 'L3_value');
                    
%% Dog UPDATED hind leg properties (with dampers and springs)
clear;

% Define the mechanical properties of link 1.
m1_value = 0.001 * 253.5;         % [kg]                 
R1_value = 0.01 * 17.5;            % [m]
L1_value = 0.01 * 22.5;         % [m]

% Define the mechanical properties of link 2.
m2_value = 0.001 * 162.8;         % [kg]
R2_value = 0.01 * 14.5;          % [m]
L2_value = 0.01 * 23;           % [m]

% Define the mechanical properties of link 3.
m3_value = 0.001 * 43.9;          % [kg]
R3_value = 0.01 * 5;            % [m]
L3_value = 0.01 * 16;           % [m]

% Save the data as a structure
save('MechPropDog3.mat', 'm1_value', 'R1_value', 'L1_value', ...
                        'm2_value','R2_value', 'L2_value', ...
                        'm3_value', 'R3_value', 'L3_value');