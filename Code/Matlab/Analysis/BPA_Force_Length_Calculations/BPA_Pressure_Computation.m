%% BPA Pressure Computation

%Clear Everything
clear
close all
clc

%% Define the BPA Pressure Model.

%Define the model constants.
c0 = 254.3e3;                       % [Pa] Model Parameter 0
c1 = 192e3;                         % [Pa] Model Parameter 1
c2 = 2.0265;                        % [-] Model Parameter 2
c3 = -0.461;                        % [-] Model Parameter 3
c4 = -0.331e-3;                     % [1/N] Model Parameter 4
c5 = 1.23e3;                        % [Pa/N] Model Parameter 5
c6 = 15.6e3;                        % [Pa] Model Parameter 6

%Define the maximum and minimum actuator length.
Lmax = 18.9e-2;                       %[m] Maximum actuator length (the length of the actuator at P = 0 kPa).
Lmin = 15.75e-2;                      %[m] Minimum actuator length (the length of the actuator at P = Pmax = 90 psi ~= 620 kpa).

%Define the maximum strain of the BPA (Same for both views of strain).
gmax = (Lmax - Lmin)/Lmax;

%% Plot the Pressure vs Type I Strain.

%Define the Type I strain.
gs = linspace(-0.02, 0.18, 100);

%Define the extension and contraction factor.
Ss = [0 1];

%Define the applied force values.
% Fs = [0 53.378659539010805e3 106.75731907802161e3];                 %[mN] Force applied to muscle.
Fs = 0;
% Fs = [0 12 24];
% Fs = (4.4482216282509*1000)*Fs;
Fs = 4.4482216282509*Fs;

%Create a plot to store the pressure values.
figure, hold on, grid on, xlabel('Type I Strain [-]'), ylabel('Pressure [kPa]'), title('Pressure vs Type I Strain')

%Compute the associated pressures.
for k1 = 1:length(Fs)                                                                               %Iterate through all of the applied forces...
    for k2 = 1:length(Ss)                                                                           %Iterate through all of the extension/contraction factors...
        
        %Compute the pressure.
        ps = c0 + c1*tan( c2*( gs/(c4*Fs(k1) + gmax) + c3 ) ) + c5*Fs(k1) + c6*Ss(k2);

        %Plot the pressure.
%         plot(gs, ps)
        plot(gs, ps*10^-3)
        
    end
end




