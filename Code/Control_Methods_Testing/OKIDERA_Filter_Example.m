%% OKID-ERA Filter Example

%Clear Everything
clear, close('all'), clc

%% Read in the Bode Data.

bode_data = xlsread('C:\Users\USER\Documents\Coursework\MSME\Thesis\AARL_Puppy_18_00_000\Control\Control_Methods_Testing\Passive_2ndOrder_LowPassFilter_BodeData', 'A3:D40');

fs_bode = bode_data(:, 1); ws_bode = 2*pi*fs_bode;
ms_bode = bode_data(:, 3)./bode_data(:, 2); dbs_bode = 20*log10(ms_bode);
ps_bode = -bode_data(:, 4);

%Retrieve the frequency domain.
f_domain = [fs_bode(1), fs_bode(end)]; w_domain = 2*pi*f_domain;

%% Read in the Impulse Response Data.

%Define the folder that the impulse data files are stored in.
path_name = 'C:\Users\USER\Documents\Coursework\MSME\Thesis\AARL_Puppy_18_00_000\Control\Control_Methods_Testing\Passive_Filter_Impulse_Data';

%Define the number of impulse data files to read.
num_files = 5;

%Define the impulse time step.
dt = 0.0002;

%Define the spike threshold.
spike_threshold = 9;

%Define the number of time steps to keep.
num_points_to_keep = 98;

%Define a location offset.
loc_offset = 0;

%Process each of the impulse files.
for k1= 1:num_files                                     %Iterate through all of the files.
    
    %Define the name of the file to read in.
    file_name = sprintf('NewFile%0.0f.csv', k1);
    
    %Define the full path to the file to read in.
    full_name = strcat(path_name, '\', file_name);
    
    %Read in the impulse data from this file.
    impulse_data = csvread(full_name, 2);
    
    %Read in the input and output signal.
    us = impulse_data(:, 2); ys = impulse_data(:, 3);
    
    %Determine the impulse spike locations.
    spike_locs = find(us > spike_threshold);
    
    %Remove any duplicate points
    spike_locs = spike_locs(diff(spike_locs) > 1);
    
    %Seperate each of the impulse pulses.
    for k2 = 1:length(spike_locs)                                               %Iterate through each of the impulse signals...
        
        %Store the impulse input and output signals into matrices.
        us_mat(k2 + loc_offset, :) = us(spike_locs(k2):(spike_locs(k2) + num_points_to_keep));
        ys_mat(k2 + loc_offset, :) = ys(spike_locs(k2):(spike_locs(k2) + num_points_to_keep));
        
    end
    
    loc_offset = k2;
    
end

%Define the time vector associated with the impulse input and output signals.
ts_impulse = 0:dt:dt*num_points_to_keep;

%Average the input and output signals.
us_impulse = mean(us_mat); ys_impulse = mean(ys_mat);

%Fit an exponential curve to the impulse response.
exp_fit = fit(ts_impulse', ys_impulse', 'exp2');

%Smooth the impulse response.
ys_impulse_smooth = exp_fit(ts_impulse);

%% Read in the White Noise Data.

%Define the folder that the white noise data files are stored in.
path_name = 'C:\Users\USER\Documents\Coursework\MSME\Thesis\AARL_Puppy_18_00_000\Control\Control_Methods_Testing\Passive_Filter_WhiteNoise_Data';

%Define the number of white noise data files to read.
num_files = 5;

%Define the sampling rate for the white noise.
dt_whitenoise = 0.00005;

%Preallocate cell arrays to store te noise inputs and outputs.
[noise_inputs_cell, noise_outputs_cell] = deal( cell(1, num_files) );

%Preallocate a variable to store the lengths of each of the files.
num_data_points = zeros(1, num_files);

%Read in each of the white noise data files.
for k = 1:num_files                                             %Read in each of the white noise data files.
    
    %Define the name of the file to read in.
    file_name = sprintf('NewFile%0.0f.csv', k1);
    
    %Define the full path to the file to read in.
    full_name = strcat(path_name, '\', file_name);
    
    %Read in the impulse data from this file.
    whitenoise_data = csvread(full_name, 2);
    
    %Store the number of data points that are in this file.
    num_data_points(k) = size(whitenoise_data, 1);
    
    %Read in the input and output signal and save them into cell arrays.
    noise_inputs_cell{k} = whitenoise_data(:, 2); noise_outputs_cell{k} = whitenoise_data(:, 3);
        
end

%Preallocate noise input and output vectors to store all of the noise input and output data.
[noise_inputs, noise_outputs] = deal( zeros(1, sum(num_data_points)) );

%Define the critical locations in the noise input and output vectors were the data from each new file needs to be inserted.
locs = cumsum([0 num_data_points]);

%Store the noise input and output data into vectors.
for k = 1:num_files                                                             %Iterate through each of the files...
    
    %Store the noise input and output data into vectors.
    noise_inputs((locs(k) + 1):locs(k + 1)) = noise_inputs_cell{k}';
    noise_outputs((locs(k) + 1):locs(k + 1)) = noise_outputs_cell{k}';

end

ts_noise =  0:dt:dt*(length(noise_inputs) - 1);

figure, hold on, grid on, plot(ts_noise, noise_inputs, '.')
figure, hold on, grid on, plot(ts_noise, noise_outputs, '.')

%% Read in the Step Response Data.

%Define the file to read in.
file_name = 'C:\Users\USER\Documents\Coursework\MSME\Thesis\AARL_Puppy_18_00_000\Control\Control_Methods_Testing\Passive_Filter_Step_Data\NewFile1.csv';

%Define the experimental step data sampling rate.
dt_step = 0.001;

%Read in the file.
step_data = csvread(file_name, 2);

%Compute the number of data points in the sample.
num_step_points = size(step_data, 1);

%Create a time vector for the experimental step response.
ts_step = linspace2(0, dt_step, num_step_points);

%Store the experimental step data into arrays.
us_step = step_data(:, 2)'; ys_step = step_data(:, 3)';

%Plot the experimental step response for reference.
figure, hold on, grid on, plot(ts_step, us_step), plot(ts_step, ys_step)

%% Define the Theoretical Transfer Function.

%Define the resistors and capacitors used in the filter.
R = 2.7e3; C = 0.22e-6;

%Compute the theoretical damping ratios and natural frequencies.
wn_theoretical = 1/(R*C); zeta_theoretical = 3/2;

%Compute the theoretical transfer function.
Gs_tf_theoretical = tf(1, [(R*C)^2 (3*R*C) 1]);

%Get the bode data associated with the theoretical transfer function.
[ dbs_theoretical, ps_theoretical ] = GetBodeData( Gs_tf_theoretical, ws_bode );

%% Fit a Transfer Function to the Bode Data.

%Fit a 2nd Order Transfer Fucntion to the Bode Data.
% [ Gs_tf_fit, wn_crit, zeta_crit, k_crit ] = Fit2ndOrderSys( ws_bode, dbs_bode, ps_bode, 1e-8, [0.8 0.2], false, false );
wn_crit = 1.7476e+03; zeta_crit = 1.4531; k_crit = 1;
Gs_tf_fit = tf(k_crit*(wn_crit^2), [1 (2*zeta_crit*wn_crit) (wn_crit^2)]);

% %Retrieve the bode data for the fitted 2nd order transfer function.
[ dbs_fit, ps_fit ] = GetBodeData( Gs_tf_fit, ws_bode );

%Retrieve the impulse response data from the fitted 2nd order transfer function.
% [ys_impulse_fit, ts_impulse_fit] = impulse(Gs_tf_fit);
[ys_impulse_fit, ts_impulse_fit] = impulse(Gs_tf_fit, ts_impulse);

%Normalize the impulse response magnitude.
ys_impulse_fit_unscaled = ys_impulse_fit/max(ys_impulse_fit);

%% Fit the Impulse Response ERA System ID.

%Fit the impulse response with the ERA.
[ Gz_ss_era_unscaled, singular_values_era ] = DERA([0; ys_impulse_smooth], dt, 'rank', 2);

%Generate the bode data for this model.
[dbs_era_unscaled, ps_era_unscaled] = GetBodeData(Gz_ss_era_unscaled, ws_bode);

%Generate the impulse data for this model.
[ys_impulse_era_unscaled, ts_impulse_era_unscaled] = impulse(Gz_ss_era_unscaled, ts_impulse);

%Retrieve the static gain associated with the unscaled model.
db_intercept_unscaled = dbs_era_unscaled(1); db_intercept_desired = dbs_bode(1);

%Compute the required scaling factor.
k_scale = 10^((db_intercept_desired - db_intercept_unscaled)/20);

%Create a discrete state space model from the ERA model that is scaled.
Gz_ss_era_scaled = ss(Gz_ss_era_unscaled.A, k_scale*Gz_ss_era_unscaled.B, Gz_ss_era_unscaled.C, Gz_ss_era_unscaled.D, dt);

%Generate the bode data for this model.
[dbs_era, ps_era] = GetBodeData(Gz_ss_era_scaled, ws_bode);

%Generate the impulse data for this model.
[ys_impulse_era, ts_impulse_era] = impulse(Gz_ss_era_scaled, ts_impulse);

%% Fit the White Noise OKID-ERA System ID.

% %Generate the state space equations associated with the impulse response via the OKID-ERA method.
% [ A_okidera, B_okidera, C_okidera, D_okidera, singular_values_okidera ] = OKIDERA( [0; ys_impulse_smooth], [us_impulse(1) us_impulse]' );
%
% %Create a continuous state space model from the OKID-ERA model.
% Gs_ss_okidera = ss(A_okidera, B_okidera, C_okidera, D_okidera);
%
% %Generate a discrete state space model from the OKID-ERA model.
% Gz_ss_okidera = ss(A_okidera, B_okidera, C_okidera, D_okidera, dt);
%
% %Generate the bode data for this model.
% [bds_okidera, ps_okidera] = GetBodeData(Gz_ss_okidera, ws_bode);
%
% %Generate the impulse response associated with the OKID-ERA model.
% [ys_impulse_okidera, ts_impulse_okidera] = impulse(Gz_ss_okidera, ts_impulse);

%Generate the state space equations associated with the impulse response via the OKID-ERA method.
% [ A_okidera, B_okidera, C_okidera, D_okidera, singular_values_okidera ] = OKIDERA( noise_outputs, noise_inputs, 'rank', 2 );
[ Gz_ss_okidera, singular_values_okidera ] = GDERA( noise_outputs, noise_inputs, 'rank', 2 );

% %Create a continuous state space model from the OKID-ERA model.
% Gs_ss_okidera = ss(A_okidera, B_okidera, C_okidera, D_okidera);
% 
% %Generate a discrete state space model from the OKID-ERA model.
% Gz_ss_okidera = ss(A_okidera, B_okidera, C_okidera, D_okidera, dt);

%Generate the bode data for this model.
[bds_okidera, ps_okidera] = GetBodeData(Gz_ss_okidera, ws_bode);

%Generate the impulse response associated with the OKID-ERA model.
[ys_impulse_okidera, ts_impulse_okidera] = impulse(Gz_ss_okidera, ts_impulse);


%% Plot the OKID & ERA Method Singular Values.

%Compute the normalized cumulative summation of the singular values.
explained_variation_era = 100*cumsum(singular_values_era/sum(singular_values_era));


%Plot the singular values for the ERA method.
figure, subplot(1, 2, 1), hold on, grid on, xlabel('Rank [#]'), ylabel('Singular Value [-]'), title('ERA: Hankle Singular Values vs Rank'), xlim([0 10]), plot(singular_values_era, '.-', 'Markersize', 20, 'Linewidth', 1)
subplot(1, 2, 2), hold on, grid on, xlabel('Rank [#]'), ylabel('Explained Variation [%]'), title('ERA: Variation Explained by Model vs Rank'), xlim([0 10]), plot(0:length(explained_variation_era), [0; explained_variation_era], '.-', 'Markersize', 20, 'Linewidth', 1)

% figure, subplot(1, 2, 1), hold on, grid on, xlabel('Rank [#]'), ylabel('Singular Value [-]'), title('ERA: Singular Values vs Rank'), plot(singular_values_era, '.-', 'Markersize', 20, 'Linewidth', 1)
% subplot(1, 2, 2), hold on, grid on, xlabel('Rank [#]'), ylabel('Singular Value [-]'), title('OKIDERA: Singular Values vs Rank'), plot(singular_values_okidera, '.-', 'Markersize', 20, 'Linewidth', 1)

%% Plot the Bode Data.

%Plot the magnitude response of the filter.
figure, subplot(2, 1, 1), hold on, grid on, set(gca, 'XScale', 'log'), title('Filter: Magnitude Response (OL)'), xlabel('Frequency [Hz]'), ylabel('Magnitude [dB]'), xlim([0 200])
plot(fs_bode, dbs_bode, '.', 'Markersize', 20), plot(fs_bode, dbs_theoretical, '-', 'Linewidth', 1), plot(fs_bode, dbs_fit, '-', 'Linewidth', 1), plot(fs_bode, dbs_era, '-', 'Linewidth', 1), plot(fs_bode, bds_okidera, '-', 'Linewidth', 1)

%Plot the phase response of the filter.
subplot(2, 1, 2), hold on, grid on, set(gca, 'XScale', 'log'), title('Filter: Phase Response (OL)'), xlabel('Frequency [Hz]'), ylabel('Phase [deg]'), xlim([0 200])
plot(fs_bode, ps_bode, '.', 'Markersize', 20), plot(fs_bode, ps_theoretical, '-', 'Linewidth', 1), plot(fs_bode, ps_fit, '-', 'Linewidth', 1), plot(fs_bode, ps_era, '-', 'Linewidth', 1), plot(fs_bode, ps_okidera, '-', 'Linewidth', 1)
legend('Experimental', 'Theoretical', 'Fitted 2nd Order', 'Scaled Discrete ERA', 'Location', 'Best')

%% Plot the Impulse Response.

%Setup a plot for the unscaled impulse response.
figure, hold on, grid on, xlabel('Time Step [#]'), ylabel('Amplitude [-]'), title('Unscaled Impulse Response')
plot(ts_impulse, ys_impulse, '.', 'Markersize', 20)
plot(ts_impulse, ys_impulse_smooth, '-')
plot(ts_impulse_fit, ys_impulse_fit_unscaled)
plot(ts_impulse_era_unscaled, ys_impulse_era_unscaled)
plot(ts_impulse_okidera, ys_impulse_okidera)

legend('Experimental', 'Experimental Smoothed', 'Unscaled Bode Fit', 'Unscaled Discrete ERA', 'Location', 'Best')


%Setup a plot for the scaled impulse response.
figure, hold on, grid on, xlabel('Time Step [#]'), ylabel('Amplitude [-]'), title('Scaled Impulse Response')
plot(ts_impulse_fit, ys_impulse_fit)
plot(ts_impulse_era_unscaled, ys_impulse_era)
plot(ts_impulse_okidera, ys_impulse_okidera)

legend('Scaled Bode Fit', 'Scaled Discrete ERA', 'Location', 'Best')

