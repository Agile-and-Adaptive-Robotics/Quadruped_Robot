%% Monoarticular static analysis 

% For quadruped robot hind legs

clear, close('all'), clc
%% Define geometric and physical constants

% Defining hind leg section lengths
l1 = 8.625 * (0.0254);              % [m] Limb length 1 (inches to meters conversion)
l2 = 8.625 * (0.0254);              % [m] Limb length 2 (inches to meters conversion)
l3 = 6.5 * (0.0254);                % [m] Limb length 3 (inches to meters conversion)

% Define gravitational constant
g = 9.8;                            % [m/s^2]

% Define length of actuators
L_AF = 5.76 * (0.0254);             % [m] Ankle flexor length (inches to meters conversion)
L_AE = 4.86 * (0.0254);             % [m] Ankle extensor length (inches to meters conversion)
L_KF = (6:0.5:10) * (0.0254);       % [m] Knee flexor length (inches to meters conversion)
L_KE = 7.28 * (0.0254);             % [m] Knee extensor length (inches to meters conversion)

% Define actuator masses based on linear density estimate of 1.698 kg/m
m_AF = 1.698 * L_AF;                % [kg] Ankle flexor mass
m_AE = 1.698 * L_AE;                % [kg] Ankle extensor mass
m_KF = 1.698 * L_KF;                % [kg] Knee flexor mass
m_KE = 1.698 * L_KE;                % [kg] Knee extensor mass

% Define mass values of the hind leg sections
me = 0.0205;                        % [kg] Mass of encoders
m1 = 0.1302;                        % [kg] Section 1 leg mass
m2 = 0.1302;                        % [kg] Section 2 leg mass
m3 = 0.09814;                       % [kg] Section 2 leg mass

% Define maximum actuator strain estimate 
k_max = 0.1667;                     % [-]

% Define range of attachment radii
r_KF = 0.005:0.001:0.06;            % [m] Knee flexor (1mm to 6cm range)

% Define the safety factor of required force
SF = 1;                             % [-]

%Define BPA model constants (eq 4 from paper)
a0 = 254.3e3;                       % [Pa] Model Parameter 0
a1 = 192e3;                         % [Pa] Model Parameter 1
a2 = 2.0265;                        % [-] Model Parameter 2
a3 = -0.461;                        % [-] Model Parameter 3
a4 = -0.331e-3;                     % [1/N] Model Parameter 4
a5 = 1.23e3;                        % [Pa/N] Model Parameter 5
a6 = 15.6e3;                        % [Pa] Model Parameter 6

% Define the hysteresis factor
S = 1;                              % [0,1]

%% Computing static force requirements

% Computing torque from gravity at a maximally flexed position
T_leg = (l2/2) * (m2 + m_AE + m_AF) * g;    % [Nm] Torque from tibia frame and lower limb actuators
T_ankle = (l2 + l3/2) * m3 * g;             % [Nm] Torque from ankle, at extended position
T_encoder = l2 * me * g;                    % [Nm] Torque from encoder at ankle
Tg = T_leg + T_ankle + T_encoder;           % [Nm] Total torque on knee from gravity

% Compute necessary force from actuator to resist gravity
F_KF = SF * (Tg ./ r_KF);                   % [N]

%% Plot relationship between necessary actuator pressure and attachment radii, varying actuator lengths

% Preallocating an array for plot legend
key = strings(1,length(L_KF)); 

% Setup the plot
fig = figure('Color', 'w'); hold on, grid on, xlabel('Attachment Radius [mm]'), ylabel('Required Pressure [kPa]'), title('Monoarticular Knee Flexor: Required Pressure')

% Plot the pressure required to resist gravity vs muscle attachment radii for each resting muscle length
for n = 1:length(L_KF)                  % Iterate through each resting muscle length
   
    % Compute muscle strain at max flexion
    k = (r_KF * sqrt(2)) ./ L_KF(n);	% [-]
    
    % Remove strains that exceed max strain
    k(k > k_max) = [];           % [-]
   
    % Compute necessary pressure to hold flexed position
    P = a0 + (a1 * tan( a2 * (( k ./ (a4 * F_KF(1:length(k)) + k_max)) + a3))) + (a5 * F_KF(1:length(k))) + (a6 * S); %Pa
    
    % Plot attachment radius vs required pressure to achieve static
    % requirements in appropriate units
    plot((r_KF(1:length(k))*1000), (P/1000), '-', 'LineWidth', 3)
   
    % Add a legend entry for actuator length curves
    key(n) = sprintf('Actuator length: %.1f inch', (L_KF(n)/0.0254));
end

% Add a line on the plot representing max pressure available
yline(620, '--r', 'LineWidth', 3);

% Add the legend
legend(key)

