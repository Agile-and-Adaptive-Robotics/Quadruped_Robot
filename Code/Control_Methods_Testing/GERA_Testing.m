%% Generalized Eigensystem Realization Algorithm Testing

%Clear Everything
clear, close('all'), clc


%% Define the System of Interest.

%Define the system parameters.
zeta = 0.25; wn = 2*pi*10; dt = 0.01;

%Define the actual system transfer function.
s = tf('s');
Gs_tf_actual = (wn^2)/(s^2 + (2*zeta*wn)*s + (wn^2));
% Gs_tf_actual = (wn^2)/(s*(s^2 + (2*zeta*wn)*s + (wn^2)));

%Convert the continuous transfer function to a digital transfer function.
Gs_ss_actual = ss(Gs_tf_actual);

%Convert the digital transfer function to a digital state space system.
Gz_ss_actual = c2d(Gs_ss_actual, dt);

%Compute the number of inputs and outputs.
num_inputs = size(Gz_ss_actual.B, 2); num_outputs = size(Gz_ss_actual.C, 1);

%% Define Simulation Parameters.

%Define the simulation time step and duration.
t_final = 5;

%Define the time vector for the impulse and step responses.
ts = 0:dt:t_final;

%Retrieve the number of data points in the simulation.
num_data_points = length(ts);

%Define the frequency range of interest for the frequency response simulations.
fs = logspace(-1, 2, 100); ws = 2*pi*fs;


%% Generate the Actual Impulse, Step, and Frequency Response.

%Generate the impulse response.
ys_impulse = impulse(Gz_ss_actual, ts);

%Generate the step response.
ys_step = step(Gz_ss_actual, ts);

% Generate the frequency response for the system.
[dbs, ps] = GetBodeData(Gz_ss_actual, ws);

%% Generate the ERA System Approximation.

%Generate the ERA system matrices.
[ Gz_ss_era, singular_values_era ] = DERA(ys_impulse, dt);

%Generate the impulse response from the ERA system approximation.
ys_impulse_era = impulse(Gz_ss_era, ts);

%Generate the step response from the ERA system approximation.
ys_step_era = step(Gz_ss_era, ts);

%Generate the frequency response for the ERA system.
[dbs_era, ps_era] = GetBodeData(Gz_ss_era, ws);

%% Apply the OKID Method to Generate an Approximate Impulse Response from an Arbitrary Input / Output Response.

%Define the level of noise to use.
noise_level = 0.05;
% noise_level = 0;

%Define a random system input.
% us_arb = randn(num_inputs, num_data_points);
% us_arb = ones(1, num_data_points);
us_arb = [0 ones(1, 100) zeros(1, 100) ones(1, 100) zeros(1, 100) ones(1, 100)];

%Compute the associated true system output.
ys_arb = lsim(Gz_ss_actual, us_arb, ts)';

%Add noise to the true system output.
ys_arb_clean = ys_arb;
ys_arb = ys_arb + noise_level*range(ys_arb)*(rand(size(ys_arb)) - 0.5);

%Generate the hankle matrix associated with the system input.
U = GetHankleMatrix( us_arb );

%Approximate the impulse response.
ys_impulse_okid = (ys_arb*pinv(U))/dt;


%% Apply ERA to the OKID Reconstructed Impulse Response.

%Generate the ERA system matrices.
% [ Gz_ss_okidera, singular_values_okidera ] = DERA(ys_impulse_okid', dt);
[ Gz_ss_okidera, singular_values_okidera ] = GDERA( ys_arb, us_arb, dt );

%Generate the impulse response from the ERA system approximation.
ys_impulse_okidera = impulse(Gz_ss_okidera, ts);

%Generate the step response from the ERA system approximation.
ys_step_okidera = step(Gz_ss_okidera, ts);

%Generate the frequency response for the ERA system.
[dbs_okidera, ps_okidera] = GetBodeData(Gz_ss_okidera, ws);

%% Plot the OKID System Input & Output.

%Plot the OKID System Input and Output.
figure, subplot(1, 2, 1), hold on, grid on, xlabel('Time [s]'), ylabel('Amplitude [-]'), title('System Input: Amplitude vs Time'), stairs(ts, us_arb)
subplot(1, 2, 2), hold on, grid on, xlabel('Time [s]'), ylabel('Amplitude [-]'), title('System Output: Amplitude vs Time'), stairs(ts, ys_arb_clean), stairs(ts, ys_arb)
legend('Actual Output', 'Noisy Output', 'Location', 'Best')

%% Plot the Frequency Response.

%Plot the magnitude response.
figure, subplot(2, 1, 1), hold on, grid on, set(gca, 'XScale', 'log'), xlabel('Frequency [Hz]'), ylabel('Magnitude [dB]'), title('Magnitude Response')
plot(fs, dbs), plot(fs, dbs_era), plot(fs, dbs_okidera)

%Plot the phase response.
subplot(2, 1, 2), hold on, grid on, set(gca, 'XScale', 'log'), xlabel('Frequency [Hz]'), ylabel('Phase [deg]'), title('Phase Response')
plot(fs, ps), plot(fs, ps_era), plot(fs, ps_okidera)
legend('Actual', 'ERA', 'OKIDERA', 'Location', 'Best')

%% Plot the Impulse Response.

%Plot the impulse response.
figure, hold on, grid on, xlabel('Time [s]'), ylabel('Amplitude [-]'), title('Impulse Response')%, ylim([0 1.6])
stairs(ts, ys_impulse), stairs(ts, ys_impulse_era), stairs(ts, ys_impulse_okid), stairs(ts, ys_impulse_okidera)
legend('Actual', 'ERA', 'OKID', 'OKIDERA', 'Location', 'Best')

%% Plot the Step Response.

%Plot the step response.
figure, hold on, grid on, xlabel('Time [s]'), ylabel('Amplitude [-]'), title('Step Response'), xlim([0 1])
stairs(ts, ys_step), stairs(ts, ys_step_era), stairs(ts, ys_step_okidera)
legend('Actual', 'ERA', 'OKIDERA', 'Location', 'Best')

