%% Monoarticular Static Analysis

% Static analysis for quadruped robot hind legs.

% Clear everything.
clear, close('all'), clc


%% Define Geometric and Physical Constants.

% Define the limb lengths.
L1 = 8.625 * (0.0254);              % [m] Limb Length 1 (inches to meters conversion).
L2 = 8.625 * (0.0254);              % [m] Limb Length 2 (inches to meters conversion).
L3 = 6.5 * (0.0254);                % [m] Limb Length 3 (inches to meters conversion).

% Define the gravitational constant.
g = 9.8;                            % [m/s^2] Gravitational Constant.

% Define the actuator lengths.
L_AF = 5.76 * (0.0254);             % [m] Ankle Flexor Length (inches to meters conversion). 
L_AE = 4.86 * (0.0254);             % [m] Ankle Extensor Length (inches to meters conversion). 
L_KF = (6:0.5:10) * (0.0254);       % [m] Knee Flexor Length (inches to meters conversion, current model is 7.28 inches).
L_KE = 7.28 * (0.0254);             % [m] Knee Extensor Length (inches to meters conversion).

% Define actuator masses (based on 1.698 [kg/m] linear density estimate).
m_AF = 1.698 * L_AF;                % [kg] Ankle Flexor Mass.
m_AE = 1.698 * L_AE;                % [kg] Ankle Extender Mass.
m_KF = 1.698 * L_KF;                % [kg] Knee Flexor Mass.
m_KE = 1.698 * L_KE;                % [kg] Knee Extender Mass.

% Define limb masses.
me = 0.0205;                        % [kg] Encoder Mass
m1 = 0.1302;                        % [kg] Limb 1 Mass.
m2 = 0.1302;                        % [kg] Limb 2 Mass.
m3 = 0.09814;                       % [kg] Limb 3 Mass.

% Define the maximum muscle strain estimate.
k_max = 0.1667;                     % [-] Maximum Muscle Strain.

% Define the range of muscle attachment radii of interest.
r_KF = 0.002:0.001:0.06;            % [m] Muscle Attachment Radii (1mm to 6cm range).

% Define the required force safety factor.
SF = 1;                             % [-] Safety Factor.

% Define the BPA model parameters. (eq 4 from paper)
a0 = 254.3e3;                       % [Pa] Model Parameter 0.
a1 = 192e3;                         % [Pa] Model Parameter 1.
a2 = 2.0265;                        % [-] Model Parameter 2.
a3 = -0.461;                        % [-] Model Parameter 3.
a4 = -0.331e-3;                     % [1/N] Model Parameter 4.
a5 = 1.23e3;                        % [Pa/N] Model Parameter 5.
a6 = 15.6e3;                        % [Pa] Model Parameter 6.

% Define the hysteresis factor.
S = 1;                              % [0,1] Hysteresis Factor


%% Compute the Force Required to Statically Resist Gravity.

% Compute the torque required to statically resist gravity in the maximally flexed configuration.
T_leg = (L2/2) * (m2 + m_AE + m_AF) * g;    % [Nm] Tibia Torque (including frame and actuator mass).
T_ankle = (L2 + L3/2) * m3 * g;             % [Nm] Ankle Torque.
T_encoder = L2 * me * g;                    % [Nm] Ankle Encoder Torque
Tg = T_leg + T_ankle + T_encoder;           % [Nm] Total Torque Required to Statically Resist Gravity.

% Compute the muscle force required to statically resist gravity.
F_KF = SF * (Tg ./ r_KF);                   % [N] Required Muscle Force.


%% Plot the Pressure Required to Statically Resist Gravity for Different Muscle Lengths & Attachment Radii.

% Preallocate an array to store the legend entries.
key = strings(1, length(L_KF)); %pre-allocating for plot legend

% Setup the plot.
fig = figure('Color', 'w'); hold on, grid on, xlabel('Attachment Radius [mm]'), ylabel('Required Pressure [kPa]'), title('Monoarticular Knee Flexor: Required Pressure')

% Plot the pressure required to resist gravity vs muscle attachment radii for each resting muscle length.
for n = 1:length(L_KF)                  % Iterate through each resting muscle length...
   
    % Compute the muscle strain at maximum flexion.
    k = (r_KF * sqrt(2)) ./ L_KF(n);            %[-] Muscle Strain @ Maximum Flexion.
    
    % Remove unfeasiable strains (those that exceed the maximum possible muscle strain).
    k(k > k_max) = [];
    
    % Compute the pressure required to resist gravity.
    P = a0 + (a1 * tan( a2 * (( k ./ (a4 * F_KF(1:length(k)) + k_max)) + a3))) + (a5 * F_KF(1:length(k))) + (a6 * S); %Pa
    
    % Plot the required pressure vs attachment radii (in appropriate units).
    plot((r_KF(1:length(k))*1000), (P/1000), '-', 'Linewidth', 3)
    
    % Add an entry to our legend string.
    key(n) = sprintf('Actuator length: %.1f inch', (L_KF(n)/0.0254));
    
end

% Plot a line at the maximum available pressure.
yline(620, '--r', 'LineWidth', 3);

% Add a legend to the plot.
legend(key)



