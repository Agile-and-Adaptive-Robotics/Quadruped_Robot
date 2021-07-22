%% BPA Pressure Computation

% Clear Everything
clear, close('all'), clc


%% Define the BPA Pressure Model.

% Define the model constants.
c0 = 254.3e3;           % [Pa] Model Parameter 0.
c1 = 192e3;             % [Pa] Model Parameter 1.
c2 = 2.0265;            % [-] Model Parameter 2.
c3 = -0.461;            % [-] Model Parameter 3.
c4 = -0.331e-3;         % [1/N] Model Parameter 4.
c5 = 1.23e3;            % [Pa/N] Model Parameter 5.
c6 = 15.6e3;            % [Pa] Model Parameter 6.

% Define the maximum and minimum actuator length.
Lmax = 18.9e-2;                         % [m] Maximum actuator length (the length of the actuator at P = 0 kPa).
Lmin = 15.75e-2;                        % [m] Minimum actuator length (the length of the actuator at P = Pmax = 90 psi ~= 620 kpa).

% Define the maximum strain of the BPA (Same for both views of strain).
gmax = (Lmax - Lmin)/Lmax;              % [-] Maximum Type I Strain


%% Plot the Pressure vs Type I Strain.

% Define the Type I strain.
gs = linspace(-0.02, gmax, 100);

% Define the hysteresis factor.
Ss = [0 1];                                         % [-] Hysteresis Factor (0 = Contraction, 1 = Extension (I am about 90% sure this is the correct order, but it could be backward.)).

% Define the applied force values.
Fs = [0 12 24];                                     % [lbf] Applied Force.

% Convert the applied force from pounds-force to newtons.
Fs = 4.4482216282509*Fs;                            % [N] Applied Force.

% Define the possible plot colors.
colors = {'r', 'g', 'b'}; num_colors = length(colors);

% Create a plot to store the pressure values.
figure('Color', 'w'), hold on, grid on, xlabel('Type I Strain [-]'), ylabel('Pressure [kPa]'), title('Pressure vs Type I Strain'), axis([-0.02, 0.95*gmax, 0, 700])

% Compute the associated pressures.
for k1 = 1:length(Fs)                                                                               % Iterate through all of the applied forces...
    
    % Define the color index.
    color_index = mod(k1 - 1, num_colors) + 1;
    
    for k2 = 1:length(Ss)                                                                           % Iterate through all of the extension/contraction factors...
        
        % Compute the pressure.
        ps = c0 + c1*tan( c2*( gs/(c4*Fs(k1) + gmax) + c3 ) ) + c5*Fs(k1) + c6*Ss(k2);
        
        % Plot the pressure.
        line = plot(gs, ps*10^-3, colors{color_index}, 'Linewidth', 3);

            
    end
end


