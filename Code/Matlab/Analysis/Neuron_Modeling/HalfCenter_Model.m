%% Half Center Neuron Model

% Clear Everything.
clear, close('all'), clc

%% Define the Half Center Neuron Properties.

% Define membrane properties.
Cm = 1;
Gm = 1;
Er = 1;

% Define synapse properties.
Vprei = 1;
Eloi = 0;
Ehii = 1;
gimax = 1;
Esi = 1;

% Define sodium channel properties.
Am = 1; Sm = 1; Em = 1;
Ah = 1; Sh = 1; Eh = 1;
Gna = 1;
Ena = 1;
tauhmax = 1;

%% Define Functions for Computing Components of the ODE.





%% Simulate the System.

% Define the simulation properties.
tf = 10;
V0 = 0;
h0 = 0;

% Simulate the system.
[ts, ys] = ode45(@HalfCenter, [0 tf], [V0; h0]);

%% Plot the System Response.

% Plot the system response.
fig = figure('color', 'w', 'name', 'Half Center Neuron Simulation'); hold on, grid on, xlabel('Time [s]'), ylabel('Membrane Voltage [V]'), title('Membrane Voltage vs Time')
plot(ts, ys, '-', 'Linewidth', 3)
legend('Membrane Voltage, V', 'Na Ch. Deactivation, h', 'Location', 'South', 'Orientation', 'Horizontal')

%% Define the System Dynamics.

function dxdt = HalfCenter(t, x)

% Retrieve the components of the input vector.
V = x(1); h = x(2);

% Define membrane properties.
Cm = 1;
Gm = 1;
Er = 1;

% Define synapse properties.
Vprei = 1;
Eloi = 0;
Ehii = 1;
gimax = 1;
Esi = 1;

% Define sodium channel properties.
Am = 1; Sm = 1; Em = 1;
Ah = 1; Sh = 1; Eh = 1;
Gna = 1;
Ena = 1;
tauhmax = 1;

% Compute the synapse conductance.
Gsi = gimax*min(max((Vprei - Eloi)/(Ehii - Eloi), 0), 1);

% Compute the steady state sodium channel activation and deactivation parameters.
minf = 1/(1 + Am*exp(Sm*(V - Em)));
hinf = 1/(1 + Ah*exp(Sh*(V - Eh)));

% Compute the sodium channel deactivation time constant.
tauh = tauhmax*hinf*sqrt(Ah*exp(Sh*(V - Eh)));

% Compute the leak current.
Ileak = Gm*(Er - V);

% Compute the synaptic current.
Isyn = Gsi*(Esi - V);

% Compute the sodium current.
Ina = Gna*minf*h*(Ena - V);

% Compute the total current.
Itotal = Ileak + Isyn + Ina;

% Compute the membrane voltage derivative.
dVdt = Itotal/Cm;

% Compute the sodium channel deactivation derivative.
dhdt = (hinf - h)/tauh;

% Compute the state derivative.
dxdt = [dVdt; dhdt];

end





