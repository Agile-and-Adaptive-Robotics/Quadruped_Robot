%% Design Lead Controller for BPA.

%Clear Everything
clear, close('all'), clc


%% Read in the Open Loop Bode Diagram Data.

%Read in the bode data.
data = dlmread('OpenLoopBodeData.txt');

%Store the bode data into separate variables.
fs = data(:, 1); Ms = data(:, 2); Ps = data(:, 3);

%Define the frequency domain over which to plot the bode diagram.
fDomain = [fs(1) fs(end)];

%Define the final time for the step responses.
tfinal = 1;

%% Create the Open Loop Transfer Function.

%Create a transfer function variable.
s = tf('s');

%Define the natural frequency, damping ratio, and magnitude.
% K_crit = 7.2458000000000000e-01;
% wn_crit = 5.2653061224489797e+01;
% zeta_crit = 6.1428571428571421e-01;

K_crit = 0.82364;
wn_crit = 24.6428571428571420;
zeta_crit = 0.6499999999999999;

%Define the uncontroller open loop continuous transfer function.
% G_sOL = ( K_crit*(wn_crit^2) )/( s^2 + 2*wn_crit*zeta_crit*s + (1 - K_crit)*(wn_crit^2) );
G_sOL = tf([0 -86.1791252816481550 2816.1374924919546000], [1 249.9457785692308700 674.3097090106466600]);

%Compute the closed loop continuous transfer function.
G_sPCL = feedback(G_sOL, 1);

%% Plot the Open Loop Bode Diagram.

%Generate the open loop bode data.
[ms_sOL, ps_sOL, w_sOL] = bode( G_sOL, {2*pi*fDomain(1), 2*pi*fDomain(2)});

%Reshape the open loop bode response data.
[ms_sOL, ps_sOL] = deal( reshape(ms_sOL, size(w_sOL)), reshape(ps_sOL, size(w_sOL)) );

%Plot the magnitude & phase response.
figure, subplot(2, 1, 1), hold on, grid on, set(gca, 'XScale', 'log'), title('BPA: Magnitude Response (OL)'), xlabel('Frequency [Hz]'), ylabel('Magnitude [dB]')
plot(w_sOL/(2*pi), 20*log10(ms_sOL), '-', 'Linewidth', 3)

subplot(2, 1, 2), hold on, grid on, set(gca, 'XScale', 'log'), title('BPA: Phase Response (OL)'), xlabel('Frequency [Hz]'), ylabel('Phase [deg]')
plot(w_sOL/(2*pi), ps_sOL, '-', 'Linewidth', 3)

%% Plot the Open Loop Step Response.

%Generate the open loop step response data.
[ys_sOL, ts_sOL] = step(G_sOL, tfinal);

%Plot the open loop step response data.
figure, hold on, grid on, title('BPA: Step Response (OL)'), xlabel('Time [s]'), ylabel('Amplitude [-]'), plot(ts_sOL, ys_sOL, '-b', 'Linewidth', 3)


%% Plot the Unit Proportional Closed Loop Bode Diagram.

%Generate the open loop bode diagram data from the transfer function model.
[ms_sCL, ps_sCL, wout] = bode( G_sPCL, {2*pi*fDomain(1), 2*pi*fDomain(2)} );

%Reshape the open loop bode response data.
[ms_sCL, ps_sCL] = deal( reshape(ms_sCL, size(wout)), reshape(ps_sCL, size(wout)) );

%Plot the magnitude & phase response.
figure, subplot(2, 1, 1), hold on, grid on, set(gca, 'XScale', 'log'), title('BPA: Magnitude Response (PCL)'), xlabel('Frequency [Hz]'), ylabel('Magnitude [dB]')
plot(fs, 20*log10(Ms), '.k', 'Markersize', 20), plot(wout/(2*pi), 20*log10(ms_sCL), '-', 'Linewidth', 3)

subplot(2, 1, 2), hold on, grid on, set(gca, 'XScale', 'log'), title('BPA: Phase Response (PCL)'), xlabel('Frequency [Hz]'), ylabel('Phase [deg]')
plot(fs, Ps, '.k', 'Markersize', 20), plot(wout/(2*pi), ps_sCL, '-', 'Linewidth', 3)

%% Plot the Unit Proportional Closed Loop Step Response.

%Generate the unit proportional closed loop step response data.
[ys_sPCL, ts_sPCL] = step(G_sPCL, tfinal);

%Plot the unit proportional closed loop step response data.
figure, hold on, grid on, title('BPA: Unit Proportional Step Response (PCL)'), xlabel('Time [s]'), ylabel('Amplitude [-]'), plot(ts_sPCL, ys_sPCL, '-', 'Linewidth', 3)


%% Compute the Digital Open Loop Transfer Function.

%Define the sampling rate.
dt = 1/4e3;

%Convert the continuous uncontrolled open loop transfer function to a digital uncontrolled open loop transfer function.
G_zOL = c2d(G_sOL, dt);


%% Design a Digital Lead Controller to Improve System Response.


%Define the amount of phase margin to add.
Pm_add = 20;

%Design a Lead Controller.
Gc_zLD = GetzLeadController( G_zOL, Pm_add );

%Define the Lead Open Loop Transfer Function.
G_zLDOL = Gc_zLD*G_zOL;

%Define the Lead Closed Loop Transfer Function.
G_zLDCL = feedback(G_zLDOL, 1);


% Pm_adds = linspace(10, 80, 100);
% 
% [RTs, STs, PMOs] = deal( zeros(1, length(Pm_adds)) );
% 
% for k = 1:length(Pm_adds)
%     
%     %Define the amount of phase margin to add.
%     Pm_add = Pm_adds(k);
%     
%     %Design a Lead Controller.
%     Gc_zLD = GetzLeadController( G_zOL, Pm_add );
%     
%     %Define the Lead Open Loop Transfer Function.
%     G_zLDOL = Gc_zLD*G_zOL;
%     
%     %Define the Lead Closed Loop Transfer Function.
%     G_zLDCL = feedback(G_zLDOL, 1);
%     
%     %Get the step info associated with the Lead Closed Loop System.
%     stepinfo_zLDCL = stepinfo(G_zLDCL);
%     
%     %Store the step info into separate variables.
%     RTs(k) = stepinfo_zLDCL.RiseTime;
%     STs(k) = stepinfo_zLDCL.SettlingTime;
%     PMOs(k) = stepinfo_zLDCL.Overshoot;
%     
% end
% 
% figure, hold on, grid on, title('Rise Time vs Added Phase Margin'), xlabel('Added Phase Margin'), ylabel('Rise Time [s]'), plot(Pm_adds, RTs)
% figure, hold on, grid on, title('Settling Time vs Added Phase Margin'), xlabel('Added Phase Margin'), ylabel('Settling Time [s]'), plot(Pm_adds, STs)
% figure, hold on, grid on, title('Percent Maximum Overshoot vs Added Phase Margin'), xlabel('Added Phase Margin'), ylabel('Percent Maximum Overshoot [%]'), plot(Pm_adds, RTs)


%% Plot the Step Response of the Lead Controlled Closed Loop System.

%Generate the controller step response associated with the HDD LDCL Transfer Function.
[ys_zLDCL, ts_zLDCL] = step(G_zLDCL, tfinal);

%Plot the HDD PCL & LeadCL Transfer Function.
figure, hold on, grid on, title('BPA: Step Response (zLDCL)'), xlabel('Time [s]'), ylabel('Amplitude [-]')
stairs(ts_zLDCL, ys_zLDCL, '-', 'Linewidth', 3)


%% Design a Digital Lag Controller to Improve System Response.

%Define the desired phase margin.
Pm = 80;

%Design a lag controller to improve the system.
Gc_zLG = GetzLagController( G_zOL, Pm );

%Define the Lead Open Loop Transfer Function.
G_zLGOL = Gc_zLG*G_zOL;

%Define the Lead Closed Loop Transfer Function.
G_zLGCL = feedback(G_zLGOL, 1);

%% Plot the Step Response of the Lag Controlled Closed Loop System.

%Generate the controller step response associated with the BPA zLGCL Transfer Function.
[ys_zLGCL, ts_zLGCL] = step(G_zLGCL, tfinal);

%Plot the HDD PCL & LeadCL Transfer Function.
figure, hold on, grid on, title('BPA: Step Response (zLGCL)'), xlabel('Time [s]'), ylabel('Amplitude [-]')
stairs(ts_zLGCL, ys_zLGCL, '-', 'Linewidth', 3)


%% Design a Digital PI Controller to Improve System Response.

%Define the desired phase margin.
Pm = 80;

%Design a PI Controller to improve the system.
Gc_zPI = GetzPIController( G_zOL, Pm );

%Define the PI Open Loop Transfer Function.
G_zPIOL = Gc_zPI*G_zOL;

%Define the PI Closed Loop Transfer Function.
G_zPICL = feedback(G_zPIOL, 1);

%% Plot the Step Response of the PI Controlled Closed Loop System.

%Generate the controller step response associated with the BPA zPI Transfer Function.
[ys_zPICL, ts_zPICL] = step(G_zPICL, tfinal);

%Plot the HDD PCL & LeadCL Transfer Function.
figure, hold on, grid on, title('BPA: Step Response (zPICL)'), xlabel('Time [s]'), ylabel('Amplitude [-]')
stairs(ts_zPICL, ys_zPICL, '-', 'Linewidth', 3)


%% Design a Digital State Space Controller with an Outer Loop Integrator.




%% Plot the Step Responses with & without Lead Control.

%Plot the Step Response with & without Lead Control.
figure, hold on, grid on, title('BPA: Step Response (sPCL & zLDCL & zLGCL)'), xlabel('Time [s]'), ylabel('Amplitude [-]')
plot(ts_sPCL, ys_sPCL, '-', 'Linewidth', 3), stairs(ts_zLDCL, ys_zLDCL, '-', 'Linewidth', 3), stairs(ts_zLGCL, ys_zLGCL, '-', 'Linewidth', 3), stairs(ts_zPICL, ys_zPICL, '-', 'Linewidth', 3)
legend('sPCL', 'zLDCL', 'zLGCL', 'zPICL', 'Orientation', 'Horizontal', 'Location', 'Southeast')

