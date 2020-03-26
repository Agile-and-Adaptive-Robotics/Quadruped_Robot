# --------------------------- SYNAPTIC CURRENT FUNCTION APPROXIMATION ---------------------------

# This script tests a method of approximating the synaptic current function.


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

# Define the synaptic conductance ensemble properties.
gsyn_neurons = 100
gsyn_dimensions = 1
gsyn_radius = 2*gsynmax

# Define the synaptic current multiplexer ensemble properties.
MUXsyn_neurons = 100
MUXsyn_dimensions = 2
MUXsyn_radius = 1

# Define the synaptic current ensemble properties.
Isyn_neurons = 100
Isyn_dimensions = 1
Isyn_radius = 75e-9

# Define network properties.
seed = 0                                                            # [-] Seed for Random Number Generation.
tau_synapse = 0.001                                                 # [s] Post-Synaptic Time Constant.
tau_probe = 0.1                                                     # [s] Probe Time Constant.

# --------------------------- DEFINE THE FUNCTIONS TO APPROXIMATE ---------------------------

# Define the input function.
def input_func(x):

    # Return the desired function.
    return R*(x - 1)

# Define the synaptic conductance function.
def synaptic_conductance_func(x):

    # Return the first rectified linear function.
    return gsynmax*np.minimum(np.maximum(x/R, 0), 1)

# Define a function to compute the synaptic current.
def synapse_current_func(x):

    # Retrieve the components of the input vector.
    U, Gsi = x

    # Compute the synaptic current.
    return (Gsi*gsyn_radius)*(Es_tilde - (U*U_radius))

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
    gsyn_ens = nengo.Ensemble(n_neurons=gsyn_neurons, dimensions=gsyn_dimensions, radius=gsyn_radius, seed=seed, label='gsyn Ensemble')
    MUXsyn_ens = nengo.Ensemble(MUXsyn_neurons, dimensions=MUXsyn_dimensions, radius=MUXsyn_radius, seed=seed, label='MUXsyn Ensemble')
    # MUXsyn_ens = nengo.Ensemble(MUXsyn_neurons, dimensions=MUXsyn_dimensions, radius=MUXsyn_radius, seed=seed, label='MUXsyn Ensemble', neuron_type=nengo.Direct())
    Isyn_ens = nengo.Ensemble(n_neurons=Isyn_neurons, dimensions=Isyn_dimensions, radius=Isyn_radius, seed=seed, label='Isyn Ensemble')
    output_node = nengo.Node(output=None, size_in=1, label='Output Node')

    # -------------------- Connect the Network Components --------------------

    nengo.Connection(input_node, U_ens, synapse=tau_synapse)
    nengo.Connection(U_ens, gsyn_ens, synapse=tau_synapse, function=synaptic_conductance_func)
    nengo.Connection(U_ens, MUXsyn_ens[0], synapse=tau_synapse, transform=1/U_radius)
    nengo.Connection(gsyn_ens, MUXsyn_ens[1], synapse=tau_synapse, transform=1/gsyn_radius)
    nengo.Connection(MUXsyn_ens, Isyn_ens, synapse=tau_synapse, function=synapse_current_func)
    nengo.Connection(Isyn_ens, output_node, synapse=tau_synapse)

    # -------------------- Collect Data From the Network --------------------

    input_probe = nengo.Probe(input_node, synapse=tau_probe)
    U_probe = nengo.Probe(U_ens, synapse=tau_probe)
    gsyn_probe = nengo.Probe(gsyn_ens, synapse=tau_probe)
    MUXsyn_probe = nengo.Probe(MUXsyn_ens, synapse=tau_probe)
    Isyn_probe = nengo.Probe(Isyn_ens, synapse=tau_probe)
    output_probe = nengo.Probe(output_node, synapse=tau_probe)

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


# --------------------------- PLOT THE NETWORK RESULTS ---------------------------

# Set plot properties.
plt.rc('text', usetex=True)

# Plot the network input.
plt.figure(); plt.xlabel(r'Time [s]'); plt.ylabel(r'Input [-]'); plt.title(r'Network Input vs Time')
plt.plot(sim.trange(), sim.data[input_probe], label=r'Input')

# Plot the membrane voltage.
plt.figure(); plt.xlabel(r'Time [s]'); plt.ylabel(r'Membrane Voltage, $U$ [V]'); plt.title(r'Membrane Voltage $U$ vs Time')
plt.plot(sim.trange(), sim.data[U_probe], label=r'$U$')

# Plot the synaptic conductance.
plt.figure(); plt.xlabel(r'Time [s]'); plt.ylabel(r'Synaptic Conductance, $g_{syn}$ [S]'); plt.title(r'Synaptic Conductance $g_{syn}$ vs Time')
plt.plot(sim.trange(), sim.data[gsyn_probe], label=r'$g_{syn}$')

# Plot the synaptic current multiplexer.
plt.figure(); plt.xlabel(r'Time [s]'); plt.ylabel(r'Synaptic Current Multiplexer, $MUX_{syn}$ [-]'); plt.title(r'Synaptic Current Multiplexer $MUX_{syn}$ vs Time')
plt.plot(sim.trange(), sim.data[MUXsyn_probe][:, 0], label=r'$U$')
plt.plot(sim.trange(), sim.data[MUXsyn_probe][:, 1], label=r'$g_{syn}$')
plt.legend()

plt.figure(); plt.xlabel(r'Time [s]'); plt.ylabel(r'Synaptic Current Multiplexer, $MUX_{syn}$ [-]'); plt.title(r'Synaptic Current Multiplexer $MUX_{syn}$ vs Time')
plt.plot(sim.trange(), sim.data[MUXsyn_probe][:, 0], label=r'$U$')
plt.plot(sim.trange(), sim.data[MUXsyn_probe][:, 1], label=r'$g_{syn}$')
plt.legend()

fig, axs = plt.subplots(2, 1)
axs[0].set_xlabel('Time [s]'); axs[0].set_ylabel('Membrane Voltage, $U$ [V]'); axs[0].set_title(r'Membrane Voltage, $U$ vs Time')
axs[0].plot(sim.trange(), sim.data[MUXsyn_probe][:, 0], label=r'$U$')
axs[0].legend()
axs[1].set_xlabel('Time [s]'); axs[1].set_ylabel('Synaptic Conductance, $g_{syn}$ [S]'); axs[1].set_title(r'Synaptic Conductance, $g_{syn}$ vs Time')
axs[1].plot(sim.trange(), sim.data[MUXsyn_probe][:, 1], label=r'$g_{syn}$')
axs[1].legend()

# Plot the synaptic current.
plt.figure(); plt.xlabel(r'Time [s]'); plt.ylabel(r'Output [-]'); plt.title(r'$I_{syn}$ vs Time')
plt.plot(sim.trange(), sim.data[Isyn_probe], label=r'$I_{syn}$')

# # Plot the tuning curves associated with the second rectified linear ensemble.
# plt.figure(); plt.xlabel('Input [-]'); plt.ylabel('Firing Frequency [Hz]'); plt.title('Firing Frequency vs Input')
# plt.plot(gsyn_evals, gsyn_activites)



# # Show the network.
# gvz_source.view()

# Display the figures.
plt.show()


