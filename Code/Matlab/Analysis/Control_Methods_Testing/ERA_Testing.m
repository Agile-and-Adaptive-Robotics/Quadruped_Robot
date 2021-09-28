%% Testing Script.

%Clear Everything
clear, close('all'), clc

%% Define the Actual System to Study.

%Define the system parameters.
zeta = 0.25; wn = 2*pi*10; dt = 0.01;

%Define the actual system transfer function.
s = tf('s');
% Gs_tf_actual = (wn^2)/(s^2 + (2*zeta*wn)*s + (wn^2));
Gs_tf_actual = (wn^2)/(s*(s^2 + (2*zeta*wn)*s + (wn^2)));

%Convert the continuous transfer function to a digital transfer function.
Gs_ss_actual = ss(Gs_tf_actual);

%Convert the digital transfer function to a digital state space system.
Gz_ss_actual = c2d(Gs_ss_actual, dt);

%Compute the number of inputs and outputs.
num_inputs = size(Gz_ss_actual.B, 2); num_outputs = size(Gz_ss_actual.C, 1);

%% Compute the Impulse Response of the Actual System.

%Set the impulse final time.
t_final = 0.5;

%Compute the impulse response.
[ys_impulse_actual, ts_impulse_actual] = impulse(Gz_ss_actual, t_final);

%% Compute the Pseudorandom Response of the Actual System.

%Define the level of noise to use.
noise_level = 0.01;
% noise_level = 0;

%Create a time vector for simulation and plotting.
ts = 0:dt:t_final;

%Define a random system input.
us_random = randn(num_inputs, length(ts));

%Compute the associated true system output.
ys_random_actual = lsim(Gz_ss_actual, us_random, ts)';

%Add noise to the true system output.
ys_random_actual_noisy = ys_random_actual + noise_level*range(ys_random_actual)*(rand(size(ys_random_actual)) - 0.5);

%% Perform the Eigensystem Realization Algorithm (ERA) Using the Impulse Response Data.

%Perform the ERA.
[A_era, B_era, C_era, D_era, singular_values_era] = ERA(ys_impulse_actual);

%Retrieve the number of singular values.
num_singular_values_era = length(singular_values_era);

%Define continuous ERA system.
Gs_ss_ERA = ss(A_era, B_era, C_era, D_era);

%Define the discrete ERA system.
Gz_ss_ERA = ss(A_era, B_era, dt*C_era, dt*D_era, dt);

%Retrieve the continuous impulse response.
[ys_impulse_ERA_cont, ts_impulse_ERA_cont] = impulse(Gs_ss_ERA, t_final);

%Retrieve the discrete impulse response.
[ys_impulse_ERA, ts_impulse_ERA] = impulse(Gz_ss_ERA, t_final);

%% Perform the ERA on the OKID Impulse Reconstruction of from Pseudorandom Data.

%Compute the desired rank.
desired_rank = floor(0.8*length(us_random));
% desired_rank = 3;

%Construct an impulse response from the pseudorandom input.
ys_impulse_okid = OKID(ys_random_actual_noisy, us_random, desired_rank);
ys_impulse_okid = permute(ys_impulse_okid, [3 1 2]);

%Create the time vector associated with the reconstructed okid impulse data.
ts_impulse_okid = 0:dt:(dt*(length(ys_impulse_okid) - 1));

%Perform the ERA on the OKID impulse reconstruction data.
[A_okidera, B_okidera, C_okidera, D_okidera, singular_values_okidera] = ERA(ys_impulse_okid);

% [ A_okidera, B_okidera, C_okidera, D_okidera, singular_values_okidera ] = OKIDERA( ys_random_actual_noisy, us_random );

%Retrieve the number of singular values.
num_singular_values_okidera = length(singular_values_okidera);

%Define the OKID-ERA system.
Gz_ss_OKIDERA = ss(A_okidera, B_okidera, C_okidera, D_okidera, dt);

%Retrieve the impulse response.
[ys_impulse_OKIDERA, ts_impulse_OKIDERA] = impulse(Gz_ss_OKIDERA, t_final);


%% Plot the Results.

%Plot the hankle matrix singular values.
figure, hold on, grid on, xlabel('Singular Value Number [#]'), ylabel('Singular Value [-]'), title('Hankle Matrix Singular Values: ERA'), plot(1:num_singular_values_era, singular_values_era, '.-', 'Markersize', 10)
figure, hold on, grid on, xlabel('Singular Value Number [#]'), ylabel('Singular Value [-]'), title('Hankle Matrix Singular Values: OKID-ERA'), plot(1:num_singular_values_okidera, singular_values_okidera, '.-', 'Markersize', 10)

%Plot the bode diagrams.
figure, bode(Gz_ss_actual, Gz_ss_ERA, Gz_ss_OKIDERA)
legend('Actual System', 'ERA System', 'OKID-ERA System')

%Plot the impulse response used to create the OKID-ERA system.
figure, hold on, grid on, xlabel('Time [s]'), ylabel('System Output [-]'), title('Impulse Response')
stairs(ts_impulse_okid, ys_impulse_okid)

%Plot the impulse response.
figure, hold on, grid on, xlabel('Time [s]'), ylabel('System Output [-]'), title('Impulse Response')
stairs(ts_impulse_actual, ys_impulse_actual), stairs(ts_impulse_ERA, ys_impulse_ERA), stairs(ts_impulse_OKIDERA, ys_impulse_OKIDERA), plot(ts_impulse_ERA_cont, ys_impulse_ERA_cont)
legend('Actual System', 'ERA System', 'OKID-ERA System', 'Continuous ERA')

%Plot the pseudorandom response.
figure, subplot(1, 2, 1), hold on, grid on, xlabel('Time [s]'), ylabel('Random Input [-]'), title('Random Input vs Time'), xlim([0 t_final]), stairs(ts, us_random)
subplot(1, 2, 2), hold on, grid on, xlabel('Time [s]'), ylabel('Random Input [-]'), title('Random Output vs Time'), xlim([0 t_final])
stairs(ts, ys_random_actual), stairs(ts, ys_random_actual_noisy)
legend('True System Output', 'Noisy System Output')

