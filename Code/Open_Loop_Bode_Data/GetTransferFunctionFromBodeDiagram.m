%% Get Transfer Function From Bode Diagram.

%Clear Everything
clear, close('all'), clc


%% Read in the Bode Data.

%Read in the bode data.
data = dlmread('OpenLoopBodeData.txt');

%Store the bode data into separate variables.
fs = data(:, 1); Ms = data(:, 2); Ps = data(:, 3);

%Define the proportional constant used to generate the bode data.
Kp = 1;

%% Fit an Arbitrary Transfer Function from the Bode Diagram.

%Compute the frequency response.
freq_response = Ms.*exp((pi/180)*Ps*1i);

%Define the sampling time for the idfrd model.
Ts = 0;

%Create the idfrd object related to our frequency response.
gfr = idfrd(freq_response, 2*pi*fs, Ts);

%Fit a transfer function to this data.
sys = tfest(gfr, 1);

%Define the frequency domain over which to plot the bode diagram.
fDomain = [fs(1) fs(end)];

%Generate the open loop bode diagram data from the transfer function model.
[mag, phase, wout] = bode( sys, {2*pi*fDomain(1), 2*pi*fDomain(2)} );

%Reshape the Motor Bode Response Data.
[mag, phase] = deal( reshape(mag, size(wout)), reshape(phase, size(wout)) );

% phase = phase - 360;

%Plot the magnitude & phase response.
figure, subplot(2, 1, 1), hold on, grid on, set(gca, 'XScale', 'log'), title('BPA: Magnitude Response (CL)'), xlabel('Frequency [Hz]'), ylabel('Magnitude [dB]')
plot(fs, 20*log10(Ms), '.k', 'Markersize', 20), plot(wout/(2*pi), 20*log10(mag), '-', 'Linewidth', 3)

subplot(2, 1, 2), hold on, grid on, set(gca, 'XScale', 'log'), title('BPA: Phase Response (CL)'), xlabel('Frequency [Hz]'), ylabel('Phase [deg]')
plot(fs, Ps, '.k', 'Markersize', 20), plot(wout/(2*pi), phase, '-', 'Linewidth', 3)


[num, den] = tfdata(sys);
num = num{1}; den = den{1};

sys_OLTF = tf(num, den - num);

figure, step(sys)
figure, step(sys_OLTF)


%% Fit a Transfer Function to the Bode Diagram (1st Order System).

%Set the plotting parameters.
bPlotFit = true; bPlotErrorSurface = true;

%Define the system parameter space domain in which to search.
wns = linspace(15, 60, 15);
zetas = linspace(0.1, 1.2, 15);

%Define the error weighting.
mag_weight = 0.8; phase_weight = 0.2;

%Generate the transfer function parameters.
[ K_crit, wn_crit, zeta_crit ] = OLBode2TF( fs, Ms, Ps, wns, zetas, mag_weight, phase_weight, bPlotFit, bPlotErrorSurface );


%% Fit a Transfer Function to the Bode Diagram (2nd Order System).
% 
% %Define a transfer function variable.
% s = tf('s');
% 
% %Define the system parameter space domain in which to search.
% Ks = linspace(-100, -10, 15);
% wns = linspace(10, 400, 15);
% zetas = linspace(0.1, 3, 15);
% 
% %Preallocate a variable to store the error values.
% errors = zeros(length(zetas), length(wns), length(Ks));
% 
% %Define the error weighting.
% mag_weight = 0.8; phase_weight = 0.2;
% 
% %Compute the error associated with each parameter combination.
% for k1 = 1:length(Ks)
%     for k2 = 1:length(wns)
%         for k3 = 1:length(zetas)
% 
%             %Define the PCL transfer function for these parameter values.
% %           Gcl = ( Kp*Ks(k1)*(wns(k2)^2) )/( s^2 + (2*zetas(k3)*wns(k2))*s + (1 + Kp*Ks(k1))*(wns(k2)^2) );
%             Gcl = ( Kp*Ks(k1)*(wns(k2)^2) )/( s^3 + (2*zetas(k3)*wns(k2))*(s^2) + (wns(k2)^2)*s + Kp*Ks(k1)*(wns(k2)^2) );
% 
%             %Generate the frequency response data assocaited with this PCL transfer function.
%             [mag_est, phase_est] = bode(Gcl, 2*pi*fs);
% 
%             %Reshape the frequency response data assocaited with this PCL transfer function.
%             [mag_est, phase_est] = deal( reshape(mag_est, size(fs)), reshape(phase_est, size(fs)) );
% 
%             %Compute the magnitude error.
%             mag_error = norm(abs(20*log10(mag_est) - 20*log10(Ms)));
% 
%             %Compute the phase error.
%             phase_error = norm(abs(phase_est - Ps));
% 
%             %Compute the weighted error.
%             errors(k3, k2, k1) = mag_weight*mag_error + phase_weight*phase_error;
% 
%         end
%     end
% end
% 
% %Compute the minimum weighted error.
% min_error = min(min(min(errors)));
% 
% %Find the indexes associated with the minimum weighted error.
% inds = AbsInd2DimInd( size(errors), find(errors == min_error) );
% 
% %Retrieve the natural frequency and damping ratio associated with minimum error.
% zeta_crit = zetas(inds(1)); wn_crit = wns(inds(2)); K_crit = Ks(inds(3));
% 
% %Define the grid of points overwhich to plot the error.
% [ZETAS, WNS, KS] = meshgrid(zetas, wns, Ks);
% 
% %Reshape the grid points so that they can be used by the scatter function.
% [ZETAS, WNS, KS, ERRORS] = deal( reshape( ZETAS, [numel(ZETAS), 1, 1] ), reshape( WNS, [numel(WNS), 1, 1] ), reshape( KS, [numel(KS), 1, 1] ), reshape( errors, [numel(errors), 1, 1] ) );
% 
% %Create the error surface as a three dimension color map plot.
% figure, hold on, grid on, scatter3(ZETAS, WNS, KS, 10, 1./(ERRORS.^3), 'filled'), plot3(zeta_crit, wn_crit, K_crit, '.r', 'Markersize', 20)
% title('Least Squares Error Over Parameter Space'), xlabel('Damping Ratio, \zeta [-]'), ylabel('Natural Frequency, \omega_n [rad/s]'), zlabel('Gain, K [-]'), axis([min(zetas) max(zetas) min(wns) max(wns) min(Ks) max(Ks)]), view(60, 30)

%% Create the Closed Loop Transfer Function.

%Create a transfer function variable.
s = tf('s');

%Create the closed loop transfer function.
% G_sCL = ( Kp*K_crit*(wn_crit^2) )/( s^3 + (2*zeta_crit*wn_crit)*(s^2) + (wn_crit^2)*s + Kp*K_crit*(wn_crit^2) );
G_sCL = (K_crit*(wn_crit^2))/(s^2 + (2*wn_crit*zeta_crit)*s + (wn_crit^2));

%Define the frequency domain over which to plot the bode diagram.
fDomain = [fs(1) fs(end)];

%Generate the open loop bode diagram data from the transfer function model.
[mag, phase, wout] = bode( G_sCL, {2*pi*fDomain(1), 2*pi*fDomain(2)} );

%Reshape the Motor Bode Response Data.
[mag, phase] = deal( reshape(mag, size(wout)), reshape(phase, size(wout)) );

%Plot the magnitude & phase response.
figure, subplot(2, 1, 1), hold on, grid on, set(gca, 'XScale', 'log'), title('BPA: Magnitude Response (CL)'), xlabel('Frequency [Hz]'), ylabel('Magnitude [dB]')
plot(fs, 20*log10(Ms), '.k', 'Markersize', 20), plot(wout/(2*pi), 20*log10(mag), '-', 'Linewidth', 3)

subplot(2, 1, 2), hold on, grid on, set(gca, 'XScale', 'log'), title('BPA: Phase Response (CL)'), xlabel('Frequency [Hz]'), ylabel('Phase [deg]')
plot(fs, Ps, '.k', 'Markersize', 20), plot(wout/(2*pi), phase, '-', 'Linewidth', 3)
