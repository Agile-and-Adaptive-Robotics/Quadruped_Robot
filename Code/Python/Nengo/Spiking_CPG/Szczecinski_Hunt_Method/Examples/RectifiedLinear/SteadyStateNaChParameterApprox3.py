# --------------------------- SYNAPTIC CONDUCTANCE FUNCTION APPROXIMATION ---------------------------

# This script tests a methods of approximating the synaptic conductance function.


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
minf_func = lambda U: 1/(1 + Am*np.exp(-Sm*(Em_tilde - U)))             # [-] Lambda Function for the Steady State Sodium Channel Activation Parameter.
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
t_sim_duration = 1                                                  # [s] Total Simulation Duration.

# Define the LIF amplitude.
LIF_amplitude = 0.001

# Define the membrane voltage ensemble properties.
U_neurons = 5000
U_dimensions = 1
U_radius = 6*R

# Define the steady state sodium channel activation parameter ensemble properties.
minf_neurons = 100
minf_dimensions = 1
minf_radius = 150

# Define the steady state sodium channel deactivation parameter ensemble properties.
hinf_neurons = 100
hinf_dimensions = 1
hinf_radius = 200

# Define network properties.
seed = 0                                                            # [-] Seed for Random Number Generation.
tau_synapse = 0.001                                                 # [s] Post-Synaptic Time Constant.
tau_probe = 0.1                                                     # [s] Probe Time Constant.

# Define the input function.
def input_func(x):

    # Return the desired function.
    return 10*R*x - 4*R

# Define the steady state sodium channel activation function.
def NaCh_Act_func(x):

    # Return the steady state sodium channel activation.
    return Am*np.exp(-Sm*(Em_tilde - x))
    # return 1/(1 + Am*np.exp(-Sm*(Em_tilde - x)))
    # return np.minimum(np.maximum(12.5*(x + 0.02), 0), 1)

# Define the steady state sodium channel deactivation function.
def NaCh_Deact_func(x):

    # Return the steady state sodium channel deactivation.
    return Ah*np.exp(-Sh*(Eh_tilde - x))
    # return 1/(1 + Ah*np.exp(-Sh*(Eh_tilde - x)))
    # return np.minimum(np.maximum(-12.5*(x - 0.0538629436111989), 0), 1)


# --------------------------- BUILD THE NETWORK ---------------------------

# Create the nengo network object.
network = nengo.Network()

# Define the network properties.
network.config[nengo.Ensemble].neuron_type = nengo.LIF(amplitude=LIF_amplitude)  # [-] Sets the neuron model to LIF.

# Build the network.
with network:

    # -------------------- Create the Network Components --------------------

    input_node = nengo.Node(output=input_func, label='Input Node')
    U_ens = nengo.Ensemble(n_neurons=U_neurons, dimensions=U_dimensions, radius=U_radius, seed=seed, label='U Ensemble')

    minf_ens = nengo.Ensemble(n_neurons=minf_neurons, dimensions=minf_dimensions, radius=minf_radius, seed=seed, label='minf Ensemble')
    hinf_ens = nengo.Ensemble(n_neurons=hinf_neurons, dimensions=hinf_dimensions, radius=hinf_radius, seed=seed, label='minf Ensemble')

    minf_node = nengo.Node(output=None, size_in=1, label='minf Node')
    hinf_node = nengo.Node(output=None, size_in=1, label='hinf Node')

    minf_direct = nengo.Node(output=None, size_in=1, label='minf Direct')
    hinf_direct = nengo.Node(output=None, size_in=1, label='hinf Direct')

    # -------------------- Connect the Network Components --------------------

    nengo.Connection(input_node, U_ens, synapse=tau_synapse)

    nengo.Connection(U_ens, minf_ens, synapse=tau_synapse, function=NaCh_Act_func)
    nengo.Connection(U_ens, hinf_ens, synapse=tau_synapse, function=NaCh_Deact_func)

    nengo.Connection(U_ens, minf_node, synapse=tau_synapse, function=NaCh_Act_func)
    nengo.Connection(U_ens, hinf_node, synapse=tau_synapse, function=NaCh_Deact_func)

    nengo.Connection(input_node, minf_direct, synapse=tau_synapse, function=NaCh_Act_func)
    nengo.Connection(input_node, hinf_direct, synapse=tau_synapse, function=NaCh_Deact_func)

    # -------------------- Collect Data From the Network --------------------

    input_probe = nengo.Probe(input_node, synapse=tau_probe)
    U_probe = nengo.Probe(U_ens, synapse=tau_probe)

    minf_probe = nengo.Probe(minf_ens, synapse=tau_probe)
    hinf_probe = nengo.Probe(hinf_ens, synapse=tau_probe)

    minf_node_probe = nengo.Probe(minf_node, synapse=tau_probe)
    hinf_node_probe = nengo.Probe(hinf_node, synapse=tau_probe)

    minf_direct_probe = nengo.Probe(minf_direct, synapse=tau_probe)
    hinf_direct_probe = nengo.Probe(hinf_direct, synapse=tau_probe)

# Generate the contents of a .dot file that describes the network.
network_contents = gvz.net_diagram(network)

# Create a graphviz document using the network contents.
gvz_source = Source(network_contents, filename="network_diagram", format="jpg")

# --------------------------- SIMULATE THE NETWORK ---------------------------

# Simulate the network.
with nengo.Simulator(network=network, dt=dt_sim) as sim:

    # Run the simulation.
    sim.run(t_sim_duration)

    # Retrieve the tuning curve data.
    minf_evals, minf_activites = tuning_curves(minf_ens, sim)
    hinf_evals, hinf_activites = tuning_curves(hinf_ens, sim)


# --------------------------- PLOT THE NETWORK RESULTS ---------------------------

# Set plot properties.
plt.rc('text', usetex=True)

# Plot the network input and output.
plt.figure(); plt.xlabel(r'Time [s]'); plt.ylabel(r'Input [-]'); plt.title(r'Network Input vs Time')
plt.plot(sim.trange(), sim.data[input_probe], label=r'Input')

plt.figure(); plt.xlabel(r'Time [s]'); plt.ylabel(r'Na Ch Activation, $m_{\infty}$ [-]'); plt.title(r'$m_{\infty}$ Na Ch Activation vs Time')
plt.plot(sim.trange(), sim.data[minf_probe])

plt.figure(); plt.xlabel(r'Time [s]'); plt.ylabel(r'Na Ch Deactivation, $h_{\infty}$ [-]'); plt.title(r'$h_{\infty}$ Na Ch Deactivation vs Time')
plt.plot(sim.trange(), sim.data[hinf_probe])

plt.figure(); plt.xlabel(r'Membrane Voltage, $U$ [V]'); plt.ylabel(r'Na Ch Activation, $m_{\infty}$ [-]'); plt.title(r'$m_{\infty}$ Na Ch Activation vs $U$ Membrane Voltage')
plt.plot(sim.data[input_probe], sim.data[minf_probe])

plt.figure(); plt.xlabel(r'Membrane Voltage, $U$ [V]'); plt.ylabel(r'Na Ch Deactivation, $h_{\infty}$ [-]'); plt.title(r'$h_{\infty}$ Na Ch Deactivation vs $U$ Membrane Voltage')
plt.plot(sim.data[input_probe], sim.data[hinf_probe])



plt.figure(); plt.xlabel(r'Time [s]'); plt.ylabel(r'Na Ch Activation, $m_{\infty}$ [-] (NODE)'); plt.title(r'$m_{\infty}$ Na Ch Activation (NODE) vs Time')
plt.plot(sim.trange(), sim.data[minf_node_probe])

plt.figure(); plt.xlabel(r'Time [s]'); plt.ylabel(r'Na Ch Deactivation, $h_{\infty}$ [-] (NODE)'); plt.title(r'$h_{\infty}$ Na Ch Deactivation (NODE) vs Time')
plt.plot(sim.trange(), sim.data[hinf_node_probe])

plt.figure(); plt.xlabel(r'Membrane Voltage, $U$ [V]'); plt.ylabel(r'Na Ch Activation, $m_{\infty}$ [-] (NODE)'); plt.title(r'$m_{\infty}$ Na Ch Activation (NODE) vs $U$ Membrane Voltage')
plt.plot(sim.data[input_probe], sim.data[minf_node_probe])

plt.figure(); plt.xlabel(r'Membrane Voltage, $U$ [V]'); plt.ylabel(r'Na Ch Deactivation, $h_{\infty}$ [-] (NODE)'); plt.title(r'$h_{\infty}$ Na Ch Deactivation (NODE) vs $U$ Membrane Voltage')
plt.plot(sim.data[input_probe], sim.data[hinf_node_probe])




plt.figure(); plt.xlabel(r'Time [s]'); plt.ylabel(r'Na Ch Activation, $m_{\infty}$ [-] (DIRECT)'); plt.title(r'$m_{\infty}$ Na Ch Activation (DIRECT) vs Time')
plt.plot(sim.trange(), sim.data[minf_direct_probe])

plt.figure(); plt.xlabel(r'Time [s]'); plt.ylabel(r'Na Ch Deactivation, $h_{\infty}$ [-] (DIRECT)'); plt.title(r'$h_{\infty}$ Na Ch Deactivation (DIRECT) vs Time')
plt.plot(sim.trange(), sim.data[hinf_direct_probe])

plt.figure(); plt.xlabel(r'Membrane Voltage, $U$ [V]'); plt.ylabel(r'Na Ch Activation, $m_{\infty}$ [-] (DIRECT)'); plt.title(r'$m_{\infty}$ Na Ch Activation (DIRECT) vs $U$ Membrane Voltage')
plt.plot(sim.data[input_probe], sim.data[minf_direct_probe])

plt.figure(); plt.xlabel(r'Membrane Voltage, $U$ [V]'); plt.ylabel(r'Na Ch Deactivation, $h_{\infty}$ [-] (DIRECT)'); plt.title(r'$h_{\infty}$ Na Ch Deactivation (DIRECT) vs $U$ Membrane Voltage')
plt.plot(sim.data[input_probe], sim.data[hinf_direct_probe])



# Plot the tuning curves associated with the Na Ch Activation ensemble.
plt.figure(); plt.xlabel('Input [-]'); plt.ylabel(r'$m_{\infty}$ Firing Frequency [Hz]'); plt.title(r'$m_{\infty}$ Firing Frequency vs Input')
plt.plot(minf_evals, minf_activites)

# Plot the tuning curves associated with the Na Ch Deactivation ensemble.
plt.figure(); plt.xlabel('Input [-]'); plt.ylabel(r'$h_{\infty}$ Firing Frequency [Hz]'); plt.title(r'$h_{\infty}$ Firing Frequency vs Input')
plt.plot(hinf_evals, hinf_activites)

# # Show the network.
# gvz_source.view()

# Display the figures.
plt.show()


