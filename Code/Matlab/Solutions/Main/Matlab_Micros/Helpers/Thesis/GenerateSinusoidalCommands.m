function [muscle_values, ts, num_commands] = GenerateSinusoidalCommands(num_muscles, num_cycles, num_per_cycle, on_value, offset)
%% Function Description.

% This function generates a matrix of muscle commands, muscle_values, of
% dimension num_commands x num_muscles, that cause the muscle to alternate
% between extension & contraction phases using sinusoidal waves with the given properties.


%% Define Default Input Arguments.

% Define the default input arguments.
if nargin < 5, offset = 0; end                          % [-] Value to offset the bottom of the sine wave.
if nargin < 4, on_value = 450; end                      % [-] Muscle On Value.
if nargin < 3, num_per_cycle = 100; end                 % [#] Number of Points per Cycle.
if nargin < 2, num_cycles = 5; end                      % [#] Number of Cycles to Generate.
if nargin < 1, num_muscles = 24; end                    % [#] Number of Muscles.

%% Generate the On/Off Commands.

% Compute the total number of commands to be sent.
num_commands = num_per_cycle*(num_cycles/2 + 1);

%Define a time vector for data collection and simulation.
ts = 1:num_commands;

% Preallocate a value to store the muscle values.
muscle_values = zeros(num_commands, num_muscles);

% Assign every other entry to be sine wave with the appropriate properties.
muscle_values(:, 1:2:end) = (on_value/2)*(sin((2*pi/num_per_cycle)*ts - pi/2)'*ones(1, num_muscles/2) + 1) + offset;
muscle_values(:, 2:2:end) = (on_value/2)*(sin((2*pi/num_per_cycle)*ts + pi/2)'*ones(1, num_muscles/2) + 1) + offset;


end

