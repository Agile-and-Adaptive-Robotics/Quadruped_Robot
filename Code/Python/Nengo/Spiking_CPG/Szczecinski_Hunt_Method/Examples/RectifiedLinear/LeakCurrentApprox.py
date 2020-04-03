# --------------------------- LEAK CURRENT FUNCTION APPROXIMATION ---------------------------

# This script tests a method of approximating the leak current function.


# --------------------------- IMPORT LIBRARIES ---------------------------

# Import standard python libraries.
import numpy as np
import scipy as sp
import matplotlib.pyplot as plt

# Import nengo libraries.
import nengo
from nengo.processes import Piecewise
import nengo_extras.graphviz as gvz
from graphviz import Source
from nengo.utils.matplotlib import rasterplot
from nengo.dists import Choice
from nengo.utils.ensemble import response_curves, tuning_curves


# --------------------------- DEFINE THE CPG PARAMETERS ---------------------------

# Define the voltage range over which the CPG will oscillator over.
R = 20e-3                       # [V] Biphasic Equilibrium Voltage Range.

# Define membrane properties.
Cm = 5e-9                      # [F] Membrane Capacitance.
Gm = 1e-6                      # [S] Membrane Conductance.
Er = -60e-3                    # [V] Membrane Reversal Potential.

# Define synapse properties.
Elo = Er                        # [V] Synapse Voltage Lower Bound.
Ehi = Elo + R                   # [V] Synapse Voltage Upper Bound.
Es = -100e-3                    # [V] Synaptic Reversal Potential.
Es_tilde = Es - Er              # [V] Synaptic Reversal Potential w.r.t Membrane Reversal Potential.
delta = 0.01e-3                 # [V] Voltage Difference Between Inhibited Neuron's Equilibrium Potential & the Presynaptic Threshold.

# Define sodium channel activation properties.
Am = 1                          # [-] First Sodium Channel Activation Parameter.
Sm = -50                        # [1/V] Second Sodium Channel Activation Parameter.
Em = Ehi                        # [V] Third Sodium Channel Activation Parameter.
Em_tilde = Em - Er              # [V] Third Sodium Channel Activation Parameter w.r.t Membrane Reversal Potential.

# Define sodium channel deactivation properties.
Ah = 0.5                        # [-] First Sodium Channel Deactivation Parameter.
Sh = 50                         # [1/V] Second Sodium Channel Deactivation Parameter.
Eh = Elo                        # [V] Third Sodium Channel Deactivation Parameter.
Eh_tilde = Eh - Er              # [V] Third Sodium Channel Deactivation Parameter w.r.t Membrane Reversal Potential.

# Define the steady state sodium channel activation & deactivation parameters.
minf_func = lambda U:  1/(1 + Am*np.exp(-Sm*(Em_tilde - U)))            # [-] Lambda Function for the Steady State Sodium Channel Activation Parameter.
hinf_func = lambda U: 1/(1 + Ah*np.exp(-Sh*(Eh_tilde - U)))             # [-] Lambda Function for the Steady State Sodium Channel Deactivation Parameter.

# Define the sodium channel reversal potential.
Ena = 50e-3                 # [V] Sodium Channel Reversal Potential.
Ena_tilde = Ena - Er        # [V] Sodium Channel Reversal Potential With Respect to the Resting Potential.

# Compute the sodium channel conductance.
Gna = (Gm*R)/(minf_func(R)*hinf_func(R)*(Ena_tilde - R))       # [S] Sodium Channel Conductance.

# Define the maximum & minimum sodium channel time constant.
tauhmax = 0.3               # [s] Maximum Sodium Channel Time Constant.
tauhmin = tauhmax/100       # [s] Minimum Sodium Channel Time Constant.

# Define a function to compute the sodium channel deactivation time constant.
tauh_func = lambda U: tauhmax*hinf_func(U)*np.sqrt(Ah*np.exp(-Sh*(Eh_tilde - U)))        # [s] Sodium Channel Time Constant.

# Compute the maximum synaptic conductance.
gsynmax = (-delta*(10**(-6)) - delta*Gna*minf_func(delta)*hinf_func(delta) + Gna*minf_func(delta)*hinf_func(delta)*Ena_tilde)/(delta - Es_tilde)

# Define the network initial conditions.
U0 = 0                      # [V] Initial Membrane Voltage w.r.t. Resting Potential.
# h0 = hinf_func(U0)          # [-] Initial Sodium Channel Deactivation Parameter.
h0 = 0          # [-] Initial Sodium Channel Deactivation Parameter.


# --------------------------- DEFINE NETWORK PROPERTIES ---------------------------

# Define simulation properties.
dt_sim = 0.001                                                      # [s] Simulation Step Size.
t_sim_duration = 3                                                  # [s] Total Simulation Duration.

# Define the LIF amplitude.
LIF_amplitude = 0.001

# Define the membrane voltage ensemble properties.
U_neurons = 100
U_dimensions = 1
U_radius = 2*R

# Define the leak current ensemble properties.
Ileak_neurons = 100
Ileak_dimensions = 1
Ileak_radius = 80e-9

# Define network properties.
seed = 0                                                            # [-] Seed for Random Number Generation.
# tau_synapse = 0.001                                                 # [s] Post-Synaptic Time Constant.
tau_synapse = None                                                 # [s] Post-Synaptic Time Constant.
tau_probe = 0.1                                                     # [s] Probe Time Constant.

# --------------------------- DEFINE THE FUNCTIONS TO APPROXIMATE ---------------------------

# Define the input function.
def input_func(x):

    # Return the desired function.
    return R*(x - 1)

# Define a function to compute the leak current.
def leak_current_func(x):

    # Return the leak current.
    return -Gm*x


# --------------------------- COMPUTE THE GROUND TRUTH SIMULATIONS RESULTS ---------------------------

# Compute the ground truth simulation results.
ts_true = np.arange(0, t_sim_duration, dt_sim)
input_true = input_func(ts_true)
Us_true = input_true
Ileak_true = leak_current_func(Us_true)


# --------------------------- BUILD THE NETWORK ---------------------------

# Create the nengo network object.
network = nengo.Network()

# Define the network properties.
network.config[nengo.Ensemble].neuron_type = nengo.LIF(amplitude=LIF_amplitude)  # [-] Sets the neuron model to LIF.

# Build the network.
with network:

    # -------------------- Create the Network Components --------------------

    input_node = nengo.Node(output=input_func, label='Input Node')
    U_ens = nengo.Ensemble(n_neurons=U_neurons, dimensions=U_dimensions, radius=U_radius, seed=seed, label='U_ens')
    Ileak_ens = nengo.Ensemble(n_neurons=Ileak_neurons, dimensions=Ileak_dimensions, radius=Ileak_radius, label='I_leak')
    # Ileak_ens = nengo.Ensemble(n_neurons=Ileak_neurons, dimensions=Ileak_dimensions, radius=Ileak_radius, label='I_leak', neuron_type=nengo.Direct())
    output_node = nengo.Node(output=None, size_in=1, label='Output Node')

    # -------------------- Connect the Network Components --------------------

    nengo.Connection(input_node, U_ens, synapse=tau_synapse)
    nengo.Connection(U_ens, Ileak_ens, synapse=tau_synapse, function=leak_current_func)
    nengo.Connection(Ileak_ens, output_node, synapse=tau_synapse)

    # -------------------- Collect Data From the Network --------------------

    input_probe = nengo.Probe(input_node, synapse=tau_probe)
    U_probe = nengo.Probe(U_ens, synapse=tau_probe)
    Ileak_probe = nengo.Probe(Ileak_ens, synapse=tau_probe)
    Ileak_probe_nofilt = nengo.Probe(Ileak_ens)

# Generate the contents of a .dot file that describes the network.
network_contents = gvz.net_diagram(network)

# Create a graphviz document using the network contents.
gvz_source = Source(network_contents, filename="network_diagram", format="jpg")


# --------------------------- SIMULATE THE NETWORK ---------------------------

# Simulate the network.
with nengo.Simulator(network=network, dt=dt_sim) as sim:

    # Run the simulation.
    sim.run(t_sim_duration)

    # # Retrieve the tuning curve data.
    # gsyn_evals, gsyn_activites = tuning_curves(gsyn_ens, sim)

# Retrieve the untrained simulation results.
ts_untrained = sim.trange()
input_untrained = sim.data[input_probe]
Us_untrained = sim.data[U_probe]
Ileak_untrained = sim.data[Ileak_probe]


# --------------------------- PLOT THE NETWORK RESULTS ---------------------------

# Set plot properties.
plt.rc('text', usetex=True)

# Plot the network input.
plt.figure(); plt.xlabel(r'Time [s]'); plt.ylabel(r'Input [-]'); plt.title(r'Network Input vs Time')
plt.plot(ts_untrained, input_untrained, label=r'Input Node')
plt.plot(ts_true, input_true, label=r'Input True')
plt.legend()

# Plot the membrane voltage.
plt.figure(); plt.xlabel(r'Time [s]'); plt.ylabel(r'Membrane Voltage, $U$ [V]'); plt.title(r'Membrane Voltage $U$ vs Time')
plt.plot(ts_untrained, Us_untrained, label=r'$U$ Untrained')
plt.plot(ts_true, Us_true, label=r'$U$ True')
plt.legend()

# Plot the synaptic current.
fig, axs = plt.subplots(2, 1)
axs[0].set_xlabel(r'Time [s]'); axs[0].set_ylabel(r'Leak Current, $I_{leak}$ [A]'); axs[0].set_title(r'$I_{leak}$ vs Time')
axs[0].plot(ts_untrained, Ileak_untrained, label=r'$I_{leak}$ Untrained')
axs[0].plot(ts_true, Ileak_true, label=r'$I_{leak}$ True')
axs[0].legend()
axs[1].set_xlabel(r'Membrane Voltage, $U$ [V]'); axs[1].set_ylabel(r'Leak Current, $I_{leak}$ [A]'); axs[1].set_title(r'$I_{leak}$ vs Membrane Voltage')
axs[1].plot(Us_untrained, Ileak_untrained, label=r'$I_{leak}$ Untrained')
axs[1].plot(Us_true, Ileak_true, label=r'$I_{leak}$ True')
axs[1].legend()


# # Show the network.
# gvz_source.view()

# Display the figures.
plt.show()


