%% Bode Data Fitting: Second Order

%Clear Everything
clear, close('all'), clc

%% Generate Bode Data from a Second Order System for Fitting.

%Define the number of noisy samples to take.
num_noisy_samples = 30;

%Define the parameters of the second order system.
k_gain = 1; zeta = 1.5; wn = 2*pi*250;

%Generate the transfer function for this second order system.
Gs_tf = tf(k_gain*(wn^2), [1 (2*zeta*wn) (wn^2)]);

%Define the frequencies at which to generate bode data.
fs = logspace(-1, 3, 100);

%Convert the bode frequencies to angular frequencies.
ws = 2*pi*fs;

%Collect the bode data from this second order system.
[ms_actual, ps_actual] = bode(Gs_tf, ws);

%Reshape the bode data.
ms_actual = reshape(ms_actual, size(ws)); ps_actual = reshape(ps_actual, size(ws));

%Convert the magnitude data to decibels for plotting.
dbs_actual = 20*log10(ms_actual);

%Define the level of noise to add to the magnitude and phase results.
dbs_noise_level = 0.5; ps_noise_level = 0.1;

%Define the magnitude noise.
dbs_noise = dbs_noise_level*dbs_actual(1)*(rand(size(dbs_actual)) - 0.5); ps_noise = 180*ps_noise_level*(rand(size(ps_actual)) - 0.5);

%Add noise to magnitude and phase responses.
dbs_noisy = dbs_actual + dbs_noise; ps_noisy = ps_actual + ps_noise;

%Subsample the noisy data.
subsample_locs = floor(linspace(1, length(fs), num_noisy_samples));
fs_noisy = fs(subsample_locs); ws_noisy = 2*pi*fs_noisy; dbs_noisy = dbs_noisy(subsample_locs); ps_noisy = ps_noisy(subsample_locs);


%% Fit a 2nd Order Transfer Function to the Bode Data.

%Fit a 2nd Order Transfer Fucntion to the Bode Data.
[ Gs, wn_crit, zeta_crit, k_crit ] = Fit2ndOrderSys( ws_noisy, dbs_noisy, ps_noisy, 1e-3, [0.8 0.2], true, true );

%Retrieve the bode data for the fitted 2nd order transfer function.
[ms_fit, ps_fit] = bode(Gs, ws);

%Reshape the bode data.
ms_fit = reshape(ms_fit, size(ws)); ps_fit = reshape(ps_fit, size(ws));

%Convert the magnitude response data to decibles for plotting.
dbs_fit = 20*log10(ms_fit);

%% Plot the Bode Diagram.

%Define common plotting properties.
marker_size = 20; line_width = 3;

figure, subplot(2, 1, 1), hold on, grid on, set(gca, 'XScale', 'log'), title('2nd Order System: Magnitude Response'), xlabel('Frequency [Hz]'), ylabel('Magnitude [dB]')
plot(fs, dbs_actual, 'Linewidth', line_width), plot(fs_noisy, dbs_noisy, '.', 'Markersize', marker_size), plot(fs, dbs_fit, 'Linewidth', line_width)
subplot(2, 1, 2), hold on, grid on, set(gca, 'XScale', 'log'), title('2nd Order System: Phase Response'), xlabel('Frequency [Hz]'), ylabel('Phase [deg]')
plot(fs, ps_actual, 'Linewidth', line_width), plot(fs_noisy, ps_noisy, '.', 'Markersize', marker_size), plot(fs, ps_fit, 'Linewidth', line_width)
legend('Actual Data', 'Noisy Data', 'Fit Data', 'Location', 'Best')


