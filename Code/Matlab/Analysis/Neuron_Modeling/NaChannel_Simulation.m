%% Na Channel Simulation

% Clear Everything.
clear, close('all'), clc

%% Simulate the Sodium Channel Deactivation Parameter.

% Define simulation properties.
tspan = [0 0.1];
h0 = 0.667;

% Simulate the system.
[ts, ys] = ode45(@NaCh_func, tspan, h0);

[dhdt, Inas, minfs, hinfs, tauhs] = deal( zeros(size(ys)) );

for k = 1:length(ys)
    
    [dhdt(k), Inas(k), minfs(k), hinfs(k), tauhs(k)] = NaCh_func(ts(k), ys(k));
    
end

% Plot the sodium channel deactivation parameter vs time.
fig_NaCh = figure('color', 'w', 'name', 'Na Ch. Deactivation Parameter'); hold on, grid on, xlabel('Time [s]'), ylabel('Na Ch. Deactivation Parameter, h [-]'), title('Na Ch. Deactivation Parameter, h [-] vs Time'), plot(ts, ys)
fig_Ina = figure('color', 'w', 'name', 'Na Ch. Current'); hold on, grid on, xlabel('Time [s]'), ylabel('Na Ch. Current, Ina [A]'), title('Na Ch. Current, Ina [A] vs Time'), plot(ts, Inas)
fig_minfs = figure('color', 'w', 'name', 'Na Ch. Steady State Activation Parameter'); hold on, grid on, xlabel('Time [s]'), ylabel('Na Ch. Steady State Activation Parameter, minf [-]'), title('Na Ch. Steady State Activation Parameter, minf [-] vs Time'), plot(ts, minfs)
fig_hinfs = figure('color', 'w', 'name', 'Na Ch. Steady State Deactivation Parameter'); hold on, grid on, xlabel('Time [s]'), ylabel('Na Ch. Steady State Deactivation Parameter, hinf [-]'), title('Na Ch. Steady State Deactivation Parameter, hinf [-] vs Time'), plot(ts, hinfs)
fig_tauhs = figure('color', 'w', 'name', 'Na Ch. Time Constant'); hold on, grid on, xlabel('Time [s]'), ylabel('Na Ch. Time Constant, tauh [s]'), title('Na Ch. Time Constant, tauh [s] vs Time'), plot(ts, tauhs)


%% Define the Sodium Channel Deactivation Function.

function [dhdt, Ina, minf, hinf, tauh] = NaCh_func(t, h)

% Define the membrane voltage.
V = 0e-3;

Cm = 5e-9;
Gm = 1e-6;

% Define the sodium channel activation parameters.
Am = 1;
Sm = -50;
Em = 20e-3;

% Define the sodium channel deactivation parameters.
Ah = 0.5;
Sh = 50;
Eh = 0;

minf_func = @(V) 1/(1 + Am*exp(Sm*(V - Em)));
hinf_func = @(V) 1/(1 + Ah*exp(Sh*(V - Eh)));

% Define the sodium channel properties.
Ena = 50e-3;
Gna = (Gm*Em)/(minf_func(Em)*hinf_func(Em)*(Ena - Em));

tauhmax = 0.3;

% Compute the steady state sodium channel activation.
minf = minf_func(V);

% Compute the steady state sodium channel deactivation.
hinf = hinf_func(V);

% Compute the sodium channel deactivation time constant.
tauh = tauhmax*hinf*sqrt(Ah*exp(Sh*(V - Eh)));

% Compute the sodium channel current.
Ina = Gna*minf*h*(Ena - V);

% Compute the sodium channel deactivation derivative.
dhdt = (hinf - h)/tauh;

end




